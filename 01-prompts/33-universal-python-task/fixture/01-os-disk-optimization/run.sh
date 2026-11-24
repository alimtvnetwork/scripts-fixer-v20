#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN="$(command -v python3 || command -v python || true)"
if [ -z "$PYTHON_BIN" ]; then
    echo "Error: Python 3 is required but not found in PATH." >&2
    exit 1
fi

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/cli_dispatcher.py"
exec "$PYTHON_BIN" "$SCRIPT_PATH" "$@"
