# Subtask 18.6: Master Registry, Keywords, and Root Dispatcher Integration

## Context & Objective
Synchronize the master configuration database `registry.yaml`, keyword resolver `install-keywords.json`, and the two root dispatchers (`scripts-linux/run.sh` and `run.ps1`) to expose Nginx, WordPress, and Laravel seamlessly.

## Target Files (All relative to repository root)
- `registry.yaml`
- `scripts/shared/install-keywords.json`
- `scripts-linux/run.sh`
- `run.ps1`
- `docs/parity-matrix.md`

## Requirements & Implementation Details
1. **`registry.yaml` Synchronization**:
   - Register `70` for Windows (`scripts/70-install-wordpress`).
   - Register `76` for Linux, macOS, and Windows (`76-install-nginx`).
   - Register `77` for Linux, macOS, and Windows (`77-install-laravel-ubuntu` / `77-install-laravel`).
   - Execute `node tools/registry-sync.cjs` to emit `scripts/registry.json` and `scripts-linux/registry.json`.
2. **`scripts/shared/install-keywords.json`**:
   - Add keyword mappings: `nginx`, `web-server`, `install-nginx`, `wordpress`, `wp`, `wp-only`, `install-wordpress`, `laravel`, `artisan`, `composer`, `install-laravel`, `lemp`, `lnmp`, `wordpress-stack`, `laravel-stack`.
   - Add mode overrides for `wp-only`, `laravel-only`, etc.
3. **`scripts-linux/run.sh`**:
   - Add top-level CLI commands: `nginx`, `laravel`, `install nginx`, `install laravel`.
   - Wire `nginx-passthrough` and `laravel-passthrough` command execution blocks.
4. **`run.ps1`**:
   - Add version detection in `Get-VersionMap` for Nginx and Laravel.
   - Register scripts in help tables and menu systems.
   - Configure `$modeEnvVars`.
5. **Quality Gate Verification**:
   - Run `node tools/smoke-check.mjs` or relevant linter scripts.
