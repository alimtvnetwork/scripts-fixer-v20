# Script 76: Install & Manage Nginx on Windows

## Overview
Automates Nginx web server installation, service management, and virtual host domain management on Windows. Features a resilient SQLite database (`nginx-domains.sqlite3`), bidirectional declarative INI synchronization (`domains.ini`), forward-slash path normalization, and automated syntax validation gating (`nginx -t`).

## CLI Commands
- `.\run.ps1 nginx install` -- Install Nginx Web Server via Chocolatey
- `.\run.ps1 nginx help` -- Display domain manager CLI help
- `.\run.ps1 nginx add <domain> [--type <static|php|wordpress|laravel|proxy>] [--port 80] [--root <path>]` -- Register virtual host in SQLite, compile Nginx config, and sync to INI
- `.\run.ps1 nginx rm <domain> [--purge] [-y]` -- Remove virtual host, update SQLite, sync to INI
- `.\run.ps1 nginx list [--json]` -- List all registered virtual host domains from SQLite ledger
- `.\run.ps1 nginx ini [--sync]` -- Display declarative domains.ini or run bidirectional sync with SQLite
- `.\run.ps1 nginx showcase [--keep]` -- Run interactive 5-phase showcase demonstrating SQLite & INI synchronization
- `.\run.ps1 nginx start` -- Launch Nginx background process
- `.\run.ps1 nginx stop` -- Gracefully stop Nginx process
- `.\run.ps1 nginx reload` -- Hot-reload configuration after syntax testing (`nginx -t`)
- `.\run.ps1 nginx status` -- Show process state and registered virtual hosts
- `.\run.ps1 nginx test` -- Verify Nginx configuration syntax (`nginx -t`)

## Storage & Configuration Architecture
- **SQLite Ledger**: `.installed\nginx-domains.sqlite3` (or `%LOCALAPPDATA%\scripts-fixer\nginx-domains.sqlite3`)
- **Declarative INI File**: `scripts\76-install-nginx\domains.ini`
- **Virtual Host Configs**: `C:\tools\nginx\conf\conf.d\*.conf`
- **Templates**: `scripts\76-install-nginx\templates\*.conf.template`
- **Binary Path**: `C:\tools\nginx\nginx.exe`
- **FastCGI Loopback**: `127.0.0.1:9000`
