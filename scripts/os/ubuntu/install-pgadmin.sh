#!/bin/bash
command_exists() { command -v "$1" >/dev/null 2>&1; }

is_installed() {
    dpkg -l | grep -q pgadmin4-desktop
}

add_repo() {
    sudo curl -fsSLo /usr/share/keyrings/pgadmin-archive-keyring.gpg https://www.pgadmin.org/static/packages_pgadmin_org.pub
    sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/pgadmin-archive-keyring.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
}

install_pgadmin() {
    if is_installed; then
        echo "pgAdmin 4 is already installed."
        return 0
    fi
    echo "Installing pgAdmin 4..."
    add_repo
    sudo apt-get install -y pgadmin4-desktop
}
install_pgadmin
