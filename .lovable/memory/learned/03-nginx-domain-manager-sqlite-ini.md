# Learned: Nginx Domain Manager, SQLite Ledger & INI Synchronization

> **Date:** 2026-09-09  
> **Status:** Permanent Institutional Knowledge  
> **Scope:** Cross-Platform Web Server Orchestration (Linux & Windows)

---

## 1. Verbatim User Directives Captured

The user required:
```text
add options like

`/run nginx install

nginx help
nginx add domain.com
nginx add sub.domain

keep all as a sqlitedb

and also 

nginx rm domain.com

also show how these will update the ini files show case
```

---

## 2. Architectural Decisions & Patterns Established

1. **Top-Level CLI Grammar Parity**:
   - Support both `/run nginx <subcommand>` and `nginx <subcommand>` across Linux (`scripts-linux/run.sh`) and Windows (`run.ps1`).
   - Root dispatchers strip leading `/run`, `\run`, or `run` tokens and route directly to the script 76 entrypoint.
   - Early root help interceptors (`Show-RootHelp` on Windows, `show_help` on Linux) must NEVER intercept child help requests when `$Command` is `nginx` (or `ssh`, `os`, `menu`).

2. **Zero-Dependency Multi-Tier SQLite Persistence**:
   - Database operations must never fail due to an uninstalled `sqlite3` CLI package.
   - On Linux: `db_engine.sh` checks for `sqlite3` CLI; if absent, transparently falls back to `python3 -c "import sqlite3..."`.
   - On Windows: `sqlite-adapter.ps1` checks for `sqlite3.exe`; if absent, routes queries to `helpers/sqlite-bridge.py` via Python standard library.
   - Standard relational schema:
     - `domains`: Stores id, domain, subdomain_of, type (`static`, `php`, `wordpress`, `laravel`, `proxy`), port, ssl_port, root_path, php_version, php_socket, proxy_pass, ssl_enabled, status, vhost_file, ini_file, created_at, updated_at.
     - `domain_history`: Full audit trail tracking `CREATE`, `UPDATE`, and `DELETE` mutations with timestamps and operator tags.
     - `domain_settings`: Key-value configuration store for default ports, sockets, and directories.
   - WAL mode (`PRAGMA journal_mode = WAL;`) enabled for high-concurrency read/write transactions.

3. **Tri-State Bidirectional Synchronization**:
   - Real-time consistency across three stores: (1) SQLite DB, (2) Declarative INI file(s), (3) Nginx virtual host `.conf` files.
   - Windows maintains `scripts/76-install-nginx/domains.ini` with automated `[domain]` sections and metadata.
   - Linux maintains per-site `/etc/nginx/sites.d/<domain>.ini` files and a master `/etc/nginx/sites.ini` inventory ledger.
   - Two-way drift reconciliation via `nginx ini --sync` detects out-of-band file edits and reconciles SQLite rows.

4. **Virtual Host Compiler & Path Normalization**:
   - Windows Nginx requires all file paths in `.conf` files to strictly use forward slashes `/` (e.g. `C:/tools/nginx/html/...`). Backslashes cause Nginx parser errors.
   - Dedicated templates for `static`, `php`, `proxy`, `wordpress`, and `laravel`.
   - Syntax validation gate: `nginx -t` must execute and pass before linking or reloading the service.

5. **5-Phase Tri-State Showcase Engine**:
   - `nginx showcase` demonstrates before/after mutations in real time:
     - Phase 1 (Before): Assert clean state in SQLite, INI, and vhosts.
     - Phase 2 (Mutation): Add apex domain (`win-showcase.local` / `showcase.example.local`) and subdomain (`api.win-showcase.local`).
     - Phase 3 (Verification): Verify and display SQLite records, generated INI files, and compiled Nginx vhost configurations.
     - Phase 4 (Removal): Remove subdomain, verifying real-time deletion from INI and SQLite audit logging.
     - Phase 5 (Teardown): Cleanly delete test domain and restore pristine state.

---

## 3. Resolved Pitfalls & Critical Gotchas

1. **PowerShell 5.1 UTF-8 BOM in Standard Input**:
   - *Problem*: `powershell.exe` prefixes piped standard input with UTF-8 byte order marks (`\xef\xbb\xbf`). When Python reads `sys.stdin.read()`, SQLite fails on syntax error at character `\ufeffSELECT`.
   - *Solution*: `sqlite-bridge.py` reads raw bytes via `sys.stdin.buffer.read().decode("utf-8-sig")`, which transparently strips the BOM.

2. **PowerShell 5.1 Null-Coalescing Operator (`??`)**:
   - *Problem*: `??` causes a fatal parser syntax error in Windows PowerShell 5.1.
   - *Solution*: Strictly use `if ($null -ne $val) { $val } else { $fallback }`.

3. **PowerShell StrictMode Array Type Preservation**:
   - *Problem*: Under `Set-StrictMode -Version Latest`, functions returning an array with 1 item unwrap it into a scalar object, causing `$result.Count` to fail.
   - *Solution*: Always wrap call results with `@(...)` and check `.Length`.

4. **PowerShell 5.1 Multibyte ANSI Parsing**:
   - *Problem*: Literal Unicode characters (e.g. `✔`) inside UTF-8 `.ps1` files without BOM cause parse errors on PowerShell 5.1.
   - *Solution*: Use `[char]0x2714` or standard ASCII.

5. **Root Dispatcher Early Help Shadowing**:
   - *Problem*: Global `run.ps1` intercepted `.\run.ps1 nginx help` because `help` was in `$Install`.
   - *Solution*: Added check `$_cmdLow -notin @("nginx", "os", "ssh", "menu", "vscode-folder", "git-tools")` to prevent early help from swallowing subcommand help flags.
