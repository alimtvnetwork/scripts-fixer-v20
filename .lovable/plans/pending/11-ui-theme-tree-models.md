# Parent Task: UI Theme Light Colors, Profile Tree Explainer & AI Model Expansion

## Phase 1: Planning (150 Subtasks)
Decompose the implementation into 150 granular micro-specifications covering theme architecture, tree formatting, profile composition, model specs, validation, and release governance.

## Phase 2: Execution (150 Actions)
1. Theme overhaul: `scripts/shared/theme.json`, `scripts/run.sh`, `run.ps1` to use high-contrast light colors (`LightGreen` / `Cyan`).
2. Profile tree viewer & explainer: `scripts/shared/profile_tree.py` providing ASCII hierarchical breakdowns and step-by-step component logs.
3. Hook tree view into `scripts/run.sh` for profile execution, `install ls`, and profile help.
4. Integrate GLM-4 and Kimi models into `scripts/42-install-ollama/config.json` and `scripts/43-install-llama-cpp/models-catalog.json`.
5. Release version bump (1.13.0 -> 1.14.0) in `version.json` and update `release-architecture-map.md`.
