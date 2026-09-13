#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
MUTED='\033[0;37m'
TEXT='\033[0m'

echo -e "\n  ${SECONDARY}=== Installing Antigravity Suite Profile (Ubuntu) ===${TEXT}"

echo -e "  ${MUTED}[1/1] Installing Antigravity...${TEXT}"
bash scripts/os/ubuntu/install-antigravity.sh

echo -e "\n  ${PRIMARY}[DONE ] Antigravity Suite Profile installed successfully!${TEXT}"
