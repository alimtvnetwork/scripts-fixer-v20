#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
ACCENT='\033[1;33m'
MUTED='\033[0;37m'
ERROR='\033[1;31m'
TEXT='\033[0m'

echo -e "\n  ${SECONDARY}[  ..  ] Installing Antigravity (agy) CLI...${TEXT}"

# ── Prerequisites ─────────────────────────────────────────────────────────────
echo -e "  ${MUTED}[step 1/4] Ensuring curl is available...${TEXT}"
if ! command -v curl &>/dev/null; then
    sudo apt-get update -y && sudo apt-get install -y curl
fi

# ── Download & run the official Antigravity installer ─────────────────────────
echo -e "  ${MUTED}[step 2/4] Fetching the latest Antigravity installer from GitHub...${TEXT}"
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/google-antigravity/antigravity-cli/releases/latest | grep "browser_download_url.*agy_cli_linux_x64.tar.gz" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo -e "  ${ERROR}[ERROR] Failed to fetch latest release URL.${TEXT}"
    exit 1
fi

TMP_DIR=$(mktemp -d)
curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/agy_cli_linux_x64.tar.gz"
tar -xzf "$TMP_DIR/agy_cli_linux_x64.tar.gz" -C "$TMP_DIR"

INSTALL_DIR="$HOME/.antigravity/bin"
mkdir -p "$INSTALL_DIR"
mv "$TMP_DIR/agy" "$INSTALL_DIR/agy"
chmod +x "$INSTALL_DIR/agy"
rm -rf "$TMP_DIR"

# ── Verify installation ───────────────────────────────────────────────────────
echo -e "  ${MUTED}[step 3/4] Verifying agy binary is available...${TEXT}"
if command -v agy &>/dev/null; then
    AGY_VERSION=$(agy --version 2>/dev/null || echo "installed")
    echo -e "  ${PRIMARY}[  OK  ] Antigravity installed: ${AGY_VERSION}${TEXT}"
else
    # Try sourcing shell profile in case PATH was just updated
    export PATH="$HOME/.local/bin:$HOME/.antigravity/bin:$PATH"
    if command -v agy &>/dev/null; then
        AGY_VERSION=$(agy --version 2>/dev/null || echo "installed")
        echo -e "  ${PRIMARY}[  OK  ] Antigravity installed: ${AGY_VERSION}${TEXT}"
        echo -e "  ${ACCENT}[NOTE ] Restart your shell or run: source ~/.bashrc${TEXT}"
    else
        echo -e "  ${ERROR}[WARN ] agy not found on PATH after install. Try: source ~/.bashrc${TEXT}"
    fi
fi

# ── Shell integration hint ────────────────────────────────────────────────────
echo -e "  ${MUTED}[step 4/4] Checking shell profile integration...${TEXT}"
SHELL_RC="$HOME/.bashrc"
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
    echo -e "  ${MUTED}  -> Added $INSTALL_DIR to $SHELL_RC${TEXT}"
fi

echo -e "\n  ${PRIMARY}[DONE ] Antigravity (agy) setup complete.${TEXT}"
echo -e "  ${MUTED}  Usage: agy \"your task here\"${TEXT}"
echo -e "  ${MUTED}  Docs : https://antigravity.dev/docs${TEXT}\n"
