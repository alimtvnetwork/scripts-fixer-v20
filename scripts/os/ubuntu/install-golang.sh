#!/bin/bash
if command -v go >/dev/null 2>&1; then
    echo "Go is already installed: $(go version)"
    exit 0
fi

sudo apt-get update -y || true

if ! sudo apt-get install -y golang; then
    echo "Initial golang install failed, retrying with --fix-missing..."
    sudo apt-get update -y
    sudo apt-get install -y --fix-missing golang || sudo apt-get install -y --fix-missing golang-go || true
fi
