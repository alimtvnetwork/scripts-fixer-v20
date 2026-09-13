#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
MUTED='\033[0;37m'
TEXT='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." 2>/dev/null && pwd || pwd)"

run_sub() {
    local rel="scripts/os/ubuntu/$1"
    if [ -f "$REPO_ROOT/$rel" ]; then
        bash "$REPO_ROOT/$rel"
    elif [ -f "$SCRIPT_DIR/$1" ]; then
        bash "$SCRIPT_DIR/$1"
    elif [ -f "$rel" ]; then
        bash "$rel"
    else
        echo -e "  \033[1;31m[FAIL] Required installer $1 not found.\033[0m"
        exit 1
    fi
}

echo -e "\n  ${SECONDARY}=== Installing Antigravity Suite Profile (Ubuntu) ===${TEXT}"

echo -e "  ${MUTED}[1/2] Installing Antigravity Manager GUI...${TEXT}"
run_sub "install-antigravity-manager.sh"

echo -e "  ${MUTED}[2/2] Installing Antigravity IDE & CLI companion...${TEXT}"
run_sub "install-antigravity.sh"

echo -e "\n  ${PRIMARY}[DONE ] Antigravity Suite Profile installed successfully!${TEXT}"
