#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$ROOT/.." && pwd)"
export SCRIPT_ID="69"

. "$ROOT/_shared/logger.sh"
. "$ROOT/_shared/pkg-detect.sh"
. "$ROOT/_shared/file-error.sh"
. "$ROOT/_shared/install-paths.sh"

CONFIG="$SCRIPT_DIR/config.json"
if [ ! -f "$CONFIG" ]; then
  log_file_error "$CONFIG" "config.json missing for 69-install-antigravity"
  exit 1
fi

INSTALLED_MARK="$ROOT/.installed/69.ok"

verify_installed() {
  if command -v agy >/dev/null 2>&1 || [ -x "$HOME/.local/bin/agy" ]; then
    return 0
  fi

  return 1
}

verb_install() {
  write_install_paths \
    --tool   "antigravity" \
    --source "https://storage.googleapis.com/antigravity-public (official archive)" \
    --temp   "/tmp/scripts-fixer-downloads/Antigravity.tar.gz" \
    --target "$HOME/.local/bin/agy"

  log_info "[69] Starting Antigravity installer"

  if verify_installed; then
    log_ok "[69] Antigravity already installed"
    mkdir -p "$ROOT/.installed"
    touch "$INSTALLED_MARK"
    return 0
  fi

  local ub_script="$REPO_ROOT/scripts/os/ubuntu/install-antigravity.sh"

  if [ -f "$ub_script" ]; then
    log_info "[69] Executing ubuntu installer: $ub_script"
    if bash "$ub_script"; then
      log_ok "[69] Antigravity installed"
      mkdir -p "$ROOT/.installed"
      touch "$INSTALLED_MARK"
      return 0
    fi
  fi

  log_err "[69] Antigravity installation failed"
  return 1
}

verb_check() {
  if verify_installed; then
    log_ok "[69] Antigravity detected"
    return 0
  fi

  log_warn "[69] Antigravity not on PATH"
  return 1
}

verb_repair() {
  rm -f "$INSTALLED_MARK"
  verb_install
}

verb_uninstall() {
  rm -f "$HOME/.local/bin/agy" "$HOME/.local/bin/antigravity"
  rm -rf "$HOME/.local/share/antigravity" "$HOME/.local/share/antigravity-ide"
  rm -f "$HOME/.local/share/applications/antigravity.desktop" \
        "$HOME/.local/share/applications/antigravity-ide.desktop" \
        "$HOME/.local/share/applications/Google Antigravity.desktop" \
        "$HOME/.local/share/applications/Google-Antigravity.desktop" \
        "$HOME/.local/share/applications/Antigravity.desktop" \
        "$HOME/Desktop/antigravity.desktop" \
        "$HOME/Desktop/antigravity-ide.desktop" \
        "$HOME/Desktop/Google Antigravity.desktop" \
        "$HOME/Desktop/Google-Antigravity.desktop" \
        "$HOME/Desktop/Antigravity.desktop"
  rm -f "$INSTALLED_MARK"
  log_ok "[69] Antigravity uninstalled"
}

show_help() {
  local CYAN="\033[96m"
  local GREEN="\033[92m"
  local YELLOW="\033[93m"
  local BOLD="\033[1m"
  local RESET="\033[0m"
  local WHITE="\033[97m"

  printf "\n${BOLD}${CYAN}Antigravity (agy) -- Google Antigravity IDE & CLI Manager (Linux/macOS)${RESET}\n"
  printf "${BOLD}${CYAN}========================================================================${RESET}\n"
  printf "${BOLD}${WHITE}USAGE:${RESET} ./run.sh agy <action> [flags]\n\n"
  printf "${BOLD}${WHITE}ACTIONS:${RESET}\n"
  printf "  ${GREEN}clear | clean${RESET}          Clear Antigravity/Gemini caches & optimize conversation databases\n"
  printf "  ${GREEN}cache clear${RESET}            Alias for 'agy clear' (prunes heavy convs & scrubs caches)\n"
  printf "  ${GREEN}cache-clear${RESET}            Alias for 'agy clear'\n"
  printf "  ${GREEN}predict${RESET}                Preview database pruning and cache savings without modifying files\n"
  printf "  ${GREEN}list-backups${RESET}           List available conversation prune backups\n"
  printf "  ${GREEN}undo [tx-id]${RESET}           Restore pruned conversation turns from 'latest' or a specific transaction ID\n"
  printf "  ${CYAN}install${RESET}                Install Antigravity IDE and CLI (agy)\n"
  printf "  ${CYAN}cli${RESET}                    Install Antigravity CLI only (agy)\n"
  printf "  ${CYAN}check${RESET}                  Check if Antigravity is installed and on PATH\n"
  printf "  ${CYAN}uninstall${RESET}              Uninstall Antigravity IDE and CLI\n"
  printf "  ${WHITE}help${RESET}                   Show this help screen\n\n"
  printf "${BOLD}${WHITE}FLAGS (for clear / clean / cache clear):${RESET}\n"
  printf "  ${YELLOW}--keep <N> | -k <N> | -k<N> | <N>${RESET}  Keep latest N conversations intact (e.g. -k1, --keep 10)\n"
  printf "  ${YELLOW}-y | --yes${RESET}                         Apply modifications without prompting\n"
  printf "  ${YELLOW}--kill${RESET}                             Terminate active Antigravity processes before cache removal\n"
  printf "  ${YELLOW}--threshold <KB> | -t<KB>${RESET}          Size threshold in KB to trigger pruning (default: 200 KB)\n\n"
  printf "${BOLD}${WHITE}EXAMPLES:${RESET}\n"
  printf "  ./run.sh agy clear                     # Preview cleanup savings without modifying files\n"
  printf "  ./run.sh agy cache clear -k1           # Preview mode keeping latest 1 conversation intact\n"
  printf "  ./run.sh agy clear -k10 -y             # Apply: keep latest 10 conversations, scrub caches\n"
  printf "  ./run.sh agy cache clear -y --kill     # Terminate running agy processes & scrub caches\n"
  printf "  ./run.sh agy undo latest               # Revert the last pruning transaction\n"
  printf "  ./run.sh agy list-backups              # View past backup transaction IDs\n\n"
}

verb_clean() {
  local helper="$SCRIPT_DIR/helpers/clear-agy.sh"

  if [ ! -f "$helper" ]; then
    log_file_error "$helper" "clear-agy.sh missing"

    return 1
  fi

  bash "$helper" "$@"
}

case "${1:-help}" in
  help|--help|-help|-h) show_help;;
  install)   verb_install;;
  check)     verb_check;;
  repair)    verb_repair;;
  uninstall) verb_uninstall;;
  clean|clear) verb_clean "${@:2}";;
  cache)
    if [ "${2:-}" = "clear" ] || [ "${2:-}" = "clean" ]; then
      verb_clean "${@:3}"
    else
      verb_clean "${@:2}"
    fi
    ;;
  cache-clear|clear-cache|clean-cache|cache-clean) verb_clean "${@:2}";;
  predict)   verb_clean "--predict" "${@:2}";;
  list-backups|backups|history) verb_clean "--list-backups";;
  undo)      verb_clean "--undo" "${2:-latest}";;
  *)         log_err "[69] Unknown verb: $1"; show_help; exit 2;;
esac

