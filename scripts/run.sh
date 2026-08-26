#!/bin/bash

# Default High-Contrast ANSI Color codes (Vibrant Light Colors)
PRIMARY='\033[1;32m'   # Bright LightGreen
SECONDARY='\033[1;36m' # Bright Cyan
ACCENT='\033[1;33m'    # Bright Yellow
MUTED='\033[0;37m'     # Bright Light Gray
ERROR='\033[1;31m'     # Bright Red
TEXT='\033[0m'         # Reset / White

map_color() {
    case "$1" in
        "Magenta") echo '\033[0;35m' ;;
        "Cyan") echo '\033[1;36m' ;;
        "Yellow") echo '\033[1;33m' ;;
        "Red") echo '\033[1;31m' ;;
        "Gray") echo '\033[0;37m' ;;
        "DarkGray") echo '\033[1;30m' ;;
        "LightBlue") echo '\033[1;34m' ;;
        "LightGreen") echo '\033[1;32m' ;;
        *) echo '' ;;
    esac
}

if [ -f "scripts/shared/theme.json" ]; then
    t_primary=$(grep -o '"primary": "[^"]*"' scripts/shared/theme.json | cut -d'"' -f4)
    t_secondary=$(grep -o '"secondary": "[^"]*"' scripts/shared/theme.json | cut -d'"' -f4)
    t_accent=$(grep -o '"accent": "[^"]*"' scripts/shared/theme.json | cut -d'"' -f4)
    t_muted=$(grep -o '"muted": "[^"]*"' scripts/shared/theme.json | cut -d'"' -f4)
    t_error=$(grep -o '"error": "[^"]*"' scripts/shared/theme.json | cut -d'"' -f4)

    [ ! -z "$t_primary" ] && val=$(map_color "$t_primary") && [ ! -z "$val" ] && PRIMARY=$val
    [ ! -z "$t_secondary" ] && val=$(map_color "$t_secondary") && [ ! -z "$val" ] && SECONDARY=$val
    [ ! -z "$t_accent" ] && val=$(map_color "$t_accent") && [ ! -z "$val" ] && ACCENT=$val
    [ ! -z "$t_muted" ] && val=$(map_color "$t_muted") && [ ! -z "$val" ] && MUTED=$val
    [ ! -z "$t_error" ] && val=$(map_color "$t_error") && [ ! -z "$val" ] && ERROR=$val
fi

show_header() {
    echo -e ""
    echo -e "  ${PRIMARY}Scripts Fixer (Linux)${TEXT}"
    echo -e "  ${SECONDARY}git $(git rev-parse --short HEAD 2>/dev/null || echo "unknown") ($(git branch --show-current 2>/dev/null || echo "unknown"))${TEXT}"
    echo -e ""
    echo -e "  ${SECONDARY}Dev Tools Setup Scripts${TEXT}"
    echo -e "  ${MUTED}=======================${TEXT}"
    echo -e ""
}

