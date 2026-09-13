#!/bin/bash
if command -v php >/dev/null 2>&1; then
    echo "PHP is already installed: $(php -v | head -n 1)"
    exit 0
fi

sudo apt-get update -y || true

if ! sudo apt-get install -y php php-cli php-fpm; then
    echo "Initial apt install failed, refreshing package index and retrying with --fix-missing..."
    sudo apt-get update -y
    if ! sudo apt-get install -y --fix-missing php php-cli php-fpm; then
        echo "Retrying core PHP packages..."
        sudo apt-get install -y --fix-missing php-cli php || sudo apt-get install -y php || true
    fi
fi
