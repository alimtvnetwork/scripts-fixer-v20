#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
ACCENT='\033[1;33m'
MUTED='\033[0;37m'
TEXT='\033[0m'

TARGET_MODEL="$1"

# Ensure Ollama is installed
if ! command -v ollama &>/dev/null; then
    echo -e "  ${SECONDARY}[  ..  ] Ollama not found. Installing Ollama runtime...${TEXT}"
    bash scripts/os/ubuntu/install-ollama.sh
fi

if [ -z "$TARGET_MODEL" ] || [ "$TARGET_MODEL" = "list" ] || [ "$TARGET_MODEL" = "ls" ]; then
    echo -e "\n  ${PRIMARY}Available Local AI / LLM Models:${TEXT}"
    echo -e "  ${MUTED}----------------------------------------------------------------------${TEXT}"
    printf "    ${SECONDARY}%-22s${TEXT}  ${ACCENT}%-10s${TEXT}  ${MUTED}%s${TEXT}\n" "qwen2.5-coder:7b" "4.7 GB" "Specialized Coding & Code Completion (7B)"
    printf "    ${SECONDARY}%-22s${TEXT}  ${ACCENT}%-10s${TEXT}  ${MUTED}%s${TEXT}\n" "qwen3.7-coder:14b" "8.4 GB" "Heavy Coding & Multi-file Architecture (14B)"
    printf "    ${SECONDARY}%-22s${TEXT}  ${ACCENT}%-10s${TEXT}  ${MUTED}%s${TEXT}\n" "glm4:9b" "5.5 GB" "Zhipu AI GLM-4 Bilingual Reasoning & Tool Calling (9B)"
    printf "    ${SECONDARY}%-22s${TEXT}  ${ACCENT}%-10s${TEXT}  ${MUTED}%s${TEXT}\n" "glm-edge:4b" "2.8 GB" "Zhipu AI GLM-Edge Fast On-Device Chat & Coding (4B)"
    printf "    ${SECONDARY}%-22s${TEXT}  ${ACCENT}%-10s${TEXT}  ${MUTED}%s${TEXT}\n" "kimi-k2:8b" "5.1 GB" "Moonshot AI Kimi K2 Long Context Reasoning (8B)"
    printf "    ${SECONDARY}%-22s${TEXT}  ${ACCENT}%-10s${TEXT}  ${MUTED}%s${TEXT}\n" "kimi-coder:8b" "4.9 GB" "Moonshot AI Kimi Coder Advanced Code Generation (8B)"
    printf "    ${SECONDARY}%-22s${TEXT}  ${ACCENT}%-10s${TEXT}  ${MUTED}%s${TEXT}\n" "deepseek-r1:8b" "4.9 GB" "DeepSeek R1 Step-by-Step Reasoning & Math (8B)"
    printf "    ${SECONDARY}%-22s${TEXT}  ${ACCENT}%-10s${TEXT}  ${MUTED}%s${TEXT}\n" "llama3.2:3b" "2.0 GB" "Meta Llama 3.2 Lightweight Fast Assistant (3B)"
    echo -e "  ${MUTED}----------------------------------------------------------------------${TEXT}"
    echo -e "  ${ACCENT}Usage:${TEXT} ./run.sh models <model_name>  (e.g. ./run.sh models glm4:9b)\n"
    exit 0
fi

echo -e "  ${SECONDARY}[  ..  ] Pulling model: $TARGET_MODEL via Ollama...${TEXT}"
ollama pull "$TARGET_MODEL"
echo -e "  ${PRIMARY}[  OK  ] Successfully downloaded and registered model: $TARGET_MODEL${TEXT}"
