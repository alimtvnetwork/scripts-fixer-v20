# Plan 19: Nginx Domain Manager with SQLite & INI Architecture for Linux

> **Document Type:** Architectural Design & Technical Implementation Plan  
> **Target Status:** Pending Implementation  
> **File Target:** `.lovable/plans/pending/19-nginx-domain-manager-sqlite-linux.md`  
> **Affected Toolkit Components:**  
> - `scripts-linux/76-install-nginx/` (Core Nginx & Domain Manager Suite)  
>   - `scripts-linux/76-install-nginx/run.sh` (Main CLI Router & Entrypoint)  
>   - `scripts-linux/76-install-nginx/modules/db_engine.sh` (SQLite3 / Python3 Fallback Engine)  
>   - `scripts-linux/76-install-nginx/modules/ini_engine.sh` (Per-Site & Master INI Generator/Parser)  
>   - `scripts-linux/76-install-nginx/modules/vhost_engine.sh` (Vhost Templating & Verification)  
>   - `scripts-linux/76-install-nginx/modules/domain_manager.sh` (Add, Remove, List, Enable, Disable)  
>   - `scripts-linux/76-install-nginx/modules/showcase.sh` (Tri-State Before/After Visualizer)  
>   - `scripts-linux/76-install-nginx/templates/` (Static, PHP-FPM, Proxy Vhost Templates)  
> - `scripts-linux/run.sh` (Linux Root Dispatcher & `nginx-passthrough`)  
> - `scripts/run.sh` (Universal Root Dispatcher Forwarder)  
> - `registry.yaml` & `scripts-linux/registry.json` (Registry Metadata)  

---

## 0. Executive Mandate & Architectural Vision

Managing virtual hosts manually via raw text editing in `/etc/nginx/sites-available/` is prone to human error, syntax drift, port collisions, and lack of auditability. 

This specification establishes an **Enterprise-Grade, Tri-State Nginx Domain Management System** for Linux:
1. **Tri-State Synchronization Engine:** Maintains strict, bidirectional consistency across three distinct architectural layers:
   - **Layer 1: Relational Database (SQLite3):** Structured single source of truth for programmatic queries, filtering, port validation, metadata tracking, and audit logging (`domain_history`).
   - **Layer 2: Declarative INI Files (`sites.d/<domain>.ini` & `sites.ini`):** Human-readable, version-controllable, filesystem-based configuration declarations.
   - **Layer 3: Nginx Virtual Hosts (`/etc/nginx/sites-available/` & `sites-enabled/`):** Hardened, production-grade server blocks utilizing modular snippets (`security-headers`, `fastcgi-php`, `static-assets`, `ssl-params`).
2. **Top-Level CLI Surface:** Seamless integration into `./run.sh nginx` allowing operators to install, add domains/subdomains, delete domains, list managed vhosts, and inspect INI states.
3. **Zero-Dependency Dual-Engine SQLite:** Seamlessly leverages the native `sqlite3` CLI if installed; otherwise automatically falls back to standard `python3 sqlite3` without requiring package installations or Python pip dependencies.
4. **Showcase & Observability:** An interactive/non-interactive demonstration engine rendering the exact **BEFORE vs AFTER** state across SQLite, INI files, and Nginx vhost configurations.

---

## 1. Mental Model & Architectural Invariants

### 1.1 The Tri-State Architecture Model

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Root Dispatcher: ./run.sh                          │
│         (scripts/run.sh  ──delegates──►  scripts-linux/run.sh nginx)         │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                scripts-linux/76-install-nginx/run.sh                         │
│           (CLI Parser: install, help, add, rm, list, showcase, ini)          │
└──────────────┬───────────────────────┬───────────────────────┬──────────────┘
               │                       │                       │
               ▼                       ▼                       ▼
      ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
      │  modules/       │     │  modules/       │     │  modules/       │
      │  db_engine.sh   │     │  ini_engine.sh  │     │  vhost_engine.sh│
      └────────┬────────┘     └────────┬────────┘     └────────┬────────┘
               │                       │                       │
               │ Dual Engine           │ Declarative           │ Nginx Config &
               │ sqlite3 / python3     │ Sync Engine           │ Syntax Validator
               ▼                       ▼                       ▼
