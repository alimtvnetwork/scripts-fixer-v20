# Subtask 19.4: Linux Domain Manager Core & Showcase Engine

## Target Files
- `scripts-linux/76-install-nginx/modules/domain_manager.sh`
- `scripts-linux/76-install-nginx/modules/showcase.sh`
- `scripts-linux/76-install-nginx/run.sh`
- `scripts-linux/76-install-nginx/readme.txt`

## Requirements
1. **`domain_manager.sh`**:
   - Implements `cmd_add`: orchestrates Vhost compilation -> `nginx -t` -> symlink -> INI write -> SQLite commit -> reload.
   - Implements `cmd_rm`: unlinks vhost -> archives config -> archives INI -> SQLite delete -> reload. Supports `--purge` and `--yes` for webroot safety.
   - Implements `cmd_list`: prints formatted table with Tri-State health status (SQLite, INI, Vhost). Supports `--json`.
   - Implements `cmd_ini`: displays master/site INI and executes `--sync` drift reconciliation.
2. **`showcase.sh`**:
   - Implements `cmd_showcase`: runs live before/after demonstration rendering terminal diffs:
     1. BEFORE State: displays empty or current SQLite rows, missing INI, missing vhost.
     2. MUTATION: adds test domain `showcase.example.local`.
     3. AFTER State: displays updated SQLite row, generated INI, rendered Nginx vhost config.
     4. PROBE: runs `curl -I` against the new vhost.
     5. TEARDOWN: unlinks test vhost, archives INI, cleans SQLite record (unless `--keep` is passed).
3. **`run.sh` & `readme.txt`**:
   - Dispatches subcommands: `install`, `help`, `add`, `rm`, `list`, `showcase`, `ini`, `sites`, `enable-site`, `disable-site`, `status`, `test`, `reload`.
   - Update `show_help()` and `readme.txt` with clear examples.
