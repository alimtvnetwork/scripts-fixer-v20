#!/usr/bin/env bash
# scripts-linux/77-install-laravel-ubuntu/components/laravel.sh
# Scaffolds or adopts Laravel applications, configures .env, generates APP_KEY,
# sets www-data permissions, and executes migrations & storage:link.
set -u

_env_set_key() {
    local key="$1"
    local val="$2"
    local file="$3"

    if [ ! -f "$file" ]; then
        log_file_error "$file" "cannot set $key: file does not exist"
        return 1
    fi

    if grep -qE "^${key}=" "$file"; then
        # Escape backslashes and ampersands for sed
        local escaped_val
        escaped_val="$(printf '%s' "$val" | sed -e 's/[\\&]/\\&/g')"
        sudo sed -i -E "s|^${key}=.*|${key}=${escaped_val}|" "$file"
    else
        echo "${key}=${val}" | sudo tee -a "$file" >/dev/null
    fi
}

_laravel_save_credentials_record() {
    local install_path="$1" db_engine="$2" db_host="$3" db_port="$4"
    local db_name="$5" db_user="$6" db_pass="$7"
    local rec_dir="$ROOT/.installed"
    local rec="$rec_dir/77-laravel-credentials.json"
    if ! mkdir -p "$rec_dir"; then
        log_file_error "$rec_dir" "mkdir -p failed for credentials record dir"
        return 1
    fi
    cat > "$rec" <<EOF
{
  "app_name": "${LARAVEL_APP_NAME:-laravel-app}",
  "install_path": "$install_path",
  "site_url": "http://${LARAVEL_SERVER_NAME:-localhost}:${LARAVEL_SITE_PORT:-80}/",
  "db_engine": "$db_engine",
  "db_host": "$db_host",
  "db_port": $db_port,
  "db_name": "$db_name",
  "db_user": "$db_user",
  "db_pass": "$db_pass",
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    chmod 600 "$rec" 2>/dev/null || true
    log_info "[77][laravel] credentials saved -> $rec (chmod 600)"
    return 0
}

component_laravel_show_credentials() {
    local rec="$ROOT/.installed/77-laravel-credentials.json"
    local json_mode=0
    [ "${1:-}" = "--json" ] && json_mode=1

    if [ ! -f "$rec" ]; then
        log_file_error "$rec" "credentials record not found (has 'install' been run?)"
        return 1
    fi

    if [ "$json_mode" = "1" ]; then
        cat "$rec"
        return 0
    fi

    if command -v jq >/dev/null 2>&1; then
        local app site engine host port db user pass
        app="$(jq -r '.app_name // "laravel-app"' "$rec")"
        site="$(jq -r '.site_url // "unknown"' "$rec")"
        engine="$(jq -r '.db_engine // "mysql"' "$rec")"
        host="$(jq -r '.db_host // "127.0.0.1"' "$rec")"
        port="$(jq -r '.db_port // 3306' "$rec")"
        db="$(jq -r '.db_name // "laravel"' "$rec")"
        user="$(jq -r '.db_user // "laravel_user"' "$rec")"
        pass="$(jq -r '.db_pass // ""' "$rec")"

        printf '\n  ============================================================\n'
        printf '  Laravel credentials (chmod 600 at %s)\n' "$rec"
        printf '  ------------------------------------------------------------\n'
        printf '  App Name : %s\n' "$app"
        printf '  Site URL : %s\n' "$site"
        printf '  DB Type  : %s\n' "$engine"
        printf '  DB Host  : %s:%s\n' "$host" "$port"
        printf '  DB Name  : %s\n' "$db"
        printf '  DB User  : %s\n' "$user"
        printf '  DB Pass  : %s\n' "$pass"
        printf '  ============================================================\n\n'
    else
        cat "$rec"
    fi
    return 0
}

component_laravel_verify() {
    local install_path="${LARAVEL_INSTALL_PATH:-/var/www/laravel}"
    [ -d "$install_path" ] || return 1
    [ -f "$install_path/artisan" ] || return 1
    [ -f "$install_path/.env" ] || return 1
    [ -f "$install_path/public/index.php" ] || return 1
    return 0
}

component_laravel_install() {
    local install_path="${LARAVEL_INSTALL_PATH:-/var/www/laravel}"
    local app_name="${LARAVEL_APP_NAME:-laravel-app}"
    local server_name="${LARAVEL_SERVER_NAME:-localhost}"
    local port="${LARAVEL_SITE_PORT:-80}"
    local engine="${LARAVEL_DB_ENGINE:-mysql}"
    local db_host="${LARAVEL_DB_HOST:-127.0.0.1}"
    local db_port="${LARAVEL_DB_PORT:-3306}"
    local db_name="${LARAVEL_DB_NAME:-laravel}"
    local db_user="${LARAVEL_DB_USER:-laravel_user}"
    local db_pass="${LARAVEL_DB_PASS:-}"

    [ "$engine" = "pgsql" ] || [ "$engine" = "postgresql" ] && db_port="${LARAVEL_DB_PORT:-5432}"

    log_info "[77][laravel] starting Laravel app setup at $install_path"

    if [ -f "$install_path/artisan" ]; then
        log_info "[77][laravel] existing Laravel application found at $install_path"
    else
        log_info "[77][laravel] scaffolding new Laravel project via composer create-project"
        if ! command -v composer >/dev/null 2>&1; then
            log_err "[77][laravel] composer binary missing -- cannot scaffold Laravel"
            return 1
        fi

        local parent_dir
        parent_dir="$(dirname "$install_path")"
        if ! sudo mkdir -p "$parent_dir"; then
            log_file_error "$parent_dir" "failed to create parent directory for Laravel"
            return 1
        fi

        # If directory exists and is empty, create-project in it, else create-project directly
        if [ -d "$install_path" ]; then
            if [ -z "$(ls -A "$install_path" 2>/dev/null)" ]; then
                if ! sudo COMPOSER_ALLOW_SUPERUSER=1 composer create-project --prefer-dist laravel/laravel "$install_path"; then
                    log_file_error "$install_path" "composer create-project failed"
                    return 1
                fi
            else
                log_warn "[77][laravel] target directory $install_path is not empty but lacks artisan"
            fi
        else
            if ! sudo COMPOSER_ALLOW_SUPERUSER=1 composer create-project --prefer-dist laravel/laravel "$install_path"; then
                log_file_error "$install_path" "composer create-project failed"
                return 1
            fi
        fi
    fi

    if [ ! -f "$install_path/artisan" ]; then
        log_file_error "$install_path/artisan" "Laravel artisan entrypoint missing after scaffolding"
        return 1
    fi

    # Ensure .env exists
    local env_file="$install_path/.env"
    if [ ! -f "$env_file" ]; then
        if [ -f "$install_path/.env.example" ]; then
            log_info "[77][laravel] copying .env from .env.example"
            if ! sudo cp "$install_path/.env.example" "$env_file"; then
                log_file_error "$env_file" "failed to copy .env.example to .env"
                return 1
            fi
        else
            log_file_error "$env_file" ".env and .env.example both missing in $install_path"
            return 1
        fi
    fi

    # Configure .env parameters
    log_info "[77][laravel] configuring .env parameters"
    _env_set_key "APP_NAME" "\"$app_name\"" "$env_file"
    _env_set_key "APP_URL" "http://${server_name}:${port}" "$env_file"

    case "$engine" in
        sqlite)
            local sqlite_path="$install_path/database/database.sqlite"
            _env_set_key "DB_CONNECTION" "sqlite" "$env_file"
            _env_set_key "DB_DATABASE" "$sqlite_path" "$env_file"
            ;;
        pgsql|postgresql)
            _env_set_key "DB_CONNECTION" "pgsql" "$env_file"
            _env_set_key "DB_HOST" "$db_host" "$env_file"
            _env_set_key "DB_PORT" "$db_port" "$env_file"
            _env_set_key "DB_DATABASE" "$db_name" "$env_file"
            _env_set_key "DB_USERNAME" "$db_user" "$env_file"
            _env_set_key "DB_PASSWORD" "$db_pass" "$env_file"
            ;;
        *)
            _env_set_key "DB_CONNECTION" "mysql" "$env_file"
            _env_set_key "DB_HOST" "$db_host" "$env_file"
            _env_set_key "DB_PORT" "$db_port" "$env_file"
            _env_set_key "DB_DATABASE" "$db_name" "$env_file"
            _env_set_key "DB_USERNAME" "$db_user" "$env_file"
            _env_set_key "DB_PASSWORD" "$db_pass" "$env_file"
            ;;
    esac

    # Ensure APP_KEY is generated
    local current_key
    current_key="$(grep -E "^APP_KEY=" "$env_file" 2>/dev/null | cut -d= -f2-)"
    if [ -z "$current_key" ] || [ "$current_key" = "base64:" ] || [ "$current_key" = "" ]; then
        log_info "[77][laravel] generating application key (php artisan key:generate)"
        if ! sudo php "$install_path/artisan" key:generate --force; then
            log_file_error "$env_file" "artisan key:generate failed"
            return 1
        fi
        log_ok "[77][laravel] APP_KEY generated"
    else
        log_info "[77][laravel] APP_KEY already populated"
    fi

    # Set ownership and permissions
    log_info "[77][laravel] setting permissions (www-data:www-data, 775 on storage & bootstrap/cache)"
    sudo chown -R www-data:www-data "$install_path" 2>/dev/null || true
    sudo chmod -R 775 "$install_path/storage" "$install_path/bootstrap/cache" 2>/dev/null || true
    sudo find "$install_path/storage" "$install_path/bootstrap/cache" -type d -exec chmod 775 {} + 2>/dev/null || true
    sudo find "$install_path/storage" "$install_path/bootstrap/cache" -type f -exec chmod 664 {} + 2>/dev/null || true

    # Run database migrations
    if [ "${LARAVEL_RUN_MIGRATIONS:-1}" = "1" ]; then
        log_info "[77][laravel] running php artisan migrate --force"
        if ! sudo -u www-data php "$install_path/artisan" migrate --force; then
            log_warn "[77][laravel] php artisan migrate --force returned non-zero (check database credentials or schema)"
        else
            log_ok "[77][laravel] database migrations completed successfully"
        fi
    fi

    # Run storage:link
    if [ "${LARAVEL_STORAGE_LINK:-1}" = "1" ]; then
        log_info "[77][laravel] running php artisan storage:link"
        sudo -u www-data php "$install_path/artisan" storage:link 2>/dev/null || true
        log_ok "[77][laravel] storage:link configured"
    fi

    _laravel_save_credentials_record "$install_path" "$engine" "$db_host" "$db_port" \
        "$db_name" "$db_user" "$db_pass" || true

    if ! component_laravel_verify; then
        log_err "[77][laravel] verify failed after setup"
        return 1
    fi

    log_ok "[77][laravel] Laravel application setup complete"
    mkdir -p "$ROOT/.installed" && touch "$ROOT/.installed/77-laravel.ok"
    return 0
}

component_laravel_uninstall() {
    local install_path="${LARAVEL_INSTALL_PATH:-/var/www/laravel}"
    log_info "[77][laravel] removing Laravel files from $install_path"
    if [ -d "$install_path" ]; then
        if ! sudo rm -rf "$install_path"; then
            log_file_error "$install_path" "failed to remove Laravel directory"
            return 1
        fi
        log_ok "[77][laravel] removed $install_path"
    else
        log_info "[77][laravel] $install_path not present"
    fi
    rm -f "$ROOT/.installed/77-laravel.ok" "$ROOT/.installed/77-laravel-credentials.json" 2>/dev/null || true
    return 0
}