show_main_help() {
    show_header
    echo -e "  ${ACCENT}Usage:${TEXT}"
    echo -e ""
    printf "    %-44s ${MUTED}%s${TEXT}\n" "./run.sh install <keywords>" "Install by keyword / ID (bare command)"
    printf "    %-44s ${MUTED}%s${TEXT}\n" "./run.sh install ls" "List all previously installed items"
    printf "    %-44s ${MUTED}%s${TEXT}\n" "./run.sh os <action>" "OS level actions (update, update-all)"
    printf "    %-44s ${MUTED}%s${TEXT}\n" "./run.sh <command> -h" "Show detailed help for a command"
    echo -e ""
    
    echo -e "  ${ACCENT}Profiles:${TEXT}"
    echo -e ""
    printf "    %-28s ${MUTED}%s${TEXT}\n" "ubuntu-basic" "Git, ZSH, aria2c, vim, curl, wget, build-essential"
    printf "    %-28s ${MUTED}%s${TEXT}\n" "ubuntu+vscode" "ubuntu-basic + VS Code snap"
    printf "    %-28s ${MUTED}%s${TEXT}\n" "ubuntu+simple-dev" "ubuntu+vscode + Golang, Rust, PHP, Python3"
    printf "    %-28s ${MUTED}%s${TEXT}\n" "ubuntu+small-dev" "Alias for ubuntu+simple-dev"
    printf "    %-28s ${MUTED}%s${TEXT}\n" "ubuntu+dev" "ubuntu+simple-dev + Node.js, PNPM, Yarn"
    echo -e ""
    
    echo -e "  ${ACCENT}Available Scripts:${TEXT}"
    echo -e "    ${MUTED}ID  Name                            Description${TEXT}"
    echo -e "    ${MUTED}--  ------------------------------  --------------------------------------------------${TEXT}"
    echo -e ""
    echo -e "    ${PRIMARY}Core Tools${TEXT}"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "01" "vscode" "Install Visual Studio Code (snap)"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "03" "nodejs" "Install Node.js LTS, Yarn"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "04" "pnpm" "Install pnpm globally"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "05" "python3" "Install Python 3, pip, venv"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "06" "golang" "Install Go compiler via APT"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "07" "git" "Install Git, Git LFS, GitHub CLI"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "16" "php" "Install PHP, CLI, FPM"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "20" "rust" "Install Rust (cargo, rustup)"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "21" "build-essential" "Install build dev tool chain"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "22" "curl" "Install curl network tool"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "23" "wget" "Install wget downloader"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "24" "vim" "Install vim text editor"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "25" "ssh" "Install SSH & configure port"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "26" "aria2c" "Install aria2c downloader"
    echo -e ""
    
    echo -e "    ${PRIMARY}System & Orchestration${TEXT}"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "10" "os-update" "Run apt update && apt upgrade"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "11" "os-update-all" "Run update + release-upgrade"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "46" "kubernetes" "Install Kubernetes CLI (kubectl)"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "47" "docker" "Install Docker and Docker Compose"
    echo -e ""
    
    echo -e "    ${PRIMARY}Desktop Tools${TEXT}"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "32" "dbeaver" "Install DBeaver via snap"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "33" "github-desktop" "Install GitHub Desktop GUI"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "34" "sticky-notes" "Install Sticky Notes GUI utility"
    echo -e ""
    
    echo -e "    ${PRIMARY}ZSH Environment${TEXT}"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "50" "zsh" "Install ZSH shell"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\n" "51" "zsh+config" "Install ZSH, Oh-My-Zsh & plugins"
    echo -e ""
    echo -e ""
    
    echo -e "  ${ACCENT}Usage Examples:${TEXT}"
    echo -e "    ./run.sh install docker"
    echo -e "    ./run.sh install profile ubuntu+small-dev"
    echo -e "    ./run.sh install profile ubuntu+dev"
    echo -e "    ./run.sh install 01,03,06,20"
    echo -e "    ./run.sh os update-all"
    echo -e "    ./run.sh install ls"
    echo -e "    ./run.sh install profile help"
    echo -e ""
}

show_install_help() {
    echo -e "  ${ACCENT}Install Command Help:${TEXT}"
    echo -e "    Installs specified tools, keywords, or profiles on the Ubuntu system."
    echo -e ""
    echo -e "  ${ACCENT}Usage:${TEXT}"
    echo -e "    ./run.sh install <tool|ID>"
    echo -e "    ./run.sh install <tool1,tool2,tool3>"
    echo -e "    ./run.sh install profile <name>"
    echo -e "    ./run.sh install ls"
    echo -e ""
    echo -e "  ${ACCENT}Examples:${TEXT}"
    echo -e "    ./run.sh install docker"
    echo -e "    ./run.sh install 01,05,golang,rust"
    echo -e "    ./run.sh install profile ubuntu+small-dev"
    echo -e "    ./run.sh install profile ubuntu+dev"
    echo -e ""
}

show_profile_help() {
    python3 scripts/shared/profile_tree.py all
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
    echo -ne "  ${PRIMARY}scripts-fixer v${VER}${TEXT} ${MUTED}|${TEXT} "
    echo -ne "${SECONDARY}git ${SHA} (${BRANCH})${TEXT} ${MUTED}|${TEXT} "
    echo -e "${ACCENT}${TIME}${TEXT}"
    if [ ! -z "$REMOTE" ]; then
        echo -e "  ${MUTED}repo: ${TEXT}${REMOTE}"
    fi
    echo -e ""
}

