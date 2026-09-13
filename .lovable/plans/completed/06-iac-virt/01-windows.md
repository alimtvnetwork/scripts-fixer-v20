# Windows IaC & Virtualization Setup Subtasks

## Objective
Update `run.ps1` and any associated PowerShell scripts to support the installation and configuration of IaC and Virtualization tools on Windows.

## Tasks
1. **Terraform**:
   - Add a check in `run.ps1` (or a dedicated module) for Terraform.
   - Implement downloading the Terraform zip and placing it in a directory within the user's PATH (e.g., via Chocolatey or Scoop if available, otherwise direct download).
2. **VirtualBox**:
   - Implement installation logic for VirtualBox (e.g., using `winget install -e --id Oracle.VirtualBox`).
   - Add a post-install check for successful installation.
3. **Vagrant**:
   - Implement installation logic for Vagrant (e.g., using `winget install -e --id Hashicorp.Vagrant`).
   - Ensure the Vagrant executable is available in the system PATH.
4. **Ansible**:
   - Add logic to check if WSL is enabled.
   - If WSL is present, attempt to install Ansible within the default WSL distribution.
   - If WSL is missing, output a warning message stating "Ansible installation skipped on Windows as WSL is required." and proceed without failing.
