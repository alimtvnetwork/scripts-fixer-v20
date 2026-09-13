#!/usr/bin/env bash
# scripts-linux/76-install-nginx/modules/db_engine.sh
# Dual-engine SQLite persistence (sqlite3 CLI + python3 sqlite3 fallback)
set -u

_resolve_db_path() {
    if [ -n "${NGINX_DB_PATH:-}" ]; then
        echo "$NGINX_DB_PATH"
        return
    fi
    local root_dir="/var/lib/scripts-fixer"
    if [ "$(id -u)" -eq 0 ]; then
        mkdir -p "$root_dir" 2>/dev/null || true
        if [ -w "$root_dir" ]; then
            echo "$root_dir/nginx-domains.sqlite3"
            return
        fi
    fi
    # Non-root fallback or user-mode testing
    local user_dir="${ROOT:-.}/.installed"
    mkdir -p "$user_dir" 2>/dev/null || true
    if [ -w "$user_dir" ]; then
        echo "$user_dir/nginx-domains.sqlite3"
        return
    fi
    echo "/tmp/nginx-domains.sqlite3"
}

DB_PATH="$(_resolve_db_path)"

db_exec() {
    local sql="$1"
    local db="${2:-$DB_PATH}"
    local db_dir; db_dir="$(dirname "$db")"
    [ -d "$db_dir" ] || mkdir -p "$db_dir" 2>/dev/null || sudo mkdir -p "$db_dir" 2>/dev/null || true

    if command -v sqlite3 >/dev/null 2>&1; then
        sqlite3 -bail "$db" "$sql"
        return $?
    elif command -v python3 >/dev/null 2>&1; then
        python3 - "$db" "$sql" <<'PYEOF'
import sys, sqlite3
db_path, sql_stmt = sys.argv[1], sys.argv[2]
try:
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.executescript(sql_stmt)
    conn.commit()
    conn.close()
except Exception as e:
    sys.stderr.write(f"SQLite Python Error: {e}\n")
    sys.exit(1)
PYEOF
        return $?
    else
        log_file_error "$db" "Neither sqlite3 CLI nor python3 available to execute SQLite query"
        return 1
    fi
}

db_query_tsv() {
    local sql="$1"
    local db="${2:-$DB_PATH}"
    if [ ! -s "$db" ]; then
        return 0
    fi

    if command -v sqlite3 >/dev/null 2>&1; then
        sqlite3 -separator '|' "$db" "$sql" 2>/dev/null
        return $?
    elif command -v python3 >/dev/null 2>&1; then
        python3 - "$db" "$sql" <<'PYEOF'
import sys, sqlite3
db_path, sql_stmt = sys.argv[1], sys.argv[2]
try:
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    for row in cur.execute(sql_stmt):
        print("|".join("" if col is None else str(col) for col in row))
    conn.close()
except Exception as e:
    sys.stderr.write(f"SQLite Query Error: {e}\n")
    sys.exit(1)
PYEOF
        return $?
    else
        log_file_error "$db" "Neither sqlite3 nor python3 available for query"
        return 1
    fi
}

db_init() {
    local db="${1:-$DB_PATH}"
    local schema="
PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS domains (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    domain TEXT NOT NULL UNIQUE,
    subdomain_of TEXT DEFAULT '',
    type TEXT NOT NULL CHECK (type IN ('static', 'php', 'wordpress', 'laravel', 'proxy')),
    port INTEGER NOT NULL DEFAULT 80,
    ssl_port INTEGER DEFAULT 443,
    root_path TEXT NOT NULL DEFAULT '',
    php_version TEXT DEFAULT '',
    php_socket TEXT DEFAULT '',
    proxy_pass TEXT DEFAULT '',
    ssl_enabled INTEGER NOT NULL DEFAULT 0,
    ssl_cert TEXT DEFAULT '',
    ssl_key TEXT DEFAULT '',
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'disabled', 'deleted')),
    vhost_file TEXT NOT NULL DEFAULT '',
    ini_file TEXT NOT NULL DEFAULT '',
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

CREATE INDEX IF NOT EXISTS idx_domains_domain ON domains(domain);
CREATE INDEX IF NOT EXISTS idx_domains_type ON domains(type);
CREATE INDEX IF NOT EXISTS idx_domains_status ON domains(status);

