# Windows Tasks: Terminal Utilities & Language Version Managers

## Objective
Update the `run.ps1` script (or create a dedicated module imported by it) to install the necessary tools on Windows using appropriate package managers like Scoop or direct downloads.

## Tasks
1. **Modern Terminal Utilities Installation (`run.ps1`)**
   - Add function to install `jq` via Scoop or Winget.
   - Add function to install `yq` via Scoop or Winget.
   - Add function to install `Zellij` (Note: Zellij on Windows may require WSL, document workaround or skip natively if unsupported, but provide instructions).

2. **Language Version Managers Installation (`run.ps1`)**
   - Add function to install `fnm` via Scoop or Winget, and add `fnm env` to `$PROFILE`.
   - Add function to install `uv` via direct PowerShell installer or Scoop.
   - Add function to install `rustup` via `rustup-init.exe` with silent flags.

3. **Validation & PATH Setup**
   - Ensure `$PROFILE` is updated with necessary initializations for `fnm`, `uv`, and `cargo/bin`.
