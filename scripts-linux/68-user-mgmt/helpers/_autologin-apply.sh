#!/usr/bin/env bash
# _autologin-apply.sh -- Configuration writers for Ubuntu auto-login.
# Part of 68-user-mgmt.

enable_gdm() {
  local target_user="$1"
  local is_dry_run="$2"

  if [ "$is_dry_run" = "true" ]; then
    echo "  [DRY RUN] Would update $GDM_CONFIG with AutomaticLoginEnable=true and AutomaticLogin=$target_user"
    return 0
  fi

  mkdir -p "$(dirname "$GDM_CONFIG")" || { log_file_error "$GDM_CONFIG" "Failed to create directory"; return 1; }

  if [ ! -f "$GDM_CONFIG" ]; then
    printf "[daemon]\nAutomaticLoginEnable=true\nAutomaticLogin=%s\n" "$target_user" > "$GDM_CONFIG"
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
