# 03 Fedora Manage (v2)

This guide provides a comprehensive, step-by-step procedure for managing and configuring an Fedora system from scratch.

## 1. System Updates & OS Prerequisites
Update the OS and install high-speed package managers.
```bash
sudo dnf update -y && sudo dnf upgrade -y
sudo add-dnf-repository ppa:dnf/stable -y
sudo dnf -y install dnf
```

## 2. Core Utilities Installation
Install essential terminal utilities and dependencies:
```bash
sudo dnf install -y build-essential libssl-dev
sudo dnf install -y curl wget git vim nano htop gedit
sudo dnf install -y aria2 # For parallel downloads
sudo dnf install -y bleachbit
```

## 3. ZSH & Oh-My-Zsh Configuration
Fedora's default shell is bash, but we upgrade to ZSH for improved productivity.
- Install ZSH:
  ```bash
  sudo dnf install -y zsh
  ```
- Install Oh-My-Zsh:
  ```bash
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ```
- Install ZSH Autosuggestions Plugin:
  ```bash
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  chmod -R g-w,o-w ~/.oh-my-zsh
  ```
- Set default shell to ZSH for current user and root:
  ```bash
  sudo chsh -s $(which zsh) root
  chsh -s $(which zsh) $USER
  ```
- Apply ZSH Theme (Agnoster):
  ```bash
  echo 'ZSH_THEME="agnoster"' >> ~/.zshrc
  source ~/.zshrc
  ```

### 3.1 Helpful Aliases (ZSH & Vim)
Add these to your `~/.zshrc`:
```bash
alias editzsh='echo "editzsh => vim ~/.zshrc" && vim ~/.zshrc'
alias codezsh='code ~/.zshrc && applyzsh'
alias gezsh='code ~/.zshrc && applyzsh'
alias vmedit='echo "vmedit => vim ~/.vimrc && to add line numer add set number" && vim ~/.vimrc'
```

## 4. User Management & SSH
- Add a new user with bash as default (if not using zsh yet):
  ```bash
  sudo useradd -m -d /home/newuser -s /bin/bash newuser
  sudo usermod -aG sudo newuser
  ```
- Configure SSH Keys:
  ```bash
  ssh-keygen -t rsa -b 4096 -C 'Your email or machine id'
  alias catssh='echo "cat ~/.ssh/id_rsa.pub" && sudo cat ~/.ssh/id_rsa.pub'
  sudo vim ~/.ssh/authorized_keys
  ```

## 5. Development Tools (Docker, Go, VSCode)
- **Docker**:
  ```bash
  sudo dnf install -y docker.io
  sudo usermod -aG docker $USER
  sudo chmod 666 /var/run/docker.sock
  sudo snap connect docker:home
  ```
- **Go Installation**:
  ```bash
  wget https://go.dev/dl/go1.22.3.linux-amd64.tar.gz
  sudo tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz
  ```
- **Python Setup**:
  ```bash
  sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1
  ```
- **DBeaver**:
  ```bash
  sudo snap install dbeaver-ce
  # Or via deb: sudo rpm -ivh dbeaver-ce_latest_amd64.rpm
  ```
- **GitHub Desktop**:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/kontr0x/github-desktop-install/main/installGitHubDesktop.sh -o installGitHubDesktop.sh
  chmod +x installGitHubDesktop.sh
  ```

## 6. Kubernetes (Minikube & Kubectl)
- Install `kubectl`:
  ```bash
  sudo mv ./kubectl /usr/local/bin/kubectl
  chmod +x /usr/local/bin/kubectl
  ```
- Start Minikube & Kubernetes Aliases:
  ```bash
  sudo gedit ~/.kube/config
  alias krun='echo "krun => kubectl apply -f ." && kubectl apply -f .'
  ```

## 7. Web Servers & Databases
- Install Nginx:
  ```bash
  sudo dnf install -y nginx
  ```
- **Nginx Management Aliases**:
  ```bash
  alias ngnst='echo "ngnst => sudo systemctl start nginx" && sudo systemctl start nginx'
  alias ngnsp='echo "ngnsp => sudo systemctl stop nginx" && sudo systemctl stop nginx'
  alias ngnrt='echo "ngnrt => sudo systemctl reload nginx" && sudo systemctl reload nginx'
  alias ngndis='echo "ngndis => sudo systemctl disable nginx" && sudo systemctl disable nginx'
  ```
- **XAMPP Download using Aria2c**:
  ```bash
  aria2c -c -s 20 -x 15 -k 1M -j 1 https://altushost-swe.dl.sourceforge.net/project/xampp/XAMPP%20Linux/8.2.12/xampp-linux-x64-8.2.12-0-installer.run
  ```

## 8. Virtual Machine Shares (VMware)
```bash
yes | sudo dnf install open-vm-tools
/usr/bin/vmhgfs-fuse --enabled && sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
ln -s /mnt/hgfs ~/Desktop/SharedDirectories
```

## 9. Cleanup & Firewall
- **Enable UFW**:
  ```bash
  sudo ufw enable
  ```
- Clean up package residues:
  ```bash
  sudo dnf autoremove --purge
  sudo dnf clean
  docker system prune
  ```
