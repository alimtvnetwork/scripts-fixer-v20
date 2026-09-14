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

case "${1:-install}" in
  install)   verb_install;;
  check)     verb_check;;
  repair)    verb_repair;;
  uninstall) verb_uninstall;;
  *)         log_err "[69] Unknown verb: $1"; exit 2;;
esac
