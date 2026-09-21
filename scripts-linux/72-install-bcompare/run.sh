#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER="$SCRIPT_DIR/../../scripts/os/ubuntu/install-bcompare.sh"

if [ ! -f "$INSTALLER" ]; then
    INSTALLER="$SCRIPT_DIR/../os/ubuntu/install-bcompare.sh"
fi

bash "$INSTALLER" --version 5 "$@"
