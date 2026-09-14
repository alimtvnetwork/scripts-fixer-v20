#!/usr/bin/env bash
# --------------------------------------------------------------------------
#  fix-antigravity-desktop.sh -- Purge duplicate launchers & restore official icon
# --------------------------------------------------------------------------
set -u

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_REPO_ROOT="$(cd "$_SCRIPT_DIR/../../.." && pwd)"

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
ACCENT='\033[1;33m'
MUTED='\033[0;37m'
ERROR='\033[1;31m'
TEXT='\033[0m'

find_antigravity_binary() {
  local candidates=(
    "$HOME/.local/share/antigravity-ide/antigravity-runner.sh"
    "$HOME/.local/share/antigravity/antigravity-runner.sh"
    "$HOME/.local/share/antigravity-ide/antigravity.run"
    "$HOME/.local/share/antigravity/antigravity.run"
    "$HOME/.local/share/antigravity-ide/antigravity"
    "$HOME/.local/share/antigravity/antigravity"
    "$HOME/.local/share/antigravity/Antigravity"
    "$HOME/.local/bin/antigravity"
    "$HOME/.local/bin/agy"
    "/usr/local/bin/antigravity"
    "/usr/bin/antigravity"
  )

  for c in "${candidates[@]}"; do
    if [ -x "$c" ]; then
      echo "$c"

      return 0
    fi
  done

  return 1
}

purge_duplicate_launchers() {
  echo -e "  ${MUTED}[1/4] Purging duplicate & conflicting Antigravity desktop launchers...${TEXT}"

  local user_apps="$HOME/.local/share/applications"
  local user_desktop="$HOME/Desktop"
  local targets=(
    "antigravity-ide.desktop"
    "Google Antigravity.desktop"
    "Google-Antigravity.desktop"
    "Antigravity.desktop"
    "antigravity.desktop"
  )

  for t in "${targets[@]}"; do
    rm -f "$user_apps/$t" 2>/dev/null || true
    rm -f "$user_desktop/$t" 2>/dev/null || true
  done

  if [ -w "/usr/share/applications" ]; then
    for t in "${targets[@]}"; do
      rm -f "/usr/share/applications/$t" 2>/dev/null || true
    done
  elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    for t in "${targets[@]}"; do
      sudo rm -f "/usr/share/applications/$t" 2>/dev/null || true
    done
  fi

  echo -e "  ${PRIMARY}[  OK  ] Cleaned stale desktop entries.${TEXT}"
}

deploy_official_icon() {
  echo -e "  ${MUTED}[2/4] Deploying official high-resolution Antigravity icon...${TEXT}"

  local repo_icon="$_REPO_ROOT/scripts/shared/antigravity-icon.png"
  local target_icon="$HOME/.local/share/icons/hicolor/256x256/apps/antigravity.png"
  local target_512="$HOME/.local/share/icons/hicolor/512x512/apps/antigravity.png"
  local target_pixmap="$HOME/.local/share/pixmaps/antigravity.png"

  mkdir -p "$(dirname "$target_icon")"
  mkdir -p "$(dirname "$target_512")"
  mkdir -p "$(dirname "$target_pixmap")"

  if [ -f "$repo_icon" ]; then
    cp -f "$repo_icon" "$target_icon"
    cp -f "$repo_icon" "$target_512"
    cp -f "$repo_icon" "$target_pixmap"
  fi

  if [ -w "/usr/share/pixmaps" ]; then
    cp -f "$target_icon" "/usr/share/pixmaps/antigravity.png" 2>/dev/null || true
  elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    sudo cp -f "$target_icon" "/usr/share/pixmaps/antigravity.png" 2>/dev/null || true
    sudo mkdir -p "/usr/share/icons/hicolor/256x256/apps" 2>/dev/null || true
    sudo cp -f "$target_icon" "/usr/share/icons/hicolor/256x256/apps/antigravity.png" 2>/dev/null || true
  fi

  echo -e "  ${PRIMARY}[  OK  ] Official icon deployed to $target_icon${TEXT}"
}

