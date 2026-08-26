# Release Architecture Map

## Current Release
- **Version**: 1.17.0
- **Previous Version**: 1.16.0
- **Source of Truth**: `version.json`
- **Synchronized Mirror**: `scripts/version.json`
- **Dynamic Readers**: `run.ps1` (PowerShell), `scripts/run.sh` (Linux Bash)

## Features in v1.17.0
- **Ubuntu VS Code Settings Sync**: Automatic keybinding, setting, and extension installation for `ubuntu+vscode` and `ubuntu+small-dev`.
- **Beyond Compare Installer**: Linux package deployment and Git diff/merge integration.
- **Ollama / LLM Runner**: Autonomous Ollama installer with GLM-4, Kimi K2, and Qwen models.
- **System Deep Cleanup**: Automated APT and journal cache maintenance.
- **Modern CLI Tools**: Fastfetch, bat, eza, ripgrep, fzf bundle.
