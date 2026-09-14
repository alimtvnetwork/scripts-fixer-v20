#!/usr/bin/env bash
# --------------------------------------------------------------------------
#  sync-repo-permissions.sh -- Synchronize repository permissions & pull on nodes
# --------------------------------------------------------------------------
set -u

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_REPO_ROOT="$(cd "$_SCRIPT_DIR/../.." && pwd)"

source "$_REPO_ROOT/kubernetes/01-base-helpers/logger.sh"

show_help() {
  echo ""
  echo "Usage: $0 [permissions] [username] [--pull]"
  echo ""
  echo "Examples:"
  echo "  $0 755 auk"
  echo "  $0 775 auk --pull"
  echo ""
}

apply_repo_permissions() {
  local perms="$1"
  local target_user="$2"
  local repo_dir="$3"

  chmod -R "$perms" "$repo_dir" 2>/dev/null || true
  chown -R "$target_user:$target_user" "$repo_dir" 2>/dev/null || true
  git config --global --add safe.directory "$repo_dir" 2>/dev/null || true

  log_message "Applied permissions ($perms) and owner ($target_user) on $repo_dir" "success"
}

pull_latest_repo() {
  local repo_dir="$1"

  log_message "Updating repository at $repo_dir..." "info"
  (
    cd "$repo_dir"
    git reset --hard >/dev/null 2>&1 || true
    git pull --ff-only >/dev/null 2>&1 || true
  )

  log_message "Repository synchronized to latest commit." "success"
}

main() {
  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help

    return 0
  fi

  local perms="755"
  local target_user="${USER:-$(whoami)}"
  local is_pull="false"

  for arg in "$@"; do
    if [ "$arg" = "--pull" ] || [ "$arg" = "-p" ]; then
      is_pull="true"
    elif [[ "$arg" =~ ^[0-7]{3,4}$ ]]; then
      perms="$arg"
    elif [ -n "$arg" ] && [ "$arg" != "$perms" ]; then
      target_user="$arg"
    fi
  done

  apply_repo_permissions "$perms" "$target_user" "$_REPO_ROOT"

  if [ "$is_pull" = "true" ]; then
    pull_latest_repo "$_REPO_ROOT"
    apply_repo_permissions "$perms" "$target_user" "$_REPO_ROOT"
  fi

  return 0
}

main "$@"
