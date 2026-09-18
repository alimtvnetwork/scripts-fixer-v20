# Task 14: Translate Python 2.7 Setup
## Where
- `01-ubuntu-installation.md`, `02-fedora-installation.md`, `03-centos-installation.md`
## What
Translate: `wget https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz`, `make altinstall`, `update-alternatives`.
## How
- **All**: Include compilation steps: `tar xzf Python-2.7.9.tgz`, `./configure --enable-optimizations`, `sudo make altinstall`.
- **Ubuntu/Fedora/CentOS**: Provide the correct compilation prerequisites (`build-essential`, `libssl-dev` / `gcc`, `openssl-devel`).
