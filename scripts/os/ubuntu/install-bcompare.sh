#!/bin/bash
set -e

VERSION=5
UNINSTALL=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --version|-v)
            VERSION="$2"
            shift 2
            ;;
        --uninstall|-u)
            UNINSTALL=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [ "$UNINSTALL" = true ]; then
    echo -e "  \033[1;33m[  ..  ] Uninstalling Beyond Compare...\033[0m"
    sudo apt-get remove -y bcompare bcompare4 bcompare5 || true
    echo -e "  \033[1;32m[  OK  ] Beyond Compare uninstalled.\033[0m"
    exit 0
fi

echo -e "  \033[1;36m[  ..  ] Installing Beyond Compare ${VERSION} on Ubuntu...\033[0m"

sudo apt-get update -qq
sudo apt-get install -y wget ca-certificates apt-transport-https

TMP_DEB="/tmp/bcompare.deb"
if [ "$VERSION" = "4" ]; then
    DEB_URL="https://www.scootersoftware.com/files/bcompare-4.4.7.28397_amd64.deb"
else
    DEB_URL="https://www.scootersoftware.com/files/bcompare-5.0.3.30064_amd64.deb"
fi

echo "Downloading ${DEB_URL}..."
wget -q -O "$TMP_DEB" "$DEB_URL"
sudo apt-get install -y "$TMP_DEB" || sudo dpkg -i "$TMP_DEB" || sudo apt-get -f install -y
rm -f "$TMP_DEB"

echo -e "  \033[1;32m[  OK  ] Beyond Compare ${VERSION} installed successfully.\033[0m"

# Configure Git Diff & Merge Tool
if command -v git &>/dev/null; then
    git config --global diff.tool bc
    git config --global difftool.bc.path "/usr/bin/bcompare"
    git config --global difftool.prompt false
    git config --global merge.tool bc
    git config --global mergetool.bc.path "/usr/bin/bcompare"
    git config --global mergetool.bc.cmd '/usr/bin/bcompare "$LOCAL" "$REMOTE" "$BASE" "$MERGED"'
    git config --global mergetool.prompt false
    echo -e "  \033[1;32m[  OK  ] Git diff and merge tools configured for Beyond Compare.\033[0m"
fi
