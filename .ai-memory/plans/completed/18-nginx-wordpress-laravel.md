# Master Plan 18: Cross-Platform Nginx, WordPress, and Laravel Installation & Configuration Suite

> **Prompt Version:** 2.1.0  
> **Status:** COMPLETED  
> **Target Platforms:** Linux (Ubuntu/Debian) & Windows (PowerShell/Chocolatey)

---

## 1. Executive Summary

This master plan establishes the complete enterprise web stack tooling across the toolkit:
1. **Nginx Web Server** (`76-install-nginx`):
   - Linux: Standalone Nginx installation with modular `/etc/nginx/snippets/` (security headers, FastCGI buffers, static cache, SSL), and CLI site manager (`sites`, `enable-site`, `disable-site`, `reload`).
   - Windows: Chocolatey/portable install, FastCGI loopback wiring to `127.0.0.1:9000`, PHP-CGI daemon, port detection, and service management.
2. **WordPress LEMP Stack** (`70-install-wordpress` / `70-install-wordpress-ubuntu`):
   - Linux: Nginx component hardening (block script execution in uploads, protect sensitive files, XML-RPC protection, FastCGI microcaching, multisite rewrites).
   - Windows: Native Windows WordPress installer matching Linux capabilities (MySQL DB/user setup, PHP extensions, archive download with SHA1/MD5 verification, live salt injection, `wp-config.php`, Nginx vhost wiring).
3. **Laravel Ecosystem** (`77-install-laravel-ubuntu` & `77-install-laravel`):
   - Linux & Windows: Composer 2 installation with cryptographic integrity verification, PHP 8.2+ runtime & extension matrix (`pdo_mysql`, `mbstring`, `bcmath`, `xml`, `curl`, `zip`, etc.), project scaffolding, `.env` configuration, `artisan key:generate`, `storage:link`, database migrations, systemd queue worker & cron scheduler daemons (Linux), and hardened Nginx vhost with strict root isolation to `/public`.
4. **Tooling & Dispatchers**:
   - `registry.yaml` updated with IDs `76`, `77`, and Windows `70`. Generated registries synced via `bun tools/registry-sync.cjs`.
   - `scripts/shared/install-keywords.json` updated with keywords (`nginx`, `wordpress`, `laravel`, `lemp`, `composer`, etc.).
   - `scripts-linux/run.sh` & `run.ps1` dispatchers equipped with top-level commands and CLI options.
   - `scripts-linux/86-change-port-nginx` upgraded to support multi-vhost port changes safely.

---

## 2. Task-Specific Rule Set (Custom Constraints)

1. **Rule C1 (Laravel Webroot Isolation)**: In all Nginx vhosts generated for Laravel, `root` MUST point to the application's `public/` directory (e.g. `/var/www/<app>/public`). It is strictly prohibited to point `root` to the project root.
2. **Rule C2 (Cryptographic Integrity)**: All remote archive downloads (WordPress archive, Composer installer) MUST verify checksums (SHA-384 for Composer, SHA1 and MD5 for WordPress) before extraction.
3. **Rule C3 (Upload Execution Barrier)**: Web server configurations for WordPress and Laravel MUST explicitly forbid executing script interpreters (`.php`, `.phtml`, `.sh`, `.py`) in user-writable directories (`wp-content/uploads/`, `storage/app/public/`).
4. **Rule C4 (Non-Destructive Vhost Coexistence)**: Nginx installations and vhost creations MUST NOT destructively delete other virtual hosts without verification. If port 80 is occupied, default sites must be disabled gracefully.
5. **Rule C5 (CODE RED Compliance & Relative Paths)**: Every file error or execution failure must report exact path and reason via `log_file_error` / `Write-FileError`. All referenced file links must be relative to repository root.

---

## 3. Subtask Decomposition Index

- [x] `01-task.md`: Standalone Nginx Suite on Linux (`scripts-linux/76-install-nginx/`)
- [x] `02-task.md`: Multi-Vhost Port Changer Enhancement (`scripts-linux/86-change-port-nginx/`)
- [x] `03-task.md`: WordPress Nginx Hardening & Advanced Options on Linux (`scripts-linux/70-install-wordpress-ubuntu/`)
- [x] `04-task.md`: Full Laravel Stack on Linux (`scripts-linux/77-install-laravel-ubuntu/`)
- [x] `05-task.md`: Windows Nginx, WordPress, and Laravel Suites (`scripts/76-install-nginx/`, `scripts/70-install-wordpress/`, `scripts/77-install-laravel/`)
- [x] `06-task.md`: Master Registry, Keywords, and Root Dispatcher Integration (`registry.yaml`, `install-keywords.json`, `run.sh`, `run.ps1`)
