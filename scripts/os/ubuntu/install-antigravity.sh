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
echo -e "  ${MUTED}[step 2/4] Fetching the official Antigravity installer...${TEXT}"
curl -fsSL https://get.antigravity.dev | bash

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

if ! grep -q "antigravity" "$SHELL_RC" 2>/dev/null; then
    echo -e "  ${MUTED}  -> Shell profile ($SHELL_RC) has no antigravity entry; the installer should have added it.${TEXT}"
fi

echo -e "\n  ${PRIMARY}[DONE ] Antigravity (agy) setup complete.${TEXT}"
echo -e "  ${MUTED}  Usage: agy \"your task here\"${TEXT}"
echo -e "  ${MUTED}  Docs : https://antigravity.dev/docs${TEXT}\n"
