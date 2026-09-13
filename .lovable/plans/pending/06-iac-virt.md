# Infrastructure as Code (IaC) & Virtualization Plan

## Goal
Implement setup scripts and configurations for Terraform, VirtualBox, Vagrant, and Ansible across Windows and Ubuntu environments.

## Custom Rules & Constraints
1. **Idempotency**: All installation scripts must be idempotent. Do not re-install or fail if the tool is already present.
2. **Ansible on Windows**: Since Ansible is Unix-centric, its installation on Windows should only be attempted via WSL (Windows Subsystem for Linux), or otherwise cleanly skipped with a warning message.
3. **Version Pinning / Validation**: Where possible, script installations should allow for version specification or at least verify the minimum required version post-installation.
4. **Clean Aborts**: Ensure virtualization tools (VirtualBox/Vagrant) handle cases where virtualization is disabled in the BIOS/UEFI by exiting gracefully rather than causing hard crashes.
5. **Path Consistency**: All paths referenced in scripts must use repository-root relative paths or use appropriate environment variables (e.g., `$PSScriptRoot` in PowerShell, `$(dirname $0)` in Bash).

## Subtasks
- [01-windows.md](../subtasks/06-iac-virt/01-windows.md)
- [02-ubuntu.md](../subtasks/06-iac-virt/02-ubuntu.md)
