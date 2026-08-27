#!/bin/bash
# Interactive Database Installer Menu for Unix

echo -e "\e[1;36mℹ Interactive Database Installer\e[0m"
echo -e ""
echo "Select a database to install:"
echo "  1) PostgreSQL"
echo "  2) MySQL"
echo "  3) Redis"
echo "  4) MongoDB"
echo "  q) Quit"
echo -e ""
read -p "Selection [1-4, q]: " selection

case $selection in
    1)
        echo "Installing PostgreSQL..."
        sudo apt-get update && sudo apt-get install -y postgresql postgresql-contrib
        ;;
    2)
        echo "Installing MySQL..."
        sudo apt-get update && sudo apt-get install -y mysql-server
        ;;
    3)
        echo "Installing Redis..."
        sudo apt-get update && sudo apt-get install -y redis-server
        ;;
    4)
        echo "Installing MongoDB..."
        sudo apt-get update && sudo apt-get install -y mongodb
        ;;
    q|Q)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "\e[1;31m✖ Invalid selection.\e[0m"
        exit 1
        ;;
esac

echo -e "\e[1;32m✔ Database installation complete.\e[0m"
