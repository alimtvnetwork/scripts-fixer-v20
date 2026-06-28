# Cross-platform interactive picker.
# Backend preference: gum -> fzf -> numbered prompt (fallback).
# Exports: pick_one, pick_many.
#
# Usage:
#   . core/picker.sh
#   choice=$(pick_one "Select tool:" "vscode" "nodejs" "python")
#   picks=$(pick_many "Select tools:" "vscode" "nodejs" "python")  # newline-separated

__picker_backend() {
  if [ -n "${LOVABLE_PICKER:-}" ]; then echo "$LOVABLE_PICKER"; return; fi
  if command -v gum >/dev/null 2>&1; then echo gum; return; fi
  if command -v fzf >/dev/null 2>&1; then echo fzf; return; fi
  echo numbered
}

pick_one() {
  local prompt="$1"; shift
  local backend; backend=$(__picker_backend)
  case "$backend" in
    gum) printf '%s\n' "$@" | gum choose --header "$prompt" ;;
    fzf) printf '%s\n' "$@" | fzf --prompt "$prompt > " --height=40% --reverse ;;
    *)
      echo "$prompt" >&2
      local i=1
      for opt in "$@"; do printf '  %2d) %s\n' "$i" "$opt" >&2; i=$((i+1)); done
      printf 'choice: ' >&2
      local n; read -r n
      eval "printf '%s\n' \"\${$n}\""
      ;;
  esac
}

pick_many() {
  local prompt="$1"; shift
  local backend; backend=$(__picker_backend)
  case "$backend" in
    gum) printf '%s\n' "$@" | gum choose --no-limit --header "$prompt" ;;
    fzf) printf '%s\n' "$@" | fzf --multi --prompt "$prompt > " --height=40% --reverse ;;
    *)
      echo "$prompt (comma-separated numbers, ranges 1-3 ok)" >&2
      local i=1
      for opt in "$@"; do printf '  %2d) %s\n' "$i" "$opt" >&2; i=$((i+1)); done
      printf 'choice: ' >&2
      local spec; read -r spec
      local IFS=','; for tok in $spec; do
        if echo "$tok" | grep -q '-'; then
          local a=${tok%-*} b=${tok#*-}
          local j=$a; while [ "$j" -le "$b" ]; do eval "printf '%s\n' \"\${$j}\""; j=$((j+1)); done
        else
          eval "printf '%s\n' \"\${$tok}\""
        fi
      done
      ;;
  esac
}

export -f pick_one pick_many 2>/dev/null || true
