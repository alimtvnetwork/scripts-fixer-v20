# Task 11: Translate Docker Engine & CLI
## Where
- `01-ubuntu-installation.md`, `02-fedora-installation.md`, `03-centos-installation.md`
## What
Translate: `apt-get install docker-ce docker-ce-cli containerd.io`.
## How
- **Ubuntu**: `sudo apt install docker.io -y` or setup Docker apt repo.
- **Fedora**: `sudo dnf install moby-engine docker-compose -y`.
- **CentOS**: setup docker-ce repo using `yum-config-manager`, then `sudo yum install docker-ce docker-ce-cli containerd.io`.
