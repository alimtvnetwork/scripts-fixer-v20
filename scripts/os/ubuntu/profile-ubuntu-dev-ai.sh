#!/bin/bash
set -e

# ubuntu+dev+ai profile
# = ubuntu+dev (VS Code + settings + Golang + Rust + PHP + Python3 + Node + pnpm)
# + Ollama LLM Runner (model list shown at end)
# + Antigravity (agy) AI coding assistant

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
ACCENT='\033[1;33m'
MUTED='\033[0;37m'
TEXT='\033[0m'

echo -e "\n  ${PRIMARY}ubuntu+dev+ai Profile${TEXT}"
echo -e "  ${MUTED}=========================================${TEXT}"
echo -e "  ${MUTED}  = ubuntu+dev + Ollama LLM + Antigravity${TEXT}\n"

# ── Phase 1: Full dev stack ────────────────────────────────────────────────────
echo -e "  ${ACCENT}[Phase 1] Installing ubuntu+dev stack...${TEXT}"
bash scripts/os/ubuntu/profile-ubuntu-dev.sh

# ── Phase 2: Local AI / LLM (Ollama runner + model list) ─────────────────────
echo -e "\n  ${ACCENT}[Phase 2] Installing Ollama LLM runner...${TEXT}"
bash scripts/os/ubuntu/install-models.sh

# ── Phase 3: Antigravity agy CLI ──────────────────────────────────────────────
echo -e "\n  ${ACCENT}[Phase 3] Installing Antigravity (agy)...${TEXT}"
bash scripts/os/ubuntu/install-antigravity.sh

echo -e "\n  ${PRIMARY}ubuntu+dev+ai profile complete!${TEXT}"
echo -e "  ${MUTED}  agy    - AI coding assistant (run anywhere)${TEXT}"
echo -e "  ${MUTED}  ollama - Local LLM runner${TEXT}"
echo -e "  ${MUTED}  Use: ./run models <name> to pull a local model${TEXT}\n"
