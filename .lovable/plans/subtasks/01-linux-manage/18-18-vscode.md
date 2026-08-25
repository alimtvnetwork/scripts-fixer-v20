# Task 18: Translate VSCode Installation
## Where
- `01-ubuntu-installation.md`, `02-fedora-installation.md`, `03-centos-installation.md`
## What
Translate: `snap install code --classic` OR `apt install code` via `packages.microsoft.com`.
## How
- **Ubuntu**: `sudo snap install code --classic` OR apt repo setup.
- **Fedora**: `sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc`, add yum repo, `sudo dnf install code`.
- **CentOS**: Same as Fedora using `yum`.
