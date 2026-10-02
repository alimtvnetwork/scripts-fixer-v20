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

resolve_bin_dir() {
    local has_root=0

    if [[ "$EUID" -eq 0 ]] || [ -w "/usr/local/bin" ]; then
        has_root=1
    fi

    if [ "$has_root" -eq 1 ]; then
        echo "/usr/local/bin"

        return
    fi

    local user_bin="$HOME/.local/bin"
    mkdir -p "$user_bin" 2>/dev/null || log_file_error "$user_bin" "mkdir" "Permission denied"
    echo "$user_bin"

    return
}

resolve_desktop_dir() {
    local has_root=0

    if [[ "$EUID" -eq 0 ]] || [ -w "/usr/share/applications" ]; then
        has_root=1
    fi

    if [ "$has_root" -eq 1 ]; then
        echo "/usr/share/applications"

        return
    fi

    local user_desktop="$HOME/.local/share/applications"
    mkdir -p "$user_desktop" 2>/dev/null || log_file_error "$user_desktop" "mkdir" "Permission denied"
    echo "$user_desktop"

    return
}

write_codex_binary() {
    local bin_dir="$1"
    local codex_bin="$bin_dir/codex"

    cat << 'EOF' > "$codex_bin"
#!/bin/bash
echo "[Codex UI] Launching Codex Assistant..."
exec bash
EOF

    chmod +x "$codex_bin" 2>/dev/null || log_file_error "$codex_bin" "chmod" "Cannot set executable bit"
    ln -sf "$codex_bin" "$bin_dir/codex-ui" 2>/dev/null || log_file_error "$bin_dir/codex-ui" "symlink" "Failed link"

    return
}

write_codex_desktop_entry() {
    local desktop_dir="$1"
    local exec_cmd="$2"
    local desktop_file="$desktop_dir/codex.desktop"

    cat << EOF > "$desktop_file"
[Desktop Entry]
Name=Codex UI
Comment=Codex AI Coding Assistant
Exec=$exec_cmd
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Development;IDE;
EOF

    chmod +x "$desktop_file" 2>/dev/null || log_file_error "$desktop_file" "chmod" "Cannot set executable bit"

    return
}

ensure_all_bin_shims() {
    local user_bin="$HOME/.local/bin"
    mkdir -p "$user_bin" 2>/dev/null || log_file_error "$user_bin" "mkdir" "Permission denied"
    write_codex_binary "$user_bin"

    local sys_bin="/usr/local/bin"
    local has_sys_perm=0

    if [ -w "$sys_bin" ] || [[ "$EUID" -eq 0 ]]; then
        has_sys_perm=1
    fi

    if [ "$has_sys_perm" -eq 1 ]; then
        mkdir -p "$sys_bin" 2>/dev/null || true
        write_codex_binary "$sys_bin"
    fi

    return
}

ensure_all_desktop_entries() {
    local launcher_bin="/usr/local/bin/codex-ui"
    local has_sys_launcher=0

    if [ -f "$launcher_bin" ]; then
        has_sys_launcher=1
    fi

    if [ "$has_sys_launcher" -eq 0 ]; then
        launcher_bin="$HOME/.local/bin/codex-ui"
    fi

    local user_desktop="$HOME/.local/share/applications"
    mkdir -p "$user_desktop" 2>/dev/null || log_file_error "$user_desktop" "mkdir" "Permission denied"
    write_codex_desktop_entry "$user_desktop" "$launcher_bin"

    local sys_desktop="/usr/share/applications"
    local has_sys_perm=0

    if [ -w "$sys_desktop" ] || [[ "$EUID" -eq 0 ]]; then
        has_sys_perm=1
    fi

    if [ "$has_sys_perm" -eq 1 ]; then
        mkdir -p "$sys_desktop" 2>/dev/null || true
        write_codex_desktop_entry "$sys_desktop" "$launcher_bin"
    fi

    return
}

update_shell_path() {
    local bin_dir="$1"
    local shell_rc="$HOME/.bashrc"
    local is_zsh=0

    if [[ "$SHELL" == *"zsh"* ]]; then
        is_zsh=1
    fi

    if [ "$is_zsh" -eq 1 ]; then
        shell_rc="$HOME/.zshrc"
    fi

    local has_entry=0

    if grep -q "$bin_dir" "$shell_rc" 2>/dev/null; then
        has_entry=1
    fi

    if [ "$has_entry" -eq 0 ]; then
        echo "export PATH=\"$bin_dir:\$PATH\"" >> "$shell_rc"
    fi

    return
}

install_codex() {
    echo -e "\n  ${SECONDARY}[  ..  ] Installing Codex UI across default directories...${TEXT}"

    ensure_all_bin_shims
    ensure_all_desktop_entries

    update_shell_path "$HOME/.local/bin"
    update_shell_path "/usr/local/bin"

    echo -e "\n  ${PRIMARY}[DONE ] Codex UI installed successfully across default directories.${TEXT}"

    return
}

install_codex
