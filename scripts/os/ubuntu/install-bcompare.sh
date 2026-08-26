#!/bin/bash
set -e

echo -e "  \033[1;36m[  ..  ] Installing Beyond Compare on Ubuntu...\033[0m"
if command -v bcompare &>/dev/null; then
    echo -e "  \033[1;32m[  OK  ] Beyond Compare is already installed: $(bcompare -version 2>&1 | head -n 1)\033[0m"
else
    sudo apt-get update -qq
    sudo apt-get install -y wget ca-certificates apt-transport-https
    wget -qO- https://www.scootersoftware.com/scootersoftware.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/scootersoftware.gpg 2>/dev/null || true
    echo "deb http://www.scootersoftware.com/ bcompare4 partner" | sudo tee /etc/apt/sources.list.d/scootersoftware.list >/dev/null
    sudo apt-get update -qq
    sudo apt-get install -y bcompare || {
        echo "Fallback to direct deb package download..."
        TMP_DEB="/tmp/bcompare.deb"
        wget -q -O "$TMP_DEB" "https://www.scootersoftware.com/bcompare-4.4.7.28397_amd64.deb"
        sudo apt-get install -y "$TMP_DEB" || sudo dpkg -i "$TMP_DEB" || sudo apt-get -f install -y
        rm -f "$TMP_DEB"
    }
fi

# Configure Git Diff & Merge Tool
if command -v git &>/dev/null; then
    git config --global diff.tool bc
    git config --global difftool.bc.path "/usr/bin/bcompare"
    git config --global difftool.prompt false
    git config --global merge.tool bc4
    git config --global mergetool.bc4.path "/usr/bin/bcompare"
    git config --global mergetool.bc4.cmd '/usr/bin/bcompare "$LOCAL" "$REMOTE" "$BASE" "$MERGED"'
    git config --global mergetool.prompt false
    echo -e "  \033[1;32m[  OK  ] Git diff and merge tools configured for Beyond Compare.\033[0m"
fi
