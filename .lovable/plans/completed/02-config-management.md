# Subtask 2: Configuration Management

## Scope
Implement `export-config <app>` and `import-config <app>` commands to backup and restore app settings. Target apps: `qtorrent`, `utorrent`, `vscode`.

## Steps
1. **Directory Structure**:
   - Create a dedicated backup folder (e.g., `./configs`).

2. **Windows (`run.ps1`)**:
   - Add `export-config` and `import-config` commands to argument parsing.
   - Implement logic for:
     - `qtorrent`: `%APPDATA%\qBittorrent\` (copy files to `./configs/qtorrent.json` or `.ini` as appropriate).
     - `utorrent`: `%APPDATA%\uTorrent\` (copy files).
     - `vscode`: `%APPDATA%\Code\User\settings.json` and `keybindings.json` (copy to `./configs/vscode/`).
   - Implement restore logic copying from `./configs` back to respective `%APPDATA%` paths.

3. **Ubuntu (`run.sh`)**:
   - Add `export-config` and `import-config` commands to argument parsing.
   - Implement logic for:
     - `qtorrent`: `~/.config/qBittorrent/`.
     - `utorrent`: Dependent on Linux installation path (usually Wine or WebUI server config).
     - `vscode`: `~/.config/Code/User/settings.json`.
   - Implement restore logic.

4. **Help Menu Updates**:
   - Add `export-config <app>` and `import-config <app>` to help menus in both scripts.
