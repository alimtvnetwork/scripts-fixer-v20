# Task 12: Translate Docker Post-Installation & Rootless
## Where
- `01-ubuntu-installation.md`, `02-fedora-installation.md`, `03-centos-installation.md`
## What
Translate: `usermod -aG docker $USER`, `curl -fsSL https://get.docker.com/rootless | sh`.
## How
- **All**: Add instructions for `sudo groupadd docker`, `sudo usermod -aG docker $USER`, `newgrp docker`.
- Include the rootless install script `dockerd-rootless-setuptool.sh install` and the rootless curl command.
