#!/bin/bash
# Install Kubernetes CLI (kubectl) and Helm on Ubuntu

echo -e "\e[1;36mℹ Installing Kubernetes CLI (kubectl) & Helm\e[0m"

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

# --- Install kubectl ---
echo -e "\e[1;33m[  ..  ] Installing kubectl\e[0m"
# Download the public signing key for the Kubernetes package repositories
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg --yes

# Add the appropriate Kubernetes apt repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

sudo apt-get update
sudo apt-get install -y kubectl

# --- Install Helm ---
echo -e "\e[1;33m[  ..  ] Installing Helm\e[0m"
curl -fsSL https://baltocdn.com/helm/signing.asc | sudo gpg --dearmor -o /usr/share/keyrings/helm.gpg --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null

sudo apt-get update
sudo apt-get install -y helm

echo -e "\e[1;32m✔ Kubernetes tools installation complete.\e[0m"
kubectl version --client --output=yaml
helm version
