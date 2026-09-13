#!/usr/bin/env bash
# scripts-linux/77-install-laravel-ubuntu/components/database.sh
# Automates database and user creation for MySQL/MariaDB, PostgreSQL, or SQLite.
set -u

_db_genpass() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 32 2>/dev/null | tr -dc 'a-zA-Z0-9' | head -c 24
    else
        head -c 32 /dev/urandom 2>/dev/null | tr -dc 'a-zA-Z0-9' | head -c 24
    fi
}

component_database_verify() {
    local engine="${LARAVEL_DB_ENGINE:-mysql}"
    case "$engine" in
        mysql|mariadb)
            local svc="mysql"
            [ "$engine" = "mariadb" ] && svc="mariadb"
            command -v mysql >/dev/null 2>&1 || return 1
            sudo systemctl is-active --quiet "$svc" || return 1
            return 0
            ;;
        pgsql|postgresql)
            command -v psql >/dev/null 2>&1 || return 1
            sudo systemctl is-active --quiet postgresql || return 1
            return 0
            ;;
        sqlite)
            local db_file="${LARAVEL_DB_FILE:-${LARAVEL_INSTALL_PATH:-/var/www/laravel}/database/database.sqlite}"
            [ -f "$db_file" ] || return 1
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

component_database_test_connection() {
    local engine="${LARAVEL_DB_ENGINE:-mysql}"
    local db_host="${LARAVEL_DB_HOST:-127.0.0.1}"
    local db_port="${LARAVEL_DB_PORT:-3306}"
    local db_name="${LARAVEL_DB_NAME:-laravel}"
    local db_user="${LARAVEL_DB_USER:-laravel_user}"
    local db_pass="${LARAVEL_DB_PASS:-}"

    case "$engine" in
        mysql|mariadb)
            if ! command -v mysql >/dev/null 2>&1; then
                log_err "[77][database][test] mysql client binary missing"
                return 1
            fi
            if ! mysql -u"$db_user" "-p$db_pass" -h "$db_host" -P "$db_port" "$db_name" -e "SELECT 1;" >/dev/null 2>&1; then
                log_err "[77][database][test] MySQL connection test failed for $db_user@$db_host:$db_port/$db_name"
                return 1
            fi
            log_ok "[77][database][test] MySQL connection successful"
            return 0
            ;;
        pgsql|postgresql)
            if ! command -v psql >/dev/null 2>&1; then
                log_err "[77][database][test] psql client binary missing"
                return 1
            fi
            if ! PGPASSWORD="$db_pass" psql -U "$db_user" -h "$db_host" -p "${LARAVEL_DB_PORT:-5432}" -d "$db_name" -c "SELECT 1;" >/dev/null 2>&1; then
                log_err "[77][database][test] PostgreSQL connection test failed for $db_user@$db_host:${LARAVEL_DB_PORT:-5432}/$db_name"
                return 1
            fi
            log_ok "[77][database][test] PostgreSQL connection successful"
            return 0
            ;;
        sqlite)
            local db_file="${LARAVEL_DB_FILE:-${LARAVEL_INSTALL_PATH:-/var/www/laravel}/database/database.sqlite}"
            if [ ! -f "$db_file" ]; then
                log_file_error "$db_file" "sqlite database file missing"
                return 1
            fi
            if command -v sqlite3 >/dev/null 2>&1; then
                if ! sqlite3 "$db_file" "SELECT 1;" >/dev/null 2>&1; then
                    log_file_error "$db_file" "sqlite3 query failed"
                    return 1
                fi
            fi
            log_ok "[77][database][test] SQLite database accessible: $db_file"
            return 0
            ;;
    esac
}

