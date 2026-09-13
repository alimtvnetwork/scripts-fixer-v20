# Ubuntu IaC & Virtualization Setup Subtasks

## Objective
Update `scripts/os/ubuntu/*.sh` to support the installation of IaC and Virtualization tools on Ubuntu.

## Tasks
1. **Terraform**:
   - Add HashiCorp GPG key and repository to the system sources.
   - Install `terraform` via `apt-get install`.
   - Verify installation via `terraform -version`.
2. **VirtualBox**:
   - Add logic to install `virtualbox` and `virtualbox-ext-pack` via `apt-get`.
   - Ensure dependencies are handled and kernel modules are properly loaded.
3. **Vagrant**:
   - Add HashiCorp repository (if not already added by Terraform step).
   - Install `vagrant` via `apt-get`.
4. **Ansible**:
   - Add the official Ansible PPA (`ppa:ansible/ansible`).
   - Install `ansible` via `apt-get`.
   - Verify installation via `ansible --version`.
