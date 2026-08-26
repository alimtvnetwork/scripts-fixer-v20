#!/bin/bash

# ANSI Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
DARK_GRAY='\033[1;30m'
NC='\033[0m' # No Color

show_header() {
    echo -e ""
    echo -e "  ${MAGENTA}Scripts Fixer (Linux)${NC}"
    echo -e "  ${CYAN}git $(git rev-parse --short HEAD) ($(git branch --show-current))${NC}"
    echo -e ""
    echo -e "  ${CYAN}Dev Tools Setup Scripts${NC}"
    echo -e "  ${DARK_GRAY}=======================${NC}"
    echo -e ""
}

show_main_help() {
    show_header
    echo -e "  ${YELLOW}Usage:${NC}"
    echo -e ""
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "./run.sh install <keywords>" "Install by keyword"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "./run.sh os <action>" "OS level actions (update, etc)"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "./run.sh <command> -h" "Show detailed help for a command"
    echo -e ""
    echo -e "  ${YELLOW}Available Installations:${NC}"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "docker" "Install Docker and Docker Compose"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "kubernetes" "Install Kubernetes CLI (kubectl)"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "python2, python3" "Install Python environments"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "rust" "Install Rust (cargo, rustup)"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "golang" "Install Go compiler"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "node, pnpm, yarn" "Install Node.js & package managers"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "php" "Install PHP, CLI, FPM"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "git-lfs, gh" "Install Git LFS and GitHub CLI"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "dbeaver, github-desktop, sticky-notes" "Install GUI tools via Snap"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "zsh, zsh+config" "Install ZSH, Oh-My-Zsh & plugins"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "profile <name>" "Install complete profile"
    echo -e ""
}

show_install_help() {
    echo -e "  ${YELLOW}Install Command Help:${NC}"
    echo -e "    Installs specified tools or profiles on the Ubuntu system."
    echo -e ""
    echo -e "  ${YELLOW}Usage:${NC}"
    echo -e "    ./run.sh install <tool>"
    echo -e "    ./run.sh install profile <name>"
    echo -e ""
    echo -e "  ${YELLOW}Examples:${NC}"
    echo -e "    ./run.sh install docker"
    echo -e "    ./run.sh install zsh,zsh+config"
    echo -e "    ./run.sh install profile ubuntu+dev"
    echo -e ""
}

show_footer() {
    local VER="unknown"
    if [ -f "version.json" ]; then
        VER=$(grep -o '"version": "[^"]*"' version.json | cut -d'"' -f4)
    fi
    local SHA=$(git rev-parse --short=12 HEAD 2>/dev/null || echo "unknown")
    local BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    local REMOTE=$(git config --get remote.origin.url 2>/dev/null)
    local TIME=$(git log -1 --format=%cd --date=local 2>/dev/null || echo "unknown")

    echo -e ""
    echo -ne "  ${MAGENTA}scripts-fixer v${VER}${NC} ${DARK_GRAY}|${NC} "
    echo -ne "${CYAN}git ${SHA} (${BRANCH})${NC} ${DARK_GRAY}|${NC} "
    echo -e "${YELLOW}${TIME}${NC}"
    if [ ! -z "$REMOTE" ]; then
        echo -e "  ${DARK_GRAY}repo: ${NC}${REMOTE}"
    fi
    echo -e ""
}

show_profile_help() {
    echo -e "  ${YELLOW}Available Profiles for $USER:${NC}"
    echo -e "    ${CYAN}ubuntu-basic${NC}       ${DARK_GRAY}- Git, ZSH, aria2c, vim, build-essential, curl, wget${NC}"
    echo -e "    ${CYAN}ubuntu+vscode${NC}      ${DARK_GRAY}- ubuntu-basic + VS Code snap${NC}"
    echo -e "    ${CYAN}ubuntu+simple-dev${NC}  ${DARK_GRAY}- ubuntu+vscode + Golang, Rust, PHP, Python3${NC}"
    echo -e "    ${CYAN}ubuntu+small-dev${NC}   ${DARK_GRAY}- Alias for ubuntu+simple-dev${NC}"
    echo -e "    ${CYAN}ubuntu+dev${NC}         ${DARK_GRAY}- ubuntu+simple-dev + Node.js, PNPM${NC}"
    echo -e ""
    echo -e "    ${YELLOW}Usage:${NC} ./run.sh install profile <profile_name>"
}

COMMAND=$1
shift
ARGS="$*"

