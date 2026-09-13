# Plan 18: Windows Nginx, WordPress, and Laravel Installation Suite

## Overview
This plan establishes cross-platform parity and full Windows implementation for:
1. **Nginx Web Server** (Script ID `76`: `scripts/76-install-nginx`): Windows Chocolatey / portable installation, FastCGI loopback wiring (`127.0.0.1:9000`), port detection, and background service management.
2. **WordPress LEMP Stack** (Script ID `70`: `scripts/70-install-wordpress`): Full parity with `scripts-linux/70-install-wordpress-ubuntu`, including MySQL database & user creation, PHP extension configuration, archive download with SHA1/MD5 checksum validation, salt generation, `wp-config.php` provisioning, Nginx vhost wiring, and credential storage.
3. **Laravel Ecosystem** (Script ID `77`: `scripts/77-install-laravel`): Composer package manager installation, PHP 8.2+ prerequisite validation, project scaffolding (`composer create-project` / `laravel new`), `.env` key generation, storage linking, and Nginx vhost / Artisan serve integration.
4. **Master Registry & Orchestration**: Synchronizing `registry.yaml`, updating `scripts/shared/install-keywords.json`, updating `run.ps1` CLI dispatchers, and updating `docs/parity-matrix.md`.

---

## Technical Specifications & Architecture

### 1. Script 76: Nginx Web Server (`scripts/76-install-nginx`)
- **Package Manager**: Chocolatey package `nginx` (`choco install nginx -y`), with portable zip fallback (`https://nginx.org/download/nginx-<version>.zip` unpacked to `$devDir\nginx`).
- **Directory Structure**:
  - Binary root: `C:\tools\nginx` or `$devDir\nginx`.
  - Configuration: `conf/nginx.conf` and `conf/conf.d/*.conf`.
  - Web root: `$devDir\www` or `html/`.
- **FastCGI Loopback Configuration**:
  - Unix domain sockets are unavailable on Windows PHP; Nginx must route PHP requests via TCP loopback:
    ```nginx
    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
    ```
- **PHP-CGI Service Daemon**:
  - Helper `helpers/php-cgi-daemon.ps1` to ensure `php-cgi.exe -b 127.0.0.1:9000` runs as a resilient background process or Windows Service (via WinSW / NSSM).
- **Port Conflict Handling**:
  - Pre-flight check on Port 80 (`Get-NetTCPConnection -LocalPort 80`). If occupied by IIS (`W3SVC`), Skype, or HTTP.sys, prompt or fall back to configurable port (default `8080`).
- **Management Verbs**: `start`, `stop`, `restart`, `reload` (`nginx -s reload`), and `check` (`nginx -t`).

---

### 2. Script 70: WordPress LEMP Stack (`scripts/70-install-wordpress`)
- **Parity with Linux Script 70**:
  - Replicates components: `mysql`, `php`, `nginx`, `wordpress`.
- **Sub-Component Orchestration**:
  1. **MySQL Setup**: Connects via `mysql.exe` (using credentials from `.resolved/18-interactive.json` or defaults). Executes:
     ```sql
     CREATE DATABASE IF NOT EXISTS wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
     CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY '<generated_or_provided_password>';
     GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';
     FLUSH PRIVILEGES;
     ```
  2. **PHP Extension Verification & Patching**:
     - Patches `php.ini` to activate required DLL extensions: `curl`, `gd`, `mbstring`, `mysqli`, `openssl`, `pdo_mysql`, `xml`, `zip`, `exif`, `fileinfo`.
  3. **WordPress Ingestion & Integrity Gate**:
     - Downloads `https://wordpress.org/latest.zip`.
     - Downloads `https://wordpress.org/latest.zip.sha1` and `latest.zip.md5`.
     - Computes local SHA1 and MD5 hashes; aborts if mismatch detected (CODE RED compliance).
     - Extracts into `$devDir\www\wordpress` or specified `-Path`.
  4. **Configuration (`wp-config.php`)**:
     - Clones `wp-config-sample.php` -> `wp-config.php`.
     - Injects DB credentials.
     - Fetches 8 live cryptographic salts from `https://api.wordpress.org/secret-key/1.1/salt/` via `Invoke-RestMethod`.
  5. **Nginx Vhost**:
     - Generates `conf/conf.d/wordpress.conf` with `root <path>`, `index index.php`, `try_files $uri $uri/ /index.php?$args;`.
     - Tests via `nginx -t` and reloads.
  6. **Security Artifacts**:
     - Saves `.installed/70-wordpress-credentials.json` with restricted Windows ACLs (`icacls`).
     - Saves `.resolved/70-wordpress.json`.

