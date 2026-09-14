#!/bin/bash
set -e

sudo apt-get update -y || true

bash scripts/os/ubuntu/profile-ubuntu-vscode.sh
bash scripts/os/ubuntu/install-github-desktop.sh
bash scripts/os/ubuntu/install-golang.sh
bash scripts/os/ubuntu/install-rust.sh
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env" || true
bash scripts/os/ubuntu/install-php.sh
bash scripts/os/ubuntu/install-python3.sh
bash scripts/os/ubuntu/dep-vscode-settings.sh
bash scripts/os/ubuntu/install-lang-managers.sh
