#!/bin/bash
ZSH_PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$ZSH_PLUGIN_DIR" ]; then
    ZSH_PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$ZSH_PLUGIN_DIR" ]; then
    sudo git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR"
else
    echo "zsh-autosuggestions is already installed."
fi
else
    echo "zsh-autosuggestions is already installed."
fi
