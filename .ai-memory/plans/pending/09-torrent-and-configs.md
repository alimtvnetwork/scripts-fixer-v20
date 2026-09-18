# Plan: 09 Torrent Installers and Config Management

## Objective
1. Add installers for `qtorrent` (qBittorrent) and `utorrent` for both Windows (run.ps1) and Ubuntu (run.sh).
2. Add configuration management commands `export-config <app>` and `import-config <app>` for `qtorrent`, `utorrent`, and `vscode` in both scripts.
3. Update help menus to document the new features.
4. Bump version to v1.36.0.

## Overview
This plan focuses on enhancing the toolkit by supporting torrent client installations and introducing a unified configuration export/import system to easily backup and restore application configurations.

## Subtasks
1. [Installers](subtasks/09-torrent-and-configs/01-installers.md): Add `qtorrent` and `utorrent` to `registry.yaml`, `run.ps1`, and `run.sh`.
2. [Config Management](subtasks/09-torrent-and-configs/02-config-management.md): Implement `export-config` and `import-config` commands for `qtorrent`, `utorrent`, and `vscode`.
3. [Release](subtasks/09-torrent-and-configs/03-release.md): Update version numbers and changelogs for v1.36.0 release.
