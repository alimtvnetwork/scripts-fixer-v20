#!/usr/bin/env bash
# autologin.sh -- Manage auto-login for Ubuntu (GDM3, LightDM, systemd console)
#
# Part of 68-user-mgmt. Sourced or run directly.
# Complies with CODE RED standards and strict boolean naming (is_*, has_*).

set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/helpers/_common.sh"

GDM_CONFIG="/etc/gdm3/custom.conf"
LIGHTDM_DIR="/etc/lightdm/lightdm.conf.d"
LIGHTDM_FILE="$LIGHTDM_DIR/50-autologin.conf"
GETTY_DIR="/etc/systemd/system/getty@tty1.service.d"
GETTY_FILE="$GETTY_DIR/override.conf"

check_gdm_status() {
  local is_enabled="false"
  local auto_user=""

  if [ -f "$GDM_CONFIG" ]; then
    if grep -Eq '^[[:space:]]*AutomaticLoginEnable[[:space:]]*=[[:space:]]*true' "$GDM_CONFIG"; then
      is_enabled="true"
    fi

    auto_user=$(grep -E '^[[:space:]]*AutomaticLogin[[:space:]]*=' "$GDM_CONFIG" | head -n1 | cut -d= -f2 | tr -d '[:space:]')
  fi

  echo "$is_enabled:$auto_user"
}

check_lightdm_status() {
  local is_enabled="false"
  local auto_user=""

  if [ -f "$LIGHTDM_FILE" ]; then
    auto_user=$(grep -E '^[[:space:]]*autologin-user[[:space:]]*=' "$LIGHTDM_FILE" | head -n1 | cut -d= -f2 | tr -d '[:space:]')

    if [ -n "$auto_user" ]; then
      is_enabled="true"
    fi
  fi

  echo "$is_enabled:$auto_user"
}

check_getty_status() {
  local is_enabled="false"
  local auto_user=""

  if [ -f "$GETTY_FILE" ]; then
    if grep -q -- "--autologin" "$GETTY_FILE"; then
      is_enabled="true"
      auto_user=$(grep -- "--autologin" "$GETTY_FILE" | sed -n 's/.*--autologin[[:space:]]\+\([^[:space:]]\+\).*/\1/p')
    fi
  fi

  echo "$is_enabled:$auto_user"
}

show_status() {
  local is_json="$1"
  local gdm_raw; gdm_raw=$(check_gdm_status)
  local ldm_raw; ldm_raw=$(check_lightdm_status)
  local get_raw; get_raw=$(check_getty_status)

  local is_gdm_on; is_gdm_on=$(echo "$gdm_raw" | cut -d: -f1)
  local gdm_user; gdm_user=$(echo "$gdm_raw" | cut -d: -f2)
  local is_ldm_on; is_ldm_on=$(echo "$ldm_raw" | cut -d: -f1)
  local ldm_user; ldm_user=$(echo "$ldm_raw" | cut -d: -f2)
  local is_get_on; is_get_on=$(echo "$get_raw" | cut -d: -f1)
  local get_user; get_user=$(echo "$get_raw" | cut -d: -f2)

  if [ "$is_json" = "true" ]; then
    cat <<EOF
{
  "gdm3": { "is_enabled": $is_gdm_on, "username": "$gdm_user" },
  "lightdm": { "is_enabled": $is_ldm_on, "username": "$ldm_user" },
  "systemd_getty": { "is_enabled": $is_get_on, "username": "$get_user" }
}
EOF
    return 0
  fi

  echo ""
  echo "▶ Ubuntu OS Auto-Login Status"
  echo "  • GDM3 (GNOME):      $is_gdm_on (user: ${gdm_user:-none})"
  echo "  • LightDM:           $is_ldm_on (user: ${ldm_user:-none})"
  echo "  • systemd tty1 getty: $is_get_on (user: ${get_user:-none})"
  echo ""
}

