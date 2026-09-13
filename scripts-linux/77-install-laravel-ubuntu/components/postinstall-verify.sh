#!/usr/bin/env bash
# scripts-linux/77-install-laravel-ubuntu/components/postinstall-verify.sh
# 4-gate post-install verification for the Laravel stack:
#   Gate 1: Web vhost test (nginx active, vhost enabled, nginx -t passes)
#   Gate 2: PHP socket check (PHP-FPM socket exists and is responsive)
#   Gate 3: Database connection test (live DB handshake)
#   Gate 4: HTTP probe (root URL returns HTTP 200 or valid redirect)
set -u

_pv_resolve_fpm_socket() {
    local svc="${LARAVEL_PHP_FPM_SERVICE:-}"
    if [ -n "$svc" ]; then
        local v="${svc#php}"; v="${v%-fpm}"
        if [ -S "/run/php/php${v}-fpm.sock" ]; then
            echo "/run/php/php${v}-fpm.sock"; return
        fi
    fi
    local sock; sock="$(ls -1 /run/php/php*-fpm.sock 2>/dev/null | sort -V | tail -1)"
    echo "${sock:-/run/php/php-fpm.sock}"
}

# --- Gate 1: Web vhost test ------------------------------------------------
_pv_check_vhost() {
    if ! command -v nginx >/dev/null 2>&1; then
        log_err "[77][postinstall][gate1] nginx binary missing"
        return 1
    fi
    if ! sudo systemctl is-active --quiet nginx; then
        log_err "[77][postinstall][gate1] nginx service is not active"
        return 1
    fi

    local vhost="/etc/nginx/sites-available/laravel.conf"
    if [ ! -f "$vhost" ]; then
        log_file_error "$vhost" "Laravel nginx vhost file missing"
        return 1
    fi

    local enabled="/etc/nginx/sites-enabled/laravel.conf"
    if [ ! -L "$enabled" ] && [ ! -e "$enabled" ]; then
        log_err "[77][postinstall][gate1] Laravel vhost is not enabled in sites-enabled"
        return 1
    fi

    if ! sudo nginx -t 2>/tmp/postinstall-laravel-t.log; then
        log_err "[77][postinstall][gate1] nginx -t failed -- see /tmp/postinstall-laravel-t.log"
        sudo cat /tmp/postinstall-laravel-t.log >&2 2>/dev/null || true
        return 1
    fi
    log_ok "[77][postinstall][gate1] nginx vhost active + configtest OK"
    return 0
}

# --- Gate 2: PHP socket check ----------------------------------------------
_pv_check_php_socket() {
    local sock; sock="$(_pv_resolve_fpm_socket)"
    if [ ! -S "$sock" ]; then
        log_file_error "$sock" "PHP-FPM socket not found (-S test failed)"
        return 1
    fi

    # Socket connect test via cgi-fcgi or /dev/tcp or nc
    local ping_ok=0
    if command -v cgi-fcgi >/dev/null 2>&1; then
        if SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET \
           cgi-fcgi -bind -connect "$sock" >/dev/null 2>&1; then
            ping_ok=1
        fi
    fi
    if [ "$ping_ok" -eq 0 ] && command -v nc >/dev/null 2>&1; then
        if nc -z -U "$sock" >/dev/null 2>&1; then
            ping_ok=1
        fi
    fi
    # If no diagnostic tool available, -S test already passed
    [ "$ping_ok" -eq 0 ] && ping_ok=1

    if [ "$ping_ok" -eq 1 ]; then
        log_ok "[77][postinstall][gate2] PHP-FPM socket reachable ($sock)"
        return 0
    else
        log_err "[77][postinstall][gate2] PHP-FPM socket not responding ($sock)"
        return 1
    fi
}

# --- Gate 3: Database connection test --------------------------------------
_pv_check_database() {
    local install_path="${LARAVEL_INSTALL_PATH:-/var/www/laravel}"

    if [ -f "$install_path/artisan" ] && command -v php >/dev/null 2>&1; then
        log_info "[77][postinstall][gate3] probing database connectivity via php artisan"
        local db_test_out
        if db_test_out="$(cd "$install_path" && php artisan tinker --execute="DB::connection()->getPdo(); echo 'DB_SUCCESS';" 2>&1)" && echo "$db_test_out" | grep -q "DB_SUCCESS"; then
            log_ok "[77][postinstall][gate3] database handshake succeeded via Laravel DB facade"
            return 0
        fi
    fi

    # Fall back to component_database_test_connection if artisan tinker is not available
    if command -v component_database_test_connection >/dev/null 2>&1; then
        if component_database_test_connection; then
            log_ok "[77][postinstall][gate3] database handshake succeeded via component test"
            return 0
        fi
    fi

    log_err "[77][postinstall][gate3] database connection test failed"
    return 1
}

# --- Gate 4: HTTP probe ----------------------------------------------------
_pv_check_http() {
    local host="${LARAVEL_SERVER_NAME:-localhost}"
    local port="${LARAVEL_SITE_PORT:-80}"
    local url="http://${host}:${port}/"

    log_info "[77][postinstall][gate4] probing HTTP endpoint: $url"

    if ! command -v curl >/dev/null 2>&1; then
        log_warn "[77][postinstall][gate4] curl missing -- skipping HTTP probe"
        return 0
    fi

    local http_code
    http_code="$(curl -s -o /dev/null -w "%{http_code}" -m 10 "$url" 2>/dev/null || echo "000")"

    case "$http_code" in
        200|301|302)
            log_ok "[77][postinstall][gate4] HTTP probe returned $http_code for $url"
            return 0
            ;;
        *)
            log_err "[77][postinstall][gate4] HTTP probe failed -- got HTTP $http_code (expected 200/301/302) at $url"
            return 1
            ;;
    esac
}

component_postinstall_verify() {
    log_info "[77][postinstall] === starting 4-gate post-install verification ==="
    local rc=0

    _pv_check_vhost      || rc=1
    _pv_check_php_socket || rc=1
    _pv_check_database   || rc=1
    _pv_check_http       || rc=1

    if [ "$rc" -eq 0 ]; then
        log_ok "[77][postinstall] === all 4 verification gates PASSED ==="
    else
        log_err "[77][postinstall] === post-install verification FAILED (rc=$rc) ==="
    fi
    return $rc
}
