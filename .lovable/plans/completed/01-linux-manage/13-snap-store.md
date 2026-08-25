# Task 13: Translate Snap Store & Snapd
## Where
- `01-ubuntu-installation.md`, `02-fedora-installation.md`, `03-centos-installation.md`
## What
Translate: `apt install snapd`, `snap refresh snap-store`.
## How
- **Ubuntu**: `snapd` is pre-installed. `sudo snap refresh snap-store`.
- **Fedora**: `sudo dnf install snapd`, `sudo ln -s /var/lib/snapd/snap /snap`.
- **CentOS**: `sudo yum install epel-release`, `sudo yum install snapd`, `sudo systemctl enable --now snapd.socket`.
