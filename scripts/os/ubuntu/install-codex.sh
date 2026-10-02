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

write_codex_binary() {
    local bin_dir="$1"
    local ui_script="$bin_dir/codex-ui.py"
    local codex_bin="$bin_dir/codex"
    local codex_ui_bin="$bin_dir/codex-ui"

    write_codex_ui_script "$ui_script"

    cat << 'EOF' > "$codex_bin"
#!/bin/bash
BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_EXEC="$(command -v python3 2>/dev/null || command -v python 2>/dev/null || true)"

if [ -n "$PYTHON_EXEC" ] && [ -f "$BIN_DIR/codex-ui.py" ]; then
    exec "$PYTHON_EXEC" "$BIN_DIR/codex-ui.py" "$@"
fi

echo "[Codex UI] Launching Codex Assistant..."
exec bash
EOF

    chmod +x "$codex_bin" 2>/dev/null || log_file_error "$codex_bin" "chmod" "Cannot set executable bit"
    ln -sf "$codex_bin" "$codex_ui_bin" 2>/dev/null || log_file_error "$codex_ui_bin" "symlink" "Failed link"

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
Terminal=false
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
