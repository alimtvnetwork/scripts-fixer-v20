#!/bin/bash
set -e

echo -e "  \033[1;36m[  ..  ] Synchronizing VS Code settings, keybindings, and extensions...\033[0m"

USER_CONFIG_DIR="$HOME/.config/Code/User"
mkdir -p "$USER_CONFIG_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SOURCE_DIR="$(cd "$SCRIPT_DIR/../../11-vscode-settings-sync" 2>/dev/null && pwd || echo "")"

if [ -n "$SYNC_SOURCE_DIR" ] && [ -d "$SYNC_SOURCE_DIR" ]; then
    if [ -f "$SYNC_SOURCE_DIR/settings.json" ]; then
        cp -f "$SYNC_SOURCE_DIR/settings.json" "$USER_CONFIG_DIR/settings.json"
        echo -e "  \033[1;32m[  OK  ] Copied settings.json -> $USER_CONFIG_DIR/settings.json\033[0m"
    fi
    if [ -f "$SYNC_SOURCE_DIR/keybindings.json" ]; then
        cp -f "$SYNC_SOURCE_DIR/keybindings.json" "$USER_CONFIG_DIR/keybindings.json"
        echo -e "  \033[1;32m[  OK  ] Copied keybindings.json -> $USER_CONFIG_DIR/keybindings.json\033[0m"
    fi
fi

# If code command is available, install essential developer extensions
if command -v code &>/dev/null; then
    echo -e "  \033[1;36m[  ..  ] Installing curated VS Code extensions...\033[0m"
    EXTENSIONS=(
        "golang.Go"
        "rust-lang.rust-analyzer"
        "ms-python.python"
        "bmewburn.vscode-intelephense-client"
        "esbenp.prettier-vscode"
        "eamodio.gitlens"
        "tamasfe.even-better-toml"
        "timonwong.shellcheck"
    )
    for EXT in "${EXTENSIONS[@]}"; do
        code --install-extension "$EXT" --force 2>/dev/null || true
    done
    echo -e "  \033[1;32m[  OK  ] VS Code extensions installed and active.\033[0m"
fi
