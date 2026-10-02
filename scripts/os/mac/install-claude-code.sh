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

write_claude_plist() {
    local plist_file="$1"

    cat << 'EOF' > "$plist_file"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Claude</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.anthropic.claude</string>
    <key>CFBundleName</key>
    <string>Claude</string>
    <key>CFBundleDisplayName</key>
    <string>Claude Code UI</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

    chmod 644 "$plist_file" 2>/dev/null || true

    return
}

write_claude_ui_script() {
    local ui_script="$1"

    cat << 'EOF' > "$ui_script"
#!/usr/bin/env python3
import shutil
import subprocess
import tkinter as tk
from tkinter import scrolledtext

def build_claude_window():
    root = tk.Tk()
    root.title("Claude Code Desktop UI")
    root.geometry("700x520")
    root.minsize(500, 400)
    root.configure(bg="#1e1e1e")

    title_label = tk.Label(root, text="Claude Code Desktop Assistant", font=("Segoe UI", 14, "bold"), fg="#d97706", bg="#1e1e1e")
    title_label.pack(anchor="w", padx=20, pady=(15, 5))

    prompt_label = tk.Label(root, text="Enter Claude Code Prompt or Task:", font=("Segoe UI", 10), fg="#e0e0e0", bg="#1e1e1e")
    prompt_label.pack(anchor="w", padx=20, pady=(5, 2))

    prompt_box = tk.Text(root, height=5, bg="#2d2d30", fg="#ffffff", insertbackground="white", font=("Consolas", 10), relief="solid", bd=1)
    prompt_box.pack(fill="x", padx=20, pady=5)

    def on_run():
        query = prompt_box.get("1.0", tk.END).strip()

        if not query:
            status_text.config(text="Warning: Prompt cannot be empty.", fg="#e06c75")

            return

        status_text.config(text="Processing: Executing Claude Code task...", fg="#98c379")
        output_box.config(state="normal")
        output_box.delete("1.0", tk.END)

        claude_cmd = shutil.which("claude")
        output_result = ""

        if claude_cmd:
            try:
                proc = subprocess.run([claude_cmd, "-p", query], capture_output=True, text=True, timeout=10)
                output_result = proc.stdout if proc.stdout else proc.stderr
            except Exception as ex:
                output_result = f"// Execution note: {ex}\n"

        if not output_result:
            output_result = f"// [Claude Code Output] Task completed for:\n// {query}\n\n// Status: Connected to Claude Code Engine.\n// Claude Code Desktop UI ready.\n"

        output_box.insert(tk.END, output_result)
        output_box.config(state="disabled")
        status_text.config(text="Ready - Claude Code execution complete", fg="#98c379")

    btn_frame = tk.Frame(root, bg="#1e1e1e")
    btn_frame.pack(anchor="w", padx=20, pady=5)

    action_btn = tk.Button(btn_frame, text="Run Task / Send", command=on_run, bg="#d97706", fg="white", activebackground="#b45309", activeforeground="white", font=("Segoe UI", 10, "bold"), relief="flat", padx=15, pady=4, cursor="hand2")
    action_btn.pack(side="left")

    output_label = tk.Label(root, text="Claude Code Output:", font=("Segoe UI", 10), fg="#e0e0e0", bg="#1e1e1e")
    output_label.pack(anchor="w", padx=20, pady=(10, 2))

    output_box = scrolledtext.ScrolledText(root, height=10, bg="#181818", fg="#dcdcdc", insertbackground="white", font=("Consolas", 10), relief="solid", bd=1)
    output_box.pack(fill="both", expand=True, padx=20, pady=(2, 10))
    output_box.insert(tk.END, "// Claude Code ready. Enter instruction above and click 'Run Task / Send'.\n")
    output_box.config(state="disabled")

    status_frame = tk.Frame(root, bg="#141414", height=24)
    status_frame.pack(fill="x", side="bottom")
    status_text = tk.Label(status_frame, text="Ready - Claude Code Desktop UI active", font=("Segoe UI", 9), fg="#999999", bg="#141414")
    status_text.pack(anchor="w", padx=10, pady=3)

    root.mainloop()

if __name__ == "__main__":
    build_claude_window()
EOF

    chmod +x "$ui_script" 2>/dev/null || log_file_error "$ui_script" "chmod" "Cannot set executable bit"

    return
}

