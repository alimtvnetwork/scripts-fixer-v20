# Script 77: Install Laravel on Windows

## Overview
Automates Composer installation, Laravel application scaffolding, `.env` encryption key generation, and storage link setup on Windows.

## Verbs
- `.\run.ps1 install laravel` or `.\run.ps1 -I 77` -- Install Composer and scaffold default Laravel project
- `.\run.ps1 -I 77 check` -- Verify PHP & Composer readiness
- `.\run.ps1 -I 77 scaffold` -- Scaffold a new application
- `.\run.ps1 -I 77 repair` -- Reinstall dependencies and re-run artisan setup
- `.\run.ps1 -I 77 uninstall` -- Remove tracking

## Parameters
- `-AppName <name>`: Target folder name under `dev-tool\www\` (default: `laravel-app`)
- `-Path <path>`: Custom absolute directory for the application
- `-DbName <name>`, `-DbUser <name>`, `-DbPass <pass>`: Database credentials to write to `.env`
