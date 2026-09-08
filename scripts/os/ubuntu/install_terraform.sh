#!/usr/bin/env bash
set -e

function is_terraform_installed() {
    command -v terraform >/dev/null 2>&1
}

function install_terraform() {
    if is_terraform_installed; then
        echo "Terraform is already installed."
        return 0
    fi
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update -y
    sudo apt-get install -y terraform
}

install_terraform
terraform -version
