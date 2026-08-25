# Task 03: Translate System Updates
## Where
- `01-ubuntu-installation.md`, `02-fedora-installation.md`, `03-centos-installation.md` (System Updates section)
## What
Translate: `apt update -y && apt upgrade -y`, `apt-get autoremove --purge`, `apt clean`.
## How
- **Ubuntu**: Use `sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge && sudo apt clean`.
- **Fedora**: Use `sudo dnf upgrade -y && sudo dnf autoremove -y && sudo dnf clean all`.
- **CentOS**: Use `sudo yum update -y && sudo yum autoremove -y && sudo yum clean all`.
