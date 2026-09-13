================================================================================
Script 76 -- Nginx standalone web server (HTTP/HTTPS, modular snippets, sites)
================================================================================

Comprehensive standalone Nginx management suite for Linux.
Installs, tunes, verifies, repairs, and manages Nginx web server instances,
including modular snippets and multi-site configuration.

Features:
  1. Automated package installation (apt / dpkg on Debian/Ubuntu, brew on macOS)
  2. Modular snippets library installed to /etc/nginx/snippets/:
     - scripts-fixer-security.conf (OWASP/Mozilla security headers)
     - scripts-fixer-fastcgi.conf  (FastCGI PHP buffers, timeouts, realpath_root)
     - scripts-fixer-static.conf   (30-day asset caching, compression headers)
     - scripts-fixer-ssl.conf      (Modern TLSv1.2/1.3, ciphers, session cache)
  3. Core engine tuning in /etc/nginx/nginx.conf:
     - worker_processes auto
     - server_tokens off
     - client_max_body_size 64M
     - gzip on
  4. Multi-site management (list, enable, disable sites with automatic validation)
  5. Safe rollback: backups created before any config edit; rolled back on 'nginx -t' error

Commands:
  ./run.sh install                Install Nginx, deploy snippets, tune nginx.conf, init SQLite/INI, start service
  ./run.sh check                  Verify binary, service status, syntax, and snippets
  ./run.sh repair                 Re-deploy snippets, re-tune nginx.conf, test and restart
  ./run.sh uninstall [--purge]    Stop/disable service, remove snippets (optional purge packages)
  ./run.sh status                 Display Nginx version, service state, listening ports, sites
  ./run.sh test                   Run 'nginx -t' configuration test with detailed logging
  ./run.sh reload                 Validate configuration and gracefully reload service
  ./run.sh sites                  List all available vhosts and their enabled status
  ./run.sh enable-site <name>     Enable site vhost in sites-enabled/ and reload Nginx
  ./run.sh disable-site <name>    Disable site vhost in sites-enabled/ and reload Nginx

Domain Management (SQLite & INI synchronized):
  ./run.sh add <domain> [opts]    Add and configure virtual host (static, php, wordpress, laravel, proxy)
  ./run.sh rm <domain> [--purge]  Deactivate and remove virtual host, archive INI, update SQLite
  ./run.sh list [--json]          List all registered domains from SQLite ledger with health
  ./run.sh ini [domain] [--sync]  Display master sites.ini or specific per-site INI
  ./run.sh showcase [--keep]      Run live demonstration of SQLite + INI + Vhost Tri-State sync

Domain Options:
  --type <type>                   static | php | wordpress | laravel | proxy (default: static)
  --port <n>                      Listening HTTP port (default: 80)
  --root <path>                   Document root path (default: /var/www/<domain>/html or /public)
  --php [version]                 Enable PHP FastCGI (e.g. 8.1, 8.2, 8.3, or auto-detected socket)
  --proxy <url>                   Reverse proxy target (e.g. http://127.0.0.1:3000)
  --ssl                           Enable SSL/TLS server block
  --purge                         Remove document root upon domain removal

Files & Paths:
  Config file:                    /etc/nginx/nginx.conf
  Snippets library:               /etc/nginx/snippets/
  Sites available:                /etc/nginx/sites-available/
  Sites enabled:                  /etc/nginx/sites-enabled/
  Per-site INI directory:         /etc/nginx/sites.d/
  Master INI inventory:           /etc/nginx/sites.ini
  SQLite Database:                /var/lib/scripts-fixer/nginx-domains.sqlite3
  Installed marker:               .installed/76.ok
