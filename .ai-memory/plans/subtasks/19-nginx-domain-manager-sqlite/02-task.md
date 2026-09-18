# Subtask 19.2: INI Configuration Engine & Two-Way Synchronization

## Target Files
- `scripts-linux/76-install-nginx/modules/ini_engine.sh`
- `scripts/76-install-nginx/helpers/ini-parser.ps1`
- `scripts/76-install-nginx/domains.ini`

## Requirements
1. **Linux `ini_engine.sh`**:
   - `ini_write_site`: Writes per-site INI file `/etc/nginx/sites.d/<domain>.ini` with sections `[domain]`, `[server]`, `[web]`, `[php]`, `[proxy]`, `[ssl]`, `[vhost]`.
   - `ini_remove_site`: Archives site INI to `/etc/nginx/sites.d/.archived/<domain>.ini.<timestamp>`.
   - `ini_update_master`: Re-indexes `/etc/nginx/sites.ini` updating `[master]` summary block and all `[site:<domain>]` blocks.
   - `ini_read_param`: Shell-safe parser extracting key-value pairs from INI files.
   - `ini_sync_reconcile`: Two-way sync comparing filesystem INI files with SQLite rows, restoring missing records or updating changed values.
2. **Windows `ini-parser.ps1`**:
   - `ConvertFrom-IniFile`: Pure PowerShell INI parser outputting structured objects.
   - `ConvertTo-IniFile`: Serializes structured domain objects back to formatted INI.
   - `Sync-IniWithDatabase`: Synchronizes changes between `domains.ini` and SQLite database.
