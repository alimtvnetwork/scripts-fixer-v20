# VMware Workstation/Player Installation Plan

## Overview
Implement the automated installation of VMware Workstation or Player for both Windows (`run.ps1`) and Ubuntu (`scripts/os/ubuntu/`). The scripts should detect the OS and install the appropriate software seamlessly.

## Custom Rules and Constraints
1. **Idempotency**: All installation scripts must check if the target software (VMware Workstation or Player) is already installed before attempting installation.
2. **Version Parameterization**: The specific version of VMware to be downloaded and installed must be defined as a variable/parameter, not hardcoded into the download URLs deep in the script.
3. **Graceful Error Handling**: If the download fails or the installer returns a non-zero exit code, the script must catch the error, log it with a clear message, and halt execution without proceeding to post-installation steps.
4. **Quiet/Unattended Mode**: The installation commands must use the appropriate flags for silent/unattended installation (e.g., `/s` or similar for Windows, `--console --required --eulas-agreed` for Linux) to avoid blocking automation.

## Subtasks
- [Subtask 1: Windows VMware Installation Implementation](../subtasks/02-vmware-suite/01-task.md)
- [Subtask 2: Ubuntu VMware Installation Implementation](../subtasks/02-vmware-suite/02-task.md)
