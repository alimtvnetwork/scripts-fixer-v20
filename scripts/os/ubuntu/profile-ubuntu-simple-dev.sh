#!/bin/bash
set -e
bash scripts/os/ubuntu/profile-ubuntu-vscode.sh
bash scripts/os/ubuntu/install-golang.sh
bash scripts/os/ubuntu/install-rust.sh
bash scripts/os/ubuntu/install-php.sh
bash scripts/os/ubuntu/install-python3.sh
bash scripts/os/ubuntu/dep-vscode-settings.sh
