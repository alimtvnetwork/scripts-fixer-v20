#!/usr/bin/env bash
# Shared helper: --user <name> drop-privileges re-exec.
#
# Usage from a 60/61/62-style script:
#   . "$ROOT/_shared/user-reexec.sh"
#   maybe_reexec_as_user "$@"
#   set -- ${REEXEC_ARGS[@]+"${REEXEC_ARGS[@]}"}
#
# If --user NAME (or --user=NAME) is present AND we are root, this re-execs the
# current script as that user via `sudo -u NAME -H bash $0 <stripped args>` so
# every $HOME / ~ reference inside the script resolves to that user's home.
# If --user is given without root privileges, exits with [ERR].
# If --user is absent or matches the current user, it's a no-op.

maybe_reexec_as_user() {
  REEXEC_ARGS=()
  local target="" next=0 a
  for a in "$@"; do
    if [ "$next" = "1" ]; then target="$a"; next=0; continue; fi
    case "$a" in
      --user=*) target="${a#--user=}" ;;
      --user)   next=1 ;;
      *)        REEXEC_ARGS+=("$a") ;;
    esac
  done
  [ -n "$target" ] || return 0
  [ "$(id -un)" = "$target" ] && return 0
  if [ "$(id -u)" != "0" ]; then
    echo "[ERR] --user $target requires running as root (use sudo)" >&2
    exit 2
  fi
  command -v sudo >/dev/null 2>&1 || { echo "[ERR] --user needs sudo on PATH" >&2; exit 2; }
  id "$target" >/dev/null 2>&1 || { echo "[ERR] --user $target: no such user" >&2; exit 2; }
  exec sudo -u "$target" -H bash "$0" ${REEXEC_ARGS[@]+"${REEXEC_ARGS[@]}"}
}
