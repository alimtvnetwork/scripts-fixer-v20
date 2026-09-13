#!/bin/bash
# Alias wrapper pointing to install-archive.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/install-archive.sh" "$@"
