# Ubuntu Manage

A single source of truth for setting up and maintaining an Ubuntu (amd64) development machine. Every section below is one self-contained block you can copy and paste in one shot.

Notes that apply everywhere:

- Blocks that use `apt-fast` work identically with `apt` — swap the word if you skipped the apt-fast section.
- Each block ends with a verification command so you know it worked.
- Anything risky or outdated lives at the end under Legacy / Use With Caution.

## Table of Contents

- [System Update And Cleanup](#system-update-and-cleanup)
- [Apt-Fast Parallel Download Accelerator](#apt-fast-parallel-download-accelerator)
- [Core Utilities And Build Dependencies](#core-utilities-and-build-dependencies)
- [Desktop Utilities](#desktop-utilities)
- [ZSH With Oh My Zsh And Autosuggestions](#zsh-with-oh-my-zsh-and-autosuggestions)
- [ZSH Alias Pack](#zsh-alias-pack)
- [Vim Configuration](#vim-configuration)
- [Create A New Sudo User With ZSH](#create-a-new-sudo-user-with-zsh)
- [SSH Keys And UFW Firewall](#ssh-keys-and-ufw-firewall)
- [Python Latest With Pip And Pipx](#python-latest-with-pip-and-pipx)
- [Python Any Version Via Pyenv](#python-any-version-via-pyenv)
- [Golang Latest Into /usr/local](#golang-latest-into-usrlocal)
- [Golang Latest Into A Custom Drive Or Mount](#golang-latest-into-a-custom-drive-or-mount)
- [PHP Latest With Extensions And Composer](#php-latest-with-extensions-and-composer)
- [Docker Engine (Rootful)](#docker-engine-rootful)
- [Docker Rootless Mode](#docker-rootless-mode)
- [Remove Docker Completely](#remove-docker-completely)
- [Kubectl Latest Stable](#kubectl-latest-stable)
- [Kubeadm, Kubelet And Kubectl From pkgs.k8s.io](#kubeadm-kubelet-and-kubectl-from-pkgsk8sio)
- [Helm Latest](#helm-latest)
- [K9s And Kubectl Shell Completion](#k9s-and-kubectl-shell-completion)
- [Minikube](#minikube)
- [Visual Studio Code](#visual-studio-code)
- [JetBrains IDEs Via Snap](#jetbrains-ides-via-snap)
- [DBeaver Community Edition](#dbeaver-community-edition)
- [MongoDB Compass](#mongodb-compass)
- [Beyond Compare Latest](#beyond-compare-latest)
- [PowerShell Core](#powershell-core)
- [GitHub Desktop](#github-desktop)
- [WordPress Latest](#wordpress-latest)
- [VMware Open VM Tools And Shared Folders](#vmware-open-vm-tools-and-shared-folders)
- [Snap Store Repair](#snap-store-repair)
- [Disk Partition Resize](#disk-partition-resize)
- [Legacy / Use With Caution](#legacy--use-with-caution)

## System Update And Cleanup

Refreshes package indexes, upgrades everything installed, then removes orphaned packages and cached archives to reclaim disk space.

```bash
sudo apt update -y
sudo apt upgrade -y
sudo apt full-upgrade -y
sudo apt-get autoremove --purge -y
sudo apt-get clean
sudo apt autoclean
echo "System updated:" && lsb_release -ds && uname -r
```

## Apt-Fast Parallel Download Accelerator

Wraps apt and downloads packages with aria2 over many parallel connections, which makes large installs dramatically faster. Install this first so later blocks can use it.

```bash
sudo apt update -y
sudo apt install -y software-properties-common aria2
sudo add-apt-repository ppa:apt-fast/stable -y
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-fast
sudo sed -i 's|^[#]*[[:space:]]*DOWNLOADBEFORE=.*|DOWNLOADBEFORE=true|' /etc/apt-fast.conf
sudo sed -i 's|^[#]*[[:space:]]*_APTMGR=.*|_APTMGR=apt-get|' /etc/apt-fast.conf
sudo sed -i 's|^[#]*[[:space:]]*DOWNLOADMANAGER=.*|DOWNLOADMANAGER="aria2c"|' /etc/apt-fast.conf
sudo sed -i 's|^[#]*[[:space:]]*MAXDOWNLOADS=.*|MAXDOWNLOADS=16|' /etc/apt-fast.conf
sudo sed -i 's|^[#]*[[:space:]]*SPLIT=.*|SPLIT=10|' /etc/apt-fast.conf
sudo sed -i 's|^[#]*[[:space:]]*_MAXNUM=.*|_MAXNUM=16|' /etc/apt-fast.conf
grep -E '^(DOWNLOADMANAGER|MAXDOWNLOADS|SPLIT|_MAXNUM)' /etc/apt-fast.conf
apt-fast --version | head -n 1
```

## Core Utilities And Build Dependencies

Compilers, headers and command line basics that almost every later install (Go modules, PHP extensions, Python builds, node-gyp) depends on.

```bash
sudo apt-fast update -y
sudo apt-fast install -y build-essential pkg-config make gcc g++ \
  libssl-dev zlib1g zlib1g-dev libpcre3 libpcre3-dev libffi-dev libbz2-dev \
  libreadline-dev libsqlite3-dev liblzma-dev libncurses-dev \
  git curl wget nano vim file unzip zip tar gnupg ca-certificates lsb-release \
  htop tree jq net-tools dnsutils apt-transport-https
gcc --version | head -n 1
git --version
```

## Desktop Utilities

Everyday GUI helpers: a text editor, screenshot tool, disk cleaner, package manager front end and snap support.

```bash
sudo apt-fast update -y
sudo apt-fast install -y gedit flameshot bleachbit synaptic snapd gnome-tweaks
sudo systemctl enable --now snapd.socket
snap version | head -n 2
```

## ZSH With Oh My Zsh And Autosuggestions

Installs the ZSH shell, the Oh My Zsh framework, the autosuggestions plugin, sets the agnoster theme, and makes ZSH the default shell for your user and root.

```bash
sudo apt-fast install -y zsh git curl
RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 2>/dev/null || true
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 2>/dev/null || true
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="agnoster"|' ~/.zshrc
sed -i 's|^plugins=.*|plugins=(git docker kubectl zsh-autosuggestions zsh-syntax-highlighting)|' ~/.zshrc
chmod -R g-w,o-w ~/.oh-my-zsh
sudo chsh -s "$(which zsh)" "$USER"
sudo chsh -s "$(which zsh)" root
zsh --version && grep -E '^(ZSH_THEME|plugins)=' ~/.zshrc
```

## ZSH Alias Pack

Appends the full shortcut set for shell config editing, networking, nginx, Kubernetes and SSH. Safe to run once; running twice duplicates the block.

```bash
cat << 'EOF' >> ~/.zshrc
# ---------- General ----------
alias clear_history='echo "" > ~/.zsh_history & exec $SHELL -l'
alias editzsh='echo "editzsh => vim ~/.zshrc" && vim ~/.zshrc'
alias codezsh='code ~/.zshrc && applyzsh'
alias gezsh='code ~/.zshrc && applyzsh'
alias applyzsh='echo "applyzsh => source ~/.zshrc" && source ~/.zshrc'
alias editapplyzsh='editzsh && echo "" && applyzsh'
alias vmedit='echo "vmedit => vim ~/.vimrc (add: set number)" && vim ~/.vimrc'
alias npzsh='notepad-plus-plus ~/.zshrc && applyzsh'
# ---------- Network & Nginx ----------
alias rsnet='echo "rsnet => systemctl restart NetworkManager.service" && sudo systemctl restart NetworkManager.service'
alias ngnsu='echo "ngnsu => sudo systemctl status nginx" && sudo systemctl status nginx'
alias ngnsp='echo "ngnsp => sudo systemctl stop nginx" && sudo systemctl stop nginx'
alias ngnst='echo "ngnst => sudo systemctl start nginx" && sudo systemctl start nginx'
alias ngnrt='echo "ngnrt => sudo systemctl reload nginx" && sudo systemctl reload nginx'
alias ngnenb='echo "ngnenb => sudo systemctl enable nginx" && sudo systemctl enable nginx'
alias ngndis='echo "ngndis => sudo systemctl disable nginx" && sudo systemctl disable nginx'
# ---------- Kubernetes ----------
alias krun='echo "krun => kubectl apply -f ." && kubectl apply -f .'
alias k0='echo "k0 => kubectl scale deployment my-deployment --replicas=0" && kubectl scale deployment my-deployment --replicas=0'
alias kdel='echo "kdel => deleting all replicasets, pods, services, pvc" && kubectl delete replicaset --all && kubectl delete pods --all && kubectl delete service --all && kubectl delete pvc --all && clear && kubectl get all'
alias kfw='echo "kubectl port-forward service/_name hostPort:dockerPort"'
alias kip='echo "minikube service --all --url" && minikube service --all --url'
alias mip='echo "minikube service --all" && minikube service --all'
alias kget='echo "kubectl get all" && kubectl get all'
# ---------- Python ----------
alias venv='echo "venv => python3 -m venv .venv && source .venv/bin/activate" && python3 -m venv .venv && source .venv/bin/activate'
alias act='echo "act => source .venv/bin/activate" && source .venv/bin/activate'
alias pipup='echo "pipup => python3 -m pip install --upgrade pip setuptools wheel" && python3 -m pip install --upgrade pip setuptools wheel'
# ---------- Security & SSH ----------
alias epass='echo "echo -n _pass | base64"'
alias authedit='echo "vim ~/.ssh/authorized_keys" && mkdir -p ~/.ssh && vim ~/.ssh/authorized_keys'
alias catssh='echo "cat ~/.ssh/id_rsa.pub" && cat ~/.ssh/id_rsa.pub'
alias genssh='echo "ssh-keygen -t rsa -b 4096 -C <email>"'
EOF
source ~/.zshrc
alias | grep -cE 'ngn|kget|applyzsh'
```

## Vim Configuration

Turns on line numbers, syntax highlighting and sane indentation defaults.

```bash
cat << 'EOF' >> ~/.vimrc
set nu
syntax on
set tabstop=4
set shiftwidth=4
set expandtab
set hlsearch
set incsearch
set mouse=a
EOF
cat ~/.vimrc
```

## Create A New Sudo User With ZSH

Creates a user with a home directory, grants sudo, and gives them the same ZSH plus agnoster setup. Change `USERNAME` before running.

```bash
USERNAME="newuser"
sudo useradd -m -d "/home/$USERNAME" -s /bin/bash "$USERNAME"
sudo passwd "$USERNAME"
sudo usermod -aG sudo "$USERNAME"
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/90-$USERNAME"
sudo chmod 440 "/etc/sudoers.d/90-$USERNAME"
sudo apt-fast install -y zsh
sudo chsh -s "$(which zsh)" "$USERNAME"
sudo -u "$USERNAME" env RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo -u "$USERNAME" bash -c 'sed -i "s|^ZSH_THEME=.*|ZSH_THEME=\"agnoster\"|" ~/.zshrc'
id "$USERNAME" && getent passwd "$USERNAME"
```

## SSH Keys And UFW Firewall

Generates a 4096-bit RSA key pair, fixes `.ssh` permissions, then enables the firewall with SSH allowed so you do not lock yourself out.

```bash
EMAIL="your-email-or-machine-id"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f ~/.ssh/id_rsa -N ""
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
sudo apt-fast install -y ufw openssh-server
sudo ufw allow OpenSSH
sudo ufw allow 22/tcp
sudo ufw --force enable
sudo ufw status verbose
cat ~/.ssh/id_rsa.pub
```

## Python Latest With Pip And Pipx

Adds the deadsnakes PPA, resolves the newest `pythonX.Y` package available, and installs it alongside the system Python. The distro `python3` is left untouched on purpose — replacing it breaks Ubuntu's own tooling (apt, netplan, ubuntu-drivers).

```bash
sudo apt-fast install -y software-properties-common ca-certificates curl
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update -y
PY_LATEST=$(apt-cache search --names-only '^python3\.[0-9]+$' | awk '{print $1}' | sed 's/python//' | sort -V | tail -n 1)
echo "Installing Python $PY_LATEST"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  "python${PY_LATEST}" "python${PY_LATEST}-venv" "python${PY_LATEST}-dev" \
  "python${PY_LATEST}-distutils" "python${PY_LATEST}-lib2to3" 2>/dev/null || \
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  "python${PY_LATEST}" "python${PY_LATEST}-venv" "python${PY_LATEST}-dev"
sudo update-alternatives --install /usr/bin/python3 python3 "/usr/bin/python${PY_LATEST}" 2
sudo update-alternatives --install /usr/bin/python python "/usr/bin/python${PY_LATEST}" 2
"python${PY_LATEST}" -m ensurepip --upgrade 2>/dev/null || {
  curl -fsSL https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
  "python${PY_LATEST}" /tmp/get-pip.py
  rm -f /tmp/get-pip.py
}
"python${PY_LATEST}" -m pip install --upgrade pip setuptools wheel
"python${PY_LATEST}" -m pip install --user --upgrade pipx virtualenv
"python${PY_LATEST}" -m pipx ensurepath
grep -q '.local/bin' ~/.zshrc 2>/dev/null || echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.zshrc
grep -q '.local/bin' ~/.bashrc 2>/dev/null || echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
python3 --version && "python${PY_LATEST}" --version && "python${PY_LATEST}" -m pip --version && pipx --version
```

Switch between installed interpreters at any time:

```bash
sudo update-alternatives --config python3
python3 --version
```

Create a project virtual environment (always prefer this over `sudo pip install`):

```bash
cd ~/your-project
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
python -V && which python
```

## Python Any Version Via Pyenv

Use this when deadsnakes has no package for your release, or when you need several exact Python versions side by side. Builds from source, so the build dependencies section must be installed first.

```bash
sudo apt-fast install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils \
  tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev git
[ -d "$HOME/.pyenv" ] || curl -fsSL https://pyenv.run | bash
cat << 'EOF' >> ~/.zshrc
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
PY_BUILD=$(pyenv install --list | grep -E '^\s+3\.[0-9]+\.[0-9]+$' | tail -n 1 | tr -d ' ')
echo "Building Python $PY_BUILD"
pyenv install -s "$PY_BUILD"
pyenv global "$PY_BUILD"
pyenv versions && python -V && pip -V
```

## Golang Latest Into /usr/local

Resolves the newest Go release from go.dev, replaces any existing toolchain, and configures PATH, GOROOT and GOPATH system-wide.

```bash
cd /tmp
GO_LATEST=$(curl -sL "https://go.dev/VERSION?m=text" | head -n 1)
GO_TARBALL="${GO_LATEST}.linux-amd64.tar.gz"
echo "Installing $GO_LATEST"
curl -fLO "https://go.dev/dl/${GO_TARBALL}"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$GO_TARBALL"
rm -f "$GO_TARBALL"
sudo tee /etc/profile.d/go.sh > /dev/null << 'EOF'
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
EOF
sudo chmod 644 /etc/profile.d/go.sh
grep -q 'profile.d/go.sh' ~/.zshrc 2>/dev/null || echo 'source /etc/profile.d/go.sh' >> ~/.zshrc
grep -q 'profile.d/go.sh' ~/.bashrc 2>/dev/null || echo 'source /etc/profile.d/go.sh' >> ~/.bashrc
source /etc/profile.d/go.sh
mkdir -p "$HOME/go/bin"
go version && go env GOROOT GOPATH
```

Confirm `go install` binaries land on your PATH:

```bash
go install golang.org/x/tools/gopls@latest
ls "$(go env GOPATH)/bin"
which gopls && gopls version
```

Updating later is the same block again — it removes `/usr/local/go` and re-extracts the newest tarball, so there is nothing to uninstall first.

## Golang Latest Into A Custom Drive Or Mount

Same latest-version install, but placed on a secondary disk or mount (the Linux equivalent of a "D drive"). Edit `GO_INSTALL_DIR` and `GO_WORKSPACE` only.

```bash
GO_INSTALL_DIR="/mnt/data"
GO_WORKSPACE="/mnt/data/gopath"
cd /tmp
GO_LATEST=$(curl -sL "https://go.dev/VERSION?m=text" | head -n 1)
GO_TARBALL="${GO_LATEST}.linux-amd64.tar.gz"
sudo mkdir -p "$GO_INSTALL_DIR" "$GO_WORKSPACE"
curl -fLO "https://go.dev/dl/${GO_TARBALL}"
sudo rm -rf "${GO_INSTALL_DIR}/go"
sudo tar -C "$GO_INSTALL_DIR" -xzf "$GO_TARBALL"
rm -f "$GO_TARBALL"
sudo chown -R "$USER":"$USER" "$GO_WORKSPACE"
sudo tee /etc/profile.d/go.sh > /dev/null << EOF
export GOROOT=${GO_INSTALL_DIR}/go
export GOPATH=${GO_WORKSPACE}
export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin
EOF
sudo chmod 644 /etc/profile.d/go.sh
grep -q 'profile.d/go.sh' ~/.zshrc 2>/dev/null || echo 'source /etc/profile.d/go.sh' >> ~/.zshrc
grep -q 'profile.d/go.sh' ~/.bashrc 2>/dev/null || echo 'source /etc/profile.d/go.sh' >> ~/.bashrc
source /etc/profile.d/go.sh
which go && go version && go env GOROOT GOPATH
```

## PHP Latest With Extensions And Composer

Installs the newest PHP from the ondrej PPA with the extensions web projects normally need, plus Composer. No XAMPP involved.

```bash
sudo apt-fast install -y software-properties-common ca-certificates lsb-release apt-transport-https
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update -y
PHP_LATEST=$(apt-cache search --names-only '^php[0-9]+\.[0-9]+$' | awk '{print $1}' | sed 's/php//' | sort -V | tail -n 1)
echo "Installing PHP $PHP_LATEST"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  "php${PHP_LATEST}" "php${PHP_LATEST}-cli" "php${PHP_LATEST}-fpm" "php${PHP_LATEST}-common" \
  "php${PHP_LATEST}-mysql" "php${PHP_LATEST}-pgsql" "php${PHP_LATEST}-sqlite3" \
  "php${PHP_LATEST}-curl" "php${PHP_LATEST}-mbstring" "php${PHP_LATEST}-xml" \
  "php${PHP_LATEST}-zip" "php${PHP_LATEST}-gd" "php${PHP_LATEST}-bcmath" \
  "php${PHP_LATEST}-intl" "php${PHP_LATEST}-opcache" "php${PHP_LATEST}-readline"
sudo update-alternatives --set php "/usr/bin/php${PHP_LATEST}"
sudo systemctl enable --now "php${PHP_LATEST}-fpm"
curl -fsSL https://getcomposer.org/installer -o /tmp/composer-setup.php
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm -f /tmp/composer-setup.php
php -v && composer --version && php -m | head -n 30
```

## Docker Engine (Rootful)

Adds Docker's official repository, installs the engine, CLI, containerd, buildx and compose, then puts your user in the docker group.

```bash
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd -f docker
sudo usermod -aG docker "$USER"
sudo systemctl enable --now docker
sudo docker run --rm hello-world
docker --version && docker compose version
echo "Log out and back in (or run: newgrp docker) to use docker without sudo"
```

Confirm you are on Docker's own packages (not Ubuntu's older `docker.io`) and that both plugins are live:

```bash
apt-cache policy docker-ce | head -n 4
grep -r 'download.docker.com' /etc/apt/sources.list.d/docker.list
docker version --format '{{.Server.Version}}'
docker buildx version
docker compose version
systemctl is-active docker && systemctl is-enabled docker
```

Upgrade to the newest engine later:

```bash
sudo apt-get update -y
sudo apt-get install -y --only-upgrade docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker --version
```

## Docker Rootless Mode

Runs the daemon as your own user without root privileges, which is safer for shared or development machines.

```bash
sudo apt-fast install -y uidmap dbus-user-session slirp4netns fuse-overlayfs
sudo systemctl disable --now docker.service docker.socket 2>/dev/null || true
curl -fsSL https://get.docker.com/rootless | sh
export PATH="$HOME/bin:$PATH"
export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
dockerd-rootless-setuptool.sh install
grep -q 'DOCKER_HOST' ~/.zshrc 2>/dev/null || printf 'export PATH=$HOME/bin:$PATH\nexport DOCKER_HOST=unix:///run/user/%s/docker.sock\n' "$(id -u)" >> ~/.zshrc
systemctl --user enable --now docker
sudo loginctl enable-linger "$USER"
docker context use rootless 2>/dev/null || true
docker info | grep -i rootless
docker run --rm hello-world
```

## Remove Docker Completely

Purges packages, images, volumes and config. This deletes all container data permanently.

```bash
docker system prune -a -f --volumes 2>/dev/null || true
sudo systemctl disable --now docker.service docker.socket 2>/dev/null || true
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker docker-engine docker.io runc
sudo apt-get autoremove --purge -y
sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker ~/.docker
sudo rm -f /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.gpg
sudo groupdel docker 2>/dev/null || true
which docker || echo "Docker fully removed"
```

## Kubectl Latest Stable

Downloads the current stable kubectl, verifies its checksum, and installs it to `/usr/local/bin`.

```bash
cd /tmp
KUBE_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)
echo "Installing kubectl $KUBE_VERSION"
curl -fLO "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
curl -fLO "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl kubectl.sha256
mkdir -p ~/.kube
kubectl version --client
```

## Kubeadm, Kubelet And Kubectl From pkgs.k8s.io

Apt-managed Kubernetes components for building a real cluster node. The minor version stream is resolved from `stable.txt`, then the packages are held so an unattended upgrade cannot jump a minor version under you.

```bash
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
KUBE_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)
KUBE_MINOR=$(echo "$KUBE_VERSION" | cut -d. -f1,2)
echo "Using Kubernetes stream $KUBE_MINOR ($KUBE_VERSION)"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${KUBE_MINOR}/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod a+r /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_MINOR}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
kubeadm version -o short && kubectl version --client --output=yaml | head -n 5 && kubelet --version
```

Node prerequisites before `kubeadm init` (swap off, kernel modules, sysctl):

```bash
sudo swapoff -a
sudo sed -i '/\sswap\s/s/^/#/' /etc/fstab
printf 'overlay\nbr_netfilter\n' | sudo tee /etc/modules-load.d/k8s.conf > /dev/null
sudo modprobe overlay && sudo modprobe br_netfilter
printf 'net.bridge.bridge-nf-call-iptables=1\nnet.bridge.bridge-nf-call-ip6tables=1\nnet.ipv4.ip_forward=1\n' | sudo tee /etc/sysctl.d/k8s.conf > /dev/null
sudo sysctl --system > /dev/null
free -h | grep -i swap && sysctl net.ipv4.ip_forward && lsmod | grep -E 'overlay|br_netfilter'
```

Move to a newer minor version later — bump the stream, then unhold:

```bash
sudo apt-mark unhold kubelet kubeadm kubectl
# re-run the block above so the repo URL points at the new minor stream
kubeadm version -o short
```

## Helm Latest

Kubernetes package manager, installed from the official script which always resolves the newest release.

```bash
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o /tmp/get-helm-3
chmod +x /tmp/get-helm-3
/tmp/get-helm-3
rm -f /tmp/get-helm-3
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
helm repo update
helm version --short && helm repo list
```

## K9s And Kubectl Shell Completion

A terminal dashboard for clusters, plus tab completion and the `k` alias for kubectl in both zsh and bash.

```bash
cd /tmp
K9S_VERSION=$(curl -fsSL https://api.github.com/repos/derailed/k9s/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+')
echo "Installing k9s $K9S_VERSION"
curl -fL -o k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
tar xzf k9s.tar.gz k9s
sudo install -o root -g root -m 0755 k9s /usr/local/bin/k9s
rm -f k9s k9s.tar.gz
grep -q 'kubectl completion zsh' ~/.zshrc 2>/dev/null || printf 'source <(kubectl completion zsh)\nalias k=kubectl\ncompdef __start_kubectl k\n' >> ~/.zshrc
grep -q 'kubectl completion bash' ~/.bashrc 2>/dev/null || printf 'source <(kubectl completion bash)\nalias k=kubectl\ncomplete -o default -F __start_kubectl k\n' >> ~/.bashrc
k9s version --short && kubectl completion zsh | head -n 1
```

## Minikube

Installs the latest Minikube binary (downloaded in parallel with aria2) and starts a local single-node cluster using the Docker driver.

```bash
mkdir -p ~/kube-ins && cd ~/kube-ins
aria2c -c -s 20 -x 15 -k 1M -j 1 -o minikube-linux-amd64 https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm -f minikube-linux-amd64
minikube start --driver=docker
minikube status && kubectl get nodes
```

## Visual Studio Code

Adds Microsoft's signed apt repository and installs VS Code so it stays updated through apt.

```bash
sudo apt-fast install -y software-properties-common apt-transport-https wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
echo "deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y code
code --version
echo "If the UI flickers on a machine without GPU acceleration, launch with: code --disable-gpu"
```

Remove VS Code and all of its user data:

```bash
sudo apt-get remove --purge -y code
rm -rf "$HOME/.config/Code" "$HOME/.vscode"
sudo rm -f /etc/apt/sources.list.d/vscode.list
which code || echo "VS Code removed"
```

## JetBrains IDEs Via Snap

Installs Rider, GoLand and WebStorm in classic confinement so they get full filesystem access.

```bash
sudo apt-fast install -y snapd
sudo systemctl enable --now snapd.socket
sudo snap install rider --classic
sudo snap install goland --classic
sudo snap install webstorm --classic
snap list | grep -E 'rider|goland|webstorm'
```

## DBeaver Community Edition

Universal database GUI client, installed from the vendor's always-current `.deb`.

```bash
cd /tmp
curl -fLO https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
sudo apt-get install -y ./dbeaver-ce_latest_amd64.deb
rm -f dbeaver-ce_latest_amd64.deb
dbeaver-ce --version 2>/dev/null || dpkg -s dbeaver-ce | grep -E 'Package|Version'
```

Snap alternative if you prefer sandboxed updates:

```bash
sudo snap install dbeaver-ce
snap list dbeaver-ce
```

## MongoDB Compass

Official GUI for MongoDB, pulled from the current stable download endpoint.

```bash
cd /tmp
curl -fL -o mongodb-compass.deb "https://downloads.mongodb.com/compass/mongodb-compass_latest_amd64.deb"
sudo apt-get install -y ./mongodb-compass.deb
rm -f mongodb-compass.deb
dpkg -s mongodb-compass | grep -E 'Package|Version'
```

## Beyond Compare Latest

Resolves the newest `.deb` link directly from the Scooter Software download page instead of pinning an old version, then installs it with dependencies resolved.

```bash
cd /tmp
BC_URL=$(curl -fsSL https://www.scootersoftware.com/download | grep -oE 'https?://[^"'"'"']*bcompare-[0-9._]+_amd64\.deb' | head -n 1)
[ -n "$BC_URL" ] || BC_URL=$(curl -fsSL https://www.scootersoftware.com/download | grep -oE '/files/bcompare-[0-9._]+_amd64\.deb' | head -n 1 | sed 's|^|https://www.scootersoftware.com|')
echo "Downloading $BC_URL"
curl -fL -o bcompare_amd64.deb "$BC_URL"
sudo apt-get install -y ./bcompare_amd64.deb
sudo apt-get install -f -y
rm -f bcompare_amd64.deb
dpkg -s bcompare | grep -E 'Package|Version'
bcompare -h 2>/dev/null | head -n 2 || true
```

## PowerShell Core

Adds the Microsoft production repository for your actual Ubuntu release and installs `pwsh`.

```bash
sudo apt-fast install -y wget apt-transport-https software-properties-common
cd /tmp
UBUNTU_VER=$(lsb_release -rs)
wget -q "https://packages.microsoft.com/config/ubuntu/${UBUNTU_VER}/packages-microsoft-prod.deb" || wget -q "https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
rm -f packages-microsoft-prod.deb
sudo apt-get update -y
sudo apt-get install -y powershell
pwsh --version
```

## GitHub Desktop

Community Linux build of GitHub Desktop, installed through the maintained helper script.

```bash
cd /tmp
curl -fsSL https://raw.githubusercontent.com/kontr0x/github-desktop-install/main/installGitHubDesktop.sh -o installGitHubDesktop.sh
chmod +x installGitHubDesktop.sh
./installGitHubDesktop.sh
rm -f installGitHubDesktop.sh
which github-desktop && dpkg -s github-desktop 2>/dev/null | grep -E 'Package|Version'
```

## WordPress Latest

Downloads and extracts the latest WordPress release into your web root, ready to point a vhost at.

```bash
cd /tmp
curl -fLO https://wordpress.org/latest.zip
sudo apt-fast install -y unzip
unzip -q latest.zip
sudo mkdir -p /var/www
sudo rm -rf /var/www/wordpress
sudo mv wordpress /var/www/wordpress
sudo chown -R www-data:www-data /var/www/wordpress
rm -f latest.zip
ls /var/www/wordpress | head -n 10
```


### AnyDesk (Cross-Platform Remote Desktop)
Install the latest version of AnyDesk directly from their official APT repository.

```bash
# Set up download directory
mkdir -p ~/scripts-download && cd ~/scripts-download

# Add repository key and list
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/anydesk.gpg
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list

# Install
sudo apt-fast update -y
sudo apt-fast install -y anydesk
```

### AnyDesk (Windows Installation via PowerShell)
To automate the installation of AnyDesk on a Windows host, you can use PowerShell to download it into the `scripts-download` directory and install it silently.

```powershell
# Set up download directory in user profile
$downloadDir = "$HOME\scripts-download"
New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null
Set-Location $downloadDir

# Download latest AnyDesk for Windows
Invoke-WebRequest -Uri "https://download.anydesk.com/AnyDesk.exe" -OutFile "AnyDesk.exe"

# Install silently (runs in background)
Start-Process -FilePath ".\AnyDesk.exe" -ArgumentList "--install", "$env:ProgramFiles\AnyDesk", "--start-with-win", "--silent" -Wait -NoNewWindow
```


## VMware Open VM Tools And Shared Folders

Enables clipboard sharing, proper scrolling and host folder mounting inside a VMware guest, then links the shares reliably to your desktop on startup.

```bash
sudo DEBIAN_FRONTEND=noninteractive apt-fast install -y open-vm-tools open-vm-tools-desktop
sudo systemctl enable --now open-vm-tools
/usr/bin/vmware-toolbox-cmd -v
```

### Automount VMware Shared Folders on Startup to Desktop

> **Note**: If you are using our provided `setup.sh` helper, you can instantly apply this fix across Ubuntu/CentOS/Fedora by simply running:
> ```bash
> ./setup.sh vm-shared-folder-fix
> ```

Using `/etc/fstab` can fail if VMware tools load too late during boot. This approach uses a systemd mount unit to guarantee that any files you share from the host will immediately appear on your Ubuntu Desktop under `SharedDirectories` every time the OS runs.

```bash
# 1. Create the mount directory and ensure the Desktop exists
sudo mkdir -p /mnt/hgfs
mkdir -p "$HOME/Desktop"

# 2. Create a persistent shortcut directly on your Desktop
ln -sfn /mnt/hgfs "$HOME/Desktop/SharedDirectories"

# 3. Create a reliable systemd mount unit
cat << 'EOF' | sudo tee /etc/systemd/system/mnt-hgfs.mount > /dev/null
[Unit]
Description=Mount VMware Shared Folders
ConditionVirtualization=vmware
After=open-vm-tools.service

[Mount]
What=.host:/
Where=/mnt/hgfs
Type=fuse.vmhgfs-fuse
Options=allow_other,auto_unmount,defaults

[Install]
WantedBy=multi-user.target
EOF

# 4. Enable and activate the mount service
sudo systemctl daemon-reload
sudo systemctl enable mnt-hgfs.mount
sudo systemctl restart mnt-hgfs.mount

# Verify
ls -la "$HOME/Desktop/SharedDirectories"
```

## Snap Store Repair

Fixes the common "cannot refresh while running" error by killing the store and refreshing it from the command line.

```bash
sudo killall snap-store 2>/dev/null || true
sudo snap refresh snap-store
sudo snap refresh
snap changes | tail -n 5
```

Optional on-premise proxy setup for controlled environments:

```bash
sudo snap install snap-store-proxy
sudo snap install snap-store-proxy-client
snap list | grep snap-store
```

## Disk Partition Resize

After enlarging the virtual disk in your hypervisor, grow the partition and then the filesystem. Confirm your device name with `lsblk` first.

```bash
lsblk
sudo cfdisk
# resize the target partition in cfdisk, write changes, then quit
sudo partprobe
sudo resize2fs /dev/sda2
df -hT | grep -E 'Filesystem|/dev/sda'
```

## Legacy / Use With Caution

The blocks below are kept for completeness. They target old systems or install unmaintained software, so read the caution line before running each one.

### Full Release Upgrade

Caution: upgrades your whole Ubuntu release in place and can break third-party repositories. Take a snapshot first.

```bash
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y update-manager-core
sudo do-release-upgrade -d
lsb_release -a
```

### Repair Apt For End-Of-Life Releases

Caution: only for EOL Ubuntu versions returning `404 Not Found`; it repoints all mirrors to old-releases.ubuntu.com.

```bash
cd /etc/apt
sudo cp sources.list sources.list.bak
sudo sed -i 's/[a-z][a-z]\.archive.ubuntu.com/old-releases.ubuntu.com/g' sources.list
sudo sed -i 's/archive.ubuntu.com/old-releases.ubuntu.com/g' sources.list
sudo sed -i 's/security.ubuntu.com/old-releases.ubuntu.com/g' sources.list
sudo apt-get update
```

### Python 2.7 From Source

Caution: Python 2 is end of life and receives no security fixes. Installed as `python2.7` via altinstall so it cannot shadow python3.

```bash
cd /tmp
sudo apt-fast install -y build-essential zlib1g-dev libssl-dev libffi-dev
curl -fLO https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
tar xzf Python-2.7.18.tgz
cd Python-2.7.18
./configure --enable-optimizations
sudo make altinstall
sudo ln -sfn /usr/local/bin/python2.7 /usr/bin/python2
python2.7 -V
```

### XAMPP Stack

Caution: bundles its own Apache, MySQL and PHP outside apt and is not hardened for production. Use the PHP section above for development instead.

```bash
mkdir -p ~/Downloads && mkdir -p ~/scripts-download && cd ~/scripts-download
mkdir -p ~/scripts-download && cd ~/scripts-download
aria2c -c -s 20 -x 15 -k 1M -j 1 https://sourceforge.net/projects/xampp/files/XAMPP%20Linux/8.2.12/xampp-linux-x64-8.2.12-0-installer.run/download -o xampp-linux-x64-installer.run
chmod +x xampp-linux-x64-installer.run
sudo ./xampp-linux-x64-installer.run
sudo /opt/lampp/lampp start
sudo /opt/lampp/lampp status
```

### Pinned MongoDB Compass Build

Caution: pins an old build; prefer the latest-endpoint section above.

```bash
cd /tmp
curl -fLO https://downloads.mongodb.com/compass/mongodb-compass_1.28.1_amd64.deb
sudo apt-get install -y ./mongodb-compass_1.28.1_amd64.deb
rm -f mongodb-compass_1.28.1_amd64.deb
dpkg -s mongodb-compass | grep Version
```

### PowerShell History Cleanup

Run these inside a `pwsh` session, not in bash.

```powershell
Clear-History
Clear-History -Count 5 -Newest
Get-History
```
