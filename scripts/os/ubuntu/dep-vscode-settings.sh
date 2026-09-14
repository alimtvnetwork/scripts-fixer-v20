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

read_extensions_python() {
    local json_file="$1"

    python3 -c "
import json, sys
try:
    with open(sys.argv[1], 'r', encoding='utf-8') as f:
        data = json.load(f)
    disabled = {str(x).strip().lower() for x in data.get('disabled', []) if str(x).strip()}
    enabled = [str(x).strip().lower() for x in data.get('extensions', []) if str(x).strip()]
    for ext in enabled:
        if ext not in disabled and not ext.startswith('vscode.'):
            print(ext)
except Exception:
    pass
" "$json_file" 2>/dev/null
}

read_extensions_fallback() {
    local json_file="$1"

    sed -n '/"extensions": *\[/,/\]/p' "$json_file" \
        | grep -o '"[^"]*"' \
        | grep -v 'extensions' \
        | tr -d '"' \
        | tr '[:upper:]' '[:lower:]' \
        | grep -v '^vscode\.' || true
}

read_json_extensions() {
    local json_file="$1"
    [ -f "$json_file" ] || return 0

    if command -v python3 &>/dev/null; then
        read_extensions_python "$json_file"
        return 0
    fi

    read_extensions_fallback "$json_file"
}

gather_extensions() {
    local sync_dir="$1"
    local json_file="$sync_dir/extensions.json"
    local base_exts=(
        "golang.go"
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

    local json_exts=""
    if [ -f "$json_file" ]; then
        json_exts=$(read_json_extensions "$json_file")
    fi

    printf "%s\n" "${base_exts[@]}" $json_exts \
        | tr '[:upper:]' '[:lower:]' \
        | grep -v '^vscode\.' \
        | grep -v '^$' \
        | sort -u
}

format_error_output() {
    local raw_output="$1"
    local formatted=""

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        formatted+="\n        \033[0;37m$line\033[0m"
    done <<< "$raw_output"

    printf "%b" "$formatted"
}

build_failure_message() {
    local ext="$1"
    local output="$2"
    local msg="    \033[1;31m✖ Failed: $ext\033[0m"

    if [ -n "$output" ]; then
        msg+="\n      \033[0;31mStacktrace / Error Details:\033[0m"
        msg+=$(format_error_output "$output")
    fi

    echo -e "$msg"
}

is_install_success() {
    local exit_code="$1"
    local output="$2"

    [ "$exit_code" -eq 0 ] || return 1

    if echo "$output" | grep -qiE "(error:|failed|not found)"; then
        return 1
    fi

    return 0
}

install_extension_worker() {
    local ext="$1"
    local output
    local exit_code=0

    output=$(code --install-extension "$ext" --force 2>&1) || exit_code=$?

    if is_install_success "$exit_code" "$output"; then
        echo -e "    \033[1;32m✔ Installed: $ext\033[0m"
        return 0
    fi

    build_failure_message "$ext" "$output"
}

filter_uninstalled_extensions() {
    local installed_list="$1"
    shift
    local -a exts=("$@")
    local ext_lower

    for ext in "${exts[@]}"; do
        ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

        if echo "$installed_list" | grep -qx "$ext_lower"; then
            continue
        fi

        echo "$ext_lower"
    done
}

install_extensions_parallel() {
    local -a exts=("$@")
    local installed_list
    installed_list=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')

    local -a to_install=()
    mapfile -t to_install < <(filter_uninstalled_extensions "$installed_list" "${exts[@]}")

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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
