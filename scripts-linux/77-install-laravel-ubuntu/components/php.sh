#!/usr/bin/env bash
# scripts-linux/77-install-laravel-ubuntu/components/php.sh
# Installs PHP 8.2/8.3 + PHP-FPM + Laravel required extensions:
# pdo_mysql, pdo_pgsql, pdo_sqlite, bcmath, mbstring, xml, curl, zip, intl, redis.
set -u

_php_distro_default() {
    local ver="${1:-}"
    case "$ver" in
        24.04|24.10|25.04) echo "8.3" ;;
        22.04|22.10|23.04|23.10) echo "8.1" ;;
        20.04|20.10|21.04|21.10) echo "7.4" ;;
        *) echo "" ;;
    esac
}

_php_resolve_version() {
    local req="${LARAVEL_PHP_VERSION:-8.3}"
    if [ "$req" = "latest" ]; then
        echo "default"
        return
    fi
    case "$req" in
        8.2|8.3) echo "$req" ;;
        *)
            log_warn "[77][php] unknown LARAVEL_PHP_VERSION='$req' -- falling back to 8.3"
            echo "8.3"
            ;;
    esac
}

_php_pkg_list() {
    local v="$1"
    if [ "$v" = "default" ]; then
        echo "php-cli php-fpm php-mysql php-pgsql php-sqlite3 php-bcmath php-mbstring php-xml php-curl php-zip php-intl php-redis"
    else
        echo "php${v}-cli php${v}-fpm php${v}-mysql php${v}-pgsql php${v}-sqlite3 php${v}-bcmath php${v}-mbstring php${v}-xml php${v}-curl php${v}-zip php${v}-intl php${v}-redis"
    fi
}

_php_fpm_service() {
    local v="$1"
    if [ "$v" = "default" ]; then
        local svc
        svc="$(systemctl list-unit-files 2>/dev/null | awk '/^php[0-9.]+-fpm\.service/ {print $1; exit}')"
        echo "${svc:-php-fpm}"
    else
        echo "php${v}-fpm"
    fi
}

_laravel_php_fpm_socket() {
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

component_php_verify() {
    command -v php >/dev/null 2>&1 || return 1
    php -m 2>/dev/null | grep -qi '^pdo$' || return 1
    return 0
}

component_php_verify_strict() {
    if ! command -v php >/dev/null 2>&1; then
        log_err "[77][php][verify] 'php' binary not found on PATH"
        return 1
    fi
    local ver
    ver="$(php -r 'echo PHP_VERSION;' 2>/dev/null || echo '')"
    local major minor
    major="$(printf '%s' "$ver" | cut -d. -f1)"
    minor="$(printf '%s' "$ver" | cut -d. -f2)"
    case "$major$minor" in
        ''|*[!0-9]*)
            log_err "[77][php][verify] could not parse PHP version (got '$ver')"
            return 1
            ;;
    esac
    # Laravel 11 requires PHP >= 8.2
    if [ "$major" -lt 8 ] || { [ "$major" -eq 8 ] && [ "$minor" -lt 2 ]; }; then
        log_err "[77][php][verify] PHP $ver is below the Laravel 11/12 minimum (8.2)"
        return 1
    fi
    log_info "[77][php][verify] PHP version $ver detected (>= 8.2 OK)"

    local required="pdo pdo_mysql pdo_pgsql pdo_sqlite bcmath mbstring xml curl zip intl redis"
    local loaded
    loaded="$(php -m 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    local missing="" ext
    for ext in $required; do
        if ! printf '%s\n' "$loaded" | grep -qx "$ext"; then
            missing="$missing $ext"
        fi
    done
    if [ -n "$missing" ]; then
        log_err "[77][php][verify] missing required PHP extensions:$missing"
        return 1
    fi
    log_ok "[77][php][verify] all required extensions present ($required)"
    return 0
}

component_php_install() {
    local v; v="$(_php_resolve_version)"

    local ubu_ver distro_default needs_ppa=0
    ubu_ver="$(get_ubuntu_version 2>/dev/null || echo unknown)"
    distro_default="$(_php_distro_default "$ubu_ver")"
    log_info "[77][php] starting installation (requested='${LARAVEL_PHP_VERSION:-8.3}', resolved='$v', ubuntu='$ubu_ver', apt-default='${distro_default:-?}')"

    if [ "$v" = "default" ]; then
        case "$distro_default" in
            7.4|8.1)
                log_warn "[77][php] Ubuntu $ubu_ver ships PHP ${distro_default} which is below Laravel 11 minimum (8.2). Ondrej PPA will be added."
                needs_ppa=1
                v="8.3"
                ;;
            *) ;;
        esac
    else
        if [ -n "$distro_default" ] && [ "$distro_default" = "$v" ]; then
            log_info "[77][php] Ubuntu $ubu_ver default APT provides PHP $v -- skipping Ondrej PPA"
        else
            needs_ppa=1
        fi
    fi

    if [ "$needs_ppa" = "1" ]; then
        if ! grep -rq 'ondrej/php' /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; then
            log_info "[77][php] adding Ondrej PHP PPA (Ubuntu $ubu_ver default is '${distro_default:-unknown}', requested '$v')"
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get update -y >/dev/null 2>&1; then
                log_warn "[77][php] initial apt-get update before ppa had warnings"
            fi
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common >/dev/null 2>&1 || true
            if ! sudo add-apt-repository -y ppa:ondrej/php >/dev/null 2>&1; then
                log_err "[77][php] add-apt-repository ppa:ondrej/php failed"
                return 1
            fi
        else
            log_info "[77][php] Ondrej PPA already present"
        fi
    fi

    sudo apt-get update -y >/dev/null 2>&1 || true
    local pkgs; pkgs="$(_php_pkg_list "$v")"
    # shellcheck disable=SC2086
    if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $pkgs; then
        log_err "[77][php] apt-get install failed for: $pkgs"
        return 1
    fi

    local svc; svc="$(_php_fpm_service "$v")"
    sudo systemctl enable "$svc" >/dev/null 2>&1 || true
    if ! sudo systemctl restart "$svc"; then
        log_err "[77][php] systemctl restart $svc failed"
        return 1
    fi

    if ! component_php_verify; then
        log_err "[77][php] post-install verify failed -- pdo not active in php -m"
        return 1
    fi

    local installed_ver
    installed_ver="$(php -r 'echo PHP_VERSION;' 2>/dev/null || echo '?')"
    log_ok "[77][php] installed OK (php=$installed_ver fpm=$svc)"
    export LARAVEL_PHP_FPM_SERVICE="$svc"
    mkdir -p "$ROOT/.installed" && touch "$ROOT/.installed/77-php.ok"
    return 0
}

component_php_uninstall() {
    log_info "[77][php] removing PHP packages"
    sudo apt-get remove --purge -y 'php8*' 2>/dev/null || true
    rm -f "$ROOT/.installed/77-php.ok" 2>/dev/null || true
    log_ok "[77][php] removed"
    return 0
}
