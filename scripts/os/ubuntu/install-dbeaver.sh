#!/bin/bash
command_exists() { command -v "$1" >/dev/null 2>&1; }

download_package() {
    wget -qO dbeaver.deb "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"
}

install_package() {
    sudo dpkg -i dbeaver.deb
    sudo apt-get install -f -y
    rm dbeaver.deb
}

install_dbeaver() {
    if command_exists dbeaver-ce || command_exists dbeaver; then
        echo "DBeaver is already installed."
        return 0
    fi
    echo "Installing DBeaver..."
    download_package
    install_package
}
install_dbeaver
