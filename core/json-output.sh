# --json output mode helpers.
# When LOVABLE_JSON_OUT=1, decorative output should go to stderr (or be skipped);
# the final JSON envelope goes to stdout via json_envelope.

is_json_mode() { [ "${LOVABLE_JSON_OUT:-}" = "1" ]; }

# Redirect Write-Host-equivalent decorative output away from stdout when in json mode.
# Callers use:   say "..." || true
say() {
  if is_json_mode; then printf '%s\n' "$*" >&2; else printf '%s\n' "$*"; fi
}

# json_envelope <scriptId> <command> <outcome> [version] [method] [scriptName] [durationMs]
json_envelope() {
  local script_id="${1:-unknown}"
  local cmd="${2:-install}"
  local outcome="${3:-ok}"
  local version="${4:-}"
  local method="${5:-}"
  local name="${6:-}"
  local dur="${7:-0}"
  local platform="linux"; case "$(uname -s)" in Darwin) platform="macos" ;; esac
  local ts; ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  __je() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }
  local v_json="null" m_json="null"
  [ -n "$version" ] && v_json="\"$(__je "$version")\""
  [ -n "$method" ]  && m_json="\"$(__je "$method")\""

  printf '{"schemaVersion":"1.0","scriptId":"%s","scriptName":"%s","command":"%s","platform":"%s","shell":"bash","outcome":"%s","version":%s,"method":%s,"finishedAt":"%s","durationMs":%s,"projectVersion":"%s"}\n' \
    "$script_id" "$(__je "$name")" "$cmd" "$platform" "$outcome" "$v_json" "$m_json" "$ts" "$dur" "${__PROJECT_VERSION:-unknown}"
}

export -f is_json_mode say json_envelope 2>/dev/null || true
