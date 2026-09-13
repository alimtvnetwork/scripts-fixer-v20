# Subtask 19.3: Virtual Host Templates & Compiler Engine

## Target Files
- `scripts-linux/76-install-nginx/modules/vhost_engine.sh`
- `scripts-linux/76-install-nginx/templates/static-vhost.conf.template`
- `scripts-linux/76-install-nginx/templates/php-vhost.conf.template`
- `scripts-linux/76-install-nginx/templates/proxy-vhost.conf.template`
- `scripts/76-install-nginx/helpers/vhost-compiler.ps1`
- `scripts/76-install-nginx/templates/static.conf.template`
- `scripts/76-install-nginx/templates/php.conf.template`
- `scripts/76-install-nginx/templates/proxy.conf.template`

## Requirements
1. **Linux `vhost_engine.sh` & Templates**:
   - Static, PHP-FPM, and Reverse Proxy templates integrating modular snippets (`security-headers`, `fastcgi-php`, `static-assets`, `ssl-params`).
   - `vhost_render`: Replaces template placeholders (`{{DOMAIN}}`, `{{PORT}}`, `{{ROOT}}`, `{{PHP_SOCKET}}`, `{{PROXY_PASS}}`).
   - `vhost_test_and_link`: Performs `sudo nginx -t` before symlinking to `sites-enabled/`. If test fails, deletes generated file and reports exact failure.
   - `vhost_unlink_and_archive`: Removes symlink and moves config to `.bak.<timestamp>`.
2. **Windows `vhost-compiler.ps1` & Templates**:
   - Renders templates ensuring Windows backslashes `\` are strictly converted to forward slashes `/` (Rule C3).
   - Validates syntax with `nginx.exe -t` before reloading service.
