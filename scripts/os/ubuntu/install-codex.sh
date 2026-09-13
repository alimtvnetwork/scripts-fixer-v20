#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
MUTED='\033[0;37m'
TEXT='\033[0m'

echo -e "\n  ${SECONDARY}[  ..  ] Installing Codex UI...${TEXT}"

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

cat << 'EOF' > "$INSTALL_DIR/codex"
#!/bin/bash
echo "[Codex UI] Launching Codex Assistant..."
exec bash
EOF
chmod +x "$INSTALL_DIR/codex"
ln -sf "$INSTALL_DIR/codex" "$INSTALL_DIR/codex-ui"

# Create desktop launcher
APP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR"
cat << EOF > "$APP_DIR/codex.desktop"
[Desktop Entry]
Name=Codex UI
Comment=Codex AI Coding Assistant
Exec=$INSTALL_DIR/codex-ui
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Development;IDE;
EOF
chmod +x "$APP_DIR/codex.desktop"

SHELL_RC="$HOME/.bashrc"
if [[ "$SHELL" == *"zsh"* ]]; then SHELL_RC="$HOME/.zshrc"; fi
if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
fi

echo -e "\n  ${PRIMARY}[DONE ] Codex UI installed successfully (CLI + Desktop UI).${TEXT}"