┌─────────────────────────┐ ┌─────────────────────┐ ┌─────────────────────────┐
│     STATE 1: SQLITE     │ │    STATE 2: INI     │ │     STATE 3: VHOST      │
│ /var/lib/scripts-fixer/ │ │ /etc/nginx/sites.d/ │ │ /etc/nginx/             │
│ nginx-domains.sqlite3   │ │ ├── <domain>.ini    │ │ ├── sites-available/   │
│ ├── domains table       │ │ └── sites.ini       │ │ │   └── <domain>.conf   │
│ └── history audit log   │ │     (master summary)│ │ └── sites-enabled/     │
│                         │ │                     │ │     └── <domain>.conf   │
└─────────────────────────┘ └─────────────────────┘ └─────────────────────────┘
               ▲                       ▲                       ▲
               └───────────────────────┼───────────────────────┘
                                       │
                        ┌──────────────┴──────────────┐
                        │   modules/showcase.sh       │
                        │ (Before / After Inspector)  │
                        └─────────────────────────────┘
```

### 1.2 Core Architectural Invariants

| # | Invariant | Enforcement Rule |
|---|---|---|
| **I1** | **Atomic Tri-State Mutation** | Every mutation (`add`, `rm`, `update`) MUST update all three layers (SQLite, INI, Vhost). If any layer fails (e.g. `nginx -t` validation fails), all previous layers MUST cleanly rollback. |
| **I2** | **Zero-Dependency SQLite Execution** | The system MUST execute database operations via `sqlite3` CLI if installed; if absent, it MUST execute via `python3` with standard library `sqlite3`. Operations must never fail due to a missing `sqlite3` package. |
| **I3** | **Syntax Safety Gate** | No virtual host may be symlinked into `/etc/nginx/sites-enabled/` without first passing `sudo nginx -t`. Corrupt vhosts must never cause Nginx reloads to fail. |
| **I4** | **Subdomain First-Class Citizen** | Subdomains (e.g. `sub.domain.com`, `api.dev.local`) are first-class entities. The schema tracks `subdomain_of` relating subdomains to parent apex domains while maintaining isolated vhost and INI files. |
| **I5** | **Audit Trail Immutability** | Every mutation generates an immutable record in `domain_history` containing domain, action, diff summary, timestamp, and system operator. |
| **I6** | **Purge Isolation & Data Safety** | Removing a domain (`rm <domain>`) removes configuration files and disables the vhost. Document root deletion requires explicit `--purge` and interactive confirmation (or `--yes`) to prevent accidental data loss. |

---

## 2. Command-Line Interface (CLI) Surface & Syntax

The toolkit provides first-class CLI commands directly from `./run.sh`:

### 2.1 Command Grammar & Subcommands

```text
./run.sh nginx <subcommand> [arguments] [flags]
```

| Subcommand | Alias | Description |
|---|---|---|
| `install` | `setup` | Install Nginx, deploy modular snippets, initialize SQLite DB & master INI |
| `help` | `-h`, `--help` | Show comprehensive CLI help, subcommands table, and usage examples |
| `add <domain>` | `create` | Add a new domain/subdomain with static, PHP, reverse-proxy, or SSL support |
| `rm <domain>` | `remove`, `delete`, `del` | Remove a domain's vhost, INI, and SQLite record (optional `--purge`) |
| `list` | `ls` | List all registered domains with Tri-State sync health (SQLite / INI / Vhost) |
| `showcase` | `demo` | Run before/after demonstration of SQLite, INI, and Nginx vhost changes |
| `ini` | `config` | View master `sites.ini`, inspect site INI, or reconcile tri-state drift |
| `status` | `info` | Show Nginx service status, listening sockets, and domain count |
| `test` | `check-syntax` | Run `nginx -t` validation with detailed diagnostics |
| `reload` | `restart` | Validate syntax and reload Nginx service |

### 2.2 Detailed Subcommand Specifications

#### A. `./run.sh nginx install`
- Verifies and installs `nginx` via APT or Homebrew.
- Initializes `/etc/nginx/snippets/` (`scripts-fixer-security.conf`, `scripts-fixer-fastcgi.conf`, `scripts-fixer-static.conf`, `scripts-fixer-ssl.conf`).
- Tunes core `/etc/nginx/nginx.conf` (`worker_processes auto`, `server_tokens off`, `client_max_body_size 64M`, `gzip on`).
- Initializes database directory `/var/lib/scripts-fixer/` and creates SQLite tables (`domains`, `domain_history`, `domain_settings`).
- Initializes INI directory `/etc/nginx/sites.d/` and generates initial master `/etc/nginx/sites.ini`.
- Enables and starts `nginx` systemd service; writes `$ROOT/.installed/76.ok`.

#### B. `./run.sh nginx help` (and `./run.sh nginx`)
- Executing `./run.sh nginx` with no arguments or with `help` prints the full operator cheat sheet.
- Features formatted ANSI color coding (`PRIMARY` green, `SECONDARY` cyan, `ACCENT` yellow, `MUTED` gray).
- Displays quick status summary (Nginx version, active domains count, SQLite status).

#### C. `./run.sh nginx add <domain> [flags]`
- **Positional Argument:** `<domain>` (e.g. `example.com`, `sub.domain.com`, `api.dev.test`).
- **Flags:**
  - `--type <static|php|proxy>`: Vhost engine type. Defaults to `static` if omitted (or auto-detected from other flags).
  - `--port <port>`: Listening HTTP port (default: `80`, or custom e.g. `8080`, `3000`).
  - `--root <path>`: Document root path. Default: `/var/www/<domain>/public` or `/var/www/<domain>/html`.
  - `--php [version|socket]`: Enable PHP FastCGI. If no version is specified, auto-discovers newest PHP-FPM socket (e.g. `/run/php/php8.3-fpm.sock`). Automatically sets `--type php`.
  - `--proxy <upstream_url>`: Reverse proxy target URL (e.g. `http://127.0.0.1:3000`, `http://unix:/run/app.sock`). Automatically sets `--type proxy`.
  - `--ssl`: Enable SSL/TLS. Generates self-signed dev certificate or configures Let's Encrypt certificates.
  - `--force`: Overwrite existing configuration if domain already exists.

