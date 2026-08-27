#!/bin/bash
# Install Nautilus Right-Click Context Menus for Ubuntu

echo -e "\e[1;36mℹ Installing Right-Click Context Menus for Ubuntu (Nautilus)\e[0m"

NAUTILUS_SCRIPTS_DIR="$HOME/.local/share/nautilus/scripts"
mkdir -p "$NAUTILUS_SCRIPTS_DIR"

# 1. Open in VS Code
VSCODE_SCRIPT="$NAUTILUS_SCRIPTS_DIR/Open in VS Code"
cat << 'EOF' > "$VSCODE_SCRIPT"
#!/bin/bash
if [ -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" ]; then
    # Multiple files/folders selected
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            code "$line"
        fi
    done <<< "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"
else
    # Current directory
    code "$NAUTILUS_SCRIPT_CURRENT_URI"
fi
EOF
chmod +x "$VSCODE_SCRIPT"

# 2. Open in Terminal (GNOME default, but let's ensure the extension is there)
echo -e "\e[1;33m[  ..  ] Installing nautilus-extension for Terminal\e[0m"
sudo apt-get update
sudo apt-get install -y nautilus-extension-gnome-terminal

# 3. Open as Administrator (nautilus-admin)
echo -e "\e[1;33m[  ..  ] Installing nautilus-admin (Open as Root)\e[0m"
sudo apt-get install -y nautilus-admin || true

# 4. Open in default Text Editor (gedit/gnome-text-editor)
EDITOR_SCRIPT="$NAUTILUS_SCRIPTS_DIR/Open in Text Editor"
cat << 'EOF' > "$EDITOR_SCRIPT"
#!/bin/bash
if [ -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" ]; then
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            xdg-open "$line"
        fi
    done <<< "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"
fi
EOF
chmod +x "$EDITOR_SCRIPT"

# Restart nautilus to apply changes
echo -e "\e[1;33m[  ..  ] Restarting Nautilus to apply context menus\e[0m"
nautilus -q || true

echo -e "\e[1;32m✔ Context menus successfully injected into Nautilus!\e[0m"
echo -e "\e[0;90mNote: Right click any file/folder and check the 'Scripts' submenu.\e[0m"
