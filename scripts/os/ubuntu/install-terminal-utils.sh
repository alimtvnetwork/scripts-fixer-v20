#!/bin/bash

# Utility to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_jq() {
    if command_exists jq; then
        echo "jq is already installed."
        return 0
    fi
    echo "Installing jq..."
    sudo apt-get update -y
    sudo apt-get install -y jq
}

install_yq() {
    if command_exists yq; then
        echo "yq is already installed."
        return 0
    fi
    echo "Installing yq..."
    sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
    sudo chmod a+x /usr/local/bin/yq
}

install_zellij() {
    if command_exists zellij; then
        echo "Zellij is already installed."
        return 0
    fi
    echo "Installing Zellij..."
    local ZELLIJ_TAR="zellij-x86_64-unknown-linux-musl.tar.gz"
    wget -q "https://github.com/zellij-org/zellij/releases/latest/download/$ZELLIJ_TAR"
    tar -xf "$ZELLIJ_TAR"
    sudo mv zellij /usr/local/bin/
    rm "$ZELLIJ_TAR"
}

main() {
    install_jq
    install_yq
    install_zellij
}

main
