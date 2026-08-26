#!/bin/bash
set -e

echo -e "  \033[1;36m[  ..  ] Installing Modern CLI Dev Tools (fastfetch, bat, eza, ripgrep, fzf)...\033[0m"
sudo apt-get update -qq
sudo apt-get install -y ripgrep fzf fd-find bat 2>/dev/null || true

# Install Fastfetch PPA if on Ubuntu
if ! command -v fastfetch &>/dev/null; then
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch 2>/dev/null || true
    sudo apt-get update -qq 2>/dev/null || true
    sudo apt-get install -y fastfetch 2>/dev/null || true
fi

# Install eza if available
if ! command -v eza &>/dev/null; then
    sudo apt-get install -y gpg wget 2>/dev/null || true
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null 2>&1 || true
    sudo apt-get update -qq 2>/dev/null || true
    sudo apt-get install -y eza 2>/dev/null || true
fi

echo -e "  \033[1;32m[  OK  ] Modern CLI developer tools configured.\033[0m"
