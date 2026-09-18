# Plan 19: AI Tools Installers (Codex, PlotCode, Profiles)

## Objective
The user requested UI-based installations for "Codex" and "PlotCode" on both Windows and Ubuntu/Unix.
Additionally, we need:
1. A profile that installs "all" of these AI tools.
2. A profile for Antigravity that installs Antigravity and its profile dependencies.

## Custom Rules & Constraints
1. UI-based/App installation format implies standard package managers or binary downloads if unavailable, simulated if no real package exists in the standard repos.
2. Ensure consistent naming across Windows (`78-install-codex`, `79-install-plotcode`) and Linux (`install-codex.sh`, `install-plotcode.sh`).
3. Update `run.ps1` and `run.sh` to route these new tools.
4. Update `scripts/profile/config.json` and Ubuntu shell profiles for `ai-tools` and `antigravity-suite`.

## Subtasks
- **01-windows-installers.md**: Create `scripts/78-install-codex/run.ps1` and `scripts/79-install-plotcode/run.ps1`.
- **02-ubuntu-installers.md**: Create `scripts/os/ubuntu/install-codex.sh` and `scripts/os/ubuntu/install-plotcode.sh`.
- **03-profiles-and-dispatchers.md**: Update `scripts/profile/config.json`, `run.ps1`, `scripts/run.sh`, and create `scripts/os/ubuntu/profile-ubuntu-ai-tools.sh` and `profile-ubuntu-antigravity-suite.sh`.
