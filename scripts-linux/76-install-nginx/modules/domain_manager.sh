#!/usr/bin/env bash
# scripts-linux/76-install-nginx/modules/domain_manager.sh
# Core domain manager controller for add, rm, list, and ini subcommands
set -u

_validate_domain() {
    local d="$1"
    if [[ "$d" =~ ^[a-zA-Z0-9][-a-zA-Z0-9.]*\.[a-zA-Z0-9]+$ ]]; then
        return 0
    fi
    # Also permit single-label or .local / .test domains for local development
    if [[ "$d" =~ ^[a-zA-Z0-9][-a-zA-Z0-9.]*\.(local|test|internal|lan)$ ]]; then
        return 0
    fi
    return 1
}

_detect_subdomain_of() {
    local d="$1"
    local dot_count; dot_count="$(echo "$d" | tr -cd '.' | wc -c)"
    if [ "$dot_count" -ge 2 ]; then
        # e.g. sub.domain.com -> domain.com
        echo "$d" | awk -F'.' '{print $(NF-1) "." $NF}'
    else
        echo ""
    fi
}

cmd_add() {
    local domain=""
    local type="static"
    local port="80"
    local root_path=""
    local php_ver=""
    local php_sock=""
    local proxy_pass=""
    local ssl_enabled=0
    local force=0

    while [ $# -gt 0 ]; do
        case "$1" in
            --type)       type="$2"; shift 2 ;;
            --port)       port="$2"; shift 2 ;;
            --root)       root_path="$2"; shift 2 ;;
            --php)
                type="php"
                if [ $# -ge 2 ] && [[ ! "$2" =~ ^-- ]]; then
                    php_ver="$2"; shift 2
                else
                    php_ver=""; shift 1
                fi
                ;;
            --proxy)      type="proxy"; proxy_pass="$2"; shift 2 ;;
            --ssl)        ssl_enabled=1; shift 1 ;;
            --force)      force=1; shift 1 ;;
            -*)           log_warn "[76] Unknown flag: $1"; shift 1 ;;
            *)
                if [ -z "$domain" ]; then domain="$1"; else log_warn "[76] Extra argument: $1"; fi
                shift 1
                ;;
        esac
    done

    if [ -z "$domain" ]; then
        log_err "[76] Domain name required. Usage: ./run.sh nginx add <domain> [options]"
        return 1
    fi

    if ! _validate_domain "$domain"; then
        log_err "[76] Invalid domain name syntax: $domain"
        return 1
    fi

    local subdomain_of; subdomain_of="$(_detect_subdomain_of "$domain")"

    # Default root path
    if [ -z "$root_path" ]; then
        case "$type" in
            laravel) root_path="/var/www/$domain/public" ;;
            *)       root_path="/var/www/$domain/html" ;;
        esac
    fi

    # Detect PHP socket if PHP type
    if [ "$type" = "php" ] || [ "$type" = "wordpress" ] || [ "$type" = "laravel" ]; then
        php_sock="$(vhost_detect_php_socket "$php_ver")"
    fi

    log_info "[76] Adding virtual host '$domain' (Type: $type, Port: $port, Root: $root_path)..."

    # 1. Create document root and sample placeholder if directory does not exist
    if [ "$type" != "proxy" ] && [ ! -d "$root_path" ]; then
        mkdir -p "$root_path" 2>/dev/null || sudo mkdir -p "$root_path" 2>/dev/null || true
        local sample_index="$root_path/index.html"
        if [ "$type" = "php" ] || [ "$type" = "wordpress" ] || [ "$type" = "laravel" ]; then
            sample_index="$root_path/index.php"
            local php_stub="<?php\n// $domain - Managed by scripts-fixer\necho '<h1>Welcome to $domain</h1><p>Nginx + PHP is running successfully.</p>';\nphpinfo();\n"
            if [ "$(id -u)" -eq 0 ]; then printf '%b' "$php_stub" > "$sample_index"; else printf '%b' "$php_stub" | sudo tee "$sample_index" >/dev/null 2>&1 || true; fi
        else
            local html_stub="<!DOCTYPE html>\n<html><head><title>$domain</title></head><body><h1>Welcome to $domain</h1><p>Nginx static virtual host is running successfully.</p></body></html>\n"
            if [ "$(id -u)" -eq 0 ]; then printf '%b' "$html_stub" > "$sample_index"; else printf '%b' "$html_stub" | sudo tee "$sample_index" >/dev/null 2>&1 || true; fi
        fi
    fi

    # 2. Render Virtual Host File
    local avail_file="$VHOST_AVAILABLE_DIR/${domain}.conf"
    local enab_file="$VHOST_ENABLED_DIR/${domain}.conf"
    vhost_render "$type" "$domain" "$port" "$root_path" "$php_sock" "$proxy_pass" "$avail_file"

    # 3. Test and Link Virtual Host
    if ! vhost_test_and_link "$domain"; then
        log_err "[76] Failed to activate virtual host configuration for $domain. Changes rolled back."
        rm -f "$avail_file" 2>/dev/null || sudo rm -f "$avail_file" 2>/dev/null || true
        return 1
    fi

    # 4. Generate Per-Site INI
    local ini_file
    ini_file="$(ini_write_site "$domain" "$subdomain_of" "$type" "$port" "$root_path" "$php_ver" "$php_sock" "$proxy_pass" "$ssl_enabled" "$avail_file" "$enab_file")"

    # 5. Commit to SQLite Database
    db_record_add "$domain" "$subdomain_of" "$type" "$port" "$root_path" "$php_ver" "$php_sock" "$proxy_pass" "$ssl_enabled" "$avail_file" "$ini_file"
    db_audit_log "$domain" "CREATE" "Added $type site on port $port"

    # 6. Update Master INI Inventory
    ini_update_master

    # 7. Reload Nginx Service
    if command -v systemctl >/dev/null 2>&1 && sudo systemctl is-active --quiet nginx 2>/dev/null; then
        sudo systemctl reload nginx 2>/dev/null || true
    elif command -v nginx >/dev/null 2>&1; then
        sudo nginx -s reload 2>/dev/null || true
    fi

    log_ok "[76] Domain '$domain' successfully created and activated!"
    log_info "  Virtual Host: $avail_file"
    log_info "  Active Link:  $enab_file"
    log_info "  INI Config:   $ini_file"
    log_info "  SQLite DB:    $DB_PATH"
}

