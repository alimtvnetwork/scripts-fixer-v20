# Plan 18: Standalone Nginx, Full Laravel Stack, and Hardened WordPress Integration for Linux

> **Document Type:** Architectural Design & Technical Specification  
> **Target Status:** Pending Implementation  
> **Affected Toolkit Components:**  
> - `scripts-linux/76-install-nginx/` (New Standalone Nginx Suite)  
> - `scripts-linux/77-install-laravel-ubuntu/` (New Full Laravel Stack Installer)  
> - `scripts-linux/70-install-wordpress-ubuntu/` (Nginx Component Hardening & Multisite/Cache Upgrades)  
> - `scripts-linux/86-change-port-nginx/` (Multi-Vhost Port Changer Enhancement)  
> - `scripts-linux/run.sh` (Root Dispatchers & CLI Passthroughs)  
> - `registry.yaml` (Single Source of Truth Script Registry)  
> - `scripts-linux/_shared/` (Webserver Helpers & Snippets)

---

## 0. Executive Mandate & Architectural Vision

The Linux administration toolkit requires high-performance, modular, production-ready web serving capabilities. Currently, Nginx is treated as an embedded child component inside `70-install-wordpress-ubuntu`, leaving the toolkit without a standalone Nginx server, without a Laravel stack, and with an unhardened, single-site WordPress vhost.

This specification establishes three decoupled yet harmonious architectural pillars:
1. **Pillar 1: Standalone Nginx (`76-install-nginx`)** — Independent web server engine with tuned global worker configurations, modular `/etc/nginx/snippets/` library (security headers, FastCGI buffers, TLS hardening, static cache), and a declarative CLI site-manager (`sites`, `enable-site`, `disable-site`, `test`, `reload`).
2. **Pillar 2: Full Laravel Stack (`77-install-laravel-ubuntu`)** — Automated deployment of modern Laravel (10/11/12) on Nginx + PHP-FPM + DB (MySQL / MariaDB / PostgreSQL / SQLite). Handles Composer 2 installation with SHA-384 verification, document root isolation to `/public`, Artisan lifecycle automation, systemd queue worker daemons, and cron scheduling.
3. **Pillar 3: Hardened WordPress Nginx Integration (`70-install-wordpress-ubuntu`)** — Upgraded `components/nginx.sh` supporting FastCGI microcaching, Redis page caching, subdirectory/subdomain multisite rewrites, strict execution blacklists on `wp-content/uploads/`, and XML-RPC mitigation.
4. **Parity & System Upgrades:**
   - `86-change-port-nginx` enhanced to handle multi-vhost port changes safely without crashing when `sites-enabled/default` is disabled.
   - `registry.yaml` updated with IDs `76` and `77` in Phase `14`.
   - `scripts-linux/run.sh` equipped with first-class top-level passthroughs: `nginx`, `laravel`, and enhanced `wordpress`.

---

## 1. Mental Model & Invariants

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                          scripts-linux/run.sh                               │
│        (Root dispatcher: --list, health doctor, parallel runner)            │
└──────┬──────────────────────┬────────────────────────┬──────────────────────┘
       │                      │                        │
       ▼                      ▼                        ▼
┌──────────────┐      ┌──────────────┐         ┌──────────────┐
│      76      │      │      70      │         │      77      │
│  Standalone  │      │  WordPress   │         │   Laravel    │
│    Nginx     │      │ Full Stack   │         │  Full Stack  │
└──────┬───────┘      └──────┬───────┘         └──────┬───────┘
       │                     │                        │
       │ installs & tunes    │ generates vhost        │ generates vhost
       │ /etc/nginx/         │ wordpress.conf         │ <app>.conf
       ▼                     ▼                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                       System Nginx Web Server (/etc/nginx/)                 │
