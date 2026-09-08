#!/bin/bash
# Install VMware Workstation/Player on Ubuntu

set -e

is_vmware_installed() {
    command -v vmware >/dev/null 2>&1
}

download_installer() {
    local version="${VMWARE_VERSION:-17.5.2}"
    local build="${VMWARE_BUILD:-23775571}"
    local default_url="https://download3.vmware.com/software/WKST-1752-LX/VMware-Workstation-Full-${version}-${build}.x86_64.bundle"
    local installer_url="${VMWARE_DOWNLOAD_URL:-$default_url}"
    
    echo -e "\e[1;33m[  ..  ] Downloading VMware Workstation ${version}\e[0m"
    if ! curl -sLo vmware-installer.bundle "$installer_url"; then
        echo -e "\e[1;31m✖ Failed to download VMware installer.\e[0m"
        return 1
    fi
}

install_vmware() {
    echo -e "\e[1;33m[  ..  ] Installing VMware Workstation\e[0m"
    chmod +x vmware-installer.bundle
    if ! sudo ./vmware-installer.bundle --console --required --eulas-agreed; then
        echo -e "\e[1;31m✖ Failed to install VMware.\e[0m"
        rm -f vmware-installer.bundle
        return 1
    fi
    rm -f vmware-installer.bundle
}

main() {
    echo -e "\e[1;36mℹ Installing VMware\e[0m"
    if is_vmware_installed; then
        echo -e "\e[1;32m✔ VMware is already installed.\e[0m"
        return 0
    fi
    
    if ! download_installer; then
        exit 1
    fi
    
    if ! install_vmware; then
        exit 1
    fi
    echo -e "\e[1;32m✔ VMware installation complete.\e[0m"
}

main
