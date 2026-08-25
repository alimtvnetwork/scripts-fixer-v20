#!/bin/bash
bash scripts/os/ubuntu/dep-git.sh
bash scripts/os/ubuntu/dep-omyzsh.sh
bash scripts/os/ubuntu/dep-zsh-autosuggestions.sh
bash scripts/os/ubuntu/dep-aria2c.sh
apt-get install -y vim build-essential wget curl file zlib1g zlib1g-dev libssl-dev
