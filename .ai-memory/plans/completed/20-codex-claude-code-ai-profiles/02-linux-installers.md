# Subtask 02: Linux / Unix Installers for Codex, Claude Code, and Antigravity

## Target Files
- `scripts/os/ubuntu/install-claude-code.sh`
- `scripts/os/ubuntu/install-codex.sh`
- `scripts/os/ubuntu/install-plotcode.sh`
- `scripts/os/ubuntu/install-antigravity.sh`
- `scripts/run.sh`

## Implementation Steps
1. Create `scripts/os/ubuntu/install-claude-code.sh` with npm install `@anthropic-ai/claude-code`, desktop entry `.desktop` file, and PATH export.
2. Ensure `scripts/os/ubuntu/install-codex.sh` and `install-plotcode.sh` create both binary and desktop menu entries.
3. Fix string in `scripts/os/ubuntu/install-antigravity.sh` from "Antigravity CLI" to "Antigravity".
4. Update `scripts/run.sh` standalone tools matching and help text.
