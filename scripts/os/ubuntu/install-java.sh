#!/bin/bash
# Install Java OpenJDK on Ubuntu

echo -e "\e[1;36mℹ Installing OpenJDK 21\e[0m"
sudo apt-get update
sudo apt-get install -y openjdk-21-jdk

echo -e "\e[1;32m✔ Java installed.\e[0m"
java -version
