#!/usr/bin/env bash
set -e

function is_gcloud_installed() {
    command -v gcloud >/dev/null 2>&1
}

function install_gcloud() {
    if is_gcloud_installed; then
        echo "Google Cloud SDK is already installed."
        return 0
    fi
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    sudo apt-get update -y
    sudo apt-get install -y google-cloud-cli
}

install_gcloud
gcloud --version
