#!/bin/bash
sudo apt-get update -y || true

bash scripts/os/ubuntu/dep-git.sh
bash scripts/os/ubuntu/dep-omyzsh.sh
bash scripts/os/ubuntu/dep-zsh-autosuggestions.sh
bash scripts/os/ubuntu/dep-aria2c.sh

if ! sudo apt-get install -y vim build-essential wget curl file zlib1g zlib1g-dev libssl-dev; then
    sudo apt-get update -y
    sudo apt-get install -y --fix-missing vim build-essential wget curl file zlib1g zlib1g-dev libssl-dev || true
fi
bash scripts/os/ubuntu/install-terminal-utils.sh
