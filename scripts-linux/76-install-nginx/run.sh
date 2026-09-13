#!/usr/bin/env bash
# scripts-linux/76-install-nginx/run.sh
# Standalone Nginx web server suite (HTTP/HTTPS, modular snippets, multi-site manager)
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export SCRIPT_ID="76"
. "$ROOT/_shared/logger.sh"
. "$ROOT/_shared/pkg-detect.sh"
. "$ROOT/_shared/file-error.sh"
. "$ROOT/_shared/install-paths.sh"
. "$SCRIPT_DIR/modules/db_engine.sh"
. "$SCRIPT_DIR/modules/ini_engine.sh"
. "$SCRIPT_DIR/modules/vhost_engine.sh"
. "$SCRIPT_DIR/modules/domain_manager.sh"
. "$SCRIPT_DIR/modules/showcase.sh"

CONFIG="$SCRIPT_DIR/config.json"
INSTALLED_MARK="$ROOT/.installed/76.ok"

# Defaults (overridden by config.json if present)
DEFAULT_PORT="80"
CLIENT_MAX_BODY_SIZE="64M"
WORKER_PROCESSES="auto"
GZIP_SETTING="on"
SERVER_TOKENS="off"
SNIPPETS_DIR="/etc/nginx/snippets"
SITES_AVAILABLE_DIR="/etc/nginx/sites-available"
SITES_ENABLED_DIR="/etc/nginx/sites-enabled"
NGINX_CONF="/etc/nginx/nginx.conf"

_read_cfg() {
    local key="$1" def="$2"
    if [ -f "$CONFIG" ]; then
        if command -v jq >/dev/null 2>&1; then
            local val; val="$(jq -r --arg k "$key" '.[$k] // empty' "$CONFIG" 2>/dev/null)"
            if [ -n "$val" ]; then echo "$val"; return; fi
        else
            local val; val="$(grep -oE "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]+\"" "$CONFIG" 2>/dev/null | sed -E 's/.*"([^"]+)"$/\1/')"
            if [ -n "$val" ]; then echo "$val"; return; fi
        fi
    fi
    echo "$def"
}

DEFAULT_PORT="$(_read_cfg "defaultPort" "80")"
CLIENT_MAX_BODY_SIZE="$(_read_cfg "clientMaxBodySize" "64M")"
WORKER_PROCESSES="$(_read_cfg "workerProcesses" "auto")"
GZIP_SETTING="$(_read_cfg "gzip" "on")"
SERVER_TOKENS="$(_read_cfg "serverTokens" "off")"
SNIPPETS_DIR="$(_read_cfg "snippetsDir" "/etc/nginx/snippets")"
SITES_AVAILABLE_DIR="$(_read_cfg "sitesAvailableDir" "/etc/nginx/sites-available")"
SITES_ENABLED_DIR="$(_read_cfg "sitesEnabledDir" "/etc/nginx/sites-enabled")"
NGINX_CONF="$(_read_cfg "configPath" "/etc/nginx/nginx.conf")"

