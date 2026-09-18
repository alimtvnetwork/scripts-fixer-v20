# Subtask 18.1: Standalone Nginx Suite on Linux (`scripts-linux/76-install-nginx`)

## Context & Objective
Currently, Nginx in `scripts-linux` only exists as an internal component of WordPress script 70. This subtask builds a standalone, first-class Nginx suite in `scripts-linux/76-install-nginx` that can be installed, checked, repaired, uninstalled, and managed independently.

## Target Files (All relative to repository root)
- `scripts-linux/76-install-nginx/manifest.json`
- `scripts-linux/76-install-nginx/config.json`
- `scripts-linux/76-install-nginx/readme.txt`
- `scripts-linux/76-install-nginx/run.sh`
- `scripts-linux/76-install-nginx/snippets/security-headers.conf`
- `scripts-linux/76-install-nginx/snippets/fastcgi-php.conf`
- `scripts-linux/76-install-nginx/snippets/static-assets.conf`
- `scripts-linux/76-install-nginx/snippets/ssl-params.conf`

## Requirements & Implementation Details
1. **Manifest & Config**:
   - Schema 1.0, ID "76", phase "14", title "Nginx standalone web server (HTTP/HTTPS, modular snippets, multi-site manager)".
   - Configuration defines default HTTP port (80), client max body size (64M), worker processes (auto).
2. **Snippets Library**:
   - Installs modular configuration snippets into `/etc/nginx/snippets/`:
     - `scripts-fixer-security.conf` (X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy).
     - `scripts-fixer-fastcgi.conf` (FastCGI buffers, timeouts, realpath_root).
     - `scripts-fixer-static.conf` (Cache-Control headers, 30-day expiration for assets).
     - `scripts-fixer-ssl.conf` (TLSv1.2/1.3, modern ciphers, session cache).
3. **Core Engine Tuning**:
   - Configures `/etc/nginx/nginx.conf` with server_tokens off, client_max_body_size 64M, gzip compression.
4. **CLI Verbs**:
   - `install`, `check`, `repair`, `uninstall`, `status`, `test`, `reload`, `sites`, `enable-site <name>`, `disable-site <name>`.
5. **Quality & Error Handling**:
   - Adheres to `_shared/logger.sh` and `_shared/file-error.sh`. Writes `.installed/76.ok` marker upon verification.
