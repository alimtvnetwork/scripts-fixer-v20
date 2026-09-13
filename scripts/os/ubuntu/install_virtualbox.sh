#!/usr/bin/env bash
set -e

function is_virtualbox_installed() {
    command -v virtualbox >/dev/null 2>&1
}

function install_virtualbox() {
    if is_virtualbox_installed; then
        echo "VirtualBox is already installed."
        return 0
    fi
    sudo apt-get update -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y virtualbox virtualbox-ext-pack
}

install_virtualbox