show_help() {
    cat <<'EOF'
Nginx standalone web server suite & domain manager (script 76)

Usage:
  ./run.sh <verb> [options]

Core Verbs:
  install             Install Nginx, deploy modular snippets, initialize SQLite & INI, start service
  check               Verify binary, service state, syntax check, and snippets presence
  repair              Re-deploy snippets, re-tune nginx.conf, run nginx -t, and restart
  uninstall [--purge] Stop and disable service, remove snippets (optional --purge removes packages)
  status              Display Nginx version, service status, listening ports, and managed domains
  test                Run 'nginx -t' configuration test with full output
  reload              Validate syntax with 'nginx -t' and gracefully reload Nginx service
  help, -h, --help    Show this help text

Domain Management Verbs (SQLite & INI synchronized):
  add <domain>        Add and configure virtual host (static, php, wordpress, laravel, proxy)
  rm <domain>         Deactivate and remove virtual host, archive INI, update SQLite (--purge)
  list                List all registered domains from SQLite with type, port, root, status
  ini [domain]        Display master sites.ini or specific per-site INI (--sync)
  showcase            Run live demonstration of SQLite + INI + Vhost Tri-State sync
  sites               List available and enabled virtual hosts in filesystem
  enable-site <name>  Enable virtual host symlink in sites-enabled/ and reload Nginx
  disable-site <name> Disable virtual host symlink in sites-enabled/ and reload Nginx

Domain Options:
  --type <type>       static | php | wordpress | laravel | proxy (default: static)
  --port <n>          Listening HTTP port (default: 80)
  --root <path>       Document root path (default: /var/www/<domain>/html or /public)
  --php [version]     Enable PHP FastCGI (e.g. 8.1, 8.2, 8.3, or auto-detected socket)
  --proxy <url>       Reverse proxy target (e.g. http://127.0.0.1:3000)
  --ssl               Enable SSL/TLS server block
  --purge             Remove document root upon domain removal
EOF
}

verify_binary() {
    if command -v nginx >/dev/null 2>&1; then
        return 0
    fi
    report_file_missing "nginx" "nginx binary not found on PATH"
    return 1
}

verify_service() {
    if command -v systemctl >/dev/null 2>&1; then
        if sudo systemctl is-active --quiet nginx; then
            return 0
        fi
        log_warn "[76] nginx systemd service is inactive"
        return 1
    fi
    log_info "[76] systemctl not available; skipping service active check"
    return 0
}

verify_syntax() {
    if ! verify_binary; then
        return 1
    fi
    local log_file="/tmp/nginx-t-$$.log"
    if sudo nginx -t >"$log_file" 2>&1; then
        rm -f "$log_file" 2>/dev/null || true
        return 0
    fi
    log_err "[76] 'nginx -t' configuration test failed:"
    if [ -f "$log_file" ]; then
        sudo cat "$log_file" >&2
        rm -f "$log_file" 2>/dev/null || true
    fi
    return 1
}

verify_snippets() {
    local missing_count=0
    local snippet_names=(
        "scripts-fixer-security.conf"
        "scripts-fixer-fastcgi.conf"
        "scripts-fixer-static.conf"
        "scripts-fixer-ssl.conf"
    )
    for sn in "${snippet_names[@]}"; do
        local p="$SNIPPETS_DIR/$sn"
        if [ ! -f "$p" ]; then
            log_warn "[76] modular snippet missing: $p"
            missing_count=$((missing_count + 1))
        fi
    done
    if [ "$missing_count" -gt 0 ]; then
        return 1
    fi
    return 0
}

install_snippets() {
    log_info "[76] installing modular snippets into $SNIPPETS_DIR..."
    if ! sudo mkdir -p "$SNIPPETS_DIR" 2>/dev/null; then
        report_dir_create_failed "$SNIPPETS_DIR" "sudo mkdir -p failed"
        return 1
    fi

    local pairs=(
        "security-headers.conf|||scripts-fixer-security.conf"
        "fastcgi-php.conf|||scripts-fixer-fastcgi.conf"
        "static-assets.conf|||scripts-fixer-static.conf"
        "ssl-params.conf|||scripts-fixer-ssl.conf"
    )

    for pair in "${pairs[@]}"; do
        local src_name="${pair%%|||*}"
        local dst_name="${pair##*|||}"
        local src_file="$SCRIPT_DIR/snippets/$src_name"
        local dst_file="$SNIPPETS_DIR/$dst_name"
        local alias_file="$SNIPPETS_DIR/$src_name"

        if [ ! -f "$src_file" ]; then
            log_file_error "$src_file" "source snippet template missing"
            return 1
        fi

        if ! sudo cp -f "$src_file" "$dst_file" 2>/dev/null; then
            log_file_error "$dst_file" "failed to copy snippet"
            return 1
        fi
        sudo chmod 644 "$dst_file" 2>/dev/null || true

        # Also maintain matching alias filename if distinct
        if [ "$dst_file" != "$alias_file" ] && [ ! -f "$alias_file" ]; then
            sudo cp -f "$src_file" "$alias_file" 2>/dev/null || true
            sudo chmod 644 "$alias_file" 2>/dev/null || true
        fi

        log_ok "[76] deployed snippet: $dst_file"
    done

    return 0
}

tune_nginx_conf() {
    if [ ! -f "$NGINX_CONF" ]; then
        log_file_error "$NGINX_CONF" "nginx.conf not found -- cannot tune configuration"
        return 1
    fi

    local ts; ts="$(date +%Y%m%d-%H%M%S)"
    local bak="$NGINX_CONF.bak.$ts"
    if ! sudo cp -p "$NGINX_CONF" "$bak" 2>/dev/null; then
        log_file_error "$bak" "failed to create backup of nginx.conf"
        return 1
    fi
    log_ok "[76] backup created: $bak"

    log_info "[76] applying core tuning to $NGINX_CONF..."

    # 1. worker_processes auto
    sudo sed -i "s/^[[:space:]]*worker_processes[[:space:]]\+[^;]*;/worker_processes $WORKER_PROCESSES;/" "$NGINX_CONF" 2>/dev/null || true

    # 2. server_tokens off
    if grep -Eq '^[[:space:]]*#[[:space:]]*server_tokens' "$NGINX_CONF" 2>/dev/null; then
        sudo sed -i "s/^[[:space:]]*#[[:space:]]*server_tokens[[:space:]]\+[^;]*;/    server_tokens $SERVER_TOKENS;/" "$NGINX_CONF" 2>/dev/null || true
    elif grep -Eq '^[[:space:]]*server_tokens' "$NGINX_CONF" 2>/dev/null; then
        sudo sed -i "s/^[[:space:]]*server_tokens[[:space:]]\+[^;]*;/    server_tokens $SERVER_TOKENS;/" "$NGINX_CONF" 2>/dev/null || true
    else
        sudo sed -i "/http[[:space:]]*{/a \    server_tokens $SERVER_TOKENS;" "$NGINX_CONF" 2>/dev/null || true
    fi

    # 3. client_max_body_size
    if grep -Eq '^[[:space:]]*client_max_body_size' "$NGINX_CONF" 2>/dev/null; then
        sudo sed -i "s/^[[:space:]]*client_max_body_size[[:space:]]\+[^;]*;/    client_max_body_size $CLIENT_MAX_BODY_SIZE;/" "$NGINX_CONF" 2>/dev/null || true
    else
        sudo sed -i "/http[[:space:]]*{/a \    client_max_body_size $CLIENT_MAX_BODY_SIZE;" "$NGINX_CONF" 2>/dev/null || true
    fi

    # 4. gzip compression
    if grep -Eq '^[[:space:]]*#[[:space:]]*gzip on;' "$NGINX_CONF" 2>/dev/null; then
        sudo sed -i "s/^[[:space:]]*#[[:space:]]*gzip on;/    gzip $GZIP_SETTING;/" "$NGINX_CONF" 2>/dev/null || true
    elif grep -Eq '^[[:space:]]*gzip[[:space:]]\+' "$NGINX_CONF" 2>/dev/null; then
        sudo sed -i "s/^[[:space:]]*gzip[[:space:]]\+[^;]*;/    gzip $GZIP_SETTING;/" "$NGINX_CONF" 2>/dev/null || true
    else
        sudo sed -i "/http[[:space:]]*{/a \    gzip $GZIP_SETTING;" "$NGINX_CONF" 2>/dev/null || true
    fi

    # Verify tuning
    if ! verify_syntax; then
        log_warn "[76] configuration check failed after tuning; rolling back to $bak"
        sudo cp -p "$bak" "$NGINX_CONF" 2>/dev/null || true
        return 1
    fi

    log_ok "[76] core engine tuning verified (worker_processes=$WORKER_PROCESSES, server_tokens=$SERVER_TOKENS, client_max_body_size=$CLIENT_MAX_BODY_SIZE, gzip=$GZIP_SETTING)"
    return 0
}

open_firewall() {
    local port="${1:-80}"
    if command -v ufw >/dev/null 2>&1; then
        if sudo ufw status 2>/dev/null | grep -qw "active"; then
            sudo ufw allow "$port/tcp" >/dev/null 2>&1 || true
            log_ok "[76] firewall: ufw allow $port/tcp"
        fi
    elif command -v firewall-cmd >/dev/null 2>&1; then
        if sudo firewall-cmd --state >/dev/null 2>&1; then
            sudo firewall-cmd --permanent --add-port="$port/tcp" >/dev/null 2>&1 || true
            sudo firewall-cmd --reload >/dev/null 2>&1 || true
            log_ok "[76] firewall: firewalld add-port $port/tcp"
        fi
    fi
}

verb_install() {
    local target_port="$DEFAULT_PORT"
    while [ $# -gt 0 ]; do
        case "$1" in
            --port)
                target_port="${2:-$DEFAULT_PORT}"
                shift 2
                ;;
            --port=*)
                target_port="${1#--port=}"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    write_install_paths \
        --tool   "Nginx standalone web server" \
        --source "Package repository (apt/brew)" \
        --temp   "${TMPDIR:-/tmp}/nginx-install" \
        --target "/usr/sbin/nginx, /etc/nginx"

    log_info "[76] Starting Nginx installation..."

    if ! verify_binary; then
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update -y >/dev/null 2>&1 || true
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx; then
                log_err "[76] apt-get install nginx failed"
                return 1
            fi
        elif command -v brew >/dev/null 2>&1; then
            if ! brew install nginx; then
                log_err "[76] brew install nginx failed"
                return 1
            fi
        else
            log_err "[76] No supported package manager found (apt-get or brew required)"
            return 1
        fi
    else
        log_ok "[76] Nginx binary already installed"
    fi

    # Ensure required directories exist
    sudo mkdir -p "$SNIPPETS_DIR" "$SITES_AVAILABLE_DIR" "$SITES_ENABLED_DIR" 2>/dev/null || true

    # Install modular snippets
    if ! install_snippets; then
        log_err "[76] failed to deploy modular snippets"
        return 1
    fi

    # Tune core nginx.conf
    if ! tune_nginx_conf; then
        log_err "[76] failed to tune nginx.conf"
        return 1
    fi

    # Open firewall
    open_firewall "$target_port"

    # Enable and restart service
    if command -v systemctl >/dev/null 2>&1; then
        sudo systemctl enable nginx >/dev/null 2>&1 || true
        if ! sudo systemctl restart nginx; then
            log_err "[76] systemctl restart nginx failed"
            return 1
        fi
    fi

    # Initialize SQLite database and master INI inventory
    db_init
    ini_update_master

    # Verify overall health
    if ! verb_check; then
        log_err "[76] post-install verification failed"
        return 1
    fi

    mkdir -p "$ROOT/.installed" 2>/dev/null || true
    touch "$INSTALLED_MARK"
    log_ok "[76] Nginx standalone suite installed and verified successfully"
    return 0
}

