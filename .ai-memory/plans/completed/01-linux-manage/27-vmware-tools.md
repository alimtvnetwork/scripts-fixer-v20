# Task 27: Translate VMware Tools & VMHGFS Mount
## Where
- `01-ubuntu-installation.md`, `02-fedora-installation.md`, `03-centos-installation.md`
## What
Translate: `apt-get install open-vm-tools`, `/usr/bin/vmhgfs-fuse --enabled`, `sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other`.
## How
- **Ubuntu**: `sudo apt install open-vm-tools open-vm-tools-desktop`.
- **Fedora/CentOS**: `sudo dnf install open-vm-tools open-vm-tools-desktop`.
- **All**: Detail the `vmhgfs-fuse` commands exactly.
