#!/usr/bin/env bash
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export SCRIPT_ID="49"
. "$ROOT/_shared/logger.sh"; . "$ROOT/_shared/pkg-detect.sh"; . "$ROOT/_shared/file-error.sh"; . "$ROOT/_shared/install-paths.sh"
CONFIG="$SCRIPT_DIR/config.json"
[ -f "$CONFIG" ] || { log_file_error "$CONFIG" "config.json missing for 49-install-whatsapp"; exit 1; }
INSTALLED_MARK="$ROOT/.installed/49.ok"

DEB_PKG="wasistlos"
DEB_REPO="eneshecan/whatsapp-for-linux"
DOWNLOAD_TIMEOUT="$(jq -r '.timeouts.downloadSeconds // 300' "$CONFIG" 2>/dev/null || echo 300)"
INSTALL_TIMEOUT="$(jq -r '.timeouts.installSeconds // 600' "$CONFIG" 2>/dev/null || echo 600)"

is_flatpak_app_installed() { flatpak list --app --columns=application 2>/dev/null | grep -qx "$1"; }
is_deb_pkg_installed() { dpkg -s "$DEB_PKG" >/dev/null 2>&1; }
verify_installed() {
  command -v flatpak >/dev/null 2>&1 && { is_flatpak_app_installed "io.github.eneshecan.WhatsAppForLinux" || is_flatpak_app_installed "com.github.xeco23.WasIstLos"; } && return 0
  is_deb_pkg_installed && return 0
  return 1
}
is_debian_os() {
  [ -f /etc/os-release ] || { log_file_error "/etc/os-release" "missing -- cannot detect OS"; return 1; }
  . /etc/os-release
  [ "${ID:-}" = "ubuntu" ] && return 0
  [ "${ID:-}" = "debian" ] && return 0
  case "${ID_LIKE:-}" in
    *debian*|*ubuntu*) return 0 ;;
  esac
  return 1
}
has_flatpak() { command -v flatpak >/dev/null 2>&1; }
has_timeout_cmd() { command -v timeout >/dev/null 2>&1; }
run_with_timeout() {
  local secs="$1"; shift
  has_timeout_cmd || { log_warn "[49] 'timeout' cmd missing -- running without timeout guard"; "$@"; return $?; }
  timeout "$secs" "$@"
}
ensure_flatpak() {
  has_flatpak && return 0
  log_info "[49] flatpak missing -- installing via apt"
  is_apt_available || { log_err "[49] apt-get missing -- cannot install flatpak"; return 1; }
  sudo apt-get update -y >/dev/null 2>&1 || true
  run_with_timeout "$INSTALL_TIMEOUT" sudo apt-get install -y flatpak || { log_err "[49] flatpak apt install failed/timed out"; return 1; }
  has_flatpak || { log_err "[49] flatpak still missing after install"; return 1; }
  log_ok "[49] flatpak installed"
}
ensure_flathub_remote() {
  flatpak remotes --columns=name 2>/dev/null | grep -qx "flathub" && return 0
  log_info "[49] adding flathub remote"
  run_with_timeout "$DOWNLOAD_TIMEOUT" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || { log_err "[49] flathub remote add failed/timed out"; return 1; }
}
install_via_flatpak() {
  ensure_flatpak || return 1
  ensure_flathub_remote || return 1
  local app_id
  for app_id in io.github.eneshecan.WhatsAppForLinux com.github.xeco23.WasIstLos; do
    log_info "[49] trying flatpak install: $app_id"
    if run_with_timeout "$INSTALL_TIMEOUT" flatpak install -y --noninteractive flathub "$app_id"; then
      is_flatpak_app_installed "$app_id" && { log_ok "[49] installed via flatpak: $app_id"; return 0; }
    fi
    log_warn "[49] flatpak install failed/timed out for $app_id -- trying next"
  done
  return 1
}
fetch_latest_deb_url() {
  has_curl || { log_err "[49] curl required for .deb fallback"; return 1; }
  local api="https://api.github.com/repos/$DEB_REPO/releases/latest"
  local json
  json=$(curl -fsSL --max-time "$DOWNLOAD_TIMEOUT" "$api" 2>/dev/null) || { log_err "[49] GitHub releases API failed/timed out"; return 1; }
  local url
  url=$(printf '%s' "$json" | grep -oE '"browser_download_url": *"[^"]+_amd64\.deb"' | head -1 | cut -d'"' -f4)
  [ -n "$url" ] || { log_err "[49] no amd64 .deb asset in latest release"; return 1; }
  printf '%s' "$url"
}
install_via_deb() {
  is_apt_available || { log_err "[49] apt-get missing -- cannot install .deb"; return 1; }
  local url deb_tmp
  url=$(fetch_latest_deb_url) || return 1
  deb_tmp=$(mktemp /tmp/whatsapp-for-linux.XXXXXX.deb) || { log_file_error "/tmp" "mktemp failed for .deb download"; return 1; }
  log_info "[49] downloading .deb: $url"
  curl -fsSL --max-time "$DOWNLOAD_TIMEOUT" -o "$deb_tmp" "$url" || { log_file_error "$deb_tmp" "download failed/timed out from $url"; rm -f "$deb_tmp"; return 1; }
  log_info "[49] installing .deb via dpkg"
  run_with_timeout "$INSTALL_TIMEOUT" sudo dpkg -i "$deb_tmp" || log_warn "[49] dpkg exited non-zero (deps?) -- running apt-get install -f"
  run_with_timeout "$INSTALL_TIMEOUT" sudo apt-get install -f -y >/dev/null 2>&1 || true
  rm -f "$deb_tmp"
  is_deb_pkg_installed && { log_ok "[49] installed via .deb ($DEB_PKG)"; return 0; }
  log_err "[49] .deb install verify failed"
  return 1
}
verb_install() {
  write_install_paths \
    --tool   "WhatsApp for Linux (unofficial)" \
    --source "flathub (flatpak) | github.com/$DEB_REPO (.deb)" \
    --temp   "/tmp/whatsapp-for-linux.*.deb" \
    --target "flatpak app | /usr/bin/wasistlos"
  log_info "[49] Starting WhatsApp installer"
  is_debian_os || { log_err "[49] not Ubuntu/Debian -- refusing"; return 1; }
  if verify_installed; then
    log_ok "[49] WhatsApp already installed"
    mkdir -p "$ROOT/.installed" && touch "$INSTALLED_MARK"
    return 0
  fi
  install_via_flatpak && { mkdir -p "$ROOT/.installed" && touch "$INSTALLED_MARK"; return 0; }
  log_warn "[49] flatpak path failed -- trying .deb fallback"
  install_via_deb && { mkdir -p "$ROOT/.installed" && touch "$INSTALLED_MARK"; return 0; }
  log_err "[49] all install methods failed"
  return 1
}
verb_check()     { if verify_installed; then log_ok "[49] WhatsApp detected"; return 0; fi; log_warn "[49] WhatsApp not installed"; return 1; }
verb_repair()    { rm -f "$INSTALLED_MARK"; verb_install; }
verb_uninstall() {
  is_deb_pkg_installed && { sudo dpkg -r "$DEB_PKG" 2>/dev/null || true; }
  has_flatpak && { flatpak uninstall -y io.github.eneshecan.WhatsAppForLinux 2>/dev/null || true; flatpak uninstall -y com.github.xeco23.WasIstLos 2>/dev/null || true; }
  rm -f "$INSTALLED_MARK"; log_ok "[49] WhatsApp removed"
}
case "${1:-install}" in install) verb_install;; check) verb_check;; repair) verb_repair;; uninstall) verb_uninstall;; *) log_err "[49] Unknown verb: $1"; exit 2;; esac
