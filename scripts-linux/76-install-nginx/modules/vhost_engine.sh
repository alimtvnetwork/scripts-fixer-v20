#!/usr/bin/env bash
# scripts-linux/76-install-nginx/modules/vhost_engine.sh
# Nginx virtual host templating, syntax validation, and symlink management
set -u

_resolve_vhost_dirs() {
    if [ "$(id -u)" -eq 0 ] && [ -d "/etc/nginx" ]; then
        VHOST_AVAILABLE_DIR="/etc/nginx/sites-available"
        VHOST_ENABLED_DIR="/etc/nginx/sites-enabled"
    else
        local fallback_dir="${ROOT:-.}/.resolved/nginx"
        mkdir -p "$fallback_dir/sites-available" "$fallback_dir/sites-enabled" 2>/dev/null || true
        VHOST_AVAILABLE_DIR="$fallback_dir/sites-available"
        VHOST_ENABLED_DIR="$fallback_dir/sites-enabled"
    fi
}

_resolve_vhost_dirs

vhost_detect_php_socket() {
    local requested_ver="${1:-}"
    if [ -n "$requested_ver" ]; then
        local target="/run/php/php${requested_ver}-fpm.sock"
        if [ -S "$target" ]; then echo "unix:$target"; return; fi
        target="/var/run/php/php${requested_ver}-fpm.sock"
        if [ -S "$target" ]; then echo "unix:$target"; return; fi
        echo "unix:/run/php/php${requested_ver}-fpm.sock"
        return
    fi

    # Auto-detect running PHP-FPM sockets
    local socks; socks="$(find /run/php /var/run/php -type s -name 'php*-fpm.sock' 2>/dev/null | sort -V | tail -n 1)"
    if [ -n "$socks" ]; then
        echo "unix:$socks"
        return
    fi
    echo "unix:/run/php/php-fpm.sock"
}

vhost_render() {
    local type="$1"
    local domain="$2"
    local port="$3"
    local root_path="$4"
    local php_sock="$5"
    local proxy_pass="$6"
    local out_file="$7"

    local template_file="${SCRIPT_DIR}/templates/static-vhost.conf.template"
    case "$type" in
        php|wordpress|laravel)
            template_file="${SCRIPT_DIR}/templates/php-vhost.conf.template" ;;
        proxy)
            template_file="${SCRIPT_DIR}/templates/proxy-vhost.conf.template" ;;
        static|*)
            template_file="${SCRIPT_DIR}/templates/static-vhost.conf.template" ;;
    esac

    if [ ! -f "$template_file" ]; then
        log_file_error "$template_file" "Virtual host template not found"
        return 1
    fi

    local content; content="$(cat "$template_file")"
    content="${content//\{\{DOMAIN\}\}/$domain}"
    content="${content//\{\{PORT\}\}/$port}"
    content="${content//\{\{ROOT\}\}/$root_path}"
    content="${content//\{\{PHP_SOCKET\}\}/$php_sock}"
    content="${content//\{\{PROXY_PASS\}\}/$proxy_pass}"

    local parent_dir; parent_dir="$(dirname "$out_file")"
    mkdir -p "$parent_dir" 2>/dev/null || sudo mkdir -p "$parent_dir" 2>/dev/null || true

    if [ "$(id -u)" -eq 0 ]; then
        printf '%s\n' "$content" > "$out_file"
    else
        printf '%s\n' "$content" | sudo tee "$out_file" >/dev/null 2>&1 || printf '%s\n' "$content" > "$out_file" 2>/dev/null || true
    fi
}

vhost_test_and_link() {
    local domain="$1"
    local avail_file="$VHOST_AVAILABLE_DIR/${domain}.conf"
    local enab_file="$VHOST_ENABLED_DIR/${domain}.conf"

    if [ ! -f "$avail_file" ]; then
        log_file_error "$avail_file" "Virtual host configuration does not exist"
        return 1
    fi

    # Create symlink temporarily to test syntax
    mkdir -p "$VHOST_ENABLED_DIR" 2>/dev/null || sudo mkdir -p "$VHOST_ENABLED_DIR" 2>/dev/null || true
    if [ "$(id -u)" -eq 0 ]; then
        ln -sf "$avail_file" "$enab_file"
    else
        sudo ln -sf "$avail_file" "$enab_file" 2>/dev/null || ln -sf "$avail_file" "$enab_file" 2>/dev/null || true
    fi

    if command -v nginx >/dev/null 2>&1; then
        local test_out
        if test_out="$(sudo nginx -t 2>&1)"; then
            log_ok "[76] Nginx syntax verification passed for $domain"
            return 0
        else
            log_err "[76] Nginx syntax verification failed: $test_out"
            # Rollback symlink
            if [ "$(id -u)" -eq 0 ]; then rm -f "$enab_file"; else sudo rm -f "$enab_file" 2>/dev/null || true; fi
            return 1
        fi
    else
        log_warn "[76] nginx binary not on PATH; skipped live syntax test"
        return 0
    fi
}

vhost_unlink_and_archive() {
    local domain="$1"
    local avail_file="$VHOST_AVAILABLE_DIR/${domain}.conf"
    local enab_file="$VHOST_ENABLED_DIR/${domain}.conf"

    # Remove enabled symlink
    if [ -L "$enab_file" ] || [ -f "$enab_file" ]; then
        if [ "$(id -u)" -eq 0 ]; then rm -f "$enab_file"; else sudo rm -f "$enab_file" 2>/dev/null || true; fi
    fi

    # Archive available configuration
    if [ -f "$avail_file" ]; then
        local now_stamp; now_stamp="$(date '+%Y%m%d%H%M%S')"
        local bak_file="${avail_file}.bak.${now_stamp}"
        if [ "$(id -u)" -eq 0 ]; then
            mv "$avail_file" "$bak_file"
        else
            sudo mv "$avail_file" "$bak_file" 2>/dev/null || mv "$avail_file" "$bak_file" 2>/dev/null || true
        fi
    fi
}
