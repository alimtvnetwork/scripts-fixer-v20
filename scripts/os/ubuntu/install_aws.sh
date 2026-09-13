#!/usr/bin/env bash
set -e

function is_aws_installed() {
    command -v aws >/dev/null 2>&1
}

function install_aws() {
    if is_aws_installed; then
        echo "AWS CLI is already installed."
        return 0
    fi
    curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "aws.zip"
    unzip -q aws.zip
    sudo ./aws/install --update
    rm -rf aws.zip aws
}

install_aws
aws --version
