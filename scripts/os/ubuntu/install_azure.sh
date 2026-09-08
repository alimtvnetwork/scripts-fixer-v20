#!/usr/bin/env bash
set -e

function is_az_installed() {
    command -v az >/dev/null 2>&1
}

function install_azure() {
    if is_az_installed; then
        echo "Azure CLI is already installed."
        return 0
    fi
    sudo mkdir -p /etc/apt/keyrings
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
    sudo apt-get update -y
    sudo apt-get install -y azure-cli
}

install_azure
az --version
