#!/usr/bin/env bash
# zsh-fanout step 03: emit a one-line summary per host for the controller log.
set -e
HOST=$(hostname)
ZSH_BIN=$(command -v zsh || echo "MISSING")
TARGET_HOME="$HOME"
if [ -n "${TARGET_USER:-}" ]; then TARGET_HOME=$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6); fi
TARGET_HOME="${TARGET_HOME:-/root}"

OMZ="$TARGET_HOME/.oh-my-zsh"
ZSHRC="$TARGET_HOME/.zshrc"
OMZ_STATE="absent"; [ -d "$OMZ" ] && OMZ_STATE="present"
ZSHRC_STATE="absent"; [ -f "$ZSHRC" ] && ZSHRC_STATE="present"
THEME="?"
[ -f "$ZSHRC" ] && THEME=$(grep -E '^ZSH_THEME=' "$ZSHRC" 2>/dev/null | head -n1 | sed -E 's/^ZSH_THEME="?([^"]*)"?.*/\1/')

echo "[OK] zsh-fanout SUMMARY host=$HOST user=${TARGET_USER:-$(id -un)} zsh=$ZSH_BIN omz=$OMZ_STATE zshrc=$ZSHRC_STATE theme=${THEME:-?}"
