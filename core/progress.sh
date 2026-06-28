# Cross-platform progress + ETA wrapper.
# Prefers `pv` when piping bytes; otherwise prints a manual progress line with ETA.
# Honors LOVABLE_JSON_OUT (silent in JSON mode).

__PROGRESS_START_TS=""
__PROGRESS_LABEL=""

progress_start() {
  __PROGRESS_LABEL="${1:-Working}"
  __PROGRESS_START_TS=$(date +%s)
}

# progress_step <percent 0-100> [status]
progress_step() {
  [ "${LOVABLE_JSON_OUT:-}" = "1" ] && return 0
  local pct="${1:-0}"
  local status="${2:-}"
  local now eta_sec total elapsed remaining
  now=$(date +%s)
  elapsed=$(( now - ${__PROGRESS_START_TS:-$now} ))
  if [ "$pct" -gt 0 ] && [ "$pct" -lt 100 ]; then
    total=$(( elapsed * 100 / pct ))
    remaining=$(( total - elapsed ))
    eta_sec=$(printf '%02d:%02d' $((remaining/60)) $((remaining%60)))
  elif [ "$pct" -ge 100 ]; then
    eta_sec="00:00"
  else
    eta_sec="--:--"
  fi
  printf '\r  [%-30s] %3d%%  ETA %s  %s' \
    "$(printf '#%.0s' $(seq 1 $((pct*30/100)) 2>/dev/null))" \
    "$pct" "$eta_sec" "$status"
}

progress_done() {
  [ "${LOVABLE_JSON_OUT:-}" = "1" ] && return 0
  printf '\n'
  __PROGRESS_START_TS=""
}

# pv_pipe <label> <expected_bytes>  -- usage: curl URL | pv_pipe "file" 12345 > out
pv_pipe() {
  local label="$1" size="${2:-0}"
  if command -v pv >/dev/null 2>&1; then
    if [ "$size" -gt 0 ]; then pv -N "$label" -s "$size"; else pv -N "$label"; fi
  else
    cat
  fi
}

export -f progress_start progress_step progress_done pv_pipe 2>/dev/null || true
