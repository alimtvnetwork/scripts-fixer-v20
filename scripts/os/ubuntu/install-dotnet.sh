#!/bin/bash
# Install .NET SDK on Ubuntu

echo -e "\e[1;36mℹ Installing .NET SDK\e[0m"
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0

echo -e "\e[1;32m✔ .NET SDK installed.\e[0m"
dotnet --version