# Handle no arguments -> git pull and help
if [ -z "$COMMAND" ]; then
    echo -e "  ${CYAN}Refreshing local repository (git pull)...${NC}"
    git pull
    show_main_help
    show_footer
    exit 0
fi

# General help check
if [[ "$COMMAND" == "help" || "$COMMAND" == "-h" || "$COMMAND" == "--help" ]]; then
    show_main_help
    show_footer
    exit 0
fi

case "$COMMAND" in
    "os")
        if [[ "$ARGS" == *"help"* || "$ARGS" == *"-h"* || "$ARGS" == *"--help"* ]]; then
            echo -e "  ${YELLOW}OS Command Help:${NC}"
            echo -e "    update      - Run apt update and upgrade"
            echo -e "    update-all  - Run update and release-upgrade"
            show_footer
    exit 0
        elif [ "$ARGS" = "update-all" ]; then
            bash scripts/os/ubuntu/update-all.sh
        elif [ "$ARGS" = "update" ]; then
            bash scripts/os/ubuntu/update.sh
        else
            echo -e "  ${RED}Unknown OS argument: $ARGS${NC}"
        fi
        ;;
    "install")
        # Sub-help handling
        if [[ "$ARGS" == *"profile help"* || "$ARGS" == *"profile -h"* || "$ARGS" == *"profile --help"* || "$ARGS" == *"profile -help"* ]]; then
            show_profile_help
            show_footer
    exit 0
        elif [[ "$ARGS" == *"help"* || "$ARGS" == *"-h"* || "$ARGS" == *"--help"* || "$ARGS" == *"-help"* ]]; then
            show_install_help
            show_footer
    exit 0
        fi

        # Profile installation
        if [[ "$ARGS" == *"profile ubuntu+dev"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-dev.sh
        elif [[ "$ARGS" == *"profile ubuntu+small-dev"* || "$ARGS" == *"profile ubuntu+simple-dev"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-simple-dev.sh
        elif [[ "$ARGS" == *"profile ubuntu+vscode"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-vscode.sh
        elif [[ "$ARGS" == *"profile ubuntu-basic"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-basic.sh
        
        # Tools
        elif [[ "$ARGS" == *"docker"* ]]; then bash scripts/os/ubuntu/install-docker.sh
        elif [[ "$ARGS" == *"kubernetes"* ]]; then bash scripts/os/ubuntu/install-kubernetes.sh
        elif [[ "$ARGS" == *"python2"* ]]; then bash scripts/os/ubuntu/install-python2.sh
        elif [[ "$ARGS" == *"python3"* || "$ARGS" == *"python"* ]]; then bash scripts/os/ubuntu/install-python3.sh
        elif [[ "$ARGS" == *"rust"* ]]; then bash scripts/os/ubuntu/install-rust.sh
        elif [[ "$ARGS" == *"golang"* ]]; then bash scripts/os/ubuntu/install-golang.sh
        elif [[ "$ARGS" == *"node"* ]]; then bash scripts/os/ubuntu/install-node.sh
        elif [[ "$ARGS" == *"pnpm"* ]]; then bash scripts/os/ubuntu/install-pnpm.sh
        elif [[ "$ARGS" == *"yarn"* ]]; then bash scripts/os/ubuntu/install-yarn.sh
        elif [[ "$ARGS" == *"php"* ]]; then bash scripts/os/ubuntu/install-php.sh
        elif [[ "$ARGS" == *"git-lfs"* ]]; then bash scripts/os/ubuntu/install-git-lfs.sh
        elif [[ "$ARGS" == *"gh"* ]]; then bash scripts/os/ubuntu/install-gh.sh
        elif [[ "$ARGS" == *"dbeaver"* ]]; then bash scripts/os/ubuntu/install-dbeaver.sh
        elif [[ "$ARGS" == *"github-desktop"* ]]; then bash scripts/os/ubuntu/install-github-desktop.sh
        elif [[ "$ARGS" == *"sticky-notes"* ]]; then bash scripts/os/ubuntu/install-sticky-notes.sh
        elif [[ "$ARGS" == *"zsh,zsh+config"* || "$ARGS" == *"zsh"* ]]; then
            bash scripts/os/ubuntu/dep-omyzsh.sh
            bash scripts/os/ubuntu/dep-zsh-autosuggestions.sh

        else
            echo -e "  ${RED}Unknown install argument: $ARGS${NC}"
            echo -e "  Run './run.sh install help' for more details."
        fi
        ;;
    *)
        echo -e "  ${RED}Unknown command: $COMMAND${NC}"
        show_main_help
        ;;
esac

show_footer
