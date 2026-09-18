# Subtask 2: Ubuntu Integration

## Objective
Implement Antigravity and Antigravity Manager installation for Ubuntu.

## Actionable Steps
1. **Create Antigravity Manager Installer:**
   - Create `scripts/os/ubuntu/68-install-antigravity-manager.sh` (or appropriate naming based on existing structure).
   - Write Bash logic to query the GitHub API for the latest release of `lbjlaq/Antigravity-Manager` using `curl` and `jq`.
   - Download the `.deb` asset.
   - Install it using `dpkg -i` or `apt install ./<file>`.
   - Include idempotency check.

2. **Verify Antigravity CLI Installer:**
   - Ensure `scripts/os/ubuntu/install-antigravity.sh` (or `scripts/os/ubuntu/69-install-antigravity.sh` depending on convention) exists and works.

3. **Update Dispatcher Menu:**
   - Modify `run.sh` at the repository root to include menu options for the new installers.

4. **Update Registry (if applicable):**
   - If Ubuntu menus rely on `registry.json` or another metadata file, add entries for the new scripts.

5. **Update Profiles:**
   - Modify the profile logic in `run.sh` (or associated profile configs) to include these tools in `dev` and `dev+ai` profiles.
   - Ensure these profiles display correctly in the Ubuntu help menus.
