#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
MUTED='\033[0;37m'
TEXT='\033[0m'

IS_FORCE=false

for arg in "$@"; do
    if [ "$arg" = "--force" ] || [ "$arg" = "-f" ] || [ "$arg" = "force" ]; then
        IS_FORCE=true
    fi
done

if [ "${FORCE:-0}" = "1" ] || [ "${IS_FORCE_INSTALL:-false}" = "true" ] || [ "${IS_FORCE:-false}" = "true" ]; then
    IS_FORCE=true
fi

is_git_compact_installed() {
    if command -v git-compact &>/dev/null; then
        return 0
    fi

    if [ -x "$HOME/.local/bin/git-compact" ]; then
        return 0
    fi

    if [ -x "/usr/local/bin/git-compact" ]; then
        return 0
    fi

    return 1
}

ensure_path_configured() {
    local bin_dir="$HOME/.local/bin"

    case ":$PATH:" in
        *":$bin_dir:"*) return 0 ;;
        *) export PATH="$bin_dir:$PATH" ;;
    esac

    return 0
}

install_via_upstream() {
    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

    if [ -f "$repo_root/scripts-linux/71-install-git-compact/run.sh" ]; then
        bash "$repo_root/scripts-linux/71-install-git-compact/run.sh" install
        return $?
    fi

    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"

    local install_url="https://raw.githubusercontent.com/alimtvnetwork/git-compact/main/install.sh"
    curl -fsSL "$install_url" | sh -s -- --dir "$bin_dir"

    return $?
}

verify_git_compact() {
    ensure_path_configured

    if command -v git-compact &>/dev/null; then
        local ver
        ver=$(git-compact --version 2>&1 | head -n 1)
        echo -e "  ${PRIMARY}[  OK  ] git-compact verified: $ver${TEXT}"
        return 0
    fi

    if [ -x "$HOME/.local/bin/git-compact" ]; then
        local ver
        ver=$("$HOME/.local/bin/git-compact" --version 2>&1 | head -n 1)
        echo -e "  ${PRIMARY}[  OK  ] git-compact verified at ~/.local/bin: $ver${TEXT}"
        return 0
    fi

    echo -e "  \033[1;31m[ FAIL ] git-compact installation could not be verified.\033[0m"
    return 1
}

main() {
    if [ "$IS_FORCE" != "true" ] && is_git_compact_installed; then
        echo -e "  ${PRIMARY}[  OK  ] git-compact is already installed.${TEXT}"
        return 0
    fi

    echo -e "  ${SECONDARY}[  ..  ] Installing git-compact CLI (repo compactor & pruner)...${TEXT}"

    install_via_upstream

    verify_git_compact
}

main "$@"