---

### 3. Script 77: Laravel Ecosystem (`scripts/77-install-laravel`)
- **Composer Installation**:
  - Verifies or installs Composer via `choco install composer -y`.
  - Ensures `composer` CLI is in system `PATH`.
- **PHP 8.2+ Prerequisite Gate**:
  - Validates PHP version >= 8.2 and required extensions (`pdo_mysql`, `mbstring`, `openssl`, `tokenizer`, `xml`, `fileinfo`, `zip`, `bcmath`, `ctype`).
- **Project Scaffolding**:
  - Supports `-Mode`: `scaffold-new` (`composer create-project laravel/laravel <path>`), `cli-only` (`composer global require laravel/installer`), or `full-stack` (Composer + Project + Nginx Vhost).
  - Target Path: Default `$devDir\www\laravel` or user-specified.
- **Environment & Key Configuration**:
  - Copies `.env.example` -> `.env`.
  - Runs `php artisan key:generate`.
  - Configures `DB_CONNECTION=mysql`, `DB_HOST=127.0.0.1`, `DB_PORT=3306`, `DB_DATABASE=laravel`.
  - Runs `php artisan storage:link`.
- **Nginx Vhost Wiring**:
  - Configures root to point strictly to `<laravel-path>/public`.
  - Rewrite rules:
    ```nginx
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    ```

---

### 4. Master Registry & Cross-Platform Alignment

#### `registry.yaml` Updates:
```yaml
  - id: '70'
    windows:
      folder: 70-install-wordpress
    linux:
      folder: 70-install-wordpress-ubuntu
      phase: '14'
      title: Ubuntu WordPress installer (Nginx + PHP-FPM + MySQL/MariaDB + latest WordPress; modular components with --interactive prompts)
    macos:
      folder: 70-install-wordpress-ubuntu
      phase: '14'
      title: Ubuntu WordPress installer (Nginx + PHP-FPM + MySQL/MariaDB + latest WordPress; modular components with --interactive prompts)

  - id: '76'
    windows:
      folder: 76-install-nginx
    linux:
      folder: 76-install-nginx
      phase: '14'
      title: Nginx web server (apt|choco)
    macos:
      folder: 76-install-nginx
      phase: '14'
      title: Nginx web server (brew)

  - id: '77'
    windows:
      folder: 77-install-laravel
    linux:
      folder: 77-install-laravel-ubuntu
      phase: '14'
      title: Laravel ecosystem installer (Composer + Project Scaffolding + Nginx vhost)
    macos:
      folder: 77-install-laravel-ubuntu
      phase: '14'
      title: Laravel ecosystem installer (Composer + Project Scaffolding + Nginx vhost)
```

---

### 5. Keyword Mapping (`scripts/shared/install-keywords.json`)

Add the following mappings to `keywords`:
```json
"nginx": [ 76 ],
"web-server": [ 76 ],
"install-nginx": [ 76 ],
"wordpress": [ 70 ],
"wp": [ 70 ],
"wp-only": [ 70 ],
"install-wordpress": [ 70 ],
"install-wp": [ 70 ],
"laravel": [ 77 ],
"artisan": [ 77 ],
"composer": [ 16 ],
"install-laravel": [ 77 ],
"lemp": [ 18, 16, 76 ],
"lnmp": [ 18, 16, 76 ],
"wordpress-stack": [ 18, 16, 76, 70 ],
"laravel-stack": [ 18, 16, 76, 77 ]
```

---

## Custom Rules & Constraints
1. **CODE RED File Error Compliance**: Every file, download, or path failure must output:
   `[FILE-ERROR] path='<path>' reason='<reason>'` and record in `$script:_LogErrors`.
2. **Strict Idempotency**:
   - Nginx: Test if binary exists and service is running before re-running setup.
   - WordPress: If `wp-config.php` and `index.php` exist at target path, skip re-downloading core files.
   - Laravel: If project directory already contains `artisan` and `composer.json`, skip `create-project`.
3. **Interactive Support**: Honor `-Interactive` / `-i` across all three scripts; save selections to `.resolved/<id>-interactive.json`.
4. **Credentials Security**: Credentials files in `.installed/` must be locked with Windows ACLs (`icacls $path /inheritance:r /grant:r "$($env:USERNAME):(R,W)"`).
5. **Strictly Relative Paths**: All cross-references between scripts and documentation must remain relative to repo root.
