#!/bin/bash
set -e

# ubuntu+dev+ai profile
# = ubuntu+dev (VS Code + settings + Golang + Rust + PHP + Python3 + Node + pnpm)
# + Antigravity (agy) AI coding assistant

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
ACCENT='\033[1;33m'
MUTED='\033[0;37m'
TEXT='\033[0m'

echo -e "\n  ${PRIMARY}ubuntu+dev+ai Profile${TEXT}"
echo -e "  ${MUTED}=========================================${TEXT}"
echo -e "  ${MUTED}  = ubuntu+dev + Antigravity${TEXT}\n"

# ── Phase 1: Full dev stack (includes Antigravity IDE) ──────────────────────────
echo -e "  ${ACCENT}[Phase 1] Installing ubuntu+dev stack...${TEXT}"
bash scripts/os/ubuntu/profile-ubuntu-dev.sh

# ── Phase 2: Local LLM Runner (Ollama) ─────────────────────────────────────────
echo -e "\n  ${ACCENT}[Phase 2] Installing Ollama local LLM runner...${TEXT}"
bash scripts/os/ubuntu/install-models.sh

echo -e "\n  ${PRIMARY}ubuntu+dev+ai profile complete!${TEXT}"
echo -e "  ${MUTED}  agy    - AI coding assistant (run anywhere)${TEXT}\n"
