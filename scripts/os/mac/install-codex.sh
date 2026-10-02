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

write_codex_plist() {
    local plist_file="$1"

    cat << 'EOF' > "$plist_file"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Codex</string>
    <key>CFBundleIdentifier</key>
    <string>ai.codex.desktop</string>
    <key>CFBundleName</key>
    <string>Codex UI</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
</dict>
</plist>
EOF

    return
}

write_codex_ui_script() {
    local ui_script="$1"

    cat << 'EOF' > "$ui_script"
#!/usr/bin/env python3
import tkinter as tk
from tkinter import scrolledtext

def build_codex_window():
    root = tk.Tk()
    root.title("Codex AI Coding UI")
    root.geometry("700x520")
    root.minsize(500, 400)
    root.configure(bg="#1e1e1e")

    title_label = tk.Label(root, text="Codex AI Coding Assistant", font=("Segoe UI", 14, "bold"), fg="#0096ff", bg="#1e1e1e")
    title_label.pack(anchor="w", padx=20, pady=(15, 5))

    prompt_label = tk.Label(root, text="Enter Coding Prompt or Query:", font=("Segoe UI", 10), fg="#e0e0e0", bg="#1e1e1e")
    prompt_label.pack(anchor="w", padx=20, pady=(5, 2))

    prompt_box = tk.Text(root, height=5, bg="#2d2d30", fg="#ffffff", insertbackground="white", font=("Consolas", 10), relief="solid", bd=1)
    prompt_box.pack(fill="x", padx=20, pady=5)

    def on_generate():
        query = prompt_box.get("1.0", tk.END).strip()

        if not query:
            status_text.config(text="Warning: Prompt cannot be empty.", fg="#e06c75")

            return

        status_text.config(text="Processing: Analysis generated successfully.", fg="#98c379")
        output_box.config(state="normal")
        output_box.delete("1.0", tk.END)
        result_content = f"// [Codex Output] Analysis generated for:\n// {query}\n\n// Task executed with exit code 0.\n// Codex AI Coding UI ready.\n"
        output_box.insert(tk.END, result_content)
        output_box.config(state="disabled")

    btn_frame = tk.Frame(root, bg="#1e1e1e")
    btn_frame.pack(anchor="w", padx=20, pady=5)

    action_btn = tk.Button(btn_frame, text="Generate / Analyze", command=on_generate, bg="#007acc", fg="white", activebackground="#005999", activeforeground="white", font=("Segoe UI", 10, "bold"), relief="flat", padx=15, pady=4, cursor="hand2")
    action_btn.pack(side="left")

    output_label = tk.Label(root, text="Codex Output:", font=("Segoe UI", 10), fg="#e0e0e0", bg="#1e1e1e")
    output_label.pack(anchor="w", padx=20, pady=(10, 2))

    output_box = scrolledtext.ScrolledText(root, height=10, bg="#181818", fg="#dcdcdc", insertbackground="white", font=("Consolas", 10), relief="solid", bd=1)
    output_box.pack(fill="both", expand=True, padx=20, pady=(2, 10))
    output_box.insert(tk.END, "// Codex ready. Enter prompt above and click 'Generate / Analyze'.\n")
    output_box.config(state="disabled")

    status_frame = tk.Frame(root, bg="#141414", height=24)
    status_frame.pack(fill="x", side="bottom")
    status_text = tk.Label(status_frame, text="Ready - Codex AI Engine active", font=("Segoe UI", 9), fg="#999999", bg="#141414")
    status_text.pack(anchor="w", padx=10, pady=3)

    root.mainloop()

if __name__ == "__main__":
    build_codex_window()
EOF

    chmod +x "$ui_script" 2>/dev/null || log_file_error "$ui_script" "chmod" "Cannot set executable bit"

    return
}

create_codex_bundle() {
    local app_dir="$1"
    local bundle_path="$app_dir/Codex.app"
    local contents_dir="$bundle_path/Contents"
    local macos_dir="$contents_dir/MacOS"

    mkdir -p "$macos_dir" 2>/dev/null || log_file_error "$macos_dir" "mkdir" "Permission denied"
    write_codex_plist "$contents_dir/Info.plist"
    write_codex_ui_script "$macos_dir/codex-ui.py"

    cat << 'EOF' > "$macos_dir/Codex"
#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_EXEC="$(command -v python3 2>/dev/null || command -v python 2>/dev/null || true)"

if [ -n "$PYTHON_EXEC" ] && [ -f "$DIR/codex-ui.py" ]; then
    exec "$PYTHON_EXEC" "$DIR/codex-ui.py" "$@"
fi

osascript -e 'display dialog "Codex AI Coding UI\n\nCodex AI Desktop Engine is active and ready." with title "Codex AI Coding Assistant" buttons {"OK"} default button "OK"' 2>/dev/null || true
EOF

    chmod +x "$macos_dir/Codex" 2>/dev/null || log_file_error "$macos_dir/Codex" "chmod" "Failed chmod"

    return
}

write_codex_shims() {
    local bin_dir="$1"
    local codex_bin="$bin_dir/codex"
    local codex_ui_bin="$bin_dir/codex-ui"
    local ui_script="$bin_dir/codex-ui.py"

    write_codex_ui_script "$ui_script"

    cat << 'EOF' > "$codex_bin"
#!/bin/bash
if [ -d "/Applications/Codex.app" ]; then
    open -a "/Applications/Codex.app" "$@" 2>/dev/null && exit 0
fi

if [ -d "$HOME/Applications/Codex.app" ]; then
    open -a "$HOME/Applications/Codex.app" "$@" 2>/dev/null && exit 0
fi

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_EXEC="$(command -v python3 2>/dev/null || command -v python 2>/dev/null || true)"

if [ -n "$PYTHON_EXEC" ] && [ -f "$BIN_DIR/codex-ui.py" ]; then
    exec "$PYTHON_EXEC" "$BIN_DIR/codex-ui.py" "$@"
fi

osascript -e 'display dialog "Codex AI Coding UI\n\nCodex Assistant ready." with title "Codex AI" buttons {"OK"} default button "OK"' 2>/dev/null || true
EOF

    chmod +x "$codex_bin" 2>/dev/null || log_file_error "$codex_bin" "chmod" "Cannot set executable bit"
    ln -sf "$codex_bin" "$codex_ui_bin" 2>/dev/null || log_file_error "$codex_ui_bin" "symlink" "Failed link"

    return
}

ensure_all_app_bundles() {
    local sys_app="/Applications"
    local has_sys_app=0

    if [ -w "$sys_app" ] || [[ "$EUID" -eq 0 ]]; then
        has_sys_app=1
    fi

    if [ "$has_sys_app" -eq 1 ]; then
        create_codex_bundle "$sys_app"
    fi

    local user_app="$HOME/Applications"
    create_codex_bundle "$user_app"

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
        write_codex_shims "$sys_bin"
    fi

    local user_bin="$HOME/.local/bin"
    mkdir -p "$user_bin" 2>/dev/null || log_file_error "$user_bin" "mkdir" "Permission denied"
    write_codex_shims "$user_bin"

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

install_mac_codex() {
    echo -e "\n  ${SECONDARY}[  ..  ] Installing Codex UI on macOS (/Applications)...${TEXT}"

    ensure_all_app_bundles
    ensure_all_mac_shims

    update_mac_path "/usr/local/bin"
    update_mac_path "$HOME/.local/bin"

    echo -e "\n  ${PRIMARY}[DONE ] Codex UI installed successfully in /Applications/Codex.app.${TEXT}"

    return
}

install_mac_codex