│  ├── nginx.conf (worker_processes auto, client_max_body_size 64M, gzip)     │
│  ├── snippets/                                                              │
│  │   ├── scripts-fixer-security.conf (nosniff, SAMEORIGIN, CSP baseline)   │
│  │   ├── scripts-fixer-fastcgi.conf  (buffers, timeouts, socket proxy)      │
│  │   ├── scripts-fixer-static.conf   (expires 30d, cache-control immutable) │
│  │   └── scripts-fixer-ssl.conf      (TLSv1.2/1.3, modern ciphers, HSTS)    │
│  ├── sites-available/ (default, wordpress.conf, laravel-app.conf)           │
│  └── sites-enabled/   (active symlinks)                                     │
└─────────────────────────────────────────────────────────────────────────────┘
       │                                              │
       ▼                                              ▼
┌──────────────────────────────┐              ┌───────────────────────────────┐
│     PHP-FPM Runtime Pool     │              │       Database Services       │
│  /run/php/php{ver}-fpm.sock  │              │  MySQL (18) / MariaDB (19)    │
│  (PHP 8.1 / 8.2 / 8.3 / 8.4) │              │  PostgreSQL (20) / SQLite (21)│
└──────────────────────────────┘              └───────────────────────────────┘
```

### Architectural Invariants:
| # | Invariant | Enforcement Rule |
|---|---|---|
| **I1** | **Root Isolation** | In Laravel, Nginx `root` MUST point to `/path/to/app/public`. Pointing to project root is a fatal security flaw that exposes `.env` and source code. |
| **I2** | **Upload Execution Denial** | Nginx MUST explicitly block script execution (`.php`, `.phtml`, `.sh`, `.py`) in `/wp-content/uploads/` and Laravel `storage/app/public/`. |
| **I3** | **Zero Config Loss on Re-run** | All vhost generation and port change edits must create timestamped backups (`.bak.<timestamp>`) and test syntax (`nginx -t`) before activating. |
| **I4** | **Shared Nginx Coexistence** | Standalone Nginx acts as the primary web host. Multiple WordPress instances and Laravel applications can coexist on the same box using distinct `server_name` or listening ports. |
| **I5** | **CODE RED Observability** | Missing paths, invalid sockets, or template failures must log exact absolute paths and reasons via `log_file_error` and abort safely without corrupting systemd units. |

---

## 2. Pillar 1: Standalone Nginx Suite (`scripts-linux/76-install-nginx`)

### 2.1 File & Directory Layout
```text
scripts-linux/76-install-nginx/
├── config.json              # Port defaults, worker settings, timeouts
├── manifest.json            # Schema 1.0, phase 14, idempotent=true
├── readme.txt               # Operator documentation and examples
├── run.sh                   # Main entrypoint & CLI verb handler
├── snippets/                # Reusable Nginx configuration templates
│   ├── security-headers.conf
│   ├── fastcgi-php.conf
│   ├── static-assets.conf
│   └── ssl-params.conf
└── templates/
    ├── default-site.conf    # Clean fallback default server block
    └── proxy-vhost.conf     # Reverse proxy template for Node/Go/Docker
