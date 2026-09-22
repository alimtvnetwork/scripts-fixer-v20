#!/usr/bin/env bash
# Antigravity & Gemini Brain Optimizer with SQLite Conversation Pruning (Linux/macOS).
# Analyzes Antigravity conversation databases, reports heavy conversations (> 100-200 KB),
# prunes historical turns into a reversible backup database, cleans ephemeral brain artifacts,
# and supports full undo/redo capabilities.
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$ROOT/.." && pwd)"
export SCRIPT_ID="69-clear"

. "$ROOT/_shared/logger.sh"
. "$ROOT/_shared/file-error.sh"

IS_PREDICT=1
IS_YES=0
IS_KILL=0
IS_JSON=0
IS_LIST_BACKUPS=0
UNDO_TX=""
THRESHOLD="200"
KEEP_COUNT="0"

resolve_python_binary() {
  if command -v python3 >/dev/null 2>&1 && python3 -c "import sys" >/dev/null 2>&1; then
    echo "python3"

    return 0
  fi

  if command -v python >/dev/null 2>&1 && python -c "import sys" >/dev/null 2>&1; then
    echo "python"

    return 0
  fi

  return 1
}

resolve_optimizer_script() {
  local primary="$SCRIPT_DIR/agy_optimizer.py"
  local fallback="$REPO_ROOT/scripts/69-install-antigravity/helpers/agy_optimizer.py"

  if [ -f "$primary" ]; then
    echo "$primary"

    return 0
  fi

  if [ -f "$fallback" ]; then
    echo "$fallback"

    return 0
  fi

  log_file_error "$primary" "agy_optimizer.py not found in helpers or fallback"

  return 1
}

parse_arguments() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --predict|-p|--dry-run|predict)
        IS_PREDICT=1
        shift
        ;;
      --yes|-y|clean|clear)
        IS_YES=1
        IS_PREDICT=0
        shift
        ;;
      --undo)
        UNDO_TX="${2:-}"
        shift 2
        ;;
      --list-backups|list-backups|backups)
        IS_LIST_BACKUPS=1
        shift
        ;;
      --threshold|-t)
        THRESHOLD="${2:-200}"
        shift 2
        ;;
      --keep|-k)
        KEEP_COUNT="${2:-0}"
        shift 2
        ;;
      [0-9]*)
        KEEP_COUNT="$1"
        shift
        ;;
      --kill)
        IS_KILL=1
        shift
        ;;
      --json)
        IS_JSON=1
        shift
        ;;
      -h|--help)
        echo "Usage: clear-agy.sh [count] [--keep <N>] [--predict] [--yes] [--undo <tx_id>] [--threshold <KB>] [--kill] [--json]"
        echo ""
        echo "Examples:"
        echo "  clear-agy.sh --keep 10        # Predict pruning, retaining latest 10 conversations"
        echo "  clear-agy.sh 5                # Positional shorthand to retain latest 5 conversations"
        echo "  clear-agy.sh --yes --keep 10  # Apply pruning retaining latest 10 conversations"
        exit 0
        ;;
      *)
        shift
        ;;
    esac
  done
}

stop_antigravity_processes() {
  local is_kill_allowed="$1"

  if [ "$is_kill_allowed" -ne 1 ]; then
    return 0
  fi

  log_warn "[69] Terminating running Antigravity processes as requested..."
  pkill -f "antigravity" 2>/dev/null || true
  pkill -f "agy" 2>/dev/null || true
  sleep 1

  return 0
}

invoke_undo_transaction() {
  local py_bin="$1"
  local opt_script="$2"
  local tx_id="$3"

  log_info "[69] Reverting Antigravity prune transaction: $tx_id..."
  "$py_bin" "$opt_script" --undo "$tx_id"

  return $?
}

invoke_optimizer_execution() {
  local py_bin="$1"
  local opt_script="$2"
  local args=()

  if [ "$IS_PREDICT" -eq 1 ]; then
    args+=("--predict")
  else
    args+=("--yes")
  fi

  args+=("--threshold" "$THRESHOLD")

  if [ "$KEEP_COUNT" -gt 0 ] 2>/dev/null; then
    args+=("--keep" "$KEEP_COUNT")
  fi

  if [ "$IS_JSON" -eq 1 ]; then
    args+=("--json")
  fi

  "$py_bin" "$opt_script" "${args[@]}"

  return $?
}

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
