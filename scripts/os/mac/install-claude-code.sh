#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
MUTED='\033[0;37m'
TEXT='\033[0m'

log_file_error() {
    local file_path="$1"
    local operation="$2"
    local reason="$3"
    echo -e "\033[1;31m[CODE RED][FILE-ERROR]\033[0m Op: ${operation} | Path: ${file_path} | Reason: ${reason}" >&2

    return
}

resolve_app_dir() {
    local has_system_app=0

    if [ -w "/Applications" ] || [[ "$EUID" -eq 0 ]]; then
        has_system_app=1
    fi

    if [ "$has_system_app" -eq 1 ]; then
        echo "/Applications"

        return
    fi

    local user_app="$HOME/Applications"
    mkdir -p "$user_app" 2>/dev/null || log_file_error "$user_app" "mkdir" "Permission denied"
    echo "$user_app"

    return
}

resolve_bin_dir() {
    local has_usr_local=0

    if [ -w "/usr/local/bin" ] || [[ "$EUID" -eq 0 ]]; then
        has_usr_local=1
    fi

    if [ "$has_usr_local" -eq 1 ]; then
        echo "/usr/local/bin"

        return
    fi

    local has_homebrew=0

    if [ -w "/opt/homebrew/bin" ]; then
        has_homebrew=1
    fi

    if [ "$has_homebrew" -eq 1 ]; then
        echo "/opt/homebrew/bin"

        return
    fi

    local user_bin="$HOME/.local/bin"
    mkdir -p "$user_bin" 2>/dev/null || log_file_error "$user_bin" "mkdir" "Permission denied"
    echo "$user_bin"

    return
}

install_cask_claude() {
    local has_brew=0

    if command -v brew &>/dev/null; then
        has_brew=1
    fi

    if [ "$has_brew" -eq 0 ]; then
        return
    fi

    echo -e "  ${MUTED}-> Installing official Claude cask via Homebrew...${TEXT}"
    brew install --cask claude 2>/dev/null || true

    return
}

create_app_bundle() {
    local app_dir="$1"
    local bundle_path="$app_dir/Claude.app"
    local macos_dir="$bundle_path/Contents/MacOS"
    local has_existing_app=0

    if [ -d "$bundle_path" ]; then
        has_existing_app=1
    fi

    if [ "$has_existing_app" -eq 1 ]; then
        return
    fi

    mkdir -p "$macos_dir" 2>/dev/null || log_file_error "$macos_dir" "mkdir" "Permission denied"

    cat << 'EOF' > "$macos_dir/Claude"
#!/bin/bash
echo "[Claude Code UI] Launching Claude Desktop UI..."
if command -v claude &>/dev/null; then
    exec claude "$@"
elif command -v npx &>/dev/null; then
    exec npx @anthropic-ai/claude-code "$@"
fi
EOF

    chmod +x "$macos_dir/Claude" 2>/dev/null || log_file_error "$macos_dir/Claude" "chmod" "Failed chmod"

    return
}

write_claude_shims() {
    local bin_dir="$1"
    local claude_bin="$bin_dir/claude-code"

    cat << 'EOF' > "$claude_bin"
#!/bin/bash
if [ -d "/Applications/Claude.app" ]; then
    open -a "/Applications/Claude.app" "$@" 2>/dev/null || true
fi
if command -v claude &>/dev/null; then
    exec claude "$@"
elif command -v npx &>/dev/null; then
    exec npx @anthropic-ai/claude-code "$@"
fi
EOF

    chmod +x "$claude_bin" 2>/dev/null || log_file_error "$claude_bin" "chmod" "Cannot set executable bit"
    ln -sf "$claude_bin" "$bin_dir/claude" 2>/dev/null || log_file_error "$bin_dir/claude" "symlink" "Failed link"
    ln -sf "$claude_bin" "$bin_dir/claude-ui" 2>/dev/null || log_file_error "$bin_dir/claude-ui" "symlink" "Failed link"

    return
}

update_mac_path() {
    local bin_dir="$1"
    local zsh_rc="$HOME/.zprofile"
    local has_zsh_entry=0

    if grep -q "$bin_dir" "$zsh_rc" 2>/dev/null; then
        has_zsh_entry=1
    fi

    if [ "$has_zsh_entry" -eq 0 ]; then
        echo "export PATH=\"$bin_dir:\$PATH\"" >> "$zsh_rc"
    fi

    return
}

install_mac_claude_code() {
    echo -e "\n  ${SECONDARY}[  ..  ] Installing Claude Code UI on macOS (/Applications)...${TEXT}"

    local app_dir
    app_dir="$(resolve_app_dir)"
    local bin_dir
    bin_dir="$(resolve_bin_dir)"

    install_cask_claude
    create_app_bundle "$app_dir"
    write_claude_shims "$bin_dir"

    local user_bin="$HOME/.local/bin"
    local has_distinct_bin=0

    if [ "$bin_dir" != "$user_bin" ]; then
        has_distinct_bin=1
    fi

    if [ "$has_distinct_bin" -eq 1 ]; then
        mkdir -p "$user_bin" 2>/dev/null || true
        write_claude_shims "$user_bin"
    fi

    update_mac_path "$bin_dir"

    echo -e "\n  ${PRIMARY}[DONE ] Claude Code UI installed successfully in $app_dir/Claude.app.${TEXT}"

    return
}

install_mac_claude_code