enable_gdm() {
  local target_user="$1"
  local is_dry_run="$2"

  if [ "$is_dry_run" = "true" ]; then
    echo "  [DRY RUN] Would update $GDM_CONFIG with AutomaticLoginEnable=true and AutomaticLogin=$target_user"
    return 0
  fi

  mkdir -p "$(dirname "$GDM_CONFIG")" || { log_file_error "$GDM_CONFIG" "Failed to create parent directory"; return 1; }

  if [ ! -f "$GDM_CONFIG" ]; then
    cat > "$GDM_CONFIG" <<EOF
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=$target_user
EOF
    log_info "Created $GDM_CONFIG with auto-login for $target_user"
    return 0
  fi

  sed -i '/AutomaticLoginEnable/d' "$GDM_CONFIG"
  sed -i '/AutomaticLogin/d' "$GDM_CONFIG"

  if grep -q '\[daemon\]' "$GDM_CONFIG"; then
    sed -i "/\[daemon\]/a AutomaticLoginEnable=true\nAutomaticLogin=$target_user" "$GDM_CONFIG"
  else
    printf "\n[daemon]\nAutomaticLoginEnable=true\nAutomaticLogin=%s\n" "$target_user" >> "$GDM_CONFIG"
  fi

  log_info "Configured GDM3 auto-login for $target_user in $GDM_CONFIG"
}

enable_lightdm() {
  local target_user="$1"
  local is_dry_run="$2"

  if [ "$is_dry_run" = "true" ]; then
    echo "  [DRY RUN] Would write $LIGHTDM_FILE with autologin-user=$target_user"
    return 0
  fi

  mkdir -p "$LIGHTDM_DIR" || { log_file_error "$LIGHTDM_DIR" "Failed to create directory"; return 1; }

  cat > "$LIGHTDM_FILE" <<EOF
[Seat:*]
autologin-user=$target_user
autologin-user-timeout=0
EOF

  log_info "Configured LightDM auto-login for $target_user in $LIGHTDM_FILE"
}

enable_getty() {
  local target_user="$1"
  local is_dry_run="$2"

  if [ "$is_dry_run" = "true" ]; then
    echo "  [DRY RUN] Would write $GETTY_FILE with --autologin $target_user"
    return 0
  fi

  mkdir -p "$GETTY_DIR" || { log_file_error "$GETTY_DIR" "Failed to create directory"; return 1; }

  cat > "$GETTY_FILE" <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $target_user --noclear %I \$TERM
EOF

  systemctl daemon-reload 2>/dev/null || true
  log_info "Configured systemd getty console auto-login for $target_user in $GETTY_FILE"
}

disable_all() {
  local is_dry_run="$1"

  if [ "$is_dry_run" = "true" ]; then
    echo "  [DRY RUN] Would remove auto-login settings from GDM3, LightDM, and systemd getty"
    return 0
  fi

  if [ -f "$GDM_CONFIG" ]; then
    sed -i '/AutomaticLoginEnable/d' "$GDM_CONFIG"
    sed -i '/AutomaticLogin/d' "$GDM_CONFIG"
  fi

  rm -f "$LIGHTDM_FILE"
  rm -f "$GETTY_FILE"
  systemctl daemon-reload 2>/dev/null || true

  log_info "Disabled auto-login across GDM3, LightDM, and systemd getty"
}

main() {
  local action="status"
  local target_user="${SUDO_USER:-$USER}"
  local target_dm="auto"
  local is_dry_run="false"
  local is_json="false"

  while [ $# -gt 0 ]; do
    case "$1" in
      status|check) action="status"; shift ;;
      enable) action="enable"; shift ;;
      disable) action="disable"; shift ;;
      -u|--user|--username) target_user="$2"; shift 2 ;;
      --dm|--display-manager) target_dm="$2"; shift 2 ;;
      --dry-run) is_dry_run="true"; shift ;;
      --json) is_json="true"; shift ;;
      -h|--help)
        echo "Usage: bash autologin.sh [status|enable|disable] [--user <name>] [--dm gdm3|lightdm|getty|auto] [--dry-run] [--json]"
        exit 0
        ;;
      *) shift ;;
    esac
  done

  if [ "$action" = "status" ]; then
    show_status "$is_json"
    exit 0
  fi

  if [ "$action" = "disable" ]; then
    disable_all "$is_dry_run"
    exit 0
  fi

  if [ "$action" = "enable" ]; then
    if [ "$target_dm" = "gdm3" ] || [ -d "/etc/gdm3" ] || [ "$target_dm" = "auto" ]; then
      enable_gdm "$target_user" "$is_dry_run"
    fi

    if [ "$target_dm" = "lightdm" ] || [ -d "/etc/lightdm" ]; then
      enable_lightdm "$target_user" "$is_dry_run"
    fi

    if [ "$target_dm" = "getty" ] || [ "$target_dm" = "server" ]; then
      enable_getty "$target_user" "$is_dry_run"
    fi

    echo "✔ Auto-login configured for '$target_user'."
    exit 0
  fi
}

main "$@"
