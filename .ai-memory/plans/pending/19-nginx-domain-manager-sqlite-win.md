# Plan 19: Windows Nginx Virtual Host & Domain Manager with SQLite Storage, INI Synchronization & Showcase Suite

> **Document Type:** Architectural Specification & Implementation Plan  
> **Status:** Pending Implementation  
> **Target OS:** Windows 10 / 11 / Windows Server (PowerShell 5.1+ & PowerShell Core 7+)  
> **Affected Toolkit Components:**  
> - `run.ps1` (Top-Level Command Router & Dispatcher)  
> - `scripts/76-install-nginx/run.ps1` (Standalone Nginx Suite & Domain Manager Entrypoint)  
> - `scripts/76-install-nginx/helpers/sqlite-adapter.ps1` (Multi-Tier SQLite Executor & Schema Migrations)  
> - `scripts/76-install-nginx/helpers/ini-parser.ps1` (Pure PowerShell INI Engine & Two-Way Sync)  
> - `scripts/76-install-nginx/helpers/vhost-compiler.ps1` (Template Engine & Windows Path Normalizer)  
> - `scripts/76-install-nginx/helpers/showcase-manager.ps1` (Showcase Provisioner & HTTP Verification)  
> - `scripts/76-install-nginx/helpers/hosts-helper.ps1` (Safe Windows Hosts File Modifier)  
> - `scripts/76-install-nginx/templates/*.conf.template` (Modular Virtual Host Templates)  
> - `scripts/76-install-nginx/domains.ini` (Declarative Domain Ledger)  
> - `registry.yaml` & `scripts/shared/install-keywords.json`

---

## 1. Executive Summary & Architectural Vision

On Windows, Nginx lacks native dynamic vhost tools, PHP requires TCP loopback FastCGI (`127.0.0.1:9000`), path formatting requires forward-slash normalization inside Nginx directives, and port conflicts must be handled safely.

This specification elevates Script 76 (`scripts/76-install-nginx`) into a **first-class Windows Virtual Host & Domain Manager Suite**, completely integrated with the root `.\run.ps1` CLI.

### Architectural Pillars:
1. **Unified CLI Ergonomics**: First-class commands via `.\run.ps1 nginx <verb>` (`install`, `help`, `add`, `rm`, `list`, `ini`, `showcase`) and direct script parity in `scripts/76-install-nginx/run.ps1`.
2. **Resilient Multi-Tier SQLite Storage**: A robust 4-tier database execution engine (`sqlite3.exe` -> `python sqlite3` -> .NET `System.Data.SQLite` -> JSON fallback) that maintains complete domain registry, configurations, and historical audit logs.
3. **Declarative INI File Management & Two-Way Synchronization**: Human-readable `domains.ini` configuration with bidirectional sync between the INI ledger and the SQLite database.
4. **Automated Windows Nginx Vhost Compilation**: Atomic generation of optimized Nginx server blocks (`conf/conf.d/<domain>.conf`) for static web apps, PHP, WordPress, Laravel, and reverse proxies, with path normalization and syntax testing (`nginx -t`) prior to live reload (`nginx -s reload`).
5. **Interactive Showcase Suite**: A one-command demonstration system (`.\run.ps1 nginx showcase`) that provisions demo vhosts, deploys styled diagnostic web pages, verifies live HTTP responses, and configures local DNS resolution via the Windows `hosts` file.

---

## 2. Invariants & Path Quirks
- **I1 (Forward-Slash Normalization)**: All Windows paths in Nginx directives must use forward slashes `/` (e.g. `D:/dev-tool/www/mysite`).
- **I2 (Syntax-Gated Reload)**: `nginx.exe -s reload` must only be invoked after `nginx.exe -t` passes.
- **I3 (FastCGI Loopback Safety)**: All PHP vhosts target `127.0.0.1:9000` over TCP loopback.
- **I4 (Dual Storage Consistency)**: SQLite database and `domains.ini` are synchronized with timestamp and hash conflict detection.

---

## 3. Database Schema

```sql
CREATE TABLE IF NOT EXISTS domains (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    domain        TEXT UNIQUE NOT NULL COLLATE NOCASE,
    type          TEXT NOT NULL CHECK(type IN ('static', 'php', 'wordpress', 'laravel', 'proxy')),
    port          INTEGER NOT NULL DEFAULT 80,
    root_dir      TEXT NOT NULL,
    upstream      TEXT DEFAULT NULL,
    ssl_enabled   INTEGER NOT NULL DEFAULT 0,
    ssl_cert_path TEXT DEFAULT NULL,
    ssl_key_path  TEXT DEFAULT NULL,
    conf_path     TEXT NOT NULL,
    status        TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active', 'disabled', 'deleted')),
    created_at    TEXT NOT NULL,
    updated_at    TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS domain_history (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    domain       TEXT NOT NULL,
    action       TEXT NOT NULL CHECK(action IN ('create', 'update', 'delete', 'enable', 'disable', 'sync_ini')),
    details      TEXT,
    performed_by TEXT NOT NULL,
    timestamp    TEXT NOT NULL
);
```
