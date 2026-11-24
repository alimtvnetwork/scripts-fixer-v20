#!/usr/bin/env bash
set -euo pipefail

COMMAND="${1:-help}"
shift || true

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON_BIN="python"
else
    echo "[FAIL] Python 3 executable not found on PATH." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISPATCHER="${SCRIPT_DIR}/scripts/cli_dispatcher.py"

if [ "$COMMAND" = "test" ]; then
    echo "[INFO] Running unit test suite..."
    exec "$PYTHON_BIN" -m unittest discover -s "${SCRIPT_DIR}/scripts" -p "test_*.py" -v
fi

exec "$PYTHON_BIN" "$DISPATCHER" "$COMMAND" "$@"
