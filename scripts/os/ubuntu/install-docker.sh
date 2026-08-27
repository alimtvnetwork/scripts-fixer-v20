#!/bin/bash
# Install Docker and Docker Compose on Ubuntu

echo -e "\e[1;36mℹ Installing Docker and Docker Compose\e[0m"

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start service
sudo systemctl enable --now docker

# Add current user to the docker group
if ! groups $USER | grep &>/dev/null '\bdocker\b'; then
    echo -e "\e[1;33mℹ Adding user $USER to the docker group...\e[0m"
    sudo usermod -aG docker $USER
    echo -e "\e[0;90mNote: You will need to log out and log back in (or run 'newgrp docker') for the group changes to take effect.\e[0m"
fi

echo -e "\e[1;32m✔ Docker installation complete.\e[0m"
docker --version
docker compose version
