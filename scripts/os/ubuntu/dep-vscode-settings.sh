#!/bin/bash
set -e

sync_config_files() {
    local sync_dir="$1"
    local user_dir="$2"

    [ -d "$sync_dir" ] || return 0

    if [ -f "$sync_dir/settings.json" ]; then
        cp -f "$sync_dir/settings.json" "$user_dir/settings.json"
        echo -e "  \033[1;32m[  OK  ] Copied settings.json -> $user_dir/settings.json\033[0m"
    fi

    if [ -f "$sync_dir/keybindings.json" ]; then
        cp -f "$sync_dir/keybindings.json" "$user_dir/keybindings.json"
        echo -e "  \033[1;32m[  OK  ] Copied keybindings.json -> $user_dir/keybindings.json\033[0m"
    fi
}

gather_extensions() {
    local sync_dir="$1"
    local base_exts=(
        "golang.Go"
        "rust-lang.rust-analyzer"
        "ms-python.python"
        "bmewburn.vscode-intelephense-client"
        "esbenp.prettier-vscode"
        "eamodio.gitlens"
        "tamasfe.even-better-toml"
        "timonwong.shellcheck"
        "redhat.vscode-yaml"
        "streetsidesoftware.code-spell-checker"
    )

    if [ -f "$sync_dir/extensions.json" ]; then
        local json_exts
        json_exts=$(grep -o '"[^"]*"' "$sync_dir/extensions.json" | grep -v 'extensions' | grep -v 'disabled' | tr -d '"' || true)
        printf "%s\n" "${base_exts[@]}" $json_exts | sort -u
        return
    fi

    printf "%s\n" "${base_exts[@]}" | sort -u
}

install_extension_worker() {
    local ext="$1"

    if code --install-extension "$ext" --force >/dev/null 2>&1; then
        echo -e "    \033[1;32m✔ Installed: $ext\033[0m"
    else
        echo -e "    \033[1;31m✖ Failed: $ext\033[0m"
    fi
}

install_extensions_parallel() {
    local -a exts=("$@")
    local installed_list
    installed_list=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')

    local -a to_install=()
    local ext_lower
    for ext in "${exts[@]}"; do
        ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
        if echo "$installed_list" | grep -qx "$ext_lower"; then
            continue
        fi
        to_install+=("$ext")
    done

    if [ ${#to_install[@]} -eq 0 ]; then
        echo -e "    \033[1;32m✔ All ${#exts[@]} curated extensions are already installed and verified.\033[0m"
        return 0
    fi

    echo -e "    \033[1;36m-> Installing ${#to_install[@]} missing extension(s) in parallel (pool: 4)...\033[0m"
    local max_workers=4
    local running=0

    for ext in "${to_install[@]}"; do
        install_extension_worker "$ext" &
        running=$((running + 1))

        if [ "$running" -ge "$max_workers" ]; then
            wait -n 2>/dev/null || wait
            running=$((running - 1))
        fi
    done

    wait
}

main() {
    echo -e "  \033[1;36m[  ..  ] Synchronizing VS Code settings, keybindings, and extensions...\033[0m"

    local user_dir="$HOME/.config/Code/User"
    mkdir -p "$user_dir"

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local sync_dir
    sync_dir="$(cd "$script_dir/../../11-vscode-settings-sync" 2>/dev/null && pwd || echo "")"

    sync_config_files "$sync_dir" "$user_dir"

    if ! command -v code &>/dev/null; then
        echo -e "  \033[0;37m[ SKIP ] VS Code CLI 'code' not found on PATH. Skipping extensions.\033[0m"
        return 0
    fi

    echo -e "  \033[1;36m[  ..  ] Verifying curated VS Code extensions...\033[0m"
    mapfile -t all_exts < <(gather_extensions "$sync_dir")
    install_extensions_parallel "${all_exts[@]}"
    echo -e "  \033[1;32m[  OK  ] VS Code configuration and extensions complete.\033[0m"
}

main "$@"