verb_check() {
    log_info "[76] Checking Nginx installation status..."
    local check_status=0

    if ! verify_binary; then
        check_status=1
    fi

    if ! verify_syntax; then
        check_status=1
    fi

    if ! verify_snippets; then
        check_status=1
    fi

    if ! verify_service; then
        check_status=1
    fi

    if [ "$check_status" -eq 0 ]; then
        log_ok "[76] Nginx verified: binary OK, service active, syntax valid, snippets present"
        return 0
    fi

    log_warn "[76] Nginx check reported issues (check_status=$check_status)"
    return 1
}

verb_repair() {
    log_info "[76] Repairing Nginx standalone suite..."
    rm -f "$INSTALLED_MARK" 2>/dev/null || true

    if ! install_snippets; then
        log_err "[76] repair: snippet deployment failed"
        return 1
    fi

    if ! tune_nginx_conf; then
        log_err "[76] repair: configuration tuning failed"
        return 1
    fi

    if command -v systemctl >/dev/null 2>&1; then
        sudo systemctl restart nginx 2>/dev/null || true
    fi

    if verb_check; then
        mkdir -p "$ROOT/.installed" 2>/dev/null || true
        touch "$INSTALLED_MARK"
        log_ok "[76] Nginx standalone suite repaired successfully"
        return 0
    fi

    log_err "[76] repair verification failed"
    return 1
}

