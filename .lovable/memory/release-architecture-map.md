# Release Architecture Map

## Current Release
- **Version**: 1.14.0
- **Source of Truth**: `version.json`
- **Dynamic Readers**: `run.ps1` (PowerShell), `scripts/run.sh` (Linux Bash)

## Theming Engine
- `scripts/shared/theme.json` configures semantic colors (`LightGreen`, `Cyan`, `Yellow`, `Gray`, `Red`).
- Both Windows PowerShell and Linux Bash dynamically read from `theme.json` to ensure 100% dark mode readability and contrast parity.

## Profile Architecture
- `scripts/shared/profile_tree.py` manages hierarchical tree definitions and step-by-step breakdowns for all profiles:
  - `ubuntu-basic`: Git, ZSH + Oh-My-Zsh, aria2c, build-essential, vim, curl, wget, libssl-dev.
  - `ubuntu+vscode`: Base + VS Code (classic snap).
  - `ubuntu+simple-dev` (alias: `ubuntu+small-dev`): Base + VS Code + Go + Rust + PHP 8.x + Python 3.
  - `ubuntu+dev`: Full stack with Node.js LTS, PNPM, and Yarn.

## AI Model Catalog Expansions
- **Ollama**: `scripts/42-install-ollama/config.json` includes GLM-4 (9B), GLM-Edge (4B), Kimi K2 (8B), and Kimi Coder (8B).
- **Llama.cpp GGUF**: `scripts/43-install-llama-cpp/models-catalog.json` includes GLM-4 9B Chat, GLM-Edge 4B Chat, Moonshot Kimi K2 8B, and Kimi Coder 8B GGUF weights.
