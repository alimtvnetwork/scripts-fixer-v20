# Release Architecture Map

## Current Release
- **Version**: 1.22.0
- **Previous Version**: 1.21.0
- **Source of Truth**: `version.json`
- **Synchronized Mirror**: `scripts/version.json`
- **Line Ending Standard**: Strict Unix LF (`\n`) enforced via `.gitattributes` (`*.sh text eol=lf`)
- **Dynamic Readers**: `run.ps1` (PowerShell), `scripts/run.sh` (Linux Bash)

## Features in v1.22.0
- **Unix LF Normalization**: Universal fix across all 479 shell scripts preventing `\r` parsing failures.
- **Ubuntu Dynamic VS Code Settings Sync**: Automated settings, keybindings, and extension installation.
- **Linux Models CLI**: `./run.sh models` to discover and pull local LLMs (GLM-4, Kimi K2, Qwen, DeepSeek).
- **Beyond Compare Git Integration**: Native diff and merge tool configurations.
- **Arch Linux Suite**: Arch package manager and yay AUR helper bootstrap.
- **System Deep Cleanup**: Automated APT and journal cache maintenance.