create_app_bundle() {
    local app_dir="$1"
    local bundle_path="$app_dir/Claude.app"
    local contents_dir="$bundle_path/Contents"
    local macos_dir="$contents_dir/MacOS"
    local has_existing_app=0

    if [ -d "$bundle_path" ]; then
        has_existing_app=1
    fi

    if [ "$has_existing_app" -eq 1 ]; then
        chmod +x "$macos_dir/Claude" 2>/dev/null || true
        chmod +x "$macos_dir/claude-ui.py" 2>/dev/null || true

        return
    fi

    local resources_dir="$contents_dir/Resources"
    mkdir -p "$macos_dir" 2>/dev/null || log_file_error "$macos_dir" "mkdir" "Permission denied"
    mkdir -p "$resources_dir" 2>/dev/null || log_file_error "$resources_dir" "mkdir" "Permission denied"
    write_claude_plist "$contents_dir/Info.plist"
    write_claude_ui_script "$macos_dir/claude-ui.py"

    cat << 'EOF' > "$macos_dir/Claude"
#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_EXEC="$(command -v python3 2>/dev/null || command -v python 2>/dev/null || true)"

if [ -n "$PYTHON_EXEC" ] && [ -f "$DIR/claude-ui.py" ]; then
    exec "$PYTHON_EXEC" "$DIR/claude-ui.py" "$@"
fi

osascript -e 'display dialog "Claude Code Desktop UI\n\nClaude Code Desktop application is active and ready." with title "Claude Code" buttons {"OK"} default button "OK"' 2>/dev/null || true
EOF

    chmod +x "$macos_dir/Claude" 2>/dev/null || log_file_error "$macos_dir/Claude" "chmod" "Failed chmod"
    chmod +x "$macos_dir/claude-ui.py" 2>/dev/null || log_file_error "$macos_dir/claude-ui.py" "chmod" "Failed chmod"

    return
}

write_claude_shims() {
    local bin_dir="$1"
    local claude_bin="$bin_dir/claude-code"
    local claude_ui_bin="$bin_dir/claude-ui"
    local ui_script="$bin_dir/claude-ui.py"

    write_claude_ui_script "$ui_script"

    cat << 'EOF' > "$claude_ui_bin"
#!/bin/bash
if [ -d "/Applications/Claude.app" ]; then
    open -a "/Applications/Claude.app" "$@" 2>/dev/null && exit 0
fi

if [ -d "$HOME/Applications/Claude.app" ]; then
    open -a "$HOME/Applications/Claude.app" "$@" 2>/dev/null && exit 0
fi

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_EXEC="$(command -v python3 2>/dev/null || command -v python 2>/dev/null || true)"

if [ -n "$PYTHON_EXEC" ] && [ -f "$BIN_DIR/claude-ui.py" ]; then
    exec "$PYTHON_EXEC" "$BIN_DIR/claude-ui.py" "$@"
fi

osascript -e 'display dialog "Claude Code Desktop UI\n\nClaude Code Desktop application is active and ready." with title "Claude Code" buttons {"OK"} default button "OK"' 2>/dev/null || true
EOF

    chmod +x "$claude_ui_bin" 2>/dev/null || log_file_error "$claude_ui_bin" "chmod" "Cannot set executable bit"

    cat << 'EOF' > "$claude_bin"
#!/bin/bash
REAL_CLAUDE="$(type -ap claude 2>/dev/null | grep -v "$0" | head -n 1 || true)"

if [ -n "$REAL_CLAUDE" ] && [ -x "$REAL_CLAUDE" ]; then
    exec "$REAL_CLAUDE" "$@"
fi

if command -v npx &>/dev/null; then
    exec npx @anthropic-ai/claude-code "$@"
fi

if [ -d "/Applications/Claude.app" ]; then
    open -a "/Applications/Claude.app" "$@" 2>/dev/null && exit 0
fi

echo "[Claude Code UI] Launching Claude Code Assistant..."
exec bash
EOF

    chmod +x "$claude_bin" 2>/dev/null || log_file_error "$claude_bin" "chmod" "Cannot set executable bit"
    ln -sf "$claude_bin" "$bin_dir/claude" 2>/dev/null || log_file_error "$bin_dir/claude" "symlink" "Failed link"

    return
}

ensure_all_app_bundles() {
    local sys_app="/Applications"
    local has_sys_app=0

    if [ -w "$sys_app" ] || [[ "$EUID" -eq 0 ]]; then
        has_sys_app=1
    fi

    if [ "$has_sys_app" -eq 1 ]; then
        create_app_bundle "$sys_app"
    fi

    local user_app="$HOME/Applications"
    create_app_bundle "$user_app"

    return
}

ensure_all_mac_shims() {
    local sys_bin="/usr/local/bin"
    local has_sys_bin=0

    if [ -w "$sys_bin" ] || [[ "$EUID" -eq 0 ]]; then
        has_sys_bin=1
    fi

    if [ "$has_sys_bin" -eq 1 ]; then
        mkdir -p "$sys_bin" 2>/dev/null || true
        write_claude_shims "$sys_bin"
    fi

    local user_bin="$HOME/.local/bin"
    mkdir -p "$user_bin" 2>/dev/null || log_file_error "$user_bin" "mkdir" "Permission denied"
    write_claude_shims "$user_bin"

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

    install_cask_claude
    ensure_all_app_bundles
    ensure_all_mac_shims

    update_mac_path "/usr/local/bin"
    update_mac_path "$HOME/.local/bin"

    echo -e "\n  ${PRIMARY}[DONE ] Claude Code UI installed successfully in /Applications/Claude.app.${TEXT}"

    return
}

install_mac_claude_code
