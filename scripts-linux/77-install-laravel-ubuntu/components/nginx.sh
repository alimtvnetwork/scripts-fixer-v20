#!/usr/bin/env bash
# scripts-linux/77-install-laravel-ubuntu/components/nginx.sh
# Installs nginx and configures a hardened Laravel vhost isolating root to /public.
set -u

_laravel_fpm_socket() {
    local svc="${LARAVEL_PHP_FPM_SERVICE:-}"
    if [ -n "$svc" ]; then
        local v="${svc#php}"; v="${v%-fpm}"
        if [ -S "/run/php/php${v}-fpm.sock" ]; then
            echo "/run/php/php${v}-fpm.sock"
            return
        fi
    fi
    local sock
    sock="$(ls -1 /run/php/php*-fpm.sock 2>/dev/null | sort -V | tail -1)"
    echo "${sock:-/run/php/php-fpm.sock}"
}

component_nginx_verify() {
    command -v nginx >/dev/null 2>&1 || return 1
    sudo systemctl is-active --quiet nginx || return 1
    return 0
}

component_nginx_install() {
    local install_path="${LARAVEL_INSTALL_PATH:-/var/www/laravel}"
    local port="${LARAVEL_SITE_PORT:-80}"
    local server_name="${LARAVEL_SERVER_NAME:-localhost}"
    log_info "[77][nginx] starting installation (docroot=$install_path/public port=$port server_name=$server_name)"

    if ! command -v nginx >/dev/null 2>&1; then
        sudo apt-get update -y >/dev/null 2>&1 || true
        if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx; then
            log_err "[77][nginx] apt-get install nginx failed"
            return 1
        fi
    fi

    local sock
    sock="$(_laravel_fpm_socket)"
    if [ ! -S "$sock" ]; then
        log_warn "[77][nginx] PHP-FPM socket not found at: $sock (vhost will be written but requests may 502 until php-fpm starts)"
    fi

    local vhost="/etc/nginx/sites-available/laravel.conf"
    log_info "[77][nginx] writing vhost -> $vhost"

    if ! sudo tee "$vhost" >/dev/null <<EOF
# Written by 77-install-laravel-ubuntu (do not edit by hand)
server {
    listen ${port};
    listen [::]:${port};
    server_name ${server_name};
    root ${install_path}/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php index.html;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \\.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${sock};
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
    }

    # Deny dotfiles (except .well-known for ACME cert challenges)
    location ~ /\\.(?!well-known).* {
        deny all;
    }

    # Deny access to sensitive files
    location ~ /(?:\\.env|artisan|composer\\.(?:json|lock)|package\\.json|phpunit\\.xml) {
        deny all;
    }
}
EOF
    then
        log_file_error "$vhost" "tee failed while writing nginx vhost"
        return 1
    fi

    # Enable site, disable default to avoid port conflicts (graceful if absent)
    if ! sudo ln -sf "$vhost" /etc/nginx/sites-enabled/laravel.conf; then
        log_file_error "/etc/nginx/sites-enabled/laravel.conf" "ln -sf failed"
        return 1
    fi
    if [ -e /etc/nginx/sites-enabled/default ] || [ -L /etc/nginx/sites-enabled/default ]; then
        sudo rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true
    fi

    if ! sudo nginx -t 2>&1 | tee /tmp/nginx-laravel-t.log >/dev/null; then
        log_err "[77][nginx] 'nginx -t' configuration test failed -- see /tmp/nginx-laravel-t.log:"
        sudo cat /tmp/nginx-laravel-t.log >&2
        return 1
    fi

    sudo systemctl enable nginx >/dev/null 2>&1 || true
    if ! sudo systemctl restart nginx; then
        log_err "[77][nginx] systemctl restart nginx failed"
        return 1
    fi

    if ! component_nginx_verify; then
        log_err "[77][nginx] post-install verify failed (binary missing or service inactive)"
        return 1
    fi
    log_ok "[77][nginx] installed OK (vhost=$vhost listening :${port})"
    mkdir -p "$ROOT/.installed" && touch "$ROOT/.installed/77-nginx.ok"
    return 0
}

component_nginx_uninstall() {
    local enabled="/etc/nginx/sites-enabled/laravel.conf"
    local available="/etc/nginx/sites-available/laravel.conf"
    local rc=0

    log_info "[77][nginx] removing Laravel site config (preserving nginx and PHP packages)"

    if [ -L "$enabled" ] || [ -e "$enabled" ]; then
        if ! sudo rm -f "$enabled"; then
            log_file_error "$enabled" "rm failed while disabling Laravel site"
            rc=1
        else
            log_ok "[77][nginx] disabled site: $enabled"
        fi
    fi

    if [ -f "$available" ]; then
        if ! sudo rm -f "$available"; then
            log_file_error "$available" "rm failed while removing Laravel vhost"
            rc=1
        else
            log_ok "[77][nginx] removed vhost: $available"
        fi
    fi

    # Restore default site if no other site is enabled (graceful handling)
    if [ ! "$(ls -A /etc/nginx/sites-enabled 2>/dev/null)" ]; then
        if [ -f /etc/nginx/sites-available/default ]; then
            log_info "[77][nginx] no other sites enabled -- restoring 'default' site"
            if ! sudo ln -sf /etc/nginx/sites-available/default \
                              /etc/nginx/sites-enabled/default 2>/dev/null; then
                log_warn "[77][nginx] ln -sf failed while restoring default site (continuing)"
            fi
        else
            log_info "[77][nginx] /etc/nginx/sites-available/default absent -- skipping default site restore"
        fi
    fi

    if ! command -v nginx >/dev/null 2>&1; then
        log_warn "[77][nginx] 'nginx' binary not found -- skipping reload"
    else
        if ! sudo nginx -t 2>/tmp/nginx-laravel-uninstall-t.log; then
            log_err "[77][nginx] 'nginx -t' failed after removing Laravel site"
            rc=1
        elif sudo systemctl is-active --quiet nginx; then
            if ! sudo systemctl reload nginx; then
                log_err "[77][nginx] systemctl reload nginx failed"
                rc=1
            else
                log_ok "[77][nginx] reloaded nginx"
            fi
        fi
    fi

    rm -f "$ROOT/.installed/77-nginx.ok" 2>/dev/null || true
    return $rc
}
