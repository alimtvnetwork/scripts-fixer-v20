# 69-install-antigravity

Google Antigravity IDE and CLI (`agy`) installer, verification, and conversation cleanup toolkit.

## Components

- `run.ps1`: Primary orchestrator script.
- `manifest.json`: Package metadata and supported verbs.
- `helpers/`:
  - `check.ps1`: Presence detection for IDE and CLI.
  - `env-path.ps1`: Environment variable and PATH management.
  - `install-ide.ps1`: Silent IDE installation routines.
  - `install-cli.ps1`: CLI binary download and deployment.
  - `shortcuts.ps1`: Desktop and Start Menu shortcut creation.
  - `telemetry.ps1`: Installation database tracking.
  - `uninstall.ps1`: Process termination and uninstallation.
  - `verify.ps1`: Binary and version verification.
  - `clear-agy.ps1`: Conversation optimizer CLI interface.
  - `agy_optimizer.py`: SQLite conversation pruner and brain cache cleaner.

## Usage

```powershell
# Check installation status
.\run.ps1 agy check

# Predict cleanup keeping latest 10 conversations
.\run.ps1 agy clear 10

# Predict cleanup keeping latest 5 conversations
.\run.ps1 agy clear -Keep 5

# Revert a pruning transaction
.\clear-agy.ps1 -Undo tx-id
```
