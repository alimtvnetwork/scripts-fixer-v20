#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
ACCENT='\033[1;33m'
MUTED='\033[0;37m'
ERROR='\033[1;31m'
TEXT='\033[0m'

hasAntigravityManager() {
    if dpkg -l | grep -q "antigravity-manager"; then
        return 0
    elif command -v antigravity-manager &>/dev/null; then
        return 0
    else
        return 1
    fi
}

fetchLatestUrl() {
    if ! command -v jq &>/dev/null; then
        sudo apt-get update -y && sudo apt-get install -y jq
    fi
    local apiUrl="https://api.github.com/repos/lbjlaq/Antigravity-Manager/releases/latest"
    local dlUrl=""
    dlUrl=$(curl -s "$apiUrl" | jq -r '.assets[] | select(.name | endswith("_amd64.deb")) | .browser_download_url' | head -n 1)
    echo "$dlUrl"
}

downloadAndInstall() {
    local url="$1"
    local tempDeb="/tmp/antigravity-manager.deb"
    
    echo -e "  ${MUTED}[step 2/3] Downloading ${url}...${TEXT}"
    curl -L "$url" -o "$tempDeb"
    
    echo -e "  ${MUTED}[step 3/3] Installing .deb package...${TEXT}"
    sudo apt-get install -y "$tempDeb"
    rm -f "$tempDeb"
}

main() {
    echo -e "\n  ${SECONDARY}[  ..  ] Installing Antigravity Manager...${TEXT}"
    
    if hasAntigravityManager; then
        echo -e "  ${PRIMARY}[  OK  ] Antigravity Manager is already installed.${TEXT}"
        return 0
    fi
    
    echo -e "  ${MUTED}[step 1/3] Fetching latest release...${TEXT}"
    local downloadUrl=""
    downloadUrl=$(fetchLatestUrl)
    
    if [ -z "$downloadUrl" ]; then
        echo -e "  ${ERROR}[FAIL ] Could not find _amd64.deb release.${TEXT}"
        return 1
    fi
    
    downloadAndInstall "$downloadUrl"
    echo -e "\n  ${PRIMARY}[DONE ] Antigravity Manager setup complete.${TEXT}"
}

main
