#!/bin/bash

is_command_exist() {
    command -v "$1" >/dev/null 2>&1
}

ask_dbeaver() {
    echo "Do you want to install DBeaver? (y/n)"
    read -p "> " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        bash scripts/os/ubuntu/install-dbeaver.sh
    fi
}

ask_pgadmin() {
    echo "Do you want to install pgAdmin? (y/n)"
    read -p "> " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        bash scripts/os/ubuntu/install-pgadmin.sh
    fi
}

install_postgres() {
    if is_command_exist psql; then
        echo "PostgreSQL is already installed."
    else
        echo "Installing PostgreSQL..."
        sudo apt-get update && sudo apt-get install -y postgresql postgresql-contrib
        sudo systemctl enable --now postgresql
    fi
    ask_dbeaver
    ask_pgadmin
}

install_mysql() {
    echo "Installing MySQL..."
    sudo apt-get update && sudo apt-get install -y mysql-server
}

install_redis() {
    echo "Installing Redis..."
    sudo apt-get update && sudo apt-get install -y redis-server
}

setup_mongo_repo() {
    sudo apt-get update && sudo apt-get install -y gnupg curl
    curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
        sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor --yes
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
}

ask_compass() {
    echo "Do you want to install MongoDB Compass? (y/n)"
    read -p "> " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        bash scripts/os/ubuntu/install-mongodb-compass.sh
    fi
}

install_mongo() {
    if is_command_exist mongod; then
        echo "MongoDB is already installed."
    else
        echo "Installing MongoDB..."
        setup_mongo_repo
        sudo apt-get update
        sudo apt-get install -y mongodb-org
        sudo systemctl enable --now mongod
    fi
    ask_compass
}

print_menu() {
    echo -e "\e[1;36mℹ Interactive Database Installer\e[0m\n"
    echo "Select a database to install:"
    echo "  1) PostgreSQL"
    echo "  2) MySQL"
    echo "  3) Redis"
    echo "  4) MongoDB"
    echo "  q) Quit"
    echo -e ""
}

handle_selection() {
    read -p "Selection [1-4, q]: " selection
    case $selection in
        1) install_postgres ;;
        2) install_mysql ;;
        3) install_redis ;;
        4) install_mongo ;;
        q|Q) echo "Exiting..."; exit 0 ;;
        *) echo -e "\e[1;31m✖ Invalid selection.\e[0m"; exit 1 ;;
    esac
    echo -e "\e[1;32m✔ Database installation complete.\e[0m"
}

main() {
    print_menu
    handle_selection
}

main
