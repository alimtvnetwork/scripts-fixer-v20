#!/usr/bin/env bash
# _autologin-detect.sh -- Auto-login status probe functions for Ubuntu.
# Part of 68-user-mgmt.

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
  echo "  • GDM3 (GNOME):       $is_gdm_on (user: ${gdm_user:-none})"
  echo "  • LightDM:            $is_ldm_on (user: ${ldm_user:-none})"
  echo "  • systemd tty1 getty: $is_get_on (user: ${get_user:-none})"
  echo ""
}