CREATE TABLE IF NOT EXISTS domain_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    domain TEXT NOT NULL,
    action TEXT NOT NULL CHECK (action IN ('CREATE', 'UPDATE', 'ENABLE', 'DISABLE', 'DELETE', 'SYNC', 'ERROR')),
    diff_summary TEXT DEFAULT '',
    operator TEXT NOT NULL DEFAULT 'root',
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

CREATE INDEX IF NOT EXISTS idx_history_domain ON domain_history(domain);

CREATE TABLE IF NOT EXISTS domain_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);
"
    db_exec "$schema" "$db"
}

db_ensure_init() {
    local db="${1:-$DB_PATH}"
    if [ ! -s "$db" ]; then
        db_init "$db"
    fi
}

db_record_add() {
    db_ensure_init
    local domain="$1"
    local subdomain_of="$2"
    local type="$3"
    local port="$4"
    local root_path="$5"
    local php_ver="$6"
    local php_sock="$7"
    local proxy_pass="$8"
    local ssl_enabled="$9"
    local vhost_file="${10}"
    local ini_file="${11}"

    # Escape single quotes in values for SQL safety
    local safe_domain; safe_domain="${domain//\'/\'\'}"
    local safe_sub; safe_sub="${subdomain_of//\'/\'\'}"
    local safe_root; safe_root="${root_path//\'/\'\'}"
    local safe_sock; safe_sock="${php_sock//\'/\'\'}"
    local safe_proxy; safe_proxy="${proxy_pass//\'/\'\'}"
    local safe_vhost; safe_vhost="${vhost_file//\'/\'\'}"
    local safe_ini; safe_ini="${ini_file//\'/\'\'}"

    local sql="
INSERT INTO domains (
    domain, subdomain_of, type, port, root_path, php_version, php_socket,
    proxy_pass, ssl_enabled, status, vhost_file, ini_file, created_at, updated_at
) VALUES (
    '$safe_domain', '$safe_sub', '$type', $port, '$safe_root', '$php_ver', '$safe_sock',
    '$safe_proxy', $ssl_enabled, 'active', '$safe_vhost', '$safe_ini',
    datetime('now', 'localtime'), datetime('now', 'localtime')
)
ON CONFLICT(domain) DO UPDATE SET
    subdomain_of = excluded.subdomain_of,
    type = excluded.type,
    port = excluded.port,
    root_path = excluded.root_path,
    php_version = excluded.php_version,
    php_socket = excluded.php_socket,
    proxy_pass = excluded.proxy_pass,
    ssl_enabled = excluded.ssl_enabled,
    status = 'active',
    vhost_file = excluded.vhost_file,
    ini_file = excluded.ini_file,
    updated_at = datetime('now', 'localtime');
"
    db_exec "$sql"
}

db_record_delete() {
    db_ensure_init
    local domain="$1"
    local safe_domain; safe_domain="${domain//\'/\'\'}"
    local sql="DELETE FROM domains WHERE domain = '$safe_domain';"
    db_exec "$sql"
}

db_record_get() {
    db_ensure_init
    local domain="$1"
    local safe_domain; safe_domain="${domain//\'/\'\'}"
    local sql="SELECT id, domain, subdomain_of, type, port, root_path, php_version, php_socket, proxy_pass, ssl_enabled, status, vhost_file, ini_file, created_at, updated_at FROM domains WHERE domain = '$safe_domain' LIMIT 1;"
    db_query_tsv "$sql"
}

db_record_list() {
    db_ensure_init
    local sql="SELECT domain, type, port, root_path, php_version, proxy_pass, ssl_enabled, status FROM domains WHERE status != 'deleted' ORDER BY domain ASC;"
    db_query_tsv "$sql"
}

db_audit_log() {
    db_ensure_init
    local domain="$1"
    local action="$2"
    local diff="$3"
    local operator="${USER:-$(id -un 2>/dev/null || echo 'unknown')}"
    local safe_domain; safe_domain="${domain//\'/\'\'}"
    local safe_diff; safe_diff="${diff//\'/\'\'}"
    local safe_op; safe_op="${operator//\'/\'\'}"

    local sql="INSERT INTO domain_history (domain, action, diff_summary, operator) VALUES ('$safe_domain', '$action', '$safe_diff', '$safe_op');"
    db_exec "$sql"
}