COMMAND=$1
shift
ARGS="$*"

# Handle no arguments -> git pull and help
if [ -z "$COMMAND" ]; then
    echo -e "  ${SECONDARY}Refreshing local repository (git pull)...${TEXT}"
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
            echo -e "  ${ACCENT}OS Command Help:${TEXT}"
            echo -e "    update      - Run apt update and upgrade"
            echo -e "    update-all  - Run update and release-upgrade"
            show_footer
            exit 0
        elif [ "$ARGS" = "update-all" ] || [ "$ARGS" = "11" ]; then
            bash scripts/os/ubuntu/update-all.sh
        elif [ "$ARGS" = "update" ] || [ "$ARGS" = "10" ]; then
            bash scripts/os/ubuntu/update.sh
        else
            echo -e "  ${ERROR}Unknown OS argument: $ARGS${TEXT}"
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
        elif [[ "$ARGS" == "ls" || "$ARGS" == "list" ]]; then
            python3 scripts/shared/list_installs.py
            show_footer
            exit 0
        fi

        INSTALLED=()
        PROFILE_INSTALLED=""

        # Split by comma
        IFS=',' read -ra ITEMS <<< "$ARGS"
        for ITEM in "${ITEMS[@]}"; do
            # Trim spaces
            ITEM=$(echo "$ITEM" | xargs)
            
            if [ -z "$ITEM" ]; then continue; fi
            
            SUCCESS=false
            echo -e "  ${SECONDARY}Processing: $ITEM${TEXT}"

            # Profile installation
            if [[ "$ITEM" == *"profile ubuntu+dev"* ]]; then
                bash scripts/os/ubuntu/profile-ubuntu-dev.sh && SUCCESS=true && PROFILE_INSTALLED="ubuntu+dev"
            elif [[ "$ITEM" == *"profile ubuntu+small-dev"* || "$ITEM" == *"profile ubuntu+simple-dev"* ]]; then
                bash scripts/os/ubuntu/profile-ubuntu-simple-dev.sh && SUCCESS=true && PROFILE_INSTALLED="ubuntu+simple-dev"
            elif [[ "$ITEM" == *"profile ubuntu+vscode"* ]]; then
                bash scripts/os/ubuntu/profile-ubuntu-vscode.sh && SUCCESS=true && PROFILE_INSTALLED="ubuntu+vscode"
            elif [[ "$ITEM" == *"profile ubuntu-basic"* ]]; then
                bash scripts/os/ubuntu/profile-ubuntu-basic.sh && SUCCESS=true && PROFILE_INSTALLED="ubuntu-basic"
            
            # Tools
            elif [[ "$ITEM" == *"docker"* || "$ITEM" == *"47"* ]]; then bash scripts/os/ubuntu/install-docker.sh && SUCCESS=true
            elif [[ "$ITEM" == *"kubernetes"* || "$ITEM" == *"46"* ]]; then bash scripts/os/ubuntu/install-kubernetes.sh && SUCCESS=true
            elif [[ "$ITEM" == *"python2"* ]]; then bash scripts/os/ubuntu/install-python2.sh && SUCCESS=true
            elif [[ "$ITEM" == *"python3"* || "$ITEM" == *"python"* || "$ITEM" == *"05"* ]]; then bash scripts/os/ubuntu/install-python3.sh && SUCCESS=true
            elif [[ "$ITEM" == *"rust"* || "$ITEM" == *"20"* ]]; then bash scripts/os/ubuntu/install-rust.sh && SUCCESS=true
            elif [[ "$ITEM" == *"golang"* || "$ITEM" == *"06"* ]]; then bash scripts/os/ubuntu/install-golang.sh && SUCCESS=true
            elif [[ "$ITEM" == *"node"* || "$ITEM" == *"nodejs"* || "$ITEM" == *"03"* ]]; then bash scripts/os/ubuntu/install-node.sh && SUCCESS=true
            elif [[ "$ITEM" == *"pnpm"* || "$ITEM" == *"04"* ]]; then bash scripts/os/ubuntu/install-pnpm.sh && SUCCESS=true
            elif [[ "$ITEM" == *"yarn"* ]]; then bash scripts/os/ubuntu/install-yarn.sh && SUCCESS=true
            elif [[ "$ITEM" == *"php"* || "$ITEM" == *"16"* ]]; then bash scripts/os/ubuntu/install-php.sh && SUCCESS=true
            elif [[ "$ITEM" == *"git-lfs"* || "$ITEM" == *"gh"* || "$ITEM" == *"git"* || "$ITEM" == *"07"* ]]; then 
                bash scripts/os/ubuntu/install-git-lfs.sh && bash scripts/os/ubuntu/install-gh.sh && SUCCESS=true
            elif [[ "$ITEM" == *"dbeaver"* || "$ITEM" == *"32"* ]]; then bash scripts/os/ubuntu/install-dbeaver.sh && SUCCESS=true
            elif [[ "$ITEM" == *"github-desktop"* || "$ITEM" == *"33"* ]]; then bash scripts/os/ubuntu/install-github-desktop.sh && SUCCESS=true
            elif [[ "$ITEM" == *"sticky-notes"* || "$ITEM" == *"34"* ]]; then bash scripts/os/ubuntu/install-sticky-notes.sh && SUCCESS=true
            elif [[ "$ITEM" == *"vscode"* || "$ITEM" == *"01"* ]]; then bash scripts/os/ubuntu/profile-ubuntu-vscode.sh && SUCCESS=true
            elif [[ "$ITEM" == *"zsh,zsh+config"* || "$ITEM" == *"zsh+config"* || "$ITEM" == *"51"* ]]; then
                bash scripts/os/ubuntu/dep-omyzsh.sh
                bash scripts/os/ubuntu/dep-zsh-autosuggestions.sh
                SUCCESS=true
            elif [[ "$ITEM" == *"zsh"* || "$ITEM" == *"50"* ]]; then
                bash scripts/os/ubuntu/dep-omyzsh.sh && SUCCESS=true
            elif [[ "$ITEM" == *"build-essential"* || "$ITEM" == *"21"* ]]; then
                bash scripts/os/ubuntu/dep-build-essential.sh && SUCCESS=true
            elif [[ "$ITEM" == *"curl"* || "$ITEM" == *"22"* ]]; then
                bash scripts/os/ubuntu/dep-curl.sh && SUCCESS=true
            elif [[ "$ITEM" == *"wget"* || "$ITEM" == *"23"* ]]; then
                bash scripts/os/ubuntu/dep-wget.sh && SUCCESS=true
            elif [[ "$ITEM" == *"vim"* || "$ITEM" == *"24"* ]]; then
                bash scripts/os/ubuntu/dep-vim.sh && SUCCESS=true
            elif [[ "$ITEM" == *"ssh"* || "$ITEM" == *"25"* ]]; then
                PORT=$(echo "$ITEM" | grep -oE '[0-9]+' | head -n 1)
                bash scripts/os/ubuntu/install-ssh.sh "$PORT" && SUCCESS=true
            elif [[ "$ITEM" == *"aria2c"* || "$ITEM" == *"26"* ]]; then
                bash scripts/os/ubuntu/dep-aria2c.sh && SUCCESS=true
            else
                echo -e "  ${ERROR}Unknown install argument: $ITEM${TEXT}"
                echo -e "  Run './run.sh install help' for more details."
            fi

            if [ "$SUCCESS" = true ]; then
                INSTALLED+=("$ITEM")
                python3 scripts/shared/logger.py "$ITEM"
            fi
        done

        if [ ${#INSTALLED[@]} -gt 0 ]; then
            echo -e "\n  ${PRIMARY}Installation Summary:${TEXT}"
            for p in "${INSTALLED[@]}"; do
                echo -e "    ${SECONDARY}✔${TEXT} $p"
            done
            
            if [ ! -z "$PROFILE_INSTALLED" ]; then
                python3 scripts/shared/profile_tree.py "$PROFILE_INSTALLED"
            fi
        fi
        ;;
    *)
        echo -e "  ${ERROR}Unknown command: $COMMAND${TEXT}"
        show_main_help
        ;;
esac

show_footer
