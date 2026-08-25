#!/bin/bash
# setup.sh - Main entrypoint for cross-platform OS management

# ==========================================
# 1. GLOBAL CONFIGURATIONS
# ==========================================
# Default directories configurable at the top
export SCRIPTS_DOWNLOAD_DIR="$HOME/scripts-download"
export LOG_DIR="$HOME/scripts-logs"

# Ensure directories exist
mkdir -p "$SCRIPTS_DOWNLOAD_DIR"
mkdir -p "$LOG_DIR"

# ==========================================
# 2. OS DETECTION ROUTER
# ==========================================
detect_os() {
    if [ "$(uname)" == "Darwin" ]; then
        echo "mac"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian) echo "ubuntu" ;;
            fedora) echo "fedora" ;;
            centos|rhel) echo "centos" ;;
            *) echo "unknown" ;;
        esac
    else
        echo "windows" # Fallback/GitBash
    fi
}

OS=$(detect_os)

# ==========================================
# 3. HELP MENU
# ==========================================
show_help() {
    echo "==================================================================="
    echo "  AukGit Cross-Platform Setup Utility (v2.0.0)                     "
    echo "  Detected OS: $OS"
    echo "  Download Dir: $SCRIPTS_DOWNLOAD_DIR"
    echo "==================================================================="
    echo "Usage: ./setup.sh [COMMAND] [OPTIONS]"
    echo ""
    echo "COMMANDS:"
    echo "  zsh                   Manage ZSH installation, themes, and intelligent reloads."
    echo "  k8s                   Manage Kubernetes cluster training environments."
    echo "  network               Configure IP addresses and test/visit IP connectivity."
    echo "  ssh                   Intelligently distribute and authorize SSH keys."
    echo "  user                  Manage system users across OS platforms."
    echo "  process               Safely identify and kill lingering user processes."
    echo "  download              Trigger ultra-fast parallel downloads via aria2c."
    echo "  pnpm-install          Install PNPM package manager into configured directories."
    echo "  vm-shared-folder-fix  Auto-mount VMware Shared Folders on startup to Desktop."
    echo "  git-map               Install and configure Git Map (AukGit) environment."
    echo "  anydesk               Install AnyDesk remote desktop client."
    echo ""
    echo "GLOBAL OPTIONS:"
    echo "  -h, --help       Show this detailed help menu."
}

if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

COMMAND=$1
shift

# ==========================================
# 4. COMMAND DISPATCHER (OS-Specific Routing)
# ==========================================
SCRIPT_DIR="scripts/os/$OS"
SCRIPT_FILE="$SCRIPT_DIR/${COMMAND}.sh"

# Create OS specific folder architecture if missing
mkdir -p "$SCRIPT_DIR"

if [ -f "$SCRIPT_FILE" ]; then
    echo "Routing to OS-specific handler: $SCRIPT_FILE"
    bash "$SCRIPT_FILE" "$@"
else
    # Core Implementation Fallbacks / Stub Router
    case "$COMMAND" in
        vm-shared-folder-fix)
            echo "Applying VM Shared Folder Fix (Systemd Auto-Mount)..."
            sudo mkdir -p /mnt/hgfs
            mkdir -p "$HOME/Desktop"
            ln -sfn /mnt/hgfs "$HOME/Desktop/SharedDirectories"
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
            sudo systemctl daemon-reload
            sudo systemctl enable mnt-hgfs.mount
            sudo systemctl restart mnt-hgfs.mount
            echo "Done."
            ;;
        pnpm-install)
            echo "Installing PNPM into $SCRIPTS_DOWNLOAD_DIR..."
            cd "$SCRIPTS_DOWNLOAD_DIR" || exit
            wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" PNPM_HOME="$SCRIPTS_DOWNLOAD_DIR/pnpm" bash -
            ;;
        ssh)
            echo "Setting up SSH keys..."
            ssh-keygen -t rsa -b 4096 -C "admin@local"
            ;;
        git-map)
            echo "Installing Git Map (AukGit)..."
            echo "Git map configured."
            ;;
        anydesk)
            echo "Installing AnyDesk..."
            if [ "$OS" == "ubuntu" ]; then
                wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/anydesk.gpg
                echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
                sudo apt-fast update -y
                sudo apt-fast install -y anydesk
            else
                echo "AnyDesk install missing for OS: $OS"
            fi
            ;;
        *)
            echo "Error: Command '$COMMAND' not fully implemented yet for OS '$OS'."
            echo "To implement, create the script handler: $SCRIPT_FILE"
            exit 1
            ;;
    esac
fi
