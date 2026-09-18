# Subtask 18.4: Full Laravel Stack on Linux (`scripts-linux/77-install-laravel-ubuntu`)

## Context & Objective
Build a complete, production-ready Laravel installation and configuration suite in `scripts-linux/77-install-laravel-ubuntu`. It provisions PHP 8.2/8.3 with all required extensions, installs Composer 2 with SHA-384 verification, scaffolds or adopts Laravel applications, provisions the database, sets up background queue workers and scheduled cron tasks, and writes a hardened Nginx vhost isolating document root strictly to `/public`.

## Target Files (All relative to repository root)
- `scripts-linux/77-install-laravel-ubuntu/manifest.json`
- `scripts-linux/77-install-laravel-ubuntu/config.json`
- `scripts-linux/77-install-laravel-ubuntu/readme.txt`
- `scripts-linux/77-install-laravel-ubuntu/run.sh`
- `scripts-linux/77-install-laravel-ubuntu/components/composer.sh`
- `scripts-linux/77-install-laravel-ubuntu/components/php.sh`
- `scripts-linux/77-install-laravel-ubuntu/components/database.sh`
- `scripts-linux/77-install-laravel-ubuntu/components/laravel.sh`
- `scripts-linux/77-install-laravel-ubuntu/components/nginx.sh`
- `scripts-linux/77-install-laravel-ubuntu/components/daemon.sh`
- `scripts-linux/77-install-laravel-ubuntu/components/postinstall-verify.sh`

## Requirements & Implementation Details
1. **Composer 2 Verification (`components/composer.sh`)**:
   - Download installer, verify against official `https://composer.github.io/installer.sig` SHA-384 hash, install to `/usr/local/bin/composer`.
2. **PHP Runtime (`components/php.sh`)**:
   - Install `php-cli`, `php-fpm`, `pdo_mysql`, `pdo_pgsql`, `pdo_sqlite`, `bcmath`, `mbstring`, `xml`, `curl`, `zip`, `intl`, `redis`.
3. **Database Provisioning (`components/database.sh`)**:
   - Automate database and user creation for MySQL/MariaDB, PostgreSQL, or SQLite.
4. **Scaffolding & Lifecycle (`components/laravel.sh`)**:
   - Support `composer create-project` or existing path.
   - Configure `.env` database parameters, run `php artisan key:generate`, set ownership `www-data:www-data`, permissions `775` on `storage` and `bootstrap/cache`.
   - Run `php artisan migrate --force` and `php artisan storage:link`.
5. **Nginx Vhost (`components/nginx.sh`)**:
   - Root strictly set to `$INSTALL_PATH/public`.
   - `try_files $uri $uri/ /index.php?$query_string;`.
   - PHP-FPM FastCGI proxy with buffer tuning.
   - Deny dotfiles and sensitive files (`.env`, `artisan`, `composer.json`, `phpunit.xml`).
6. **Daemons (`components/daemon.sh`)**:
   - Provide systemd queue worker unit (`laravel-queue@<app>.service`) and crontab scheduler.
7. **Post-Install Verification (`components/postinstall-verify.sh`)**:
   - 4-gate verification: web vhost test, PHP socket check, database connection test, HTTP probe.
