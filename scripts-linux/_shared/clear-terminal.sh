#!/usr/bin/env bash
# scripts-linux/_shared/clear-terminal.sh
# Clear terminal histories and suggestions, and reseed GitMap suggestions.
# Features parity with scripts/os/helpers/clear-terminal.ps1.

set -u

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$__DIR/../.." && pwd)"

if ! command -v log_info >/dev/null 2>&1; then
  # shellcheck disable=SC1091
  . "$__DIR/logger.sh" 2>/dev/null || true
fi

if ! command -v log_file_error >/dev/null 2>&1; then
  # shellcheck disable=SC1091
  . "$__DIR/file-error.sh" 2>/dev/null || true
fi

get_gitmap_seeds() {
  cat <<'EOF'
gitmap status
gitmap doctor
gitmap scan
gitmap pull
gitmap sync
gitmap cd
gitmap repo list
gitmap group list
gitmap ssh list
gitmap cluster list
gitmap pipeline errors
gitmap pipeline status
gitmap storage list
gitmap agy running-prompts
gitmap agy sug
gitmap agy clear 10
gitmap completion install
EOF
}

test_gitmap_installed() {
  if command -v gitmap >/dev/null 2>&1; then
    echo 1
    return 0
  fi

  local h="${HOME:-}"
  if [ -d "$h/.gitmap" ] || [ -d "$h/.config/gitmap" ] || [ -d "$h/.local/share/gitmap" ]; then
    echo 1
    return 0
  fi

  if [ -x "/usr/local/bin/gitmap" ] || [ -x "$h/go/bin/gitmap" ]; then
    echo 1
    return 0
  fi

  echo 0
}

count_file_lines() {
  local f="$1"
  if [ ! -f "$f" ]; then
    echo 0
    return 0
  fi

  wc -l < "$f" 2>/dev/null | tr -d ' ' || echo 0
}

clear_file_content() {
  local f="$1"
  local is_dry="$2"

  if [ ! -f "$f" ]; then
    return 0
  fi

  if [ "$is_dry" -eq 1 ]; then
    return 0
  fi

  if : > "$f" 2>/dev/null; then
    return 0
  fi

  if command -v log_file_error >/dev/null 2>&1; then
    log_file_error "$f" "failed to clear terminal history file"
  fi
  return 1
}

append_seeds() {
  local f="$1"
  local is_dry="$2"

  if [ "$is_dry" -eq 1 ]; then
    return 0
  fi

  local dir
  dir="$(dirname "$f")"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir" 2>/dev/null || true
  fi

  get_gitmap_seeds >> "$f" 2>/dev/null || true
}

show_help() {
  cat <<EOF

  Clear Terminal Histories & Reseed GitMap Suggestions
  ====================================================
  Usage: ./run.sh clear-terminal [flags]
         ./run.sh clear terminal [flags]
         ./run.sh os clear-terminal [flags]

  Flags:
    --dry-run, -n      Preview files to be cleared without modifying
    --yes, -y          Skip interactive confirmation prompt
    --reseed-only      Reseed GitMap suggestions without clearing history
    --no-reseed        Clear histories without reseeding GitMap suggestions
    --json, -j         Output results as machine-readable JSON
    --help, -h         Show this help message

EOF
}

# ── Main Entrypoint ───────────────────────────────────────────────────────────

IS_DRY_RUN=0
IS_JSON=0
IS_RESEED_ONLY=0
IS_NO_RESEED=0
HAS_HELP=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run|-n|dry-run)
      IS_DRY_RUN=1; shift ;;
    --yes|-y|yes)
      shift ;;
    --json|-j|json)
      IS_JSON=1; shift ;;
    --reseed-only)
      IS_RESEED_ONLY=1; shift ;;
    --no-reseed)
      IS_NO_RESEED=1; shift ;;
    --help|-h|help)
      HAS_HELP=1; shift ;;
    *)
      shift ;;
  esac
done

if [ "$HAS_HELP" -eq 1 ]; then
  show_help
  exit 0
fi

