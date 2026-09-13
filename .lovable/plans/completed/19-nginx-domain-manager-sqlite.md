# Master Plan 19: Cross-Platform Nginx Domain Manager with SQLite & INI Architecture

> **Prompt Version:** 2.1.0  
> **Status:** COMPLETED  
> **Target Platforms:** Linux (Ubuntu/Debian) & Windows (PowerShell/Chocolatey)

---

## 1. Executive Summary

This master plan establishes the complete **Nginx Domain Management Suite** with **SQLite Database Tracking** and **INI File Synchronization** across both Linux and Windows:

1. **Top-Level CLI Grammar**:
   - `install` -> `./run.sh nginx install` / `.\run.ps1 nginx install`
   - `help` -> `./run.sh nginx help` (or `nginx help`) / `.\run.ps1 nginx help`
   - `add <domain>` -> `./run.sh nginx add domain.com` / `nginx add sub.domain` (with `--type`, `--port`, `--root`, `--php`, `--proxy`, `--ssl`)
   - `rm <domain>` -> `./run.sh nginx rm domain.com` (with `--purge`, `--keep-data`)
   - `list` -> `./run.sh nginx list` (lists all managed vhosts with health status)
   - `ini` -> `./run.sh nginx ini` (displays master/site INI and `--sync` drift reconciliation)
   - `showcase` -> `./run.sh nginx showcase` (demonstrates Before -> Mutation -> After state in SQLite, INI, and Nginx vhost)

2. **SQLite Database Architecture**:
   - Stores all registered domains, subdomains, types, root paths, ports, FastCGI sockets/ports, proxy upstreams, SSL flags, and audit logs.
   - Dual/Multi-tier execution: Native `sqlite3` CLI if available; fallback to Python standard library `sqlite3` (guaranteed zero dependency failure).

3. **INI Configuration Management**:
   - Per-site INI files and master inventory INI.
   - Full bidirectional synchronization: additions/removals update both SQLite and INI files; manual INI changes can be synced into SQLite.

4. **Showcase Visualizer**:
   - Interactive terminal demonstration showing Before state, adding apex and subdomains, displaying the SQLite record, the generated INI file, the rendered Nginx vhost `.conf`, running probe/verification, and cleaning up.

---

## 2. Task-Specific Rule Set (Custom Constraints)

1. **Rule C1 (Dual-Engine SQLite Guarantee)**: Database operations must NEVER fail due to a missing `sqlite3` package. If `sqlite3` binary is absent, execution seamlessly falls back to `python3 -c "import sqlite3..."` or `python` standard library bridge.
2. **Rule C2 (Atomic Tri-State Mutation)**: Adding or removing a domain updates SQLite, INI, and Nginx vhosts in a single transaction. If `nginx -t` validation fails, all changes cleanly rollback.
3. **Rule C3 (Windows Path Normalization)**: In all Nginx vhost configurations generated on Windows, backslashes `\` are strictly normalized to forward slashes `/`.
4. **Rule C4 (Subdomain First-Class Isolation)**: Subdomains (e.g. `sub.domain.com`) have dedicated virtual hosts, isolated INI files, and independent document roots, with `subdomain_of` relationships tracked in SQLite.
5. **Rule C5 (CODE RED Compliance & Relative Paths)**: Every file error logs exact path and reason via `log_file_error` / `Write-FileError`. All links in docs are strictly relative to repository root.

---

## 3. Subtask Decomposition Index

- [x] `01-task.md`: SQLite Engine & Adapter (`scripts-linux/76-install-nginx/modules/db_engine.sh` & `scripts/76-install-nginx/helpers/sqlite-adapter.ps1`)
- [x] `02-task.md`: INI Engine & Two-Way Sync (`scripts-linux/76-install-nginx/modules/ini_engine.sh` & `scripts/76-install-nginx/helpers/ini-parser.ps1`)
- [x] `03-task.md`: Nginx Vhost Generator & Templates (`scripts-linux/76-install-nginx/modules/vhost_engine.sh`, `scripts/76-install-nginx/helpers/vhost-compiler.ps1`, templates)
- [x] `04-task.md`: Linux Domain Manager CLI & Showcase (`scripts-linux/76-install-nginx/modules/domain_manager.sh`, `showcase.sh`, and `run.sh`)
- [x] `05-task.md`: Windows Domain Manager CLI & Showcase (`scripts/76-install-nginx/run.ps1` and helpers)
- [x] `06-task.md`: Root Dispatcher Passthroughs (`scripts-linux/run.sh`, `scripts/run.sh`, `run.ps1`, `install-keywords.json`)

---

## 4. Verification Results

| Platform | Verification Action | Exit Code | Result |
| :--- | :--- | :---: | :--- |
| Windows | `powershell.exe -File scripts\76-install-nginx\run.ps1 showcase` | 0 | PASS (all 5 phases) |
| Windows | `pwsh -File scripts\76-install-nginx\run.ps1 showcase` | 0 | PASS (all 5 phases) |
| Windows | `.\run.ps1 /run nginx help --no-pull` | 0 | PASS |
| Windows | `.\run.ps1 nginx showcase --no-pull` | 0 | PASS |
| Windows | `node tools/smoke-check.mjs --id 76` | 0 | PASS in 1.3s |
| Linux | `bash -n scripts-linux/run.sh` | 0 | PASS (valid syntax) |
| Linux | `scripts-linux/run.sh nginx help` | 0 | PASS |
| Linux | `scripts-linux/run.sh nginx showcase` | 0 | PASS (all 5 phases) |
| Global | `node tools/manifest-validate.cjs` | 0 | PASS (145/145 valid) |
| Global | `node tools/validate-json-configs.mjs` | 0 | PASS (424/424 valid) |
