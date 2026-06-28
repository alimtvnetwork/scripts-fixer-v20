# Lovable unified state store.
# Append-only JSONL — grep-able, atomic per-line, safe under concurrent writes
# because Linux/macOS POSIX guarantees <4 KiB writes via O_APPEND are atomic.

. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/core/.noop.sh" 2>/dev/null || true

__STATE_ROOT="${__STATE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.state}"
__STATE_LOG="${__STATE_LOG:-$__STATE_ROOT/events.jsonl}"

state_init() {
  mkdir -p "$__STATE_ROOT" 2>/dev/null || {
    echo "[STATE FAIL] cannot create $__STATE_ROOT" >&2
    return 1
  }
  touch "$__STATE_LOG" 2>/dev/null || {
    echo "[STATE FAIL] cannot write $__STATE_LOG" >&2
    return 1
  }
}

# state_emit <scriptId> <command> <outcome> [version] [method] [scriptName] [durationMs] [errorJsonOrEmpty]
state_emit() {
  state_init || return 1
  local script_id="${1:-unknown}"
  local cmd="${2:-install}"
  local outcome="${3:-ok}"
  local version="${4:-}"
  local method="${5:-}"
  local script_name="${6:-}"
  local duration_ms="${7:-0}"
  local error="${8:-}"

  local platform="linux"
  case "$(uname -s)" in Darwin) platform="macos" ;; esac

  local ts host user proj_ver
  ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  host=$(hostname 2>/dev/null || echo unknown)
  user=$(id -un 2>/dev/null || echo unknown)
  proj_ver="${__PROJECT_VERSION:-unknown}"

  # JSON-escape helper (handles \ " and control chars minimally)
  __jq_esc() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/\\n/g'; }

  local v_json="null" m_json="null" n_json="" e_json="null"
  [ -n "$version" ] && v_json="\"$(__jq_esc "$version")\""
  [ -n "$method" ]  && m_json="\"$(__jq_esc "$method")\""
  [ -n "$script_name" ] && n_json=",\"scriptName\":\"$(__jq_esc "$script_name")\""
  [ -n "$error" ]   && e_json="$error"

  printf '{"ts":"%s","scriptId":"%s","command":"%s","platform":"%s","outcome":"%s","version":%s,"method":%s,"durationMs":%s,"projectVersion":"%s","host":"%s","user":"%s","error":%s%s}\n' \
    "$ts" "$script_id" "$cmd" "$platform" "$outcome" \
    "$v_json" "$m_json" "$duration_ms" "$proj_ver" \
    "$(__jq_esc "$host")" "$(__jq_esc "$user")" "$e_json" "$n_json" \
    >> "$__STATE_LOG"
}

# state_query [--script ID] [--outcome NAME] [--last N]
state_query() {
  [ -f "$__STATE_LOG" ] || return 0
  local filter_script="" filter_outcome="" last=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --script)  filter_script="$2"; shift 2 ;;
      --outcome) filter_outcome="$2"; shift 2 ;;
      --last)    last="$2"; shift 2 ;;
      *) shift ;;
    esac
  done
  local out="$__STATE_LOG"
  [ -n "$filter_script" ]  && out=$(grep "\"scriptId\":\"$filter_script\""  "$out" || true)
  [ -n "$filter_outcome" ] && { if [ "$out" = "$__STATE_LOG" ]; then out=$(grep "\"outcome\":\"$filter_outcome\"" "$__STATE_LOG" || true); else out=$(printf '%s\n' "$out" | grep "\"outcome\":\"$filter_outcome\"" || true); fi; }
  if [ "$out" = "$__STATE_LOG" ]; then out=$(cat "$__STATE_LOG"); fi
  if [ -n "$last" ]; then printf '%s\n' "$out" | tail -n "$last"; else printf '%s\n' "$out"; fi
}

export -f state_init state_emit state_query 2>/dev/null || true
