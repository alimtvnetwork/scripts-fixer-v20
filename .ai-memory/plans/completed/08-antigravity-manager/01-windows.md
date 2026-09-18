# Subtask 1: Windows Integration

## Objective
Implement Antigravity and Antigravity Manager installation for Windows.

## Actionable Steps
1. **Create Antigravity Manager Installer:**
   - Create `scripts/68-install-antigravity-manager/run.ps1`.
   - Write PowerShell logic to query the GitHub API for the latest release of `lbjlaq/Antigravity-Manager`.
   - Download the `.exe` asset.
   - Install it silently.
   - Include idempotency check.

2. **Create Antigravity CLI Installer:**
   - Create `scripts/69-install-antigravity/run.ps1`.
   - Add the command: `irm https://get.antigravity.dev | iex`.

3. **Update Dispatcher Menu:**
   - Modify `run.ps1` at the repository root to include options for `68-install-antigravity-manager` and `69-install-antigravity`.

4. **Update Registry:**
   - Modify `registry.json` to register the new Windows installer paths and descriptions.

5. **Update Profiles:**
   - Ensure the new tools are injected into the `dev` and `dev+ai` profiles on the Windows side.
