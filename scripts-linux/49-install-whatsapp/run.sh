#!/usr/bin/env bash
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export SCRIPT_ID="49"
. "$ROOT/_shared/logger.sh"
. "$ROOT/_shared/pkg-detect.sh"
. "$ROOT/_shared/file-error.sh"
. "$ROOT/_shared/install-paths.sh"

CONFIG="$SCRIPT_DIR/config.json"
[ -f "$CONFIG" ] || { log_file_error "$CONFIG" "config.json missing for 49-install-whatsapp"; exit 1; }
INSTALLED_MARK="$ROOT/.installed/49.ok"

DEB_PKG="wasistlos"
DEB_REPO="eneshecan/whatsapp-for-linux"
DOWNLOAD_TIMEOUT="$(jq -r '.timeouts.downloadSeconds // 300' "$CONFIG" 2>/dev/null || echo 300)"
INSTALL_TIMEOUT="$(jq -r '.timeouts.installSeconds // 600' "$CONFIG" 2>/dev/null || echo 600)"

is_snap_app_installed() {
  command -v snap >/dev/null 2>&1 || return 1

  snap list "$1" >/dev/null 2>&1
}

is_flatpak_app_installed() {
  command -v flatpak >/dev/null 2>&1 || return 1

  flatpak list --app --columns=application 2>/dev/null | grep -qx "$1"
}

is_deb_pkg_installed() {
  dpkg -s whatsapp-for-linux >/dev/null 2>&1 && return 0

  dpkg -s "$DEB_PKG" >/dev/null 2>&1
}

is_pwa_installed() {
  [ -x "$HOME/.local/bin/whatsapp" ] && [ -f "$HOME/.local/share/applications/whatsapp.desktop" ]
}

