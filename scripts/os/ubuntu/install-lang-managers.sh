#!/bin/bash

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

update_path_in_profiles() {
    local EXPORT_LINE="$1"
    for profile in ~/.bashrc ~/.zshrc; do
        if [ -f "$profile" ] && ! grep -qF "$EXPORT_LINE" "$profile"; then
            echo "$EXPORT_LINE" >> "$profile"
        fi
    done
}

install_fnm() {
    if command_exists fnm; then
        echo "fnm is already installed."
        return 0
    fi
    echo "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    update_path_in_profiles 'export PATH="$HOME/.local/share/fnm:$PATH"'
    update_path_in_profiles 'eval "$(fnm env)"'
}

install_uv() {
    if command_exists uv; then
        echo "uv is already installed."
        return 0
    fi
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$HOME/.cargo/bin" sh
    update_path_in_profiles 'export PATH="$HOME/.cargo/bin:$PATH"'
}

install_rustup() {
    if command_exists rustup; then
        echo "rustup is already installed."
        return 0
    fi
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    update_path_in_profiles 'source "$HOME/.cargo/env"'
}

main() {
    install_fnm
    install_uv
    install_rustup
}

main
