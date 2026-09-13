#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
ACCENT='\033[1;33m'
MUTED='\033[0;37m'
TEXT='\033[0m'

echo -e "\n  ${SECONDARY}[  ..  ] Installing Claude Code (UI & CLI)...${TEXT}"

# Step 1: Ensure Node.js & npm or create standalone launcher
echo -e "  ${MUTED}[step 1/3] Checking Node.js / npm environment...${TEXT}"
if command -v npm &>/dev/null; then
    echo -e "  ${MUTED}  -> Installing @anthropic-ai/claude-code via npm...${TEXT}"
    npm install -g @anthropic-ai/claude-code 2>/dev/null || true
fi

# Step 2: Binary shims and PATH integration
echo -e "  ${MUTED}[step 2/3] Setting up executable shims...${TEXT}"
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

cat << 'EOF' > "$INSTALL_DIR/claude-code"
#!/bin/bash
if command -v claude &>/dev/null; then
    exec claude "$@"
elif command -v npx &>/dev/null; then
    exec npx @anthropic-ai/claude-code "$@"
else
    echo "Claude Code CLI wrapper. Please install Node.js/npm for full agent functionality."
fi
EOF
chmod +x "$INSTALL_DIR/claude-code"
ln -sf "$INSTALL_DIR/claude-code" "$INSTALL_DIR/claude"
ln -sf "$INSTALL_DIR/claude-code" "$INSTALL_DIR/claude-ui"

# Step 3: Desktop UI launcher
echo -e "  ${MUTED}[step 3/3] Creating desktop application launcher...${TEXT}"
APP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR"
cat << EOF > "$APP_DIR/claude-code.desktop"
[Desktop Entry]
Name=Claude Code
Comment=Claude Code AI Agent Assistant
Exec=$INSTALL_DIR/claude-ui
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Development;IDE;
EOF
chmod +x "$APP_DIR/claude-code.desktop"

# Shell integration
SHELL_RC="$HOME/.bashrc"
if [[ "$SHELL" == *"zsh"* ]]; then SHELL_RC="$HOME/.zshrc"; fi
if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
fi

echo -e "\n  ${PRIMARY}[DONE ] Claude Code setup complete (CLI + Desktop UI).${TEXT}"
