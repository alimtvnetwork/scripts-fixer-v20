#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
ACCENT='\033[1;33m'
MUTED='\033[0;37m'
ERROR='\033[1;31m'
TEXT='\033[0m'

echo -e "\n  ${SECONDARY}[  ..  ] Installing Antigravity (agy)...${TEXT}"

# ── Prerequisites ─────────────────────────────────────────────────────────────
echo -e "  ${MUTED}[step 1/4] Ensuring curl and tar are available...${TEXT}"
if ! command -v curl &>/dev/null || ! command -v tar &>/dev/null; then
    sudo apt-get update -y && sudo apt-get install -y curl tar
fi

# ── Download & run the official Antigravity installer ─────────────────────────
echo -e "  ${MUTED}[step 2/4] Fetching the latest Antigravity installer from GitHub...${TEXT}"
ARCH_RAW=$(uname -m)
case "$ARCH_RAW" in
    x86_64|amd64)
        ARCH="x64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        ARCH="x64"
        ;;
esac

ASSET_NAME="agy_cli_linux_${ARCH}.tar.gz"
DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/google-antigravity/antigravity-cli/releases/latest" 2>/dev/null | grep "browser_download_url.*${ASSET_NAME}" | cut -d '"' -f 4 || true)

if [ -z "$DOWNLOAD_URL" ]; then
    DOWNLOAD_URL="https://github.com/google-antigravity/antigravity-cli/releases/latest/download/${ASSET_NAME}"
fi

TMP_DIR=$(mktemp -d)
curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/${ASSET_NAME}"
tar -xzf "$TMP_DIR/${ASSET_NAME}" -C "$TMP_DIR"

INSTALL_DIR="$HOME/.antigravity/bin"
mkdir -p "$INSTALL_DIR"

if [ -f "$TMP_DIR/antigravity" ]; then
    mv "$TMP_DIR/antigravity" "$INSTALL_DIR/antigravity"
elif [ -f "$TMP_DIR/agy" ]; then
    mv "$TMP_DIR/agy" "$INSTALL_DIR/antigravity"
else
    FOUND_BIN=$(find "$TMP_DIR" -maxdepth 2 -type f -perm -111 ! -name "*.tar.gz" ! -name "*.zip" 2>/dev/null | head -n 1)
    if [ -n "$FOUND_BIN" ]; then
        mv "$FOUND_BIN" "$INSTALL_DIR/antigravity"
    else
        echo -e "  ${ERROR}[ERROR] Antigravity binary not found in extracted archive.${TEXT}"
        rm -rf "$TMP_DIR"
        exit 1
    fi
fi

chmod +x "$INSTALL_DIR/antigravity"
ln -sf "$INSTALL_DIR/antigravity" "$INSTALL_DIR/agy"
rm -rf "$TMP_DIR"

# Also symlink into ~/.local/bin for standard Linux PATH compatibility
mkdir -p "$HOME/.local/bin"
ln -sf "$INSTALL_DIR/antigravity" "$HOME/.local/bin/antigravity"
ln -sf "$INSTALL_DIR/agy" "$HOME/.local/bin/agy"

# ── Verify installation ───────────────────────────────────────────────────────
echo -e "  ${MUTED}[step 3/4] Verifying antigravity & agy binaries...${TEXT}"
export PATH="$INSTALL_DIR:$HOME/.local/bin:$PATH"
if command -v antigravity &>/dev/null; then
    AGY_VERSION=$(antigravity --version 2>/dev/null || echo "installed")
    echo -e "  ${PRIMARY}[  OK  ] Antigravity installed: ${AGY_VERSION}${TEXT}"
elif command -v agy &>/dev/null; then
    AGY_VERSION=$(agy --version 2>/dev/null || echo "installed")
    echo -e "  ${PRIMARY}[  OK  ] Antigravity installed: ${AGY_VERSION}${TEXT}"
else
    echo -e "  ${ACCENT}[NOTE ] Antigravity installed to $INSTALL_DIR. Restart your shell or run: source ~/.bashrc${TEXT}"
fi

# ── Shell integration hint ────────────────────────────────────────────────────
echo -e "  ${MUTED}[step 4/4] Checking shell profile integration...${TEXT}"
for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -f "$rc" ]; then
        if ! grep -q "$INSTALL_DIR" "$rc" 2>/dev/null; then
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$rc"
            echo -e "  ${MUTED}  -> Added $INSTALL_DIR to $rc${TEXT}"
        fi
    fi
done

echo -e "\n  ${PRIMARY}[DONE ] Antigravity setup complete.${TEXT}"
echo -e "  ${MUTED}  Usage: antigravity \"your task\" or agy \"your task\"${TEXT}"
echo -e "  ${MUTED}  Docs : https://antigravity.dev/docs${TEXT}\n"

