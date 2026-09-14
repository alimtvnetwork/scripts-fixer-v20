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

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ROOT_DIR="$(cd "$_SCRIPT_DIR/../../.." && pwd)"

if [ -f "$_ROOT_DIR/scripts/shared/db.sh" ]; then
    . "$_ROOT_DIR/scripts/shared/db.sh"
    ensure_db
fi

for arg in "$@"; do
    if [ "$arg" = "tools" ] || [ "$arg" = "--tools" ] || [ "$arg" = "mount" ] || [ "$arg" = "--mount" ]; then
        exec bash "$_SCRIPT_DIR/install-vmware-tools.sh" "$@"
    fi
done

main() {
    echo -e "\e[1;36mℹ Installing VMware\e[0m"

    if is_vmware_installed; then
        echo -e "\e[1;32m✔ VMware is already installed.\e[0m"
        db_record_skipped package "vmware" "already installed"

        return 0
    fi

    db_record_start package "vmware" "install"

    if ! download_installer; then
        db_record_failure package "vmware" 1 "download failed"
        exit 1
    fi

    if ! install_vmware; then
        db_record_failure package "vmware" 1 "installer failed"
        exit 1
    fi

    local ver="${VMWARE_VERSION:-17.5.2}"
    db_record_success package "vmware" "$ver" "VMware Workstation installed"
    echo -e "\e[1;32m✔ VMware installation complete.\e[0m"
}

main "$@"
