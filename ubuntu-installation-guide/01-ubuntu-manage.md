# Ubuntu Manage (Comprehensive Installation & Configuration Guide)

This guide provides a single source of truth for setting up an Ubuntu development environment from scratch. Every block of code below is fully copy-pasteable.

## System Maintenance & OS Updates

Update the operating system and clean up old packages.

```bash
sudo apt update -y && sudo apt upgrade -y
sudo do-release-upgrade -y
sudo apt-get autoremove --purge && sudo apt-get clean && sudo apt autoclean
```

## Apt-Fast Installation

Apt-fast is a wrapper that accelerates package downloading using multiple connections (via aria2).

```bash
sudo add-apt-repository ppa:apt-fast/stable -y
sudo apt-get update -y
sudo apt-get install apt-fast aria2 -y

# Configuration for apt-fast
# Edit /etc/apt-fast.conf to set DOWNLOADMANAGER="aria2c", MAXDOWNLOADS=16, SPLIT=10
sudo sed -i 's/^DOWNLOADMANAGER.*/DOWNLOADMANAGER="aria2c"/' /etc/apt-fast.conf
sudo sed -i 's/^MAXDOWNLOADS.*/MAXDOWNLOADS=16/' /etc/apt-fast.conf
```

## Fix Apt Update Issues (Old Releases)

If encountering `404 Not Found` for older Ubuntu versions:

```bash
cd /etc/apt
sudo cp sources.lst sources.lst.bak
sudo sed -i -- 's/us.archive/old-releases/g' sources.lst
sudo sed -i -- 's/security/old-releases/g' sources.lst
sudo apt-get update
```

## Basic Utilities & Dependencies

Install Git, Vim, Curl, Wget, Build-Essential, and other prerequisites.

```bash
sudo apt-fast install -y build-essential libssl-dev wget nano curl file git zlib1g zlib1g-dev libpcre3 libpcre3-dev
sudo apt-fast install -y vim gedit bleachbit snapd synaptic flameshot
```

## ZSH & Oh My Zsh Setup

Install ZSH, Oh My Zsh, auto-suggestions, and apply the configuration.

```bash
sudo apt-fast install -y zsh

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Install Zsh Autosuggestions Plugin
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
chmod -R g-w,o-w ~/.oh-my-zsh

# Set ZSH as default shell for user and root
sudo chsh -s $(which zsh)
sudo chsh -s $(which zsh) root

# Apply Theme
echo 'ZSH_THEME="agnoster"' >> ~/.zshrc
source ~/.zshrc
```

## ZSH Custom Aliases & Fixes

Append these powerful aliases to your `.zshrc` for faster workflows.

```bash
cat << 'EOF' >> ~/.zshrc

# General Aliases
alias clear_history='echo "" > ~/.zsh_history & exec $SHELL -l'
alias editzsh='echo "editzsh => vim ~/.zshrc" && vim ~/.zshrc'
alias codezsh='code ~/.zshrc && applyzsh'
alias gezsh='code ~/.zshrc && applyzsh'
alias applyzsh='echo "applyedit => source ~/.zshrc" && source ~/.zshrc'
alias editapplyzsh='echo "editapplyzsh => editzsh && echo "" && applyedit" && editzsh && echo "" && applyedit'
alias vmedit='echo "vmedit => vim ~/.vimrc && to add line numer add set number" && vim ~/.vimrc'
alias npzsh='notepad-plus-plus ~/.zshrc && applyzsh'

# Network & Nginx Aliases
alias rsnet='echo "rsnet => systemctl restart NetworkManager.service" && systemctl restart NetworkManager.service'
alias ngnsu='echo "ngnsu => sudo systemctl status nginx" && sudo systemctl status nginx'
alias ngnsp='echo "ngnsp => sudo systemctl stop nginx" && sudo systemctl stop nginx'
alias ngnst='echo "ngnst => sudo systemctl start nginx" && sudo systemctl start nginx'
alias ngnrt='echo "ngnrt => sudo systemctl reload nginx" && sudo systemctl reload nginx'
alias ngnenb='echo "ngnenb => sudo systemctl enable nginx" && sudo systemctl enable nginx'
alias ngndis='echo "ngndis => sudo systemctl disable nginx" && sudo systemctl disable nginx'

# Kubernetes Aliases
alias krun='echo "krun => kubectl apply -f ." && kubectl apply -f .'
alias k0='echo "k0 => kubectl scale deployment my-deployment --replicas=0" && kubectl scale deployment my-deployment --replicas=0'
alias kdel='echo "kdel => deleting all pods, service, pvc" && kubectl delete replicaset --all && kubectl delete pods --all && kubectl delete service --all && kubectl delete pvc --all & clear && kubectl get all'
alias kfw='echo "kubectl port-forward service/_name hostPort:dockerPort"'
alias kip='echo "minikube service --all --url" && minikube service --all --url'
alias mip='echo "minikube service --all" && minikube service --all'
alias kget='echo "kubectl get all" && kubectl get all'

# Security & SSH Aliases
alias epass='echo "echo -n _pass | base64"'
alias authedit='echo "sudo vim ~/.ssh/authorized_keys" && mkdir -p ~/.ssh && vim ~/.ssh/authorized_keys'
alias catssh='echo "cat ~/.ssh/id_rsa.pub" && sudo cat ~/.ssh/id_rsa.pub'
alias genssh='echo "ssh-keygen -t rsa -b 4096 -C <email>"'

EOF
source ~/.zshrc
```

## Vim Configuration

Set line numbers and syntax highlighting by default.

```bash
echo 'set nu' >> ~/.vimrc
echo 'syntax on' >> ~/.vimrc
```

