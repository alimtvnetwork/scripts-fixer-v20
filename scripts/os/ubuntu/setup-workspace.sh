#!/bin/bash
# Setup default workspace directory for the user

DEFAULT_WORKSPACE="$HOME/work"

echo -e "\e[1;36mℹ Setting up Workspace Directory\e[0m"
echo -e "\e[0;90mCurrent default is: $DEFAULT_WORKSPACE\e[0m"
echo -e ""
read -p "Enter new workspace path (or press Enter to keep default): " USER_WORKSPACE

if [ ! -z "$USER_WORKSPACE" ]; then
    WORKSPACE="$USER_WORKSPACE"
else
    WORKSPACE="$DEFAULT_WORKSPACE"
fi

# Expand tilde if present
WORKSPACE="${WORKSPACE/#\~/$HOME}"

echo -e "Creating workspace at: \e[1;33m$WORKSPACE\e[0m"
mkdir -p "$WORKSPACE"

# Set an environment variable in bashrc/zshrc
if grep -q "DEV_WORKSPACE=" ~/.bashrc; then
    sed -i "s|export DEV_WORKSPACE=.*|export DEV_WORKSPACE=\"$WORKSPACE\"|" ~/.bashrc
else
    echo "export DEV_WORKSPACE=\"$WORKSPACE\"" >> ~/.bashrc
fi

if [ -f ~/.zshrc ]; then
    if grep -q "DEV_WORKSPACE=" ~/.zshrc; then
        sed -i "s|export DEV_WORKSPACE=.*|export DEV_WORKSPACE=\"$WORKSPACE\"|" ~/.zshrc
    else
        echo "export DEV_WORKSPACE=\"$WORKSPACE\"" >> ~/.zshrc
    fi
fi

echo -e "\e[1;32m✔ Workspace configured successfully.\e[0m"
echo -e "You can navigate to it using \e[1;36mcd \$DEV_WORKSPACE\e[0m"
