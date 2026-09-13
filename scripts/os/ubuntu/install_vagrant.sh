#!/usr/bin/env bash
set -e

function is_vagrant_installed() {
    command -v vagrant >/dev/null 2>&1
}

function install_vagrant() {
    if is_vagrant_installed; then
        echo "Vagrant is already installed."
        return 0
    fi
    if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    fi
    sudo apt-get update -y
    sudo apt-get install -y vagrant
}

install_vagrant
vagrant --version
