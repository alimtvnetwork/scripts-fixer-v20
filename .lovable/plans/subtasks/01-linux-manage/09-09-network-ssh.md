# Task 09: Translate Network & SSH Settings
## Where
- `01-ubuntu-installation.md`, `02-fedora-installation.md`, `03-centos-installation.md`
## What
Translate: `systemctl restart ssh`, `ssh-keygen -t rsa -b 4096`, `cat ~/.ssh/id_rsa.pub`, `touch ~/.ssh/authorized_keys`.
## How
- **Ubuntu**: `sudo apt install openssh-server`, `sudo systemctl enable --now ssh`.
- **Fedora/CentOS**: `sudo dnf install openssh-server`, `sudo systemctl enable --now sshd`.
- **All**: Provide keygen commands identically.
