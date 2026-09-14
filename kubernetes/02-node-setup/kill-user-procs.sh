#!/usr/bin/env bash
# --------------------------------------------------------------------------
#  kill-user-procs.sh -- Terminate all active processes for a target user
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

kill_procs() {
  local target_user="$1"

  if ! id "$target_user" >/dev/null 2>&1; then
    log_message "User '$target_user' does not exist." "warn"

    return 0
  fi

  log_message "Terminating all processes for user: $target_user..." "info"
  pkill -9 -u "$target_user" 2>/dev/null || true
  log_message "Processes for '$target_user' terminated." "success"
}

main() {
  if [ $# -lt 1 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help

    return 0
  fi

  if ! assert_root_user; then
    return 1
  fi

  kill_procs "$1"

  return 0
}

main "$@"
