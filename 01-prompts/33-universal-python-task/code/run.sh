#!/usr/bin/env bash
# POSIX Bash entrypoint for universal Python task automation.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Environment & WORK Navigation Setup
WORK="$(cd "$SCRIPT_DIR/.." && pwd)"
export WORK

ENV_INI="$SCRIPT_DIR/config/env.ini"
if [ ! -f "$ENV_INI" ] && [ -f "$WORK/ini-env/env.ini" ]; then
    ENV_INI="$WORK/ini-env/env.ini"
fi

if [ -f "$ENV_INI" ]; then
    while IFS='=' read -r key val || [ -n "$key" ]; do
        key="$(echo "$key" | tr -d ' \r\t')"
        val="$(echo "$val" | tr -d '\r')"
        if [ -n "$key" ] && [[ ! "$key" =~ ^[#;] ]]; then
            export "$key"="$val"
        fi
    done < "$ENV_INI"
fi

# 2. Python Runtime Discovery
PYTHON_CMD=""
for candidate in python3 python py; do
    if command -v "$candidate" >/dev/null 2>&1; then
        PYTHON_CMD="$candidate"
        break
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "[ FAIL ] Python 3 runtime not found on PATH. Please install Python 3." >&2
    exit 1
fi

if [ "${1:-}" = "test" ]; then
    shift
    exec "$PYTHON_CMD" -m unittest discover "$SCRIPT_DIR/tests" -v "$@"
fi

exec "$PYTHON_CMD" "$SCRIPT_DIR/scripts/cli_dispatcher.py" "$@"
