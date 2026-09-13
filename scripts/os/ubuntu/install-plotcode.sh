#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
MUTED='\033[0;37m'
TEXT='\033[0m'

echo -e "\n  ${SECONDARY}[  ..  ] Installing PlotCode UI...${TEXT}"

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

cat << 'EOF' > "$INSTALL_DIR/plotcode"
#!/bin/bash
echo "[PlotCode UI] Launching PlotCode Assistant..."
exec bash
EOF
chmod +x "$INSTALL_DIR/plotcode"
ln -sf "$INSTALL_DIR/plotcode" "$INSTALL_DIR/plotcode-ui"

# Create desktop launcher
APP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR"
cat << EOF > "$APP_DIR/plotcode.desktop"
[Desktop Entry]
Name=PlotCode UI
Comment=PlotCode Visual Data Assistant
Exec=$INSTALL_DIR/plotcode-ui
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Development;IDE;
EOF
chmod +x "$APP_DIR/plotcode.desktop"

SHELL_RC="$HOME/.bashrc"
if [[ "$SHELL" == *"zsh"* ]]; then SHELL_RC="$HOME/.zshrc"; fi
if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
fi

echo -e "\n  ${PRIMARY}[DONE ] PlotCode UI installed successfully (CLI + Desktop UI).${TEXT}"
