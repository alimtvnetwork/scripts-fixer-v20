#!/bin/bash
set -e
bash scripts/os/ubuntu/profile-ubuntu-basic.sh
if ! command -v code &>/dev/null; then
    sudo snap install code --classic
fi
bash scripts/os/ubuntu/dep-vscode-settings.sh