cmd_rm() {
    local domain=""
    local purge_data=0
    local auto_yes=0

    while [ $# -gt 0 ]; do
        case "$1" in
            --purge)    purge_data=1; shift 1 ;;
            -y|--yes)   auto_yes=1; shift 1 ;;
            -*)         log_warn "[76] Unknown flag: $1"; shift 1 ;;
            *)
                if [ -z "$domain" ]; then domain="$1"; else log_warn "[76] Extra argument: $1"; fi
                shift 1
                ;;
        esac
    done

    if [ -z "$domain" ]; then
        log_err "[76] Domain name required. Usage: ./run.sh nginx rm <domain> [--purge] [-y]"
        return 1
    fi

    log_info "[76] Removing virtual host and domain '$domain'..."

    # Retrieve existing record
    local existing_row; existing_row="$(db_record_get "$domain")"
    local root_dir=""
    if [ -n "$existing_row" ]; then
        root_dir="$(echo "$existing_row" | awk -F'|' '{print $6}')"
    fi

    # 1. Unlink and Archive Vhost
    vhost_unlink_and_archive "$domain"

    # 2. Archive INI File
    ini_remove_site "$domain"

    # 3. Delete SQLite Record and write audit log
    db_record_delete "$domain"
    db_audit_log "$domain" "DELETE" "Removed site vhost and INI"

    # 4. Update Master INI Inventory
    ini_update_master

    # 5. Verify Syntax & Reload Nginx
    if command -v nginx >/dev/null 2>&1; then
        if sudo nginx -t >/dev/null 2>&1; then
            if command -v systemctl >/dev/null 2>&1 && sudo systemctl is-active --quiet nginx 2>/dev/null; then
                sudo systemctl reload nginx 2>/dev/null || true
            else
                sudo nginx -s reload 2>/dev/null || true
            fi
        else
            log_warn "[76] Nginx syntax warning detected after unlinking $domain"
        fi
    fi

    # 6. Handle optional document root purge
    if [ "$purge_data" = "1" ] && [ -n "$root_dir" ] && [ -d "$root_dir" ]; then
        local confirm="no"
        if [ "$auto_yes" = "1" ]; then
            confirm="yes"
        else
            printf "Permanently remove document root directory '%s'? [y/N]: " "$root_dir"
            read -r reply
            case "$reply" in y|Y|yes|YES) confirm="yes" ;; esac
        fi

        if [ "$confirm" = "yes" ]; then
            if [ "$(id -u)" -eq 0 ]; then rm -rf "$root_dir"; else sudo rm -rf "$root_dir" 2>/dev/null || true; fi
            log_ok "[76] Purged document root: $root_dir"
        else
            log_info "[76] Document root preserved: $root_dir"
        fi
    fi

    log_ok "[76] Domain '$domain' successfully removed from Nginx, INI, and SQLite!"
}

