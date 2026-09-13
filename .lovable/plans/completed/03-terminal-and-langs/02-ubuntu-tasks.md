# Ubuntu Tasks: Terminal Utilities & Language Version Managers

## Objective
Update or create scripts within `scripts/os/ubuntu/` to install the target utilities for Ubuntu.

## Tasks
1. **Modern Terminal Utilities Installation (`scripts/os/ubuntu/install-terminal-utils.sh`)**
   - Add function to install `jq` via `apt`.
   - Add function to install `yq` via binary download or PPA.
   - Add function to install `Zellij` via binary download or `cargo` (if Rust is installed first).

2. **Language Version Managers Installation (`scripts/os/ubuntu/install-lang-managers.sh`)**
   - Add function to install `fnm` via official install script and update `~/.bashrc`.
   - Add function to install `uv` via curl bash script.
   - Add function to install `rustup` via `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y`.

3. **Main Script Integration**
   - Ensure the new scripts are correctly sourced and called within the main Ubuntu setup entrypoint.
   - Validate `PATH` setup in shell profiles (`~/.bashrc`, `~/.zshrc`).
