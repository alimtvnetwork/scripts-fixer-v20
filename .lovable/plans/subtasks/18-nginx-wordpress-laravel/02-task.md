# Subtask 18.2: Multi-Vhost Port Changer Enhancement (`scripts-linux/86-change-port-nginx`)

## Context & Objective
`scripts-linux/86-change-port-nginx/run.sh` hardcodes `/etc/nginx/sites-enabled/default`. If WordPress or another application disabled the default site, changing the Nginx port crashes with a fatal error because the default file is missing. This subtask enhances the port changer to dynamically discover active enabled vhosts or accept a specific site name.

## Target Files (All relative to repository root)
- `scripts-linux/86-change-port-nginx/run.sh`
- `scripts-linux/86-change-port-nginx/config.json`
- `scripts-linux/86-change-port-nginx/manifest.json`

## Requirements & Implementation Details
1. **Dynamic Target Discovery**:
   - Add `--site <name>` support to allow targeting `/etc/nginx/sites-enabled/<name>` (or `<name>.conf`).
   - If `--site` is omitted, check for `/etc/nginx/sites-enabled/default`. If missing, scan `sites-enabled/*` for vhosts with active `listen` directives.
   - If a single active vhost exists, auto-select it. If multiple exist, pick or report available sites.
2. **Dual IPv4 / IPv6 Rewrite**:
   - Update replacement pattern to update both IPv4 `listen <port>;` and IPv6 `listen [::]:<port>;`.
3. **Safety & Verification**:
   - Run `nginx -t` before and after modifications. Rollback changes if `nginx -t` fails.
