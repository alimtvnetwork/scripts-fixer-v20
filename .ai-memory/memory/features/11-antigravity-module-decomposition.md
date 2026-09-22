# Antigravity Module Architecture & File Size Reduction History

> **Status:** Active Reference & Permanent Architecture Record  
> **Target:** `scripts/69-install-antigravity/` and root `run.ps1` dispatcher  
> **Last Updated:** Refactored for modular sub-files and <= 8-15 line micro-functions

---

## 1. Architectural Overview

To adhere to the repository's strict standard of maintaining files under **100 lines** and functions targeting **<= 8 lines of execution logic (max 15 lines)**, the Antigravity runner (`scripts/69-install-antigravity/run.ps1`) was decomposed from a monolithic 551-line file into a clean, modular orchestrator supported by 8 specialized helper scripts in `scripts/69-install-antigravity/helpers/`.

### Directory Layout

```text
scripts/69-install-antigravity/
├── manifest.json                  # Package registry manifest
├── run.ps1                        # Lean orchestrator (~85 lines)
└── helpers/
    ├── agy_optimizer.py           # Cross-platform SQLite conversation pruner & prediction engine
    ├── clear-agy.ps1              # Database optimizer CLI wrapper with -Keep <N> support
    ├── check.ps1                  # Candidate discovery & installation presence detection
    ├── env-path.ps1               # User/Process PATH modification & broadcast helper
    ├── install-cli.ps1            # CLI zip fetch, extraction & binary deployment
    ├── install-ide.ps1            # IDE installer download, fallback API & silent execution
    ├── shortcuts.ps1              # Desktop & Start Menu shortcut generation
    ├── telemetry.ps1              # Database success recorder bridge
    ├── uninstall.ps1              # Process termination & surgical cleanup
    └── verify.ps1                 # Version check execution & IDE verification
```

---

## 2. Responsibilities of Extracted Helper Files

1. **`run.ps1` (Orchestrator, ~85 lines):**
   - Handles cross-platform Unix/Linux forwarding.
   - Dot-sources modular helpers from `helpers/`.
   - Defines high-level routines `Install-Antigravity` and `Install-AntigravityCLIOnly`.
   - Dispatches subcommands: `cli`, `check`, `uninstall`, `clean`, `clear`, `predict`, `default`.

2. **`helpers/env-path.ps1`:**
   - `Broadcast-EnvironmentChange`: P/Invoke `SendMessageTimeout` for `WM_SETTINGCHANGE`.
   - `Update-UserPath`: Semicolon-delimited user PATH updating.
   - `Update-ProcessPath`: Process-level PATH updating.
   - `Update-EnvironmentPath`: Master coordinator.

3. **`helpers/shortcuts.ps1`:**
   - `New-AntigravityShortcut`: WScript.Shell COM object shortcut creator.
   - `Create-DesktopShortcut`: Shortcut on User Desktop.
   - `Create-StartMenuShortcut`: Shortcut in Start Menu Programs.
   - `Create-Shortcuts`: Master coordinator.

4. **`helpers/check.ps1`:**
   - `Find-ExistingIdeCandidate`: Checks standard LocalAppData and ProgramFiles paths.
   - `Test-HasCli`: Checks PATH and `~/.antigravity/bin/`.
   - `Check-Antigravity`: Formatted status output.

5. **`helpers/verify.ps1`:**
   - `Verify-CliCommand`: Executes `--version` on CLI executables.
   - `Verify-IdePresence`: Verifies presence of IDE executable.
   - `Verify-AntigravityInstallation`: Master verifier.

6. **`helpers/install-ide.ps1`:**
   - `Invoke-ReferenceInstaller`: Checks existing custom installers.
   - `Get-IdeDownloadUrl`: Determines Google Storage URL for arm64/x64.
   - `Get-IdeFallbackUrl`: Auto-updater API and gvt1 fallback.
   - `Download-IdeInstaller`: Handles HTTP download with timeout and size check.
   - `Execute-SilentIdeInstall`: Executes `/S` (NSIS) or `/VERYSILENT` (Inno Setup).
   - `Install-AntigravityIDE`: Master coordinator.

7. **`helpers/install-cli.ps1`:**
   - `Ensure-CliDirectory`: Prepares `~/.antigravity/bin`.
   - `Test-HasExistingCliBinaries`: Checks existing binaries.
   - `Test-CopyLocalAgy`: Checks local appdata binaries.
   - `Get-CliDownloadUrl`: Resolves latest release asset from GitHub API.
   - `Deploy-ExtractedCli`: Extracts zip and places `agy.exe` and `antigravity.exe`.
   - `Install-AntigravityCLI`: Master coordinator.

8. **`helpers/uninstall.ps1`:**
   - `Stop-RunningAntigravityProcs`: Stops running Antigravity processes.
   - `Invoke-IdeUninstallerExecutable`: Executes native uninstaller silently.
   - `Remove-IdeResidualDirectories`: Deletes leftover program directories.
   - `Remove-CliResidualDirectories`: Deletes `~/.antigravity` files.
   - `Remove-AntigravityShortcuts`: Removes Desktop and Start Menu links.
   - `Remove-FromPathVariables`: Strips directory from User and Process PATH.
   - `Uninstall-Antigravity`: Master coordinator.

9. **`helpers/clear-agy.ps1` & `helpers/agy_optimizer.py`:**
   - SQLite conversation pruning into reversible backup database (`antigravity-backup.db`).
   - Ephemeral Gemini brain cleanup (`crashes`, `task_logs`, `logs`).
   - Supports `-Keep <N>` (or positional `<count>`, e.g., `.\run.ps1 agy clear 10`) to preserve the latest N conversations intact and prune older ones to their last 1-2 turns.
   - Prediction mode by default (`-Predict`).

---

## 3. Usage & Verification Commands

All changes have been validated across:
- `.\run.ps1 agy check`: PASS
- `.\run.ps1 agy clear 10`: PASS (prediction mode)
- `.\run.ps1 agy clear -Keep 5`: PASS (prediction mode)
- `.\clear-agy.ps1 10`: PASS
- `.\clean-agy.ps1 10`: PASS
- `.\scripts\69-install-antigravity\run.ps1 check`: PASS
- `.\scripts\69-install-antigravity\run.ps1 clear 10`: PASS
- `.\run.ps1 -Help`: PASS
- Linux Bash (`./clear-agy.sh --keep 10`, `scripts-linux/run.sh agy clear 10`): PASS
