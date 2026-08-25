# 01 Debian Manage

This guide provides a comprehensive, step-by-step procedure for managing and configuring an Debian system from scratch. Any AI or developer can follow these instructions to replicate the environment.

## 1. System Updates & Prerequisites
Before installing any packages, ensure the system is up to date and uses high-speed package managers.
- Update the system:
  ```bash
  sudo apt update -y && sudo apt upgrade -y
  ```
- Install `apt-fast` to accelerate downloads using multiple connections:
  ```bash
  sudo add-apt-repository ppa:apt-fast/stable -y
  sudo apt -y install apt-fast
  ```

## 2. Core Utilities Installation
Install essential terminal utilities:
```bash
sudo apt-fast install -y curl wget git vim nano htop
sudo apt-fast install -y aria2 # For parallel downloads
sudo apt-fast install -y gedit bleachbit
```

## 3. ZSH & Oh-My-Zsh Configuration
Debian's default shell is bash, but we upgrade to ZSH for improved productivity.
- Install ZSH:
  ```bash
  sudo apt-fast install -y zsh
  ```
- Install Oh-My-Zsh:
  ```bash
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ```
- Set default shell to ZSH for current user and root:
  ```bash
  sudo chsh -s $(which zsh) root
  chsh -s $(which zsh) $USER
  ```
- Apply ZSH Theme (e.g., Agnoster):
  ```bash
  echo 'ZSH_THEME="agnoster"' >> ~/.zshrc
  source ~/.zshrc
  ```

## 4. User Management & SSH
- Add a new user with bash as default (if not using zsh yet):
  ```bash
  sudo useradd -m -d /home/newuser -s /bin/bash newuser
  ```
- Configure SSH Authorized Keys safely:
  ```bash
  sudo vim ~/.ssh/authorized_keys
  ```

## 5. Development Tools (Docker, Go, VSCode)
- **Docker**:
  ```bash
  sudo apt-fast install -y docker.io
  sudo usermod -aG docker $USER
  ```
- **Go Installation**:
  ```bash
  sudo tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz
  ```
- **VSCode**:
  Download the `.deb` and install using `dpkg -i`, or uninstall via `sudo apt-fast remove --purge code`.
- **DBeaver & Beyond Compare**:
  ```bash
  sudo dpkg -i dbeaver-ce_latest_amd64.deb
  ```

## 6. Kubernetes (Minikube & Kubectl)
- Install `kubectl`:
  ```bash
  sudo mv ./kubectl /usr/local/bin/kubectl
  chmod +x /usr/local/bin/kubectl
  ```
- Start Minikube. Note the custom alias for running k8s configurations:
  ```bash
  alias krun='kubectl apply -f .'
  ```

## 7. Web Servers & Databases
- Install Nginx:
  ```bash
  sudo apt-fast install -y nginx
  sudo systemctl start nginx
  ```
- XAMPP: Download the installer and execute.

## 8. Cleanup
- Clean up package residues:
  ```bash
  sudo apt-get autoremove --purge
  sudo apt-get clean
  ```
