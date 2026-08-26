# Release Architecture Map

## Current Release
- **Version**: 1.19.0
- **Previous Version**: 1.18.0
- **Source of Truth**: `version.json`
- **Synchronized Mirror**: `scripts/version.json`
- **Dynamic Readers**: `run.ps1` (PowerShell), `scripts/run.sh` (Linux Bash)

## Features in v1.19.0
- **Linux Models CLI**: `./run.sh models` and `./run.sh models <slug>` to manage and pull local LLMs.
- **Ubuntu Dynamic Extension Sync**: Reads `extensions.json` and syncs VS Code settings and language tools.
- **Beyond Compare Git Integration**: Auto-configures Git diff and merge tools.
- **Arch Linux Suite**: Arch package manager and yay AUR helper bootstrap.
- **System Deep Cleanup**: Complete APT cache and journal log vacuuming.
