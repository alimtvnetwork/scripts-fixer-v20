#!/bin/bash
set -e

echo -e "  \033[1;36m[  ..  ] Detecting Arch Linux environment and package managers...\033[0m"

if ! command -v pacman &>/dev/null; then
    echo -e "  \033[1;33m[ WARN ] pacman not detected. This system appears to be non-Arch (Debian/Ubuntu/Fedora).\033[0m"
    echo -e "  \033[0;37m        Installing Arch-compatibility build utilities and pacman emulation tooling...\033[0m"
    sudo apt-get update -qq 2>/dev/null || true
    sudo apt-get install -y pacman-package-manager arch-install-scripts 2>/dev/null || true
    exit 0
fi

echo -e "  \033[1;36m[  ..  ] Updating Arch system repositories (pacman -Syu)...\033[0m"
sudo pacman -Syu --noconfirm

echo -e "  \033[1;36m[  ..  ] Installing base development toolchain & modern CLI utilities...\033[0m"
sudo pacman -S --needed --noconfirm base-devel git zsh curl wget vim aria2 ripgrep fzf fd bat fastfetch code

# Check for yay or paru AUR helper
if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
    echo -e "  \033[1;36m[  ..  ] Bootstrapping yay AUR helper...\033[0m"
    TMP_YAY=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$TMP_YAY"
    (cd "$TMP_YAY" && makepkg -si --noconfirm)
    rm -rf "$TMP_YAY"
fi

echo -e "  \033[1;32m[  OK  ] Arch Linux development environment and AUR tooling configured.\033[0m"
