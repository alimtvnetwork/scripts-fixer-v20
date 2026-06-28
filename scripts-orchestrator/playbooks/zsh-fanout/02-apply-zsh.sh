#!/usr/bin/env bash
# zsh-fanout step 02: run 60 (zsh + OMZ + payload) and optionally 61 (theme
# switcher) on this host. Drops privileges to TARGET_USER if set.
#
# Optional env: REMOTE_BUNDLE_DIR (default /opt/zsh-fanout), TARGET_USER,
#               THEME, SKIP_THEME_SWITCHER, DRY_RUN
set -e
REMOTE_BUNDLE_DIR="${REMOTE_BUNDLE_DIR:-/opt/zsh-fanout}"
SCRIPT60="$REMOTE_BUNDLE_DIR/60-install-zsh/run.sh"
SCRIPT61="$REMOTE_BUNDLE_DIR/61-install-zsh-theme-switcher/run.sh"

[ -x "$SCRIPT60" ] || { echo "[FILE-ERROR] path=$SCRIPT60 reason=missing or non-executable (was 01-upload-bundle.sh run?)" >&2; exit 2; }

ARGS60=(install)
ARGS61=(install)
if [ -n "${TARGET_USER:-}" ]; then ARGS60+=(--user "$TARGET_USER"); ARGS61+=(--user "$TARGET_USER"); fi
if [ -n "${THEME:-}" ];       then ARGS61+=(--theme "$THEME" --no-prompt); fi

if [ "${DRY_RUN:-0}" = "1" ]; then
  echo "[DRY] sudo bash $SCRIPT60 ${ARGS60[*]}"
  [ "${SKIP_THEME_SWITCHER:-0}" = "1" ] || [ ! -x "$SCRIPT61" ] || echo "[DRY] sudo bash $SCRIPT61 ${ARGS61[*]}"
  echo "[OK] zsh-fanout: dry-run complete on $(hostname)"
  exit 0
fi

if ! sudo bash "$SCRIPT60" "${ARGS60[@]}"; then
  echo "[FILE-ERROR] path=$SCRIPT60 reason=60-install-zsh failed on $(hostname)" >&2
  exit 2
fi

if [ "${SKIP_THEME_SWITCHER:-0}" != "1" ] && [ -x "$SCRIPT61" ]; then
  if ! sudo bash "$SCRIPT61" "${ARGS61[@]}"; then
    echo "[WARN] 61-install-zsh-theme-switcher failed on $(hostname) (continuing)" >&2
  fi
fi

echo "[OK] zsh-fanout: 60+61 applied on $(hostname)${TARGET_USER:+ (user=$TARGET_USER)}"