```

### 2.2 Core Engine Tuning (`/etc/nginx/nginx.conf`)
The installer patches or verifies `/etc/nginx/nginx.conf` with production-grade defaults:
- `worker_processes auto;` & `worker_rlimit_nofile 65535;`
- `events { worker_connections 4096; multi_accept on; }`
- `http { ... }`:
  - `sendfile on; tcp_nopush on; tcp_nodelay on;`
  - `server_tokens off;` (Hides Nginx version in HTTP headers and default error pages)
  - `client_max_body_size 64M;` (Allows standard WordPress/Laravel media uploads)
  - `keepalive_timeout 65;`
  - `gzip on; gzip_comp_level 5; gzip_min_length 256;`
  - Gzip MIME types: `application/javascript`, `application/json`, `application/xml`, `text/css`, `text/plain`, `image/svg+xml`.

### 2.3 Modular Snippet Library (`/etc/nginx/snippets/`)
Installed to `/etc/nginx/snippets/` for consumption by any site:
1. **`scripts-fixer-security.conf`**:
   ```nginx
   add_header X-Frame-Options "SAMEORIGIN" always;
   add_header X-Content-Type-Options "nosniff" always;
   add_header X-XSS-Protection "1; mode=block" always;
   add_header Referrer-Policy "strict-origin-when-cross-origin" always;
   ```
2. **`scripts-fixer-static.conf`**:
   ```nginx
   location ~* \.(jpg|jpeg|gif|png|webp|svg|ico|css|js|woff2?|eot|ttf|otf)$ {
       expires 30d;
       access_log off;
       log_not_found off;
       add_header Cache-Control "public, max-age=2592000, immutable";
   }
   ```
3. **`scripts-fixer-fastcgi.conf`**:
   ```nginx
   fastcgi_split_path_info ^(.+\.php)(/.+)$;
   fastcgi_index index.php;
   include fastcgi_params;
   fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
   fastcgi_param DOCUMENT_ROOT $realpath_root;
   fastcgi_buffer_size 128k;
   fastcgi_buffers 4 256k;
   fastcgi_busy_buffers_size 256k;
   fastcgi_read_timeout 120s;
   fastcgi_hide_header X-Powered-By;
   ```

### 2.4 CLI Verbs & Site Management Surface
`scripts-linux/76-install-nginx/run.sh` supports:
- `install` — Installs Nginx via APT, tunes `nginx.conf`, installs snippets, enables systemd service, validates with `nginx -t`.
- `check` — Doctor probe: binary present, systemctl active, `nginx -t` exits 0, port 80/configured listening.
- `repair` — Re-applies configuration snippets and restores systemd unit.
- `uninstall` — Stops service, removes package (with confirmation), cleans install markers.
- `status` — Prints human-readable service status, active worker count, and listening ports.
- `test` — Wraps `sudo nginx -t` with clean logging.
- `reload` — Validates config first (`nginx -t`); only reloads if valid.
- `sites` — Lists all sites in `sites-available` and marks which are enabled in `sites-enabled`.
- `enable-site <name>` — Symlinks `/etc/nginx/sites-available/<name>` to `sites-enabled/` and reloads.
- `disable-site <name>` — Removes symlink from `sites-enabled/` and reloads.
- `create-site <name> --type static|proxy --root <path>|--proxy-pass <url> --server-name <domain>` — Generates a new vhost.

---

## 3. Pillar 2: Full Laravel Stack (`scripts-linux/77-install-laravel-ubuntu`)

### 3.1 File & Directory Layout
```text
scripts-linux/77-install-laravel-ubuntu/
├── components/
│   ├── composer.sh          # Composer 2 installer & SHA-384 verifier
│   ├── daemon.sh            # Systemd queue worker & cron scheduler setup
│   ├── database.sh          # MySQL/PgSQL/SQLite automated provisioning
│   ├── firewall.sh          # UFW port configuration
│   ├── https.sh             # Certbot HTTP-01 & DNS-01 SSL automation
│   ├── laravel.sh           # Project scaffolding, .env, artisan key/link/cache
│   ├── nginx.sh             # Hardened Laravel Nginx vhost generator
│   ├── php.sh               # PHP-FPM 8.2/8.3/8.4 & extension matrix
│   └── postinstall-verify.sh # 4-gate verification engine
├── config.json              # Defaults for PHP version, DB engine, docroot
├── manifest.json            # Schema 1.0, phase 14, idempotent=true
├── readme.txt               # Operator cheat sheet
└── run.sh                   # Main orchestrator & CLI parser
```

### 3.2 PHP Runtime & Extension Requirements
Laravel 11+ requires PHP >= 8.2 (PHP 8.3 recommended). The PHP component provisions:
- Core: `php8.3-cli`, `php8.3-fpm`, `php8.3-common`
- Database PDO: `php8.3-mysql`, `php8.3-pgsql`, `php8.3-sqlite3`
- Framework Core: `php8.3-bcmath`, `php8.3-curl`, `php8.3-mbstring`, `php8.3-xml` (dom, simplexml), `php8.3-zip`, `php8.3-intl`, `php8.3-soap`
- Performance & Caching: `php8.3-opcache`, `php8.3-redis`
- Media: `php8.3-gd`, `php8.3-imagick`

### 3.3 Composer 2 Cryptographic Installation (`components/composer.sh`)
```bash
# 1. Fetch expected SHA-384 signature
EXPECTED_SIGNATURE="$(curl -fsSL https://composer.github.io/installer.sig | tr -d '[:space:]')"
# 2. Download official installer
curl -fsSL https://getcomposer.org/installer -o /tmp/composer-setup.php
# 3. Verify SHA-384 hash
ACTUAL_SIGNATURE="$(sha384sum /tmp/composer-setup.php | awk '{print $1}')"
if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    log_file_error "/tmp/composer-setup.php" "Composer installer SHA-384 mismatch (corrupted or intercepted)"
    rm -f /tmp/composer-setup.php; return 1
