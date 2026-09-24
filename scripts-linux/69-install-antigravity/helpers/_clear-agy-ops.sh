#!/usr/bin/env bash
# _clear-agy-ops.sh -- Execution and resolution routines for Antigravity cleaner.
# Part of 69-install-antigravity.

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
