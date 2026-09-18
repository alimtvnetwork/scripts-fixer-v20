# Subtask 03: Profile Definitions and Keyword Mappings

## Target Files
- `scripts/profile/config.json`
- `scripts/profile/profile-aliases.json`
- `scripts/shared/install-keywords.json`
- `scripts/shared/profile_tree.py`
- `scripts/os/ubuntu/profile-ubuntu-ai-tools.sh`
- `scripts/os/ubuntu/profile-ubuntu-antigravity.sh`
- `scripts/os/ubuntu/profile-ubuntu-antigravity-suite.sh`

## Implementation Steps
1. Update `scripts/profile/config.json`:
   - Include script `80` (Claude Code) in profile `ai-tools`.
   - Add profile `antigravity` alongside `antigravity-suite` (scripts `69` and `68`).
2. Add aliases in `scripts/profile/profile-aliases.json`:
   - `antigravity` -> `antigravity-suite`
   - `all-ai` / `ai` -> `ai-tools`
3. Update `scripts/shared/install-keywords.json`:
   - Map keywords inside `"keywords"`: `claude`, `claude-code`, `codex`, `plotcode`, `antigravity`, `ai-tools`, `antigravity-suite`.
4. Update `scripts/shared/profile_tree.py` with definitions for `ubuntu+ai-tools` and `ubuntu+antigravity`.
5. Ensure Ubuntu profile scripts install all tools sequentially.
