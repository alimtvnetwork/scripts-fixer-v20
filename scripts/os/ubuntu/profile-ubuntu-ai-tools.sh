#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
MUTED='\033[0;37m'
TEXT='\033[0m'

echo -e "\n  ${SECONDARY}=== Installing AI Tools Suite Profile (Ubuntu) ===${TEXT}"

echo -e "  ${MUTED}[1/4] Installing Antigravity...${TEXT}"
bash scripts/os/ubuntu/install-antigravity.sh

echo -e "  ${MUTED}[2/4] Installing Codex UI...${TEXT}"
bash scripts/os/ubuntu/install-codex.sh

echo -e "  ${MUTED}[3/4] Installing PlotCode UI...${TEXT}"
bash scripts/os/ubuntu/install-plotcode.sh

echo -e "  ${MUTED}[4/4] Installing Claude Code (UI & CLI)...${TEXT}"
bash scripts/os/ubuntu/install-claude-code.sh

echo -e "\n  ${PRIMARY}[DONE ] All AI Tools installed successfully!${TEXT}"
