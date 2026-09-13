#!/bin/bash
if command -v python3 >/dev/null 2>&1 && command -v pip3 >/dev/null 2>&1; then
    echo "Python3 and pip3 are already installed: $(python3 --version)"
    exit 0
fi

sudo apt-get update -y || true

if ! sudo apt-get install -y python3 python3-pip python3-venv; then
    echo "Initial python3 install failed, retrying with --fix-missing..."
    sudo apt-get update -y
    sudo apt-get install -y --fix-missing python3 python3-pip python3-venv || sudo apt-get install -y python3 || true
fi
