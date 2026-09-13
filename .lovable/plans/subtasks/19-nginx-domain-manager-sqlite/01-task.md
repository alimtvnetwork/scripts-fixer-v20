# Subtask 19.1: Cross-Platform SQLite Engine & Adapter

## Target Files
- `scripts-linux/76-install-nginx/modules/db_engine.sh`
- `scripts/76-install-nginx/helpers/sqlite-adapter.ps1`

## Requirements
1. **Linux `db_engine.sh`**:
   - Provide `db_init`, `db_exec`, `db_query_tsv`, `db_query_json`, `db_record_add`, `db_record_delete`, `db_record_get`, `db_record_list`, `db_audit_log`.
   - Implement dual-engine execution: check for `sqlite3` CLI first; if absent, execute SQL via `python3` with standard library `sqlite3`.
   - Define schema with tables: `domains` (id, domain, subdomain_of, type, port, ssl_port, root_path, php_version, php_socket, proxy_pass, ssl_enabled, status, vhost_file, ini_file, created_at, updated_at), `domain_history` (id, domain_id, domain, action, diff_summary, operator, created_at), and `domain_settings`.
   - Enable WAL mode (`PRAGMA journal_mode = WAL;`) and foreign keys.
2. **Windows `sqlite-adapter.ps1`**:
   - Implement `Invoke-SqliteQuery`, `Initialize-NginxDatabase`, `Get-SqliteDomainList`, `Add-SqliteDomainRecord`, `Remove-SqliteDomainRecord`.
   - Support multi-tier execution (`sqlite3.exe` -> `python.exe` -> JSON fallback).
   - Follow strict PowerShell error handling and CODE RED path logging.
