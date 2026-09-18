# Subtask 1: Torrent Installers

## Scope
Add installers for `qtorrent` (qBittorrent) and `utorrent` on both Windows and Ubuntu.

## Steps
1. **Update `registry.yaml`**:
   - Add entries for `qtorrent` (e.g., ID 76).
   - Add entries for `utorrent` (e.g., ID 77).
   - Define download URLs or package manager commands (e.g., `choco install qbittorrent`, `apt install qbittorrent`).

2. **Windows (`run.ps1`)**:
   - Add `qtorrent` and `utorrent` cases in the main installation switch block.
   - Implement winget/choco/direct download logic based on `registry.yaml`.

3. **Ubuntu (`run.sh`)**:
   - Add `qtorrent` and `utorrent` cases in the package installation logic.
   - Implement `apt`/`snap` commands as defined.

4. **Help Menu Updates**:
   - Update `Show-Help` in `run.ps1` to include `install qtorrent` and `install utorrent`.
   - Update `show_help` in `run.sh` similarly.