write_canonical_desktop_entry() {
  local exec_bin="$1"
  local app_dir="$HOME/.local/share/applications"
  local desktop_file="$app_dir/antigravity.desktop"
  local icon_path="$HOME/.local/share/icons/hicolor/256x256/apps/antigravity.png"

  [ -f "$icon_path" ] || icon_path="antigravity"

  echo -e "  ${MUTED}[3/4] Writing single canonical launcher: $desktop_file...${TEXT}"
  mkdir -p "$app_dir"

  cat <<EOF > "$desktop_file"
[Desktop Entry]
Version=1.0
Type=Application
Name=Antigravity
Comment=Google Antigravity IDE & AI Coding Assistant
GenericName=Text Editor
Exec=$exec_bin %F
Icon=$icon_path
Terminal=false
StartupNotify=true
StartupWMClass=Antigravity
Categories=Development;IDE;TextEditor;Utility;
MimeType=text/plain;inode/directory;
EOF

  chmod +x "$desktop_file"

  if [ -d "$HOME/Desktop" ]; then
    cp -f "$desktop_file" "$HOME/Desktop/" 2>/dev/null || true
    chmod +x "$HOME/Desktop/antigravity.desktop" 2>/dev/null || true
    if command -v gio >/dev/null 2>&1; then
      gio set "$HOME/Desktop/antigravity.desktop" metadata::trusted true 2>/dev/null || true
    fi
  fi

  echo -e "  ${PRIMARY}[  OK  ] Canonical launcher registered.${TEXT}"
}

reload_desktop_database() {
  echo -e "  ${MUTED}[4/4] Updating GNOME icon cache & desktop database...${TEXT}"

  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
  fi

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
  fi

  # Touch file to force GNOME Shell to reload launcher metadata immediately
  touch "$HOME/.local/share/applications/antigravity.desktop" 2>/dev/null || true

  echo -e "  ${PRIMARY}[  OK  ] Desktop caches refreshed.${TEXT}"
}

purge_antigravity_manager() {
  echo -e "  ${MUTED}[+] Purging Antigravity Manager package & launcher...${TEXT}"

  if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    sudo apt-get purge -y antigravity-manager >/dev/null 2>&1 || true
    sudo rm -f "/usr/share/applications/antigravity-manager.desktop" 2>/dev/null || true
  fi

  rm -f "$HOME/.local/share/applications/antigravity-manager.desktop" 2>/dev/null || true
  rm -f "$HOME/Desktop/antigravity-manager.desktop" 2>/dev/null || true

  echo -e "  ${PRIMARY}[  OK  ] Antigravity Manager removed.${TEXT}"
}

check_manager_presence() {
  local has_manager=false

  if dpkg -l antigravity-manager >/dev/null 2>&1 || [ -f "/usr/share/applications/antigravity-manager.desktop" ]; then
    has_manager=true
  fi

  if [ "$has_manager" = "true" ]; then
    echo -e "  ${MUTED}[NOTE ] 'Antigravity Manager' companion GUI is also installed on this system.${TEXT}"
    echo -e "  ${MUTED}        To remove it and keep ONLY the canonical IDE, run:${TEXT}"
    echo -e "  ${ACCENT}        ./run.sh fix-antigravity --purge-manager${TEXT}"
  fi
}

main() {
  echo -e "\n  ${PRIMARY}Antigravity Desktop Launcher & Icon Repair Utility${TEXT}"
  echo -e "  ${MUTED}==================================================${TEXT}"

  local is_purge_manager=false
  for arg in "$@"; do
    if [ "$arg" = "--purge-manager" ] || [ "$arg" = "--remove-manager" ]; then
      is_purge_manager=true
    fi
  done

  if [ "$is_purge_manager" = "true" ]; then
    purge_antigravity_manager
  fi

  local bin_path
  if ! bin_path="$(find_antigravity_binary)"; then
    echo -e "  ${ERROR}[FAIL ] Antigravity binary not found in standard directories.${TEXT}"
    echo -e "  ${ACCENT}Please install Antigravity first using: ./run.sh install agy${TEXT}\n"

    return 1
  fi

  echo -e "  ${MUTED}Detected binary: ${SECONDARY}$bin_path${TEXT}"

  purge_duplicate_launchers
  deploy_official_icon
  write_canonical_desktop_entry "$bin_path"
  reload_desktop_database
  check_manager_presence

  echo -e "\n  ${PRIMARY}[DONE ] Antigravity icon fixed & duplicate launchers removed!${TEXT}"
  echo -e "  ${MUTED}Check your application menu -- only one clean Antigravity icon will show.${TEXT}\n"

  return 0
}

main "$@"
