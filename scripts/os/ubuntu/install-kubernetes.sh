#!/bin/bash
# Install Kubernetes CLI (kubectl), Helm, kind, minikube, and k9s on Ubuntu

set -e

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

install_kubectl() {
    if is_installed "kubectl"; then
        echo -e "\e[1;32m✔ kubectl is already installed.\e[0m"
        return
    fi
    echo -e "\e[1;33m[  ..  ] Installing kubectl\e[0m"
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg --yes
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y kubectl
}

install_helm() {
    if is_installed "helm"; then
        echo -e "\e[1;32m✔ helm is already installed.\e[0m"
        return
    fi
    echo -e "\e[1;33m[  ..  ] Installing Helm\e[0m"
    curl -fsSL https://baltocdn.com/helm/signing.asc | sudo gpg --dearmor -o /usr/share/keyrings/helm.gpg --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y helm
}

install_kind() {
    if is_installed "kind"; then
        echo -e "\e[1;32m✔ kind is already installed.\e[0m"
        return
    fi
    echo -e "\e[1;33m[  ..  ] Installing kind\e[0m"
    local version="${KIND_VERSION:-latest}"
    if [ "$version" = "latest" ]; then
        curl -sLo ./kind "https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64"
    else
        curl -sLo ./kind "https://kind.sigs.k8s.io/dl/${version}/kind-linux-amd64"
    fi
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
}

install_minikube() {
    if is_installed "minikube"; then
        echo -e "\e[1;32m✔ minikube is already installed.\e[0m"
        return
    fi
    echo -e "\e[1;33m[  ..  ] Installing minikube\e[0m"
    local version="${MINIKUBE_VERSION:-latest}"
    curl -sLO "https://storage.googleapis.com/minikube/releases/${version}/minikube-linux-amd64"
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
}

install_k9s() {
    if is_installed "k9s"; then
        echo -e "\e[1;32m✔ k9s is already installed.\e[0m"
        return
    fi
    echo -e "\e[1;33m[  ..  ] Installing k9s\e[0m"
    local version="${K9S_VERSION:-latest}"
    local url="https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz"
    if [ "$version" != "latest" ]; then
        url="https://github.com/derailed/k9s/releases/download/${version}/k9s_Linux_amd64.tar.gz"
    fi
    curl -sLo k9s.tar.gz "$url"
    tar -xzf k9s.tar.gz k9s
    sudo mv k9s /usr/local/bin/
    rm k9s.tar.gz
}

main() {
    echo -e "\e[1;36mℹ Installing Kubernetes Suite\e[0m"
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
    install_kubectl
    install_helm
    install_kind
    install_minikube
    install_k9s
    echo -e "\e[1;32m✔ Kubernetes suite installation complete.\e[0m"
}

main
