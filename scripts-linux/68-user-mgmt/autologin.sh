#!/usr/bin/env bash
# autologin.sh -- Manage auto-login for Ubuntu (GDM3, LightDM, systemd console)
# Part of 68-user-mgmt. Sourced or run directly.

set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/helpers/_common.sh"
. "$SCRIPT_DIR/helpers/_autologin-detect.sh"
. "$SCRIPT_DIR/helpers/_autologin-apply.sh"

parse_arguments() {
  ACTION="status"
  TARGET_USER="${SUDO_USER:-$USER}"
  TARGET_DM="auto"
  IS_DRY_RUN="false"
  IS_JSON="false"

  while [ $# -gt 0 ]; do
    case "$1" in
      status|check) ACTION="status"; shift ;;
      enable) ACTION="enable"; shift ;;
      disable) ACTION="disable"; shift ;;
      -u|--user|--username) TARGET_USER="$2"; shift 2 ;;
      --dm|--display-manager) TARGET_DM="$2"; shift 2 ;;
      --dry-run) IS_DRY_RUN="true"; shift ;;
      --json) IS_JSON="true"; shift ;;
      -h|--help)
        echo "Usage: bash autologin.sh [status|enable|disable] [--user <name>] [--dm gdm3|lightdm|getty|auto] [--dry-run] [--json]"
        exit 0
        ;;
      *) shift ;;
    esac
  done
}

main() {
  parse_arguments "$@"

  if [ "$ACTION" = "status" ]; then
    show_status "$IS_JSON"
    exit 0
  fi

  if [ "$ACTION" = "disable" ]; then
    disable_all "$IS_DRY_RUN"
    exit 0
  fi

  if [ "$ACTION" = "enable" ]; then
    if [ "$TARGET_DM" = "gdm3" ] || [ -d "/etc/gdm3" ] || [ "$TARGET_DM" = "auto" ]; then
      enable_gdm "$TARGET_USER" "$IS_DRY_RUN"
    fi

    if [ "$TARGET_DM" = "lightdm" ] || [ -d "/etc/lightdm" ]; then
      enable_lightdm "$TARGET_USER" "$IS_DRY_RUN"
    fi

    if [ "$TARGET_DM" = "getty" ] || [ "$TARGET_DM" = "server" ]; then
      enable_getty "$TARGET_USER" "$IS_DRY_RUN"
    fi

    echo "✔ Auto-login configured for '$TARGET_USER'."
    exit 0
  fi
}

main "$@"