component_database_install() {
    local engine="${LARAVEL_DB_ENGINE:-mysql}"
    local db_host="${LARAVEL_DB_HOST:-127.0.0.1}"
    local db_port="${LARAVEL_DB_PORT:-3306}"
    local db_name="${LARAVEL_DB_NAME:-laravel}"
    local db_user="${LARAVEL_DB_USER:-laravel_user}"
    local db_pass="${LARAVEL_DB_PASS:-}"

    if [ -z "$db_pass" ] && [ "$engine" != "sqlite" ]; then
        db_pass="$(_db_genpass)"
        export LARAVEL_DB_PASS="$db_pass"
        log_info "[77][database] generated database password (24 chars)"
    fi

    log_info "[77][database] provisioning database (engine=$engine db=$db_name user=$db_user)"

    case "$engine" in
        mysql|mariadb)
            local svc="mysql"
            local pkgs="mysql-server mysql-client"
            if [ "$engine" = "mariadb" ]; then
                svc="mariadb"
                pkgs="mariadb-server mariadb-client"
            fi

            if ! command -v mysql >/dev/null 2>&1 || ! sudo systemctl is-active --quiet "$svc"; then
                log_info "[77][database] installing $pkgs"
                sudo apt-get update -y >/dev/null 2>&1 || true
                # shellcheck disable=SC2086
                if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $pkgs; then
                    log_err "[77][database] apt-get install failed for $pkgs"
                    return 1
                fi
                sudo systemctl enable "$svc" >/dev/null 2>&1 || true
                sudo systemctl restart "$svc" >/dev/null 2>&1 || true
            fi

            log_info "[77][database] creating MySQL database and user: $db_name / $db_user"
            local grant_sql="
              CREATE DATABASE IF NOT EXISTS \`${db_name}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
              CREATE USER IF NOT EXISTS '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}';
              ALTER USER '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}';
              GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'localhost';
              CREATE USER IF NOT EXISTS '${db_user}'@'127.0.0.1' IDENTIFIED BY '${db_pass}';
              ALTER USER '${db_user}'@'127.0.0.1' IDENTIFIED BY '${db_pass}';
              GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'127.0.0.1';
              FLUSH PRIVILEGES;"

            local sql_out
            if ! sql_out="$(sudo mysql -uroot -e "$grant_sql" 2>&1)"; then
                log_err "[77][database] MySQL grant failed: $sql_out"
                return 1
            fi
            log_ok "[77][database] MySQL database and user ready"
            ;;

        pgsql|postgresql)
            if ! command -v psql >/dev/null 2>&1 || ! sudo systemctl is-active --quiet postgresql; then
                log_info "[77][database] installing postgresql"
                sudo apt-get update -y >/dev/null 2>&1 || true
                if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql postgresql-contrib; then
                    log_err "[77][database] apt-get install postgresql failed"
                    return 1
                fi
                sudo systemctl enable postgresql >/dev/null 2>&1 || true
                sudo systemctl restart postgresql >/dev/null 2>&1 || true
            fi

            log_info "[77][database] creating PostgreSQL database and user: $db_name / $db_user"
            local pg_sql="
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${db_user}') THEN
    CREATE ROLE ${db_user} WITH LOGIN PASSWORD '${db_pass}';
  ELSE
    ALTER ROLE ${db_user} WITH PASSWORD '${db_pass}';
  END IF;
END
\$\$;
SELECT 'CREATE DATABASE ${db_name} OWNER ${db_user}'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${db_name}')\gexec
GRANT ALL PRIVILEGES ON DATABASE ${db_name} TO ${db_user};"

            if ! sudo -u postgres psql -v ON_ERROR_STOP=1 <<< "$pg_sql" >/dev/null 2>&1; then
                log_err "[77][database] PostgreSQL role/database creation failed"
                return 1
            fi
            log_ok "[77][database] PostgreSQL database and role ready"
            ;;

        sqlite)
            local install_path="${LARAVEL_INSTALL_PATH:-/var/www/laravel}"
            local db_file="${LARAVEL_DB_FILE:-$install_path/database/database.sqlite}"
            local db_dir
            db_dir="$(dirname "$db_file")"

            if ! command -v sqlite3 >/dev/null 2>&1; then
                log_info "[77][database] installing sqlite3"
                sudo apt-get update -y >/dev/null 2>&1 || true
                sudo DEBIAN_FRONTEND=noninteractive apt-get install -y sqlite3 >/dev/null 2>&1 || true
            fi

            if ! sudo mkdir -p "$db_dir"; then
                log_file_error "$db_dir" "failed to create database directory"
                return 1
            fi
            if [ ! -f "$db_file" ]; then
                if ! sudo touch "$db_file"; then
                    log_file_error "$db_file" "failed to create sqlite database file"
                    return 1
                fi
            fi

            sudo chown -R www-data:www-data "$db_dir" 2>/dev/null || true
            sudo chmod 775 "$db_dir" 2>/dev/null || true
            sudo chmod 664 "$db_file" 2>/dev/null || true
            log_ok "[77][database] SQLite database file ready: $db_file"
            ;;

        *)
            log_err "[77][database] unsupported database engine: '$engine' (expected: mysql|mariadb|pgsql|sqlite)"
            return 1
            ;;
    esac

    mkdir -p "$ROOT/.installed" && touch "$ROOT/.installed/77-database.ok"
    return 0
}

component_database_uninstall() {
    local engine="${LARAVEL_DB_ENGINE:-mysql}"
    local db_name="${LARAVEL_DB_NAME:-laravel}"
    local db_user="${LARAVEL_DB_USER:-laravel_user}"

    log_info "[77][database] removing database objects for $db_name (engine=$engine)"
    case "$engine" in
        mysql|mariadb)
            if command -v mysql >/dev/null 2>&1; then
                sudo mysql -uroot -e "DROP DATABASE IF EXISTS \`${db_name}\`; DROP USER IF EXISTS '${db_user}'@'localhost'; DROP USER IF EXISTS '${db_user}'@'127.0.0.1';" 2>/dev/null || true
                log_ok "[77][database] dropped MySQL database $db_name and user $db_user"
            fi
            ;;
        pgsql|postgresql)
            if command -v psql >/dev/null 2>&1; then
                sudo -u postgres psql -c "DROP DATABASE IF EXISTS ${db_name}; DROP ROLE IF EXISTS ${db_user};" 2>/dev/null || true
                log_ok "[77][database] dropped PostgreSQL database $db_name and role $db_user"
            fi
            ;;
        sqlite)
            local db_file="${LARAVEL_DB_FILE:-${LARAVEL_INSTALL_PATH:-/var/www/laravel}/database/database.sqlite}"
            if [ -f "$db_file" ]; then
                sudo rm -f "$db_file" 2>/dev/null || true
                log_ok "[77][database] removed sqlite file $db_file"
            fi
            ;;
    esac
    rm -f "$ROOT/.installed/77-database.ok" 2>/dev/null || true
    return 0
}