verify_installed() {
  is_snap_app_installed "whatsapp-for-linux" && return 0

  is_flatpak_app_installed "io.github.eneshecan.WhatsAppForLinux" && return 0

  is_flatpak_app_installed "com.github.xeco23.WasIstLos" && return 0

  is_deb_pkg_installed && return 0

  is_pwa_installed && return 0

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

has_snap() {
  command -v snap >/dev/null 2>&1
}

has_flatpak() {
  command -v flatpak >/dev/null 2>&1
}

has_timeout_cmd() {
  command -v timeout >/dev/null 2>&1
}

run_with_timeout() {
  local secs="$1"; shift

  has_timeout_cmd || { log_warn "[49] 'timeout' cmd missing -- running without timeout guard"; "$@"; return $?; }

  timeout "$secs" "$@"
}

install_via_snap() {
  has_snap || return 1

  log_info "[49] trying snap install: whatsapp-for-linux"

  run_with_timeout "$INSTALL_TIMEOUT" sudo snap install whatsapp-for-linux || return 1

  is_snap_app_installed "whatsapp-for-linux"
}

ensure_flatpak() {
  has_flatpak && return 0

  log_info "[49] flatpak missing -- installing via apt"

  is_apt_available || { log_err "[49] apt-get missing -- cannot install flatpak"; return 1; }

  sudo apt-get update -y >/dev/null 2>&1 || true

  run_with_timeout "$INSTALL_TIMEOUT" sudo apt-get install -y flatpak || return 1

  has_flatpak
}

ensure_flathub_remote() {
  flatpak remotes --columns=name 2>/dev/null | grep -qx "flathub" && return 0

  log_info "[49] adding flathub remote"

  run_with_timeout "$DOWNLOAD_TIMEOUT" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

install_single_flatpak_app() {
  local app_id="$1"

  log_info "[49] trying flatpak install: $app_id"

  run_with_timeout "$INSTALL_TIMEOUT" flatpak install -y --noninteractive flathub "$app_id" || return 1

  is_flatpak_app_installed "$app_id"
}

install_via_flatpak() {
  ensure_flatpak || return 1

  ensure_flathub_remote || return 1

  install_single_flatpak_app "io.github.eneshecan.WhatsAppForLinux" && return 0

  install_single_flatpak_app "com.github.xeco23.WasIstLos" && return 0

  return 1
}

fetch_latest_deb_url() {
  has_curl || { log_err "[49] curl required for .deb fallback"; return 1; }

  local api="https://api.github.com/repos/$DEB_REPO/releases/latest"
  local json
  json=$(curl -fsSL --max-time "$DOWNLOAD_TIMEOUT" "$api" 2>/dev/null) || return 1

  local url
  url=$(printf '%s' "$json" | grep -oE '"browser_download_url": *"[^"]+_amd64\.deb"' | head -1 | cut -d'"' -f4)
  [ -n "$url" ] || return 1

  printf '%s' "$url"
}

download_deb_file() {
  local url="$1" deb_path="$2"

  log_info "[49] downloading .deb: $url"

  curl -fsSL --max-time "$DOWNLOAD_TIMEOUT" -o "$deb_path" "$url" || { log_file_error "$deb_path" "download failed from $url"; return 1; }
}

apply_deb_file() {
  local deb_path="$1"

  log_info "[49] installing .deb via dpkg"

  run_with_timeout "$INSTALL_TIMEOUT" sudo dpkg -i "$deb_path" || log_warn "[49] dpkg exited non-zero -- running apt-get install -f"

  run_with_timeout "$INSTALL_TIMEOUT" sudo apt-get install -f -y >/dev/null 2>&1 || true
}

install_via_deb() {
  is_apt_available || { log_err "[49] apt-get missing -- cannot install .deb"; return 1; }

  local url deb_tmp
  url=$(fetch_latest_deb_url) || return 1

  deb_tmp=$(mktemp /tmp/whatsapp-for-linux.XXXXXX.deb) || { log_file_error "/tmp" "mktemp failed"; return 1; }

  download_deb_file "$url" "$deb_tmp" || { rm -f "$deb_tmp"; return 1; }

  apply_deb_file "$deb_tmp"
  rm -f "$deb_tmp"

  is_deb_pkg_installed
}

find_pwa_browser() {
  local candidate
  for candidate in google-chrome google-chrome-stable chromium-browser chromium brave-browser brave; do
    command -v "$candidate" 2>/dev/null && return 0
  done

  return 1
}

write_pwa_launcher() {
  local browser_bin="$1"
  local launcher="$HOME/.local/bin/whatsapp"

  mkdir -p "$HOME/.local/bin" || { log_file_error "$HOME/.local/bin" "mkdir failed"; return 1; }

  printf '#!/usr/bin/env bash\nexec "%s" --app=https://web.whatsapp.com --class=WhatsApp "$@"\n' "$browser_bin" > "$launcher" || { log_file_error "$launcher" "write launcher failed"; return 1; }

  chmod +x "$launcher" || { log_file_error "$launcher" "chmod failed"; return 1; }

  return 0
}

write_pwa_desktop_entry() {
  local app_dir="$HOME/.local/share/applications"
  local desktop_file="$app_dir/whatsapp.desktop"

  mkdir -p "$app_dir" || { log_file_error "$app_dir" "mkdir failed"; return 1; }

  cat > "$desktop_file" << 'EOF'
[Desktop Entry]
Version=1.0
Name=WhatsApp
Comment=WhatsApp Desktop Web Client
Exec=whatsapp %U
Icon=whatsapp
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
MimeType=x-scheme-handler/whatsapp;
EOF
  [ -f "$desktop_file" ] || { log_file_error "$desktop_file" "write desktop entry failed"; return 1; }

  return 0
}

install_via_pwa() {
  local browser_bin
  browser_bin="$(find_pwa_browser)" || { log_warn "[49] no supported browser found for PWA"; return 1; }

  log_info "[49] deploying PWA launcher with browser: $browser_bin"

  write_pwa_launcher "$browser_bin" || return 1

  write_pwa_desktop_entry || return 1

  is_pwa_installed
}

verb_install() {
  write_install_paths \
    --tool   "WhatsApp Desktop (snap|flatpak|deb|PWA)" \
    --source "snapcraft.io | flathub | github.com/$DEB_REPO | PWA" \
    --temp   "/tmp/whatsapp-for-linux.*.deb" \
    --target "snap | flatpak | /usr/bin/whatsapp-for-linux | ~/.local/bin/whatsapp"

  log_info "[49] Starting WhatsApp installer"

  is_debian_os || { log_err "[49] not Ubuntu/Debian -- refusing"; return 1; }

  if verify_installed; then
    log_ok "[49] WhatsApp already installed"
    mkdir -p "$ROOT/.installed" && touch "$INSTALLED_MARK"
    return 0
  fi

  install_via_snap && { mkdir -p "$ROOT/.installed" && touch "$INSTALLED_MARK"; return 0; }

  log_warn "[49] snap path failed -- trying flatpak"

  install_via_flatpak && { mkdir -p "$ROOT/.installed" && touch "$INSTALLED_MARK"; return 0; }

  log_warn "[49] flatpak path failed -- trying .deb fallback"

  install_via_deb && { mkdir -p "$ROOT/.installed" && touch "$INSTALLED_MARK"; return 0; }

  log_warn "[49] .deb path failed -- trying PWA fallback"

  install_via_pwa && { mkdir -p "$ROOT/.installed" && touch "$INSTALLED_MARK"; return 0; }

  log_err "[49] all install methods failed"

  return 1
}

verb_check() {
  if verify_installed; then
    log_ok "[49] WhatsApp detected"
    return 0
  fi

  log_warn "[49] WhatsApp not installed"

  return 1
}

verb_repair() {
  rm -f "$INSTALLED_MARK"

  verb_install
}

uninstall_snap() {
  has_snap || return 0

  is_snap_app_installed "whatsapp-for-linux" || return 0

  sudo snap remove whatsapp-for-linux 2>/dev/null || true
}

uninstall_flatpak() {
  has_flatpak || return 0

  flatpak uninstall -y io.github.eneshecan.WhatsAppForLinux 2>/dev/null || true
  flatpak uninstall -y com.github.xeco23.WasIstLos 2>/dev/null || true
}

uninstall_deb() {
  dpkg -s whatsapp-for-linux >/dev/null 2>&1 && sudo dpkg -r whatsapp-for-linux 2>/dev/null || true
  dpkg -s wasistlos >/dev/null 2>&1 && sudo dpkg -r wasistlos 2>/dev/null || true
}

uninstall_pwa() {
  rm -f "$HOME/.local/bin/whatsapp" 2>/dev/null || true
  rm -f "$HOME/.local/share/applications/whatsapp.desktop" 2>/dev/null || true
}

verb_uninstall() {
  log_info "[49] uninstalling WhatsApp across all tiers"

  uninstall_snap

  uninstall_flatpak

  uninstall_deb

  uninstall_pwa

  rm -f "$INSTALLED_MARK"

  log_ok "[49] WhatsApp removed"
}

case "${1:-install}" in
  install) verb_install ;;
  check) verb_check ;;
  repair) verb_repair ;;
  uninstall) verb_uninstall ;;
  *)
    log_err "[49] Unknown verb: $1"
    exit 2
    ;;
esac
