# Command Specification: `nginx` (Nginx Domain Manager)

> **Version:** 2.1.0  
> **Status:** Standard Command Specification  
> **Updated:** 2026-09-13  
> **Target Scripts:** `scripts/76-install-nginx/run.ps1` (Windows), `scripts-linux/76-install-nginx/run.sh` (Linux), `run.ps1`, `scripts-linux/run.sh`

---

## 1. Overview

The `nginx` command suite provides cross-platform management for Nginx web server installation, multi-domain/subdomain virtual hosts, SQLite database tracking, and bidirectional INI configuration synchronization.

All commands can be invoked via the root dispatchers or directly from the component directories:
- **Windows:** `.\run.ps1 nginx <subcommand> [options]` or `.\scripts\76-install-nginx\run.ps1 <subcommand> [options]`
- **Linux:** `./run.sh nginx <subcommand> [options]` or `./scripts-linux/76-install-nginx/run.sh <subcommand> [options]`

---

## 2. Command Grammar & Subcommands

### 2.1 `nginx install`
- **Syntax:** `nginx install [flags]`
- **Purpose:** Installs Nginx on the host system (via Chocolatey on Windows, `apt` on Ubuntu/Debian), creates required directories, initializes the SQLite database schema (`nginx-domains.sqlite3`), and bootstraps default INI configuration files.
- **Flags:**
  - `-Port <int>` / `--port <int>`: Default listen port (default: `80`).
  - `-DryRun` / `--dry-run`: Validate prerequisite packages without installing.
- **Exit Codes:** `0` on success, `1` on installation failure.

### 2.2 `nginx help`
- **Syntax:** `nginx help` or `nginx --help` or `nginx -h`
- **Purpose:** Displays detailed usage instructions, supported parameters, subcommands, and operational examples.
- **Exit Codes:** `0`.

### 2.3 `nginx add <domain>`
- **Syntax:** `nginx add <domain> [options]`
- **Purpose:** Registers an apex domain (e.g. `domain.com`) or subdomain (e.g. `sub.domain.com`), compiles its virtual host configuration, generates its dedicated INI file, registers the record in SQLite, and hot-reloads Nginx.
- **Parameters & Options:**
  - `<domain>` (Positional): Target domain name or subdomain string.
  - `-Type <static|php|proxy|laravel|wordpress>` / `--type <type>`: Site architecture (default: `static`).
  - `-Port <int>` / `--port <int>`: HTTP listening port (default: `80`).
  - `-Root <path>` / `--root <path>`: Custom document root path. If omitted, defaults to `<nginx_root>/html/<domain>`.
  - `-Php <upstream>` / `--php <upstream>`: FastCGI socket or TCP host:port (e.g., `127.0.0.1:9000` or `unix:/run/php/php8.2-fpm.sock`).
  - `-Proxy <url>` / `--proxy <url>`: Reverse proxy destination URL (e.g., `http://127.0.0.1:3000`).
  - `-Ssl` / `--ssl`: Enable SSL virtual host template on port `443`.
- **Atomic Tri-State Flow:**
  1. Record site specifications in SQLite with status `provisioning`.
  2. Write site INI (`<domain>.ini`) and update master INI inventory (`domains.ini` / `sites.ini`).
  3. Compile Nginx configuration snippet (`conf.d/<domain>.conf` or `sites-available/<domain>`).
  4. Run validation check (`nginx -t`).
  5. If valid: reload Nginx and update SQLite status to `active`.
  6. If invalid: rollback file creations, record failure reason in SQLite history log, and return exit code `1`.

### 2.4 `nginx rm <domain>`
- **Syntax:** `nginx rm <domain> [options]` (Aliases: `remove`, `delete`)
- **Purpose:** Deactivates and removes an existing domain virtual host.
- **Options:**
  - `-Purge` / `--purge`: Remove document root contents from disk in addition to virtual host configuration.
  - `-KeepData` / `--keep-data`: Keep document root intact, removing only virtual host and INI file (default behavior).
- **Atomic Flow:**
  1. Mark SQLite record as `decommissioning`.
  2. Remove or archive Nginx virtual host configuration file.
  3. Remove or archive site INI file.
  4. Validate configuration syntax (`nginx -t`).
  5. Reload Nginx and update SQLite record status to `removed` or purge from database.

### 2.5 `nginx list`
- **Syntax:** `nginx list [options]` (Alias: `ls`)
- **Purpose:** Tabulates all managed domains and subdomains from the SQLite database.
- **Output Columns:**
  - `Domain`: Domain name.
  - `Type`: Site type (`static`, `php`, `proxy`, `laravel`, `wordpress`).
  - `Port`: Bound listening port.
  - `Root`: Document root path.
  - `SSL`: Boolean (`enabled` / `disabled`).
  - `Status`: Operational status (`active`, `inactive`, `error`).

### 2.6 `nginx ini`
- **Syntax:** `nginx ini [options]`
- **Purpose:** Displays master and per-site INI configuration states, and provides bidirectional synchronization.
- **Options:**
  - `-Sync` / `--sync`: Detects drift between INI files on disk and SQLite database records, reconciling changes into SQLite.
  - `-Domain <domain>` / `--domain <domain>`: Inspect the INI configuration for a specific site.

### 2.7 `nginx showcase`
- **Syntax:** `nginx showcase`
- **Purpose:** Runs an end-to-end automated demonstration of the domain management architecture across 5 execution phases:
  - **Phase 1:** Display initial SQLite database records and INI state.
  - **Phase 2:** Register test apex domain (`showcase-test.local`) and test subdomain (`api.showcase-test.local`).
  - **Phase 3:** Display mutated SQLite table and newly generated INI configuration files.
  - **Phase 4:** Display compiled Nginx virtual host configurations and verify configuration syntax.
  - **Phase 5:** Safely clean up test domains, restore original state, and confirm zero pollution.
- **Exit Codes:** `0` on successful completion of all 5 phases.

---

## 3. Data Persistence Contracts

### 3.1 SQLite Schema (`nginx-domains.sqlite3`)
- **Table: `domains`**
  - `id`: INTEGER PRIMARY KEY AUTOINCREMENT
  - `domain`: TEXT UNIQUE NOT NULL
  - `type`: TEXT NOT NULL DEFAULT 'static'
  - `port`: INTEGER NOT NULL DEFAULT 80
  - `root_path`: TEXT NOT NULL
  - `php_upstream`: TEXT
  - `proxy_upstream`: TEXT
  - `ssl_enabled`: INTEGER NOT NULL DEFAULT 0
  - `subdomain_of`: TEXT
  - `status`: TEXT NOT NULL DEFAULT 'active'
  - `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
  - `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

- **Table: `domain_history`**
  - `id`: INTEGER PRIMARY KEY AUTOINCREMENT
  - `domain`: TEXT NOT NULL
  - `action`: TEXT NOT NULL
  - `details`: TEXT
  - `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 3.2 INI Configuration File Structure
- Master INI: `domains.ini` (Windows) / `sites.ini` (Linux)
- Per-Site INI: `sites.d/<domain>.ini`
- Sections:
  - `[site]`: domain, type, port, root, status
  - `[upstream]`: php_fastcgi, proxy_pass
  - `[ssl]`: enabled, cert, key