#### D. `./run.sh nginx rm <domain> [flags]`
- **Positional Argument:** `<domain>` to remove.
- **Flags:**
  - `--purge`: In addition to removing vhost, INI, and SQLite record, prompts to permanently delete the document root directory `/var/www/<domain>`.
  - `--yes`, `-y`: Skip interactive confirmation prompt on purge.

#### E. `./run.sh nginx list [flags]`
- Aligned table listing all domains with columns:
  `DOMAIN`, `TYPE`, `PORT`, `ROOT / TARGET`, `PHP`, `SSL`, `STATUS`, `TRI-STATE HEALTH`.
- **Flags:**
  - `--json`: Output raw machine-readable JSON array.
  - `--type <static|php|proxy>`: Filter by type.

#### F. `./run.sh nginx showcase [flags]`
- Demonstrates the Tri-State synchronization engine in action.
- Displays BEFORE state (SQLite rows, INI file presence, Vhost existence).
- Adds a test domain (e.g. `showcase.example.local`).
- Displays AFTER state (new SQLite row, generated INI, complete Nginx vhost config).
- Executes test curl request and gracefully cleans up (unless `--keep` is specified).

#### G. `./run.sh nginx ini [domain] [flags]`
- Bare `./run.sh nginx ini`: Displays master `/etc/nginx/sites.ini`.
- `./run.sh nginx ini <domain>`: Dumps specific per-site INI file.
- `--sync`: Reconciles any filesystem or SQLite drift.
- `--check`: Validates INI syntax and cross-references against SQLite and vhosts.

---

## 3. SQLite Database Architecture & Dual-Engine Fallback

- **Primary Database File:** `/var/lib/scripts-fixer/nginx-domains.sqlite3`
- **Fallback Portable File:** `$ROOT/.installed/nginx-domains.sqlite3`
- **File Permissions:** `chmod 640`, owned by `root:root` (or current executing user in user-mode).
- **WAL Mode Enabled:** `PRAGMA journal_mode = WAL;` to support concurrent read operations without locking.
- **Dual-Engine Execution:** Executes via `sqlite3` CLI if available; otherwise dynamically falls back to standard Python 3 `sqlite3` module.

---

## 4. INI File Architecture & Tri-State Synchronization

- **Per-Site INI:** `/etc/nginx/sites.d/<domain>.ini` storing sectioned config (`[domain]`, `[server]`, `[web]`, `[php]`, `[proxy]`, `[ssl]`, `[vhost]`).
- **Master INI:** `/etc/nginx/sites.ini` storing global summary counters and per-site summaries (`[master]`, `[site:<domain>]`).
- **Bi-Directional Sync:** Changes in SQLite export to INI; manual edits in INI can be ingested into SQLite and recompile `.conf` files via `--sync`.

---

## 5. Verification & Quality Gates
- Smoke tests for static, PHP, and proxy vhosts.
- Syntax validation (`nginx -t`) with zero-downtime reloads.
- Dual-engine fallback verification with and without `sqlite3` binary.
