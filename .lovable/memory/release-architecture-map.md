# Release Architecture Map

## Current Release
- **Version**: 1.36.0
- **Previous Version**: 1.35.0
- **Source of Truth**: `version.json`
- **Synchronized Mirror**: `scripts/version.json`
- **Line Ending Standard**: Strict Unix LF (`\n`) enforced via `.gitattributes` (`*.sh text eol=lf`)
- **File Naming Standard**: All markdown files MUST be lowercase (`readme.md`, `changelog.md`).
- **Dynamic Readers**: `run.ps1` (PowerShell), `scripts/run.sh` (Linux Bash)

## Features in v1.36.0
- **Torrent Installers**: qBittorrent and uTorrent for Windows and Ubuntu.
- **Config Management**: `export-config` and `import-config` CLI commands globally for VSCode, qtorrent, and utorrent.
