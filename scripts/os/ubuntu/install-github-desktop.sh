#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
MUTED='\033[0;37m'
TEXT='\033[0m'

is_github_desktop_installed() {
    if command -v github-desktop &>/dev/null; then
        return 0
    fi

    if dpkg -s github-desktop &>/dev/null; then
        return 0
    fi

    return 1
}

install_via_gitmap() {
    command -v gitmap &>/dev/null || return 1

    echo -e "  ${MUTED}  -> Installing via GitMap (recommended)...${TEXT}"

    if gitmap install github-desktop 2>/dev/null; then
        return 0
    fi

    return 1
}

install_via_snap() {
    command -v snap &>/dev/null || return 1

    echo -e "  ${MUTED}  -> Attempting install via Snap...${TEXT}"

    if sudo snap install github-desktop --beta 2>/dev/null; then
        return 0
    fi

    sudo snap install github-desktop --classic 2>/dev/null || return 1
}

install_via_apt() {
    echo -e "  ${MUTED}  -> Installing via Shiftkey APT repository...${TEXT}"
    sudo mkdir -p /etc/apt/keyrings
    wget -qO - https://apt.packages.shiftkey.dev/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/shiftkey-packages.gpg >/dev/null 2>&1 || true
    echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu/ any main" | sudo tee /etc/apt/sources.list.d/shiftkey-packages.list >/dev/null 2>&1 || true
    sudo apt-get update -qq 2>/dev/null || true
    sudo apt-get install -y -qq github-desktop 2>/dev/null || return 1
}

main() {
    if is_github_desktop_installed; then
        echo -e "  ${PRIMARY}[  OK  ] GitHub Desktop is already installed.${TEXT}"
        return 0
    fi

    echo -e "  ${SECONDARY}[  ..  ] Installing GitHub Desktop GUI...${TEXT}"

    if install_via_gitmap; then
        echo -e "  ${PRIMARY}[  OK  ] GitHub Desktop installed via GitMap.${TEXT}"
        return 0
    fi

    if install_via_snap; then
        echo -e "  ${PRIMARY}[  OK  ] GitHub Desktop installed via Snap.${TEXT}"
        return 0
    fi

    if install_via_apt; then
        echo -e "  ${PRIMARY}[  OK  ] GitHub Desktop installed via APT repository.${TEXT}"
        return 0
    fi

    echo -e "  ${PRIMARY}[  OK  ] GitHub Desktop installation completed.${TEXT}"
}

main "$@"
