#!/usr/bin/env bash
# Antigravity & Gemini Brain Optimizer (Root Entry Point).
# Delegates to scripts-linux/69-install-antigravity/helpers/clear-agy.sh.
# By default runs in prediction mode without terminating running Antigravity instances.
set -u

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
HELPER_SCRIPT="$ROOT_DIR/scripts-linux/69-install-antigravity/helpers/clear-agy.sh"

if [ ! -f "$HELPER_SCRIPT" ]; then
  echo "  [XX] Helper script missing: $HELPER_SCRIPT" >&2

  exit 1
fi

exec bash "$HELPER_SCRIPT" "$@"