fi
# 4. Install globally
sudo php /tmp/composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer
rm -f /tmp/composer-setup.php
```

### 3.4 Multi-Database Automation Matrix (`components/database.sh`)
Supports 4 database backends selectable via `--db mysql|mariadb|pgsql|sqlite`:
1. **MySQL / MariaDB**:
   - Creates database `CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
   - Creates user `'${DB_USER}'@'localhost'` and grants privileges.
2. **PostgreSQL**:
   - Installs `postgresql` via script `20-install-postgresql`.
   - Creates database and user: `CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASS}'; CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};`
3. **SQLite**:
   - Zero-server, file-based database:
     `touch /var/www/<app>/database/database.sqlite`
   - Strict permissions: `chown -R www-data:www-data /var/www/<app>/database` and `chmod 664 /var/www/<app>/database/database.sqlite`.

### 3.5 Laravel Scaffolding & Artisan Automation (`components/laravel.sh`)
Supports 3 project provisioning modes:
- **Mode A: `create-project` (Default)** — Runs `composer create-project laravel/laravel:^11.0 <install_path> --prefer-dist --no-interaction`.
- **Mode B: `git-clone` (`--git <repo_url>`)** — Clones repository, runs `composer install --no-dev --optimize-autoloader`.
- **Mode C: `existing-path` (`--path <dir>`)** — Adopts existing Laravel code at directory.

**Lifecycle Steps:**
1. Generate `.env` from template with DB connection parameters populated.
2. Run `php artisan key:generate --force`.
3. Set file ownership: `sudo chown -R www-data:www-data "$INSTALL_PATH"`.
4. Set permissions: directories `755`, files `644`, and writable dirs:
   `chmod -R 775 "$INSTALL_PATH/storage" "$INSTALL_PATH/bootstrap/cache"`.
5. Run migrations: `php artisan migrate --force` (skipped if `--skip-migrate` is set).
6. Create public storage symlink: `php artisan storage:link`.
7. Cache configuration for production:
   `php artisan config:cache && php artisan route:cache && php artisan view:cache`.

### 3.6 Background Daemons (`components/daemon.sh`)
1. **Systemd Queue Worker** (`/etc/systemd/system/laravel-queue@<app>.service`):
   ```ini
   [Unit]
   Description=Laravel Queue Worker [%i]
   After=network.target

   [Service]
   Type=simple
   User=www-data
   Group=www-data
   Restart=always
   RestartSec=5s
   ExecStart=/usr/bin/php /var/www/%i/artisan queue:work --sleep=3 --tries=3 --max-time=3600 --timeout=90

   [Install]
   WantedBy=multi-user.target
   ```
2. **Cron Task Scheduler** (`/etc/cron.d/laravel-<app>`):
   ```cron
   * * * * * www-data cd /var/www/<app> && /usr/bin/php artisan schedule:run >> /dev/null 2>&1
   ```