## User Management

Create new users, modify privileges, and switch seamlessly.

```bash
# Add a new user
username="newuser"
homedir="/home/$username"
sudo useradd -m -d "$homedir" -s /bin/bash "$username"

# Grant sudo access
sudo usermod -aG sudo "$username"
echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

# Configure ZSH for the new user automatically
sudo chsh -s $(which zsh) "$username"
sudo -u "$username" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo -u "$username" bash -c 'echo "ZSH_THEME="agnoster"" >> ~/.zshrc'
```

## SSH & Firewall Setup

Generate SSH keys and open firewall ports.

```bash
# Generate Key
ssh-keygen -t rsa -b 4096 -C 'Your email or machine id'

# Fix Permissions
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Setup UFW
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 22
sudo ufw status
```

## Development Languages (Golang & Python 2.7)

### Automated Latest Golang Installation
This script dynamically fetches and installs the absolutely latest version of Go.

```bash
# Fetch latest version number automatically
GO_LATEST=$(curl -sL "https://go.dev/VERSION?m=text" | head -n 1)

# Download and install
wget "https://go.dev/dl/${GO_LATEST}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "${GO_LATEST}.linux-amd64.tar.gz"

# Configure PATH
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/go.sh
source /etc/profile.d/go.sh
go version
```

### Python 2.7 (Legacy Support)
```bash
wget https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz
sudo tar xzf Python-2.7.9.tgz
cd Python-2.7.9
sudo ./configure --enable-optimizations
sudo make altinstall
python2.7 -V
sudo ln -sfn /usr/local/bin/python2.7 /usr/bin/python2
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1
```

## Docker Installation & Configuration

### Rootful Docker (Standard)
```bash
sudo apt-fast install -y docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
newgrp docker
docker run hello-world
```

### Rootless Docker
```bash
sudo apt-fast install -y uidmap
curl -fsSL https://get.docker.com/rootless | sh
dockerd-rootless-setuptool.sh install
```

### Clean Docker Engine
```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get purge docker-ce docker-ce-cli containerd.io
docker system prune -a
```

## Kubernetes (Kubectl & Minikube)

### Kubectl Install
```bash
wget -qO- https://dl.k8s.io/release/stable.txt > v1.30.1.txt
KUBE_VERSION=$(cat v1.30.1.txt)
wget "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client
```

### Minikube Install
```bash
mkdir kube-ins && cd kube-ins
aria2c -c -s 20 -x 15 -k 1M -j 1 -o minikube-linux-amd64 https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
minikube start
```

## Integrated Development Environments (IDEs)

### Visual Studio Code
```bash
sudo apt-fast install -y software-properties-common apt-transport-https wget
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt-fast update -y
sudo apt-fast install -y code

# Fix UI Issues if lacking GPU
# Run VS Code via: code --disable-gpu

# Uninstall VS Code
# sudo apt-get remove code && rm -rf $HOME/.config/Code && rm -rf ~/.vscode
```

### JetBrains IDEs (Rider, Goland, WebStorm)
```bash
sudo snap install rider --classic
sudo snap install goland --classic
sudo snap install webstorm --classic
```

## Database Tools

### DBeaver
```bash
wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
sudo dpkg -i dbeaver-ce_latest_amd64.deb
# Alternative: sudo snap install dbeaver-ce
```

### MongoDB Compass
```bash
wget https://downloads.mongodb.com/compass/mongodb-compass_1.28.1_amd64.deb
sudo apt install -y ./mongodb-compass_1.28.1_amd64.deb
```

## VMware Tools & Shared Folders
Configure VM tools for host-to-guest sharing and mouse scroll fixes.

```bash
# VM Tools Install
yes | sudo apt-fast install open-vm-tools
sudo apt update -y && /usr/bin/vmware-toolbox-cmd -v

# Mount VM Shared Directories
/usr/bin/vmhgfs-fuse --enabled && sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
ln -s /mnt/hgfs ~/Desktop/SharedDirectories
```

## Additional Tools & Software

### XAMPP (Via Aria2c)
```bash
cd ~/Downloads
aria2c -c -s 20 -x 15 -k 1M -j 1 https://altushost-swe.dl.sourceforge.net/project/xampp/XAMPP%20Linux/8.2.12/xampp-linux-x64-8.2.12-0-installer.run
chmod +x xampp-linux-x64-8.2.12-0-installer.run
sudo ./xampp-linux-x64-8.2.12-0-installer.run
```

### WordPress Latest
```bash
wget https://wordpress.org/latest.zip
unzip latest.zip
```

### Beyond Compare
```bash
wget https://www.scootersoftware.com/files/bcompare-4.4.7.28397_amd64.deb
sudo dpkg -i bcompare-4.4.7.28397_amd64.deb
sudo apt-fast install -f
```

### PowerShell Core
```bash
sudo apt-fast install -y wget apt-transport-https software-properties-common
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-fast update -y
sudo apt-fast install -y powershell
pwsh
```

### GitHub Desktop
```bash
curl -fsSL https://raw.githubusercontent.com/kontr0x/github-desktop-install/main/installGitHubDesktop.sh -o installGitHubDesktop.sh
chmod +x installGitHubDesktop.sh
./installGitHubDesktop.sh
```

### Snap Store Fixes
```bash
sudo snap install snap-store-proxy
sudo snap install snap-store-proxy-client
sudo killall snap-store
sudo snap refresh snap-store
```

## Disk Management

Resize disks and clean history.

```bash
sudo cfdisk
# After resizing partition via cfdisk:
sudo resize2fs /dev/sda2

# Clear PowerShell History
Clear-History
Clear-History -Count 5 -Newest
```
