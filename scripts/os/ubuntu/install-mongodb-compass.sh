#!/bin/bash
command_exists() { command -v "$1" >/dev/null 2>&1; }

download_package() {
    wget -qO mongodb-compass.deb "https://downloads.mongodb.com/compass/mongodb-compass_1.44.5_amd64.deb"
}

install_package() {
    sudo dpkg -i mongodb-compass.deb
    sudo apt-get install -f -y
    rm mongodb-compass.deb
}

install_compass() {
    if command_exists mongodb-compass; then
        echo "MongoDB Compass is already installed."
        return 0
    fi
    echo "Installing MongoDB Compass..."
    download_package
    install_package
}
install_compass