verb_uninstall() {
    local purge_requested=0
    while [ $# -gt 0 ]; do
        case "$1" in
            --purge) purge_requested=1; shift ;;
            *) shift ;;
        esac
    done

    log_info "[76] Uninstalling Nginx standalone suite (purge=$purge_requested)..."

    if command -v systemctl >/dev/null 2>&1; then
        sudo systemctl stop nginx 2>/dev/null || true
        sudo systemctl disable nginx 2>/dev/null || true
    fi

    # Remove deployed snippets
    sudo rm -f "$SNIPPETS_DIR"/scripts-fixer-*.conf 2>/dev/null || true
    rm -f "$INSTALLED_MARK" 2>/dev/null || true

    if [ "$purge_requested" -eq 1 ]; then
        log_info "[76] purging Nginx packages..."
        if command -v apt-get >/dev/null 2>&1; then
            sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y nginx nginx-common nginx-core 2>/dev/null || true
            sudo apt-get autoremove -y >/dev/null 2>&1 || true
        elif command -v brew >/dev/null 2>&1; then
            brew uninstall --force nginx 2>/dev/null || true
        fi
    fi

    log_ok "[76] Nginx standalone suite uninstalled"
    return 0
}

verb_status() {
    printf '\n===== Nginx Status =====\n'
    if command -v nginx >/dev/null 2>&1; then
        nginx -v 2>&1
    else
        echo "nginx: not installed"
    fi

    if command -v systemctl >/dev/null 2>&1; then
        printf '\nSystemd Service:\n'
        sudo systemctl status nginx --no-pager 2>/dev/null || true
    fi

    printf '\nListening Sockets (nginx):\n'
    if command -v ss >/dev/null 2>&1; then
        ss -tulpn 2>/dev/null | grep -E 'nginx|:80|:443' || echo "  (no active listeners found)"
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tulpn 2>/dev/null | grep -E 'nginx|:80|:443' || echo "  (no active listeners found)"
    fi

    printf '\nVirtual Hosts:\n'
    verb_sites
    printf '\n'
}

