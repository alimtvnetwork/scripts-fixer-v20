#!/bin/bash
sudo apt-get install -y openssh-server

PORT=$1
if [ -z "$PORT" ]; then
    read -p "Enter custom SSH port (Default: 22): " PORT
fi
if [ -z "$PORT" ]; then
    PORT=22
fi

echo "Configuring SSH on Port $PORT..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

if grep -q "^#Port" /etc/ssh/sshd_config; then
    sudo sed -i "s/^#Port.*/Port $PORT/" /etc/ssh/sshd_config
elif grep -q "^Port" /etc/ssh/sshd_config; then
    sudo sed -i "s/^Port.*/Port $PORT/" /etc/ssh/sshd_config
else
    echo "Port $PORT" | sudo tee -a /etc/ssh/sshd_config
fi

sudo service ssh restart || sudo systemctl restart ssh
echo "SSH Installation and configuration complete."
