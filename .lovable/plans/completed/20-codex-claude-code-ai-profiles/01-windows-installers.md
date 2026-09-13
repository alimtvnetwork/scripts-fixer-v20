# Subtask 01: Windows Installers for Codex and Claude Code

## Target Files
- `scripts/80-install-claude-code/run.ps1`
- `scripts/80-install-claude-code/uninstall.ps1`
- `scripts/78-install-codex/run.ps1`
- `scripts/78-install-codex/uninstall.ps1`
- `scripts/79-install-plotcode/run.ps1`
- `scripts/79-install-plotcode/uninstall.ps1`
- `run.ps1`

## Implementation Steps
1. Create `scripts/80-install-claude-code/run.ps1` with UI desktop shortcut creation, npm package install (`@anthropic-ai/claude-code` or native wrapper), and PATH environment export.
2. Create `scripts/80-install-claude-code/uninstall.ps1`.
3. Enhance `scripts/78-install-codex/run.ps1` with desktop shortcut and PATH registration.
4. Update `run.ps1` help output (`Show-RootHelpRaw`) and `$uninstallTargets` mapping to include `claude`, `claude-code`, `codex`, `plotcode`.
