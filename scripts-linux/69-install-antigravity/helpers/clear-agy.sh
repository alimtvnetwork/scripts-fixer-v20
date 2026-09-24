#!/usr/bin/env bash
# Antigravity & Gemini Brain Optimizer with SQLite Conversation Pruning (Linux/macOS).
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$ROOT/.." && pwd)"
export SCRIPT_ID="69-clear"

. "$ROOT/_shared/logger.sh"
. "$ROOT/_shared/file-error.sh"
. "$SCRIPT_DIR/_clear-agy-ops.sh"
. "$SCRIPT_DIR/_clear-agy-args.sh"

IS_PREDICT=1
IS_YES=0
IS_KILL=0
IS_JSON=0
IS_LIST_BACKUPS=0
UNDO_TX=""
THRESHOLD="200"
KEEP_COUNT="0"

main() {
  parse_arguments "$@"

  local py_bin
  py_bin="$(resolve_python_binary)" || {
    log_err "[69] Python (python3 or python) is required to run Antigravity optimizer."

    exit 1
  }

  local opt_script
  opt_script="$(resolve_optimizer_script)" || {
    exit 1
  }

  if [ "$IS_LIST_BACKUPS" -eq 1 ]; then
    "$py_bin" "$opt_script" --list-backups

    exit $?
  fi

  local has_undo=0
  if [ -n "$UNDO_TX" ]; then
    has_undo=1
  fi

  if [ "$has_undo" -eq 1 ]; then
    invoke_undo_transaction "$py_bin" "$opt_script" "$UNDO_TX"

    exit $?
  fi

  if [ "$IS_PREDICT" -eq 1 ]; then
    log_info "[69] Running Antigravity Optimizer in PREDICTION mode..."
    log_info "[69] Antigravity processes will NOT be terminated."
  else
    stop_antigravity_processes "$IS_KILL"
  fi

  invoke_optimizer_execution "$py_bin" "$opt_script"

  exit $?
}

main "$@"
