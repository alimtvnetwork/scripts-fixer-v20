# Release Architecture Map

## Current Release
- **Version**: 1.15.0
- **Source of Truth**: `version.json`
- **Synchronized Mirror**: `scripts/version.json`
- **Dynamic Readers**: `run.ps1` (PowerShell), `scripts/run.sh` (Linux Bash)

## Theming Engine
- `scripts/shared/theme.json` configures semantic colors (`LightGreen`, `Cyan`, `Yellow`, `Gray`, `Red`).

## Under-the-Hood Tree View
- `scripts/shared/list_installs.py` and `scripts/shared/profile_tree.py` provide recursive, indented ASCII tree views (`├──`, `└──`) for `install ls` / `install list` and profile installations.