### 3.7 Hardened Laravel Nginx Virtual Host
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name laravel.example.com;
    root /var/www/my-app/public;

    index index.php index.html;
    charset utf-8;

    include snippets/scripts-fixer-security.conf;
    include snippets/scripts-fixer-static.conf;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        include snippets/scripts-fixer-fastcgi.conf;
    }

    # Strict file denial
    location ~ /\.(?!well-known).* { deny all; }
    location ~ (^|/)(artisan|\.env|composer\.(json|lock)|package(-lock)?\.json|phpunit\.xml) {
        deny all;
        return 404;
    }
}
```

### 3.8 Strict 4-Gate Post-Install Verification
Returns `rc=0` only if all 4 gates pass:
1. **Gate 1: Web Vhost** — `nginx -t` passes and symlink exists in `sites-enabled/`.
2. **Gate 2: PHP-FPM Socket** — FastCGI handshake or AF_UNIX connection succeeds on `/run/php/php8.3-fpm.sock`.
3. **Gate 3: Database Connection** — `php artisan tinker --execute="DB::connection()->getPdo();"` exits 0.
4. **Gate 4: HTTP 200 Probe** — `curl -s -o /dev/null -w "%{http_code}" http://localhost:<port>/` returns 200 (or 301/302 when HTTPS redirect active).

---

## 4. Pillar 3: WordPress Nginx Integration Hardening (`scripts-linux/70-install-wordpress-ubuntu`)

### 4.1 Upgrades to `components/nginx.sh`
The existing WordPress Nginx component will be upgraded with the following enterprise features:

1. **Upload Execution Prevention:**
   ```nginx
   # Block direct execution of PHP files inside user upload/cache directories
   location ~* /(?:uploads|files|wp-content/cache)/.*\.php$ {
       deny all;
       return 404;
   }
   ```
2. **Sensitive File Protections:**
   ```nginx
   location ~* (wp-config\.php|\.htaccess|\.user\.ini|readme\.html|license\.txt) {
       deny all;
       return 404;
   }
   ```
3. **Configurable XML-RPC Protection (`--protect-xmlrpc` flag):**
   ```nginx
   location = /xmlrpc.php {
       deny all;
       access_log off;
       log_not_found off;
       return 403;
   }
   ```
4. **Multisite Rewrite Support:**
   - **Subfolder Multisite (`--multisite-subfolder`):**
     ```nginx
     if (!-e $request_filename) {
         rewrite /wp-admin$ $scheme://$host$uri/ permanent;
         rewrite ^/[_0-9a-zA-Z-]+(/wp-.*) $1 last;
         rewrite ^/[_0-9a-zA-Z-]+(/.*\.php)$ $1 last;
     }
     ```
   - **Subdomain Multisite (`--multisite-subdomain`):**
     Generates wildcard `server_name example.com *.example.com;` and binds with DNS-01 wildcard SSL cert from `components/https.sh`.
5. **FastCGI Microcaching Layer (`--cache fastcgi`):**
   - Configures `fastcgi_cache_path /var/run/nginx-cache levels=1:2 keys_zone=WORDPRESS:100m inactive=60m;`
   - Bypasses cache when cookies match `comment_author|wordpress_logged_in|woocommerce_items_in_cart` or request method is POST.
   - Adds diagnostic header: `add_header X-Cache-Status $upstream_cache_status;`.
6. **Graceful Default Site Coexistence:**
   - Instead of indiscriminately executing `rm -f /etc/nginx/sites-enabled/default`, check if the default site is port-conflicted. If port 80 is claimed by the new WordPress vhost, gracefully disable default or move it to a fallback catch-all.

---

## 5. Port Management Parity (`scripts-linux/86-change-port-nginx`)

### 5.1 The Defect in the Current Implementation
Currently, `scripts-linux/86-change-port-nginx/run.sh` contains:
```bash
PC_EDIT_SPECS=(
    "/etc/nginx/sites-enabled/default|||listen[[:space:]]\+[0-9]\+\([[:space:]]\+default_server\)\?;|||listen {PORT};"
)
```
If `default` was removed or disabled (standard procedure in script 70 and 77), `_pc_backup_file` fails immediately with a fatal CODE RED error.

### 5.2 The Enhanced Multi-Vhost Engine
Upgrade `86-change-port-nginx` to support targeted and multi-vhost port shifting:
1. **Site Targeting Flag (`--site <name>`):**
   - Allows changing the port of a specific site: e.g. `./run.sh 86 --site wordpress --port 8080`.
   - Resolves `/etc/nginx/sites-enabled/<name>` (or `sites-available/<name>`).
