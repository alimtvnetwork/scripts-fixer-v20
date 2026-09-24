#!/usr/bin/env bash
# 68-user-mgmt -- root dispatcher for cross-OS user/group management.
#
# This script is a PURE PASS-THROUGH: it parses the subverb, picks the
# matching leaf script, and forwards every remaining argument unchanged.
# All real work happens in the leaves, which can also be invoked directly.
#
# Run any subverb with --help for full options.

set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/helpers/_common.sh"
. "$SCRIPT_DIR/helpers/_usage.sh"

usage() {
  show_user_mgmt_usage
}

if [ $# -eq 0 ]; then usage; exit 0; fi

SUBVERB="$1"; shift

write_install_paths \
  --tool   "User-mgmt dispatcher (subverb=$SUBVERB)" \
  --source "$SCRIPT_DIR/<leaf>.sh + CLI args + optional JSON spec" \
  --temp   "$ROOT/.logs/68/<TS>" \
  --target "/etc/passwd + /etc/group + /etc/shadow + /home/<user>/.ssh/authorized_keys (per leaf)"

case "$SUBVERB" in
  -h|--help|help)
    usage; exit 0 ;;
  add-user)
    exec bash "$SCRIPT_DIR/add-user.sh" "$@" ;;
  add-group)
    exec bash "$SCRIPT_DIR/add-group.sh" "$@" ;;
  add-user-json|add-users-json|user-json)
    exec bash "$SCRIPT_DIR/add-user-from-json.sh" "$@" ;;
  add-group-json|add-groups-json|group-json)
    exec bash "$SCRIPT_DIR/add-group-from-json.sh" "$@" ;;
  edit-user|modify-user|edituser)
    exec bash "$SCRIPT_DIR/edit-user.sh" "$@" ;;
  edit-user-json|edit-users-json|edituser-json|modify-user-json)
    exec bash "$SCRIPT_DIR/edit-user-from-json.sh" "$@" ;;
  remove-user|delete-user|deluser|removeuser)
    exec bash "$SCRIPT_DIR/remove-user.sh" "$@" ;;
  remove-user-json|remove-users-json|delete-user-json|deluser-json)
    exec bash "$SCRIPT_DIR/remove-user-from-json.sh" "$@" ;;
  gen-key|genkey|ssh-keygen)
    exec bash "$SCRIPT_DIR/gen-key.sh" "$@" ;;
  autologin|auto-login)
    exec bash "$SCRIPT_DIR/autologin.sh" "$@" ;;
  bootstrap|orchestrate|all)
    exec bash "$SCRIPT_DIR/orchestrate.sh" "$@" ;;
  verify|check|verify-state)
    exec bash "$SCRIPT_DIR/verify.sh" "$@" ;;
  verify-summary|check-summary|verify-ssh-summary)
    exec bash "$SCRIPT_DIR/verify-summary.sh" "$@" ;;
  *)
    log_err "unknown subverb: '$SUBVERB' (failure: see --help for the list)"
    usage
    exit 64
    ;;
esac