#!/usr/bin/env bash
# Antigravity & Gemini Brain Optimizer (Alias for clear-agy.sh).
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec bash "$SCRIPT_DIR/clear-agy.sh" "$@"
