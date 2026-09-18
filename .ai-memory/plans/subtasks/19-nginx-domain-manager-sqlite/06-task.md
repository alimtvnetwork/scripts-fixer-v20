# Subtask 19.6: Root Dispatcher Passthroughs & Top-Level CLI Wiring

## Target Files
- `scripts-linux/run.sh`
- `scripts/run.sh`
- `run.ps1`
- `scripts/shared/install-keywords.json`

## Requirements
1. **`scripts-linux/run.sh`**:
   - Add top-level `nginx)` case handling delegating to `nginx-passthrough`.
   - Add `nginx-passthrough` execution block forwarding all flags to `scripts-linux/76-install-nginx/run.sh "$@"`.
   - If `./run.sh install nginx` is called, route to `nginx-passthrough` with `install`.
   - Add Nginx command suite to `show_help()`.
2. **`scripts/run.sh`**:
   - Forward `nginx)` commands to `scripts-linux/76-install-nginx/run.sh`.
3. **`run.ps1`**:
   - Add `'nginx'` to `$canonicalVerbs` and implement `$isBareNginxCommand` dispatching to `scripts/76-install-nginx/run.ps1`.
   - Update help menu with Nginx domain manager examples.
4. **`scripts/shared/install-keywords.json`**:
   - Verify keywords `nginx`, `webserver`, `vhost` are properly mapped.
