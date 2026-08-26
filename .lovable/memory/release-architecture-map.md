# Release Architecture Map

## Current Release
- **Version**: 1.16.0
- **Previous Version**: 1.15.0
- **Source of Truth**: `version.json`
- **Synchronized Mirror**: `scripts/version.json`
- **Dynamic Readers**: `run.ps1` (PowerShell), `scripts/run.sh` (Linux Bash)

## Theming Engine
- `scripts/shared/theme.json` configures semantic colors (`LightGreen`, `Cyan`, `Yellow`, `Gray`, `Red`).

## Under-the-Hood Tree View
- `scripts/shared/list_installs.py` and `scripts/shared/profile_tree.py` provide recursive, indented ASCII tree views (`├──`, `└──`) for `install ls` / `install list` and profile installations.

## AI Model Catalog Expansions
- **Ollama**: `scripts/42-install-ollama/config.json` includes GLM-4 (9B), GLM-Edge (4B), Kimi K2 (8B), and Kimi Coder (8B).
- **Llama.cpp GGUF**: `scripts/43-install-llama-cpp/models-catalog.json` includes GLM-4 9B Chat, GLM-Edge 4B Chat, Moonshot Kimi K2 8B, and Kimi Coder 8B GGUF weights.
