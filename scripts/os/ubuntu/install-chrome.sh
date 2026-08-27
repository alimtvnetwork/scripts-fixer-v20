#!/bin/bash
# Install Google Chrome on Ubuntu

echo -e "\e[1;36mℹ Installing Google Chrome\e[0m"

sudo apt-get update
sudo apt-get install -y wget curl

# Download and install Google Chrome Stable
echo -e "\e[1;33m[  ..  ] Downloading Google Chrome (.deb)...\e[0m"
wget -q -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

echo -e "\e[1;33m[  ..  ] Installing package...\e[0m"
sudo apt-get install -y /tmp/google-chrome-stable_current_amd64.deb

# Clean up
rm -f /tmp/google-chrome-stable_current_amd64.deb

echo -e "\e[1;32m✔ Google Chrome installation complete.\e[0m"
google-chrome --version
