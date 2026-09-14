#!/usr/bin/env bash
# --------------------------------------------------------------------------
#  system-autopurge.sh -- Deep clean APT cache, obsolete packages, and temp
# --------------------------------------------------------------------------
set -u

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_REPO_ROOT="$(cd "$_SCRIPT_DIR/../.." && pwd)"

source "$_REPO_ROOT/kubernetes/01-base-helpers/logger.sh"

assert_root_user() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    log_message "This script must be executed as root (sudo)." "error"

    return 1
  fi

  return 0
}

purge_apt_packages() {
  log_message "Running apt autoremove --purge..." "info"
  apt-get autoremove --purge -y >/dev/null 2>&1 || true

  log_message "Cleaning apt cache and autoclean..." "info"
  apt-get clean >/dev/null 2>&1 || true
  apt-get autoclean >/dev/null 2>&1 || true

  log_message "APT package cleanup completed." "success"
}

main() {
  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    echo "Usage: $0"
    exit 0
  fi

  if ! assert_root_user; then
    return 1
  fi

  purge_apt_packages

  return 0
}

main "$@"
