#!/usr/bin/env bash
# _shared/db.sh -- SQLite database common engine for scripts-fixer
set -u

_DB_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_DB_ROOT="$(cd "$_DB_SCRIPT_DIR/../.." && pwd)"
_DB_BRIDGE="$_DB_ROOT/scripts/shared/db_bridge.py"

get_python_bin() {
  if command -v python3 >/dev/null 2>&1 && python3 -c "import sys" >/dev/null 2>&1; then
    echo "python3"

    return 0
  fi

  if command -v python >/dev/null 2>&1 && python -c "import sys" >/dev/null 2>&1; then
    echo "python"

    return 0
  fi

  return 1
}

has_python() {
  get_python_bin >/dev/null 2>&1
}

has_sqlite3_cli() {
  command -v sqlite3 >/dev/null 2>&1
}

get_db_file() {
  if [ -n "${SCRIPTS_FIXER_DB:-}" ]; then
    echo "$SCRIPTS_FIXER_DB"

    return 0
  fi

  local target_dir="${HOME:-/root}/.local/share/scripts-fixer"
  mkdir -p "$target_dir" 2>/dev/null || true

  if [ -d "$target_dir" ] && [ -w "$target_dir" ]; then
    echo "$target_dir/scripts-fixer.db"

    return 0
  fi

  echo "$_DB_ROOT/.data/scripts-fixer.db"
}

ensure_db() {
  local db_file
  db_file="$(get_db_file)"
  local parent_dir
  parent_dir="$(dirname "$db_file")"

  if ! mkdir -p "$parent_dir" 2>/dev/null; then
    log_file_error "$parent_dir" "db: mkdir failed for sqlite database directory"

    return 1
  fi

  if has_python && [ -f "$_DB_BRIDGE" ]; then
    "$(get_python_bin)" "$_DB_BRIDGE" init >/dev/null 2>&1

    return 0
  fi

  if has_sqlite3_cli; then
    sqlite3 "$db_file" "CREATE TABLE IF NOT EXISTS schema_migrations (version INTEGER PRIMARY KEY, applied_at TEXT); CREATE TABLE IF NOT EXISTS packages (name TEXT PRIMARY KEY, version TEXT, status TEXT, installed_at TEXT, updated_at TEXT, details TEXT); CREATE TABLE IF NOT EXISTS profiles (name TEXT PRIMARY KEY, status TEXT, installed_at TEXT, updated_at TEXT); CREATE TABLE IF NOT EXISTS install_logs (id TEXT PRIMARY KEY, target_type TEXT, target_name TEXT, action TEXT, status TEXT, exit_code INTEGER, error_message TEXT, log_path TEXT, started_at TEXT, ended_at TEXT); CREATE TABLE IF NOT EXISTS error_logs (id TEXT PRIMARY KEY, target_name TEXT, error_stage TEXT, error_message TEXT, stacktrace TEXT, created_at TEXT);" 2>/dev/null || true

    return 0
  fi

  return 0
}

db_record_start() {
  local target_type="${1:-package}"
  local target_name="${2:-}"
  local action="${3:-install}"

  if has_python && [ -f "$_DB_BRIDGE" ]; then
    "$(get_python_bin)" "$_DB_BRIDGE" record-start "$target_type" "$target_name" "$action" 2>/dev/null || true

    return 0
  fi

  return 0
}

db_record_success() {
  local target_type="${1:-package}"
  local target_name="${2:-}"
  local version="${3:-}"
  local details="${4:-}"

  if has_python && [ -f "$_DB_BRIDGE" ]; then
    "$(get_python_bin)" "$_DB_BRIDGE" record-success "$target_type" "$target_name" "$version" "$details" 2>/dev/null || true

    return 0
  fi

  return 0
}

db_record_failure() {
  local target_type="${1:-package}"
  local target_name="${2:-}"
  local exit_code="${3:-1}"
  local error_msg="${4:-failure}"

  if has_python && [ -f "$_DB_BRIDGE" ]; then
    "$(get_python_bin)" "$_DB_BRIDGE" record-failure "$target_type" "$target_name" "$exit_code" "$error_msg" 2>/dev/null || true

    return 0
  fi

  return 0
}

db_record_skipped() {
  local target_type="${1:-package}"
  local target_name="${2:-}"
  local reason="${3:-already installed}"

  if has_python && [ -f "$_DB_BRIDGE" ]; then
    "$(get_python_bin)" "$_DB_BRIDGE" record-skipped "$target_type" "$target_name" "$reason" 2>/dev/null || true

    return 0
  fi

  return 0
}

db_is_installed() {
  local target_type="${1:-package}"
  local target_name="${2:-}"

  if has_python && [ -f "$_DB_BRIDGE" ]; then
    "$(get_python_bin)" "$_DB_BRIDGE" is-installed "$target_type" "$target_name" >/dev/null 2>&1

    return $?
  fi

  local db_file
  db_file="$(get_db_file)"

  if has_sqlite3_cli && [ -f "$db_file" ]; then
    local table="packages"
    [ "$target_type" = "profile" ] && table="profiles"
    local status
    status=$(sqlite3 "$db_file" "SELECT status FROM $table WHERE name='$target_name' LIMIT 1;" 2>/dev/null || true)
    [ "$status" = "installed" ]

    return $?
  fi

  return 1
}

db_get_status() {
  local target_type="${1:-package}"
  local target_name="${2:-}"

  if has_python && [ -f "$_DB_BRIDGE" ]; then
    "$(get_python_bin)" "$_DB_BRIDGE" get-status "$target_type" "$target_name" 2>/dev/null || echo "unknown"

    return 0
  fi

  echo "unknown"
}
