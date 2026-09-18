# Subtask 18.3: WordPress Nginx Hardening & Options (`scripts-linux/70-install-wordpress-ubuntu`)

## Context & Objective
Upgrade `scripts-linux/70-install-wordpress-ubuntu/components/nginx.sh` and `run.sh` to introduce security hardening (blocking PHP execution in uploads, protecting sensitive files, XML-RPC control) and support modern configuration options (FastCGI caching, multisite rewrites).

## Target Files (All relative to repository root)
- `scripts-linux/70-install-wordpress-ubuntu/components/nginx.sh`
- `scripts-linux/70-install-wordpress-ubuntu/run.sh`
- `scripts-linux/70-install-wordpress-ubuntu/config.json`
- `scripts-linux/70-install-wordpress-ubuntu/readme.txt`

## Requirements & Implementation Details
1. **Security Protections in Nginx Vhost**:
   - Deny script execution in `/wp-content/uploads/` and `/wp-content/cache/`.
   - Deny access to `wp-config.php`, `.htaccess`, `.user.ini`, `readme.html`.
   - Add `--protect-xmlrpc` flag / configuration to block access to `/xmlrpc.php`.
2. **Multisite Rewrite Support**:
   - Support `--multisite-subfolder` and `--multisite-subdomain` options for WordPress multisite network installs.
3. **FastCGI Caching Option**:
   - Support `--cache fastcgi` to configure `fastcgi_cache_path` and cache bypass conditions.
4. **Graceful Default Site Handling**:
   - Avoid hard error if `/etc/nginx/sites-enabled/default` is absent.