cmd_list() {
    local as_json=0
    for arg in "$@"; do
        [ "$arg" = "--json" ] && as_json=1
    done

    local rows; rows="$(db_record_list)"

    if [ "$as_json" = "1" ]; then
        if command -v jq >/dev/null 2>&1; then
            echo "$rows" | jq -R -s -c 'split("\n") | map(select(length > 0)) | map(split("|")) | map({domain: .[0], type: .[1], port: .[2], root: .[3], php: .[4], proxy: .[5], ssl: .[6], status: .[7]})'
        else
            echo "$rows" | python3 -c '
import sys, json
lines = [l.strip().split("|") for l in sys.stdin if l.strip()]
data = [{"domain": r[0], "type": r[1], "port": r[2], "root": r[3], "php": r[4], "proxy": r[5], "ssl": r[6], "status": r[7]} for r in lines if len(r) >= 8]
print(json.dumps(data, indent=2))
'
        fi
        return 0
    fi

    printf '\n  ===============================================================================\n'
    printf '                          MANAGED NGX DOMAINS (SQLITE LEDGER)\n'
    printf '  ===============================================================================\n'
    printf '  %-24s %-10s %-6s %-32s %-8s\n' "DOMAIN" "TYPE" "PORT" "TARGET / ROOT" "STATUS"
    printf '  %-24s %-10s %-6s %-32s %-8s\n' "------------------------" "----------" "------" "--------------------------------" "--------"

    local count=0
    while IFS='|' read -r dom typ prt rot php prx ssl sta; do
        [ -z "$dom" ] && continue
        count=$((count + 1))
        local target="$rot"
        [ "$typ" = "proxy" ] && target="$prx"
        [ ${#target} -gt 30 ] && target="${target:0:27}..."
        printf '  %-24s %-10s %-6s %-32s %-8s\n' "$dom" "$typ" "$prt" "$target" "$sta"
    done <<< "$rows"

    if [ "$count" -eq 0 ]; then
        printf '  (No virtual host domains registered yet. Add one via: ./run.sh nginx add <domain>)\n'
    fi
    printf '  ===============================================================================\n'
    printf '  Total Managed Domains: %s | SQLite DB: %s\n\n' "$count" "$DB_PATH"
}

cmd_ini() {
    local target_domain=""
    local sync_mode=0

    while [ $# -gt 0 ]; do
        case "$1" in
            --sync)   sync_mode=1; shift 1 ;;
            -*)       shift 1 ;;
            *)        target_domain="$1"; shift 1 ;;
        esac
    done

    if [ "$sync_mode" = "1" ]; then
        log_info "[76] Synchronizing INI files with SQLite database..."
        ini_update_master
        log_ok "[76] Master INI inventory re-synchronized with SQLite."
        return 0
    fi

    if [ -n "$target_domain" ]; then
        local site_ini="$INI_SITES_DIR/${target_domain}.ini"
        if [ -f "$site_ini" ]; then
            cat "$site_ini"
        else
            log_err "[76] INI file for domain '$target_domain' not found at $site_ini"
            return 1
        fi
    else
        if [ -f "$INI_MASTER_FILE" ]; then
            cat "$INI_MASTER_FILE"
        else
            log_info "[76] Generating initial master INI file..."
            ini_update_master
            cat "$INI_MASTER_FILE"
        fi
    fi
}
