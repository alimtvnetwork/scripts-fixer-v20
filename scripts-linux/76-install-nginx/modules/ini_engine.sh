#!/usr/bin/env bash
# scripts-linux/76-install-nginx/modules/ini_engine.sh
# INI file generator, parser, and bidirectional SQLite synchronization
set -u

_resolve_ini_paths() {
    if [ "$(id -u)" -eq 0 ] && [ -d "/etc/nginx" ]; then
        INI_SITES_DIR="/etc/nginx/sites.d"
        INI_MASTER_FILE="/etc/nginx/sites.ini"
    else
        local fallback_dir="${ROOT:-.}/.resolved/nginx"
        mkdir -p "$fallback_dir" 2>/dev/null || true
        INI_SITES_DIR="$fallback_dir/sites.d"
        INI_MASTER_FILE="$fallback_dir/sites.ini"
    fi
}

_resolve_ini_paths

ini_write_site() {
    local domain="$1"
    local subdomain_of="$2"
    local type="$3"
    local port="$4"
    local root_path="$5"
    local php_ver="$6"
    local php_sock="$7"
    local proxy_pass="$8"
    local ssl_enabled="$9"
    local vhost_avail="${10}"
    local vhost_enab="${11}"

    mkdir -p "$INI_SITES_DIR" 2>/dev/null || sudo mkdir -p "$INI_SITES_DIR" 2>/dev/null || true
    local ini_file="$INI_SITES_DIR/${domain}.ini"
    local now; now="$(date '+%Y-%m-%d %H:%M:%S')"

    local content="; scripts-fixer Nginx Domain Specification
[domain]
name = ${domain}
subdomain_of = ${subdomain_of}
type = ${type}
status = active
created_at = ${now}
updated_at = ${now}

[server]
port = ${port}
ssl_port = 443
server_tokens = off

[web]
root = ${root_path}
index = index.php index.html index.htm
client_max_body_size = 64M

[php]
enabled = $( [ "$type" = "php" ] || [ "$type" = "wordpress" ] || [ "$type" = "laravel" ] && echo "true" || echo "false" )
version = ${php_ver}
socket = ${php_sock}

[proxy]
enabled = $( [ "$type" = "proxy" ] && echo "true" || echo "false" )
pass_url = ${proxy_pass}

[ssl]
enabled = $( [ "$ssl_enabled" = "1" ] && echo "true" || echo "false" )
cert_file = 
key_file = 

[vhost]
available_path = ${vhost_avail}
enabled_path = ${vhost_enab}
symlinked = true
"
    if [ "$(id -u)" -eq 0 ]; then
        printf '%s' "$content" > "$ini_file"
    else
        printf '%s' "$content" | sudo tee "$ini_file" >/dev/null 2>&1 || printf '%s' "$content" > "$ini_file" 2>/dev/null || true
    fi

    echo "$ini_file"
}

ini_remove_site() {
    local domain="$1"
    local ini_file="$INI_SITES_DIR/${domain}.ini"
    if [ -f "$ini_file" ]; then
        local archive_dir="$INI_SITES_DIR/.archived"
        mkdir -p "$archive_dir" 2>/dev/null || sudo mkdir -p "$archive_dir" 2>/dev/null || true
        local now_stamp; now_stamp="$(date '+%Y%m%d%H%M%S')"
        local archived_dest="$archive_dir/${domain}.ini.${now_stamp}"
        if [ "$(id -u)" -eq 0 ]; then
            mv "$ini_file" "$archived_dest" 2>/dev/null || rm -f "$ini_file"
        else
            sudo mv "$ini_file" "$archived_dest" 2>/dev/null || sudo rm -f "$ini_file" 2>/dev/null || true
        fi
    fi
}

ini_update_master() {
    local now; now="$(date '+%Y-%m-%d %H:%M:%S')"
    local lines; lines="$(db_query_tsv "SELECT domain, subdomain_of, type, port, root_path, php_version, proxy_pass, ssl_enabled, status, ini_file, vhost_file FROM domains WHERE status != 'deleted' ORDER BY domain ASC;")"

    local total_count=0
    local active_count=0
    local site_blocks=""

    while IFS='|' read -r d sub t p r pv px s st i v; do
        [ -z "$d" ] && continue
        total_count=$((total_count + 1))
        [ "$st" = "active" ] && active_count=$((active_count + 1))

        site_blocks="${site_blocks}
[site:${d}]
domain = ${d}
subdomain_of = ${sub}
type = ${t}
port = ${p}
root = ${r}
php_version = ${pv}
proxy_pass = ${px}
ssl = $( [ "$s" = "1" ] && echo "true" || echo "false" )
status = ${st}
ini = ${i}
conf = ${v}
"
    done <<< "$lines"

    local master_content="; ==============================================================================
; scripts-fixer Nginx Master Inventory
; Auto-synchronized with SQLite database
; ==============================================================================

[master]
version = 1.0.0
last_sync = ${now}
total_sites = ${total_count}
active_sites = ${active_count}
db_path = ${DB_PATH}
${site_blocks}
"
    local master_dir; master_dir="$(dirname "$INI_MASTER_FILE")"
    mkdir -p "$master_dir" 2>/dev/null || sudo mkdir -p "$master_dir" 2>/dev/null || true

    if [ "$(id -u)" -eq 0 ]; then
        printf '%s' "$master_content" > "$INI_MASTER_FILE"
    else
        printf '%s' "$master_content" | sudo tee "$INI_MASTER_FILE" >/dev/null 2>&1 || printf '%s' "$master_content" > "$INI_MASTER_FILE" 2>/dev/null || true
    fi
}

ini_read_param() {
    local file="$1" section="$2" key="$3"
    [ -f "$file" ] || return 1
    awk -v sec="$section" -v k="$key" '
        BEGIN { in_sec = 0 }
        /^[[:space:]]*\[.*\]/ {
            curr_sec = $0
            gsub(/^[[:space:]]*\[|[\]][[:space:]]*$/, "", curr_sec)
            if (curr_sec == sec) in_sec = 1; else in_sec = 0;
            next
        }
        in_sec && $0 ~ "^[[:space:]]*" k "[[:space:]]*=" {
            split($0, parts, "=")
            sub(/^[[:space:]]*/, "", parts[2])
            sub(/[[:space:]]*$/, "", parts[2])
            print parts[2]
            exit
        }
    ' "$file"
}
