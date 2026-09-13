================================================================================
Script 77 -- Ubuntu Laravel Installer (Nginx + PHP-FPM + Composer 2 + DB + Queue)
================================================================================

Modular installer that provisions and configures a complete, production-ready
Laravel application stack on Ubuntu.

Components (each is its own bash file under components/, called in order):
  1. php.sh                PHP-FPM (8.2, 8.3, or latest; adds Ondrej PPA if needed)
                           Installs required extensions: pdo_mysql, pdo_pgsql,
                           pdo_sqlite, bcmath, mbstring, xml, curl, zip, intl, redis
  2. composer.sh           Downloads Composer installer, verifies against official
                           SHA-384 signature (https://composer.github.io/installer.sig),
                           and installs to /usr/local/bin/composer
  3. database.sh           Provisions database and user credentials for MySQL/MariaDB,
                           PostgreSQL, or SQLite
  4. laravel.sh            Scaffolds application (composer create-project) or adopts
                           existing path, configures .env, runs key:generate,
                           sets www-data permissions (775 storage & bootstrap/cache),
                           executes migrations, and links public storage
  5. nginx.sh              Nginx vhost isolating document root strictly to /public,
                           fastcgi buffer tuning, blocks dotfiles, and denies direct
                           access to sensitive files (.env, artisan, composer.json, etc.)
  6. daemon.sh             Configures systemd queue worker unit (laravel-queue.service
                           and laravel-queue@.service) and crontab scheduler runner
  7. postinstall-verify.sh 4-gate verification: web vhost test, PHP socket check,
                           database connection handshake, and HTTP probe

Usage from the toolkit root (scripts-linux/):

  ./run.sh install laravel                # full stack, default settings
  ./run.sh install laravel -i             # interactive configuration wizard
  ./run.sh laravel -i                     # alias
  ./run.sh uninstall laravel              # remove app + vhost + daemons

Direct invocation supports per-component verbs:

  ./77-install-laravel-ubuntu/run.sh install               # all components
  ./77-install-laravel-ubuntu/run.sh install php           # single component
  ./77-install-laravel-ubuntu/run.sh install composer
  ./77-install-laravel-ubuntu/run.sh install database
  ./77-install-laravel-ubuntu/run.sh install laravel
  ./77-install-laravel-ubuntu/run.sh install nginx
  ./77-install-laravel-ubuntu/run.sh install daemon
  ./77-install-laravel-ubuntu/run.sh check                 # verify all components
  ./77-install-laravel-ubuntu/run.sh verify                # run 4-gate test
  ./77-install-laravel-ubuntu/run.sh repair                # wipe markers + reinstall
  ./77-install-laravel-ubuntu/run.sh show-credentials      # view saved credentials
  ./77-install-laravel-ubuntu/run.sh uninstall             # remove app stack

Flags (all optional):
  -i | --interactive          Prompt for configurable values
  --path <path>               Laravel install path (default: /var/www/laravel)
  --docroot <path>            Alias of --path
  --app-name <name>           Application name in .env (default: laravel-app)
  --site-port <n>             nginx HTTP port (default: 80)
  --server-name <name>        nginx server_name (default: localhost)
  --php <ver>                 PHP version: 8.2 | 8.3 | latest (default: 8.3)
  --db <engine>               DB engine: mysql | mariadb | pgsql | sqlite (default: mysql)
  --db-name <name>            Database name (default: laravel)
  --db-user <name>            Database user (default: laravel_user)
  --db-pass <pw>              Database password (default: auto-generated 24 chars)
  --db-host <host>            Database host (default: 127.0.0.1)
  --db-port <port>            Database port (default: 3306 or 5432)
  --queue <0|1>               Enable systemd queue worker (default: 1)
  --cron <0|1>                Enable artisan crontab scheduler (default: 1)
  --migrate <0|1>             Run php artisan migrate --force (default: 1)
  --show-credentials          Print saved DB credentials upon installation
  --json                      Emit machine-readable JSON with show-credentials

Outputs:
  .installed/77-php.ok                     marker after PHP install
  .installed/77-composer.ok                marker after Composer install
  .installed/77-database.ok                marker after Database provisioning
  .installed/77-laravel.ok                 marker after Laravel scaffolding
  .installed/77-nginx.ok                   marker after Nginx vhost install
  .installed/77-daemon.ok                  marker after Queue & Cron setup
  .installed/77-laravel-credentials.json   chmod 600, contains site URL & DB creds
  .logs/77.log                             full execution log from this script

CODE RED compliance:
Every file/path error logs `FILE-ERROR path='<exact path>' reason='<exact reason>'`
via `log_file_error` from _shared/logger.sh. Examples include Nginx vhost
write failures, Composer SHA-384 signature mismatch, missing .env files, etc.

Idempotency:
  * php.sh skips package installation if required extensions are already loaded
  * composer.sh skips download if composer binary already exists and is healthy
  * database.sh uses CREATE DATABASE IF NOT EXISTS / CREATE USER IF NOT EXISTS
  * laravel.sh detects existing applications and skips project creation
  * nginx.sh re-applies the vhost cleanly
  * daemon.sh rewrites systemd units and safely reloads systemd
