# Release Architecture Map

## Current Release
- **Version**: 1.18.0
- **Previous Version**: 1.17.0
- **Source of Truth**: `version.json`
- **Synchronized Mirror**: `scripts/version.json`
- **Dynamic Readers**: `run.ps1` (PowerShell), `scripts/run.sh` (Linux Bash)

## Features in v1.18.0
- **Combo Shortcuts**: Full terminal visibility for combinations (`vscode+settings`, `vms`, `frontend`, `backend`, `full-stack`, `ollama`, `bcompare`, `clean`).
- **Ubuntu VS Code Settings Sync**: Automatic keybinding, setting, and extension installation for `ubuntu+vscode` and `ubuntu+small-dev`.
- **Beyond Compare Installer**: Linux package deployment and Git diff/merge integration.
- **Ollama / LLM Runner**: Autonomous Ollama installer with GLM-4, Kimi K2, and Qwen models.
- **Arch Linux Suite**: `scripts/os/arch/install-arch-tools.sh` for pacman and yay AUR helper environments.
- **System Deep Cleanup**: Automated APT and journal cache maintenance.
