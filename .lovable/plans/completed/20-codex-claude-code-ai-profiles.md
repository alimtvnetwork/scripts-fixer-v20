# Plan 20: Codex, Claude Code, and Antigravity AI Profiles

## Objective
Provide first-class UI-based and CLI installation for **Codex** and **Claude Code** (and retain PlotCode), plus unified profiles:
1. An all-in-one AI profile (`ai-tools` / `all-ai`) that installs Antigravity, Antigravity Manager, Codex, Claude Code, and PlotCode.
2. A dedicated Antigravity profile (`antigravity` / `antigravity-suite`) that installs Antigravity and its profile dependencies/manager.
3. Full cross-platform parity on Windows (`run.ps1`, `scripts/`) and Ubuntu/Unix (`run.sh`, `scripts/os/ubuntu/`).

## Architecture & Conventions
- Windows Scripts:
  - `scripts/78-install-codex/run.ps1` & `uninstall.ps1`
  - `scripts/79-install-plotcode/run.ps1` & `uninstall.ps1`
  - `scripts/80-install-claude-code/run.ps1` & `uninstall.ps1`
  - `scripts/profile/config.json` profile mappings for `ai-tools`, `antigravity`, `antigravity-suite`
  - `scripts/shared/install-keywords.json` keyword-to-script mappings
- Linux / Unix Scripts:
  - `scripts/os/ubuntu/install-codex.sh`
  - `scripts/os/ubuntu/install-plotcode.sh`
  - `scripts/os/ubuntu/install-claude-code.sh`
  - `scripts/os/ubuntu/profile-ubuntu-ai-tools.sh`
  - `scripts/os/ubuntu/profile-ubuntu-antigravity.sh` & `profile-ubuntu-antigravity-suite.sh`
  - `scripts/run.sh` CLI dispatcher & profile resolution
  - `scripts/shared/profile_tree.py` visual tree representations

## Task-Specific Constraints
1. Support both interactive/GUI desktop launcher/shortcut and CLI PATH integration.
2. Maintain strict Windows PowerShell and Ubuntu Bash compatibility.
3. Clean error management with descriptive console messages.
4. Unix LF line endings, UTF-8 without BOM.
5. All paths in plans and subtasks strictly relative.
