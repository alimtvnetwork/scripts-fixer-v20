# Subtask 1: Windows VMware Installation Implementation

## Description
Modify the Windows setup script (`run.ps1`) to include the installation logic for VMware Workstation/Player.

## Steps
1. Add a check in `run.ps1` to detect if VMware Workstation/Player is already installed via Registry or WMI.
2. Download the VMware installer executable using `Invoke-WebRequest` to a temporary directory if not installed.
3. Execute the installer with silent arguments.
4. Perform post-installation cleanup (delete the downloaded installer).
5. Update logs to reflect the status of the installation.

## Files to Modify
- `run.ps1`
