#!/bin/bash
sudo apt-get update -y || true
bash scripts/os/ubuntu/profile-ubuntu-simple-dev.sh
bash scripts/os/ubuntu/install-node.sh
bash scripts/os/ubuntu/install-pnpm.sh
bash scripts/os/ubuntu/install-antigravity-manager.sh
bash scripts/os/ubuntu/install-antigravity.sh
