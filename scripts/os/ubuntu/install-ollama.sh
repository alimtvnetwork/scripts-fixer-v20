#!/bin/bash
set -e

echo -e "  \033[1;36m[  ..  ] Installing Ollama & Local LLM Environment...\033[0m"
if command -v ollama &>/dev/null; then
    echo -e "  \033[1;32m[  OK  ] Ollama is already installed: $(ollama --version)\033[0m"
else
    curl -fsSL https://ollama.com/install.sh | sh
fi

if systemctl is-active --quiet ollama; then
    echo -e "  \033[1;32m[  OK  ] Ollama service is active and running.\033[0m"
else
    sudo systemctl enable --now ollama 2>/dev/null || true
fi

echo -e "  \033[1;36m[  ..  ] Pulling default recommended coding & reasoning models...\033[0m"
ollama pull qwen2.5-coder:7b 2>/dev/null || ollama pull llama3.2:3b 2>/dev/null || true
echo -e "  \033[1;32m[  OK  ] Local LLM infrastructure ready.\033[0m"
