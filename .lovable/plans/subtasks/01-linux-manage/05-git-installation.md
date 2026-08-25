# Task 05: Translate Git & Git LFS
## Where
- `01-ubuntu-installation.md`, `02-fedora-installation.md`, `03-centos-installation.md`
## What
Translate: `apt-get install -y git git-core git-lfs`, `add-apt-repository ppa:git-core/ppa`.
## How
- **Ubuntu**: `sudo add-apt-repository ppa:git-core/ppa`, `sudo apt update`, `sudo apt install git git-lfs -y`.
- **Fedora**: `sudo dnf install git git-lfs -y`.
- **CentOS**: `sudo yum install git git-lfs -y`. (Note EPEL might be needed for git-lfs).