2. **Auto-Discovery Fallback:**
   - If `--site` is omitted and `/etc/nginx/sites-enabled/default` is missing, scan `/etc/nginx/sites-enabled/*` for files containing active `listen` directives.
   - If exactly one enabled vhost exists (e.g. `wordpress.conf`), select it automatically.
   - If multiple exist, prompt interactively or require `--site <name>`.
3. **IPv4 and IPv6 Dual Rewrite:**
   ```bash
   PC_EDIT_SPECS=(
       "$TARGET_FILE|||listen[[:space:]]\+[0-9]\+;|||listen {PORT};"
       "$TARGET_FILE|||listen[[:space:]]\+\[::\]:[0-9]\+;|||listen [::]:{PORT};"
   )
   ```

---

## 6. Root Dispatcher & Registry Integration

### 6.1 `registry.yaml` Registration
Add the following entries under `scripts:` in `registry.yaml`:
```yaml
  - id: '76'
    linux:
      folder: 76-install-nginx
      phase: '14'
      title: Nginx standalone web server (HTTP/HTTPS, modular snippets, multi-site manager)
    macos:
      folder: 76-install-nginx
      phase: '14'
      title: Nginx standalone web server (HTTP/HTTPS, modular snippets, multi-site manager)
  - id: '77'
    linux:
      folder: 77-install-laravel-ubuntu
      phase: '14'
      title: Ubuntu Laravel stack installer (Nginx + PHP-FPM + MySQL/PgSQL/SQLite + Composer + artisan)
    macos:
      folder: 77-install-laravel-ubuntu
      phase: '14'
      title: Ubuntu Laravel stack installer (Nginx + PHP-FPM + MySQL/PgSQL/SQLite + Composer + artisan)
```
Run `node tools/registry-sync.cjs` to propagate to `scripts-linux/registry.json`.

### 6.2 `scripts-linux/run.sh` Top-Level Passthroughs
Add top-level shortcuts in `scripts-linux/run.sh` to match existing `wp-passthrough`:
```bash
    # Standalone Nginx passthrough
    nginx)
        VERB="nginx-passthrough"; NGINX_SUB="install"; shift; NGINX_REST=("$@"); break ;;
    # Laravel stack passthrough
    laravel)
        VERB="laravel-passthrough"; LARAVEL_SUB="install"; shift; LARAVEL_REST=("$@"); break ;;
```
And handle execution blocks:
```bash
  nginx-passthrough)
    _ng_filtered=()
    for _a in "${NGINX_REST[@]:-}"; do [ -n "$_a" ] && _ng_filtered+=("$_a"); done
    bash "$ROOT/76-install-nginx/run.sh" "$NGINX_SUB" "${_ng_filtered[@]}"
    ;;
  laravel-passthrough)
    _lar_filtered=()
    for _a in "${LARAVEL_REST[@]:-}"; do [ -n "$_a" ] && _lar_filtered+=("$_a"); done
    bash "$ROOT/77-install-laravel-ubuntu/run.sh" "$LARAVEL_SUB" "${_lar_filtered[@]}"
    ;;
```

### 6.3 Doctor & Health Check Integration (`_shared/doctor.sh`)
- Script 76 writes install marker `$ROOT/.installed/76.ok` on successful install.
- Script 77 writes install marker `$ROOT/.installed/77.ok` on successful install.
- When `run.sh health` runs, `doctor_state` automatically verifies both IDs using their native `check` verbs.

---

## 7. Implementation Subtask Breakdown

- **Subtask 18.1: Standalone Nginx Suite (`scripts-linux/76-install-nginx`)**
- **Subtask 18.2: Port Changer Multi-Vhost Upgrade (`scripts-linux/86-change-port-nginx`)**
- **Subtask 18.3: WordPress Nginx Hardening & Options (`scripts-linux/70-install-wordpress-ubuntu`)**
- **Subtask 18.4: Full Laravel Stack Installer (`scripts-linux/77-install-laravel-ubuntu`)**
- **Subtask 18.5: Registry & Root Dispatcher Integration (`registry.yaml` & `scripts-linux/run.sh`)**
