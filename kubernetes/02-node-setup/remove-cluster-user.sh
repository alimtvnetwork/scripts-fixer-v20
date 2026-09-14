#!/usr/bin/env bash
# --------------------------------------------------------------------------
#  remove-cluster-user.sh -- Safely remove user, sudoers entry, and home dir
# --------------------------------------------------------------------------
set -u

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_REPO_ROOT="$(cd "$_SCRIPT_DIR/../.." && pwd)"

source "$_REPO_ROOT/kubernetes/01-base-helpers/logger.sh"

show_help() {
  echo ""
  echo "Usage: $0 <username>"
  echo ""
}

assert_root_user() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    log_message "This script must be executed as root (sudo)." "error"

    return 1
  fi

  return 0
}

remove_sudoers_entry() {
  local target_user="$1"
  local sudoers_file="/etc/sudoers.d/$target_user"

  if [ -f "$sudoers_file" ]; then
    rm -f "$sudoers_file"
    log_message "Removed $sudoers_file" "info"
  fi

  sed -i "/^$target_user ALL=(ALL) NOPASSWD:ALL/d" /etc/sudoers 2>/dev/null || true
}

remove_user_account() {
  local target_user="$1"

  if ! id "$target_user" >/dev/null 2>&1; then
    log_message "User '$target_user' does not exist." "info"

    return 0
  fi

  pkill -9 -u "$target_user" 2>/dev/null || true
  gpasswd -d "$target_user" sudo 2>/dev/null || true
  deluser --remove-home "$target_user" 2>/dev/null || true

  log_message "User '$target_user' and home directory removed." "success"
}

main() {
  if [ $# -lt 1 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help

    return 0
  fi

  if ! assert_root_user; then
    return 1
  fi

  remove_sudoers_entry "$1"
  remove_user_account "$1"

  return 0
}

main "$@"
