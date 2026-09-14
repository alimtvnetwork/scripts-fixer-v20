#!/bin/bash
set -e

ensure_vscode_installed() {
    if command -v code &>/dev/null; then
        return 0
    fi

    echo -e "  \033[1;36m[  ..  ] Installing Visual Studio Code...\033[0m"
    local is_installed=false

    if command -v snap &>/dev/null && systemctl is-active --quiet snapd 2>/dev/null; then
        if sudo snap install code --classic 2>/dev/null; then
            is_installed=true
        fi
    fi

    if [ "$is_installed" != "true" ]; then
        echo -e "  \033[0;37m[ INFO ] Snap unavailable; configuring Microsoft APT repository for VS Code...\033[0m"
        sudo apt-get update -y || true
        sudo apt-get install -y wget gpg apt-transport-https || true
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg 2>/dev/null || true

        if [ -f /tmp/packages.microsoft.gpg ]; then
            sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg 2>/dev/null || true
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' 2>/dev/null || true
            rm -f /tmp/packages.microsoft.gpg
            sudo apt-get update -y || true
            sudo apt-get install -y code || true
        fi
    fi
}

main() {
    bash scripts/os/ubuntu/profile-ubuntu-basic.sh
    ensure_vscode_installed

    if command -v code &>/dev/null; then
        local code_ver
        code_ver=$(code --version 2>/dev/null | head -n 1 || echo "operational")
        echo -e "  \033[1;32m[  OK  ] Visual Studio Code is confirmed installed ($code_ver).\033[0m"
    fi

    bash scripts/os/ubuntu/dep-vscode-settings.sh
}

main "$@"
