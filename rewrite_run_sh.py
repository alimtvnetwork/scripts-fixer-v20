import os

run_sh_code = r"""#!/bin/bash

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
    echo -e "  ${CYAN}git $(git rev-parse --short HEAD 2>/dev/null || echo "unknown") ($(git branch --show-current 2>/dev/null || echo "unknown"))${NC}"
    echo -e ""
    echo -e "  ${CYAN}Dev Tools Setup Scripts${NC}"
    echo -e "  ${DARK_GRAY}=======================${NC}"
    echo -e ""
}

show_main_help() {
    show_header
    echo -e "  ${YELLOW}Usage:${NC}"
    echo -e ""
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "./run.sh install <keywords>" "Install by keyword (bare command)"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "./run.sh os <action>" "OS level actions (update, update-all)"
    printf "    %-44s ${DARK_GRAY}%s${NC}\n" "./run.sh <command> -h" "Show detailed help for a command"
    echo -e ""
    
    echo -e "  ${YELLOW}Combo Shortcuts:${NC}"
    echo -e ""
    printf "    %-28s ${DARK_GRAY}%s${NC}\n" "ubuntu-basic" "Git, ZSH, aria2c, vim, curl, wget"
    printf "    %-28s ${DARK_GRAY}%s${NC}\n" "ubuntu+vscode" "ubuntu-basic + VS Code snap"
    printf "    %-28s ${DARK_GRAY}%s${NC}\n" "ubuntu+simple-dev" "ubuntu+vscode + Golang, Rust, PHP, Python3"
    printf "    %-28s ${DARK_GRAY}%s${NC}\n" "ubuntu+dev" "ubuntu+simple-dev + Node.js, PNPM"
    echo -e ""
    
    echo -e "  ${YELLOW}Available Scripts:${NC}"
    echo -e ""
    echo -e "    ${DARK_GRAY}ID  Name                            Description${NC}"
    echo -e "    ${DARK_GRAY}--  ------------------------------  --------------------------------------------------${NC}"
    echo -e ""
    echo -e "    ${MAGENTA}Core Tools${NC}"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "01" "Install VS Code" "Install Visual Studio Code (snap)"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "03" "Node.js + Yarn" "Install Node.js LTS, Yarn"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "04" "pnpm" "Install pnpm globally"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "05" "Python 3" "Install Python 3, pip, venv"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "06" "Golang" "Install Go compiler via APT"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "07" "Git + LFS + gh" "Install Git, Git LFS, GitHub CLI"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "16" "PHP" "Install PHP, CLI, FPM"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "20" "Rust" "Install Rust (cargo, rustup)"
    echo -e ""
    
    echo -e "    ${MAGENTA}System & Orchestration${NC}"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "10" "OS Update" "Run apt update && apt upgrade"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "11" "OS Update All" "Run update + release-upgrade"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "46" "Kubernetes" "Install Kubernetes CLI (kubectl)"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "47" "Docker" "Install Docker and Docker Compose"
    echo -e ""
    
    echo -e "    ${MAGENTA}Desktop Tools${NC}"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "32" "DBeaver Community" "Install DBeaver via snap"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "33" "GitHub Desktop" "Install GitHub Desktop GUI"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "34" "Sticky Notes" "Install Sticky Notes GUI utility"
    echo -e ""
    
    echo -e "    ${MAGENTA}ZSH Environment${NC}"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "50" "ZSH" "Install ZSH shell"
    printf "    ${DARK_GRAY}%s${NC}  %-30s  %s\n" "51" "ZSH + Config" "Install ZSH, Oh-My-Zsh & plugins"
    echo -e ""
    
    echo -e "  ${YELLOW}Usage Examples:${NC}"
    echo -e "    ./run.sh install docker"
    echo -e "    ./run.sh install profile ubuntu+dev"
    echo -e "    ./run.sh os update-all"
    echo -e "    ./run.sh install help"
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
"""

with open("scripts/run.sh", "w", encoding="utf-8", newline='\n') as f:
    f.write(run_sh_code)

import subprocess
subprocess.run(["git", "add", "."], check=True)
subprocess.run(["git", "commit", "-m", "feat: redesign linux cli ui to identically match windows run.ps1 layout"], check=True)
subprocess.run(["git", "push"], check=True)
print("Updated run.sh UI layout successfully!")
