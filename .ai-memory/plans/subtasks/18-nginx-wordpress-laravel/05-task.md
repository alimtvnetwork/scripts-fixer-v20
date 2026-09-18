# Subtask 18.5: Windows Nginx, WordPress, and Laravel Suites

## Context & Objective
Implement cross-platform Windows scripts for Nginx (76), WordPress (70), and Laravel (77) under `scripts/`.

## Target Files (All relative to repository root)
- `scripts/76-install-nginx/manifest.json`
- `scripts/76-install-nginx/config.json`
- `scripts/76-install-nginx/log-messages.json`
- `scripts/76-install-nginx/readme.md`
- `scripts/76-install-nginx/run.ps1`
- `scripts/70-install-wordpress/manifest.json`
- `scripts/70-install-wordpress/config.json`
- `scripts/70-install-wordpress/log-messages.json`
- `scripts/70-install-wordpress/readme.md`
- `scripts/70-install-wordpress/run.ps1`
- `scripts/77-install-laravel/manifest.json`
- `scripts/77-install-laravel/config.json`
- `scripts/77-install-laravel/log-messages.json`
- `scripts/77-install-laravel/readme.md`
- `scripts/77-install-laravel/run.ps1`

## Requirements & Implementation Details
1. **Nginx on Windows (`scripts/76-install-nginx`)**:
   - Install via Chocolatey `nginx` or portable zip.
   - Configure `conf/nginx.conf` and FastCGI proxy to `127.0.0.1:9000`.
   - Provide daemon runner for `php-cgi.exe -b 127.0.0.1:9000`.
2. **WordPress on Windows (`scripts/70-install-wordpress`)**:
   - Match Linux Script 70 capabilities: MySQL database/user creation via `mysql.exe`, PHP extension verification (`curl`, `gd`, `mbstring`, `mysqli`, `pdo_mysql`, `zip`), WordPress zip download with SHA1/MD5 verification, live salt fetching, `wp-config.php` generation, Nginx vhost wiring, and credential storage in `.installed/70-wordpress-credentials.json`.
3. **Laravel on Windows (`scripts/77-install-laravel`)**:
   - Check/install Composer (`choco install composer`).
   - Validate PHP 8.2+ extensions.
   - Scaffold application via `composer create-project` or clone, generate `.env`, `php artisan key:generate`, `storage:link`.
   - Wire Nginx vhost pointing to `<app>\public`.
