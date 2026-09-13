#!/usr/bin/env bash
set -e

function is_ansible_installed() {
    command -v ansible >/dev/null 2>&1
}

function install_ansible() {
    if is_ansible_installed; then
        echo "Ansible is already installed."
        return 0
    fi
    sudo apt-get update -y
    sudo apt-get install -y software-properties-common
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible
}

install_ansible
ansible --version