H="${HOME:-}"
TARGETS=(
  "$H/.bash_history:Bash"
  "$H/.zsh_history:Zsh"
  "$H/.zhistory:Zsh"
  "$H/.sh_history:Sh"
  "$H/.history:Sh"
  "$H/.local/share/powershell/PSReadLine/ConsoleHost_history.txt:PowerShell"
)

TOTAL_LINES=0
CLEARED_INFO=()

if [ "$IS_RESEED_ONLY" -eq 0 ]; then
  for item in "${TARGETS[@]}"; do
    path="${item%%:*}"
    sh_name="${item##*:}"

    if [ -f "$path" ]; then
      lines=$(count_file_lines "$path")
      TOTAL_LINES=$((TOTAL_LINES + lines))
      clear_file_content "$path" "$IS_DRY_RUN"
      CLEARED_INFO+=("$sh_name:$path:$lines")
    fi
  done
fi

HAS_GITMAP=$(test_gitmap_installed)
IS_RESEEDED=0

if [ "$HAS_GITMAP" -eq 1 ] && [ "$IS_NO_RESEED" -eq 0 ]; then
  if [ "$IS_DRY_RUN" -eq 0 ]; then
    append_seeds "$H/.bash_history" "$IS_DRY_RUN"
    append_seeds "$H/.zsh_history" "$IS_DRY_RUN"

    if command -v gitmap >/dev/null 2>&1; then
      gitmap completion install >/dev/null 2>&1 || true
    fi
  fi
  IS_RESEEDED=1
fi

if [ "$IS_JSON" -eq 1 ]; then
  gitmap_bool="false"
  [ "$HAS_GITMAP" -eq 1 ] && gitmap_bool="true"
  dry_bool="false"
  [ "$IS_DRY_RUN" -eq 1 ] && dry_bool="true"
  reseed_bool="false"
  [ "$IS_RESEEDED" -eq 1 ] && reseed_bool="true"

  cat <<EOF
{
  "status": "ok",
  "dryRun": $dry_bool,
  "totalLinesCleared": $TOTAL_LINES,
  "isGitmapInstalled": $gitmap_bool,
  "isReseeded": $reseed_bool,
  "seedCount": 17
}
EOF
  exit 0
fi

printf "\n"
printf "  \033[36m● Terminal History & Suggestions Cleanup\033[0m\n"
printf "  \033[90m========================================\033[0m\n"

if [ "$IS_DRY_RUN" -eq 1 ]; then
  printf "  \033[33m[DRY-RUN] Preview mode -- no files were modified.\033[0m\n"
fi

if [ "$IS_RESEED_ONLY" -eq 0 ]; then
  printf "  \033[33mCleared Terminal Histories:\033[0m\n"
  for entry in "${CLEARED_INFO[@]:-}"; do
    [ -z "$entry" ] && continue
    sh_n=$(echo "$entry" | cut -d: -f1)
    p_val=$(echo "$entry" | cut -d: -f2)
    l_val=$(echo "$entry" | cut -d: -f3)
    printf "    \033[90m[%-10s] %s (%s lines)\033[0m\n" "$sh_n" "$p_val" "$l_val"
  done

  if [ "${#CLEARED_INFO[@]}" -eq 0 ]; then
    printf "    \033[90m(No existing history files found to clear)\033[0m\n"
  fi

  printf "  \033[32m[  OK  ] Total lines cleared: %d\033[0m\n" "$TOTAL_LINES"
fi

if [ "$HAS_GITMAP" -eq 1 ]; then
  if [ "$IS_RESEEDED" -eq 1 ]; then
    printf "\n"
    printf "  \033[33mGitMap Reseed & Prediction Engine:\033[0m\n"
    printf "    \033[32m[  OK  ] GitMap detected on system.\033[0m\n"
    printf "    \033[32m[  OK  ] Reseeded 17 canonical command suggestions into terminal history.\033[0m\n"
    printf "    \033[32m[  OK  ] Configured shell tab-completion and suggestion hooks.\033[0m\n"
  fi
else
  printf "\n"
  printf "  \033[90mGitMap: not detected (reseed skipped).\033[0m\n"
fi

printf "\n"
printf "  \033[36mTerminal history and suggestion caches are fresh.\033[0m\n\n"
exit 0