verb_test() {
    log_info "[76] Running 'nginx -t' configuration test..."
    if ! verify_binary; then
        return 1
    fi
    if sudo nginx -t; then
        log_ok "[76] Configuration test: SUCCESS"
        return 0
    fi
    log_err "[76] Configuration test: FAILED"
    return 1
}

verb_reload() {
    log_info "[76] Validating configuration before reload..."
    if ! verify_syntax; then
        log_err "[76] Configuration syntax invalid -- aborting reload"
        return 1
    fi

    if command -v systemctl >/dev/null 2>&1; then
        if sudo systemctl reload nginx; then
            log_ok "[76] Nginx service successfully reloaded"
            return 0
        fi
        log_err "[76] systemctl reload nginx failed"
        return 1
    elif command -v nginx >/dev/null 2>&1; then
        if sudo nginx -s reload; then
            log_ok "[76] Nginx successfully reloaded (nginx -s reload)"
            return 0
        fi
        log_err "[76] nginx -s reload failed"
        return 1
    fi

    log_err "[76] No service manager available to reload Nginx"
    return 1
}

verb_sites() {
    if [ ! -d "$SITES_AVAILABLE_DIR" ]; then
        log_info "[76] sites-available directory ($SITES_AVAILABLE_DIR) does not exist"
        return 0
    fi

    local count=0
    for vhost in "$SITES_AVAILABLE_DIR"/*; do
        [ -f "$vhost" ] || continue
        count=$((count + 1))
        local base; base="$(basename "$vhost")"
        if [ -L "$SITES_ENABLED_DIR/$base" ] || [ -f "$SITES_ENABLED_DIR/$base" ]; then
            printf '  \033[32m[enabled]\033[0m  %s -> %s\n' "$base" "$vhost"
        else
            printf '  \033[33m[disabled]\033[0m %s\n' "$base"
        fi
    done

    if [ "$count" -eq 0 ]; then
        echo "  (no virtual hosts found in $SITES_AVAILABLE_DIR)"
    fi
    return 0
}

verb_enable_site() {
    local site_name="${1:-}"
    if [ -z "$site_name" ]; then
        log_err "[76] enable-site requires a site name (e.g. ./run.sh enable-site mysite)"
        return 2
    fi

    local target_file=""
    if [ -f "$SITES_AVAILABLE_DIR/$site_name" ]; then
        target_file="$SITES_AVAILABLE_DIR/$site_name"
    elif [ -f "$SITES_AVAILABLE_DIR/${site_name}.conf" ]; then
        target_file="$SITES_AVAILABLE_DIR/${site_name}.conf"
    elif [ -f "$site_name" ]; then
        target_file="$site_name"
    else
        log_file_error "$SITES_AVAILABLE_DIR/$site_name" "vhost file not found in sites-available"
        return 1
    fi

    local base; base="$(basename "$target_file")"
    local enabled_link="$SITES_ENABLED_DIR/$base"

    sudo mkdir -p "$SITES_ENABLED_DIR" 2>/dev/null || true
    if ! sudo ln -sf "$target_file" "$enabled_link"; then
        log_file_error "$enabled_link" "failed to create enabled symlink"
        return 1
    fi

    log_info "[76] testing configuration with '$base' enabled..."
    if ! verify_syntax; then
        log_err "[76] 'nginx -t' failed with site '$base' enabled -- rolling back symlink"
        sudo rm -f "$enabled_link" 2>/dev/null || true
        return 1
    fi

    verb_reload
    log_ok "[76] Site '$base' enabled successfully"
    return 0
}

verb_disable_site() {
    local site_name="${1:-}"
    if [ -z "$site_name" ]; then
        log_err "[76] disable-site requires a site name (e.g. ./run.sh disable-site mysite)"
        return 2
    fi

    local enabled_link=""
    if [ -L "$SITES_ENABLED_DIR/$site_name" ] || [ -f "$SITES_ENABLED_DIR/$site_name" ]; then
        enabled_link="$SITES_ENABLED_DIR/$site_name"
    elif [ -L "$SITES_ENABLED_DIR/${site_name}.conf" ] || [ -f "$SITES_ENABLED_DIR/${site_name}.conf" ]; then
        enabled_link="$SITES_ENABLED_DIR/${site_name}.conf"
    else
        log_info "[76] site '$site_name' is not currently enabled"
        return 0
    fi

    local base; base="$(basename "$enabled_link")"
    if ! sudo rm -f "$enabled_link"; then
        log_file_error "$enabled_link" "failed to remove enabled symlink"
        return 1
    fi

    log_info "[76] testing configuration with '$base' disabled..."
    if ! verify_syntax; then
        log_warn "[76] 'nginx -t' reported warnings after disabling '$base'"
    fi

    verb_reload
    log_ok "[76] Site '$base' disabled successfully"
    return 0
}

# Main command dispatcher
CMD="${1:-install}"
if [ $# -gt 0 ]; then shift; fi

case "$CMD" in
    install)
        verb_install "$@"
        ;;
    check)
        verb_check "$@"
        ;;
    repair)
        verb_repair "$@"
        ;;
    uninstall)
        verb_uninstall "$@"
        ;;
    status)
        verb_status "$@"
        ;;
    test)
        verb_test "$@"
        ;;
    reload)
        verb_reload "$@"
        ;;
    sites)
        verb_sites "$@"
        ;;
    enable-site)
        verb_enable_site "$@"
        ;;
    disable-site)
        verb_disable_site "$@"
        ;;
    add)
        cmd_add "$@"
        ;;
    rm|remove|delete|del)
        cmd_rm "$@"
        ;;
    list|ls)
        cmd_list "$@"
        ;;
    ini|config)
        cmd_ini "$@"
        ;;
    showcase|demo)
        cmd_showcase "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_err "[76] Unknown verb: $CMD (run ./run.sh --help for available verbs)"
        exit 2
        ;;
esac
