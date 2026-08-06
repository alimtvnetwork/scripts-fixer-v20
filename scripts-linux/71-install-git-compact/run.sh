#!/usr/bin/env bash
# 71-install-git-compact -- git-compact CLI (curl one-liner from alimtvnetwork/git-compact)
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export SCRIPT_ID="71"
. "$ROOT/_shared/logger.sh"
. "$ROOT/_shared/pkg-detect.sh"
. "$ROOT/_shared/file-error.sh"
. "$ROOT/_shared/install-paths.sh"

CONFIG="$SCRIPT_DIR/config.json"
[ -f "$CONFIG" ] || { log_file_error "$CONFIG" "config.json missing for 71-install-git-compact"; exit 1; }

show_help() {
  cat <<'EOF'
git-compact installer (script 71)

Usage:
  ./run.sh [install|check|repair|uninstall] [--tag <ref>] [--help]

Commands:
  install     Install the git-compact CLI (default)
  check       Verify the installed binary responds to --version
  repair      Remove the binary and reinstall from scratch
  uninstall   Remove the binary and its install marker

Flags:
  --tag <ref> Pin a git ref (branch / tag / commit) on alimtvnetwork/git-compact.
              Numeric values like 1.2.0 are normalised to v1.2.0. Default: main.
  --help      Show this help text and exit.

Environment:
  GIT_COMPACT_TAG   Same as --tag, lower precedence than the flag.

Examples:
  ./run.sh install
  ./run.sh install --tag v1.2.0
  ./run.sh check
  ./run.sh uninstall
  curl -fsSL https://raw.githubusercontent.com/alimtvnetwork/git-compact/main/install.sh | sh
EOF
}

# ---------------------------------------------------------------------------
# Resolve effective git ref (branch / tag / commit)
# Precedence:  --tag flag  >  $GIT_COMPACT_TAG env  >  config install.releaseTag
#              >  hard default "main".
# ---------------------------------------------------------------------------
TAG_FLAG=""
ARGS=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --tag)          TAG_FLAG="${2:-}"; shift 2 ;;
    --tag=*)        TAG_FLAG="${1#--tag=}"; shift ;;
    --help|-h)      show_help; exit 0 ;;
    *)              ARGS+=("$1"); shift ;;
  esac
done
set -- "${ARGS[@]+"${ARGS[@]}"}"

CONFIG_TAG="$(grep -oE '"releaseTag"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG" 2>/dev/null | sed -E 's/.*"([^"]+)"$/\1/' | head -n1)"
CONFIG_URL_TEMPLATE="$(grep -oE '"installUrl"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG" 2>/dev/null | sed -E 's/.*"([^"]+)"$/\1/' | head -n1)"

EFFECTIVE_TAG="${TAG_FLAG:-${GIT_COMPACT_TAG:-${CONFIG_TAG:-main}}}"
case "$EFFECTIVE_TAG" in
  [0-9]*) EFFECTIVE_TAG="v${EFFECTIVE_TAG}" ;;
esac

URL_TEMPLATE="${CONFIG_URL_TEMPLATE:-https://raw.githubusercontent.com/alimtvnetwork/git-compact/{tag}/install.sh}"
INSTALL_URL="${URL_TEMPLATE//\{tag\}/$EFFECTIVE_TAG}"

log_info "[71] git-compact ref: $EFFECTIVE_TAG"
log_info "[71] resolved install URL: $INSTALL_URL"

BIN_DIR="${HOME}/.local/bin"
DEST="$BIN_DIR/git-compact"
INSTALLED_MARK="$ROOT/.installed/71.ok"

verify_installed() { command -v git-compact >/dev/null 2>&1 || [ -x "$DEST" ]; }

# ---------------------------------------------------------------------------
# assert_version -- authoritative post-install check. Logs the resolved binary
# path plus the printed version, or an explicit file-error with exact path and
# reason on failure.
# ---------------------------------------------------------------------------
assert_version() {
  log_info "[71] Verifying 'git-compact --version' works in current session..."

  local bin=""
  if command -v git-compact >/dev/null 2>&1; then
    bin="$(command -v git-compact)"
  elif [ -x "$DEST" ]; then
    bin="$DEST"
    log_warn "[71] git-compact not on PATH; falling back to $DEST"
  else
    log_file_error "$DEST" "git-compact binary not found on PATH and not present at \$DEST after install"
    return 1
  fi

  local out rc
  out="$("$bin" --version 2>&1)"
  rc=$?
  if [ "$rc" -ne 0 ] || [ -z "$out" ]; then
    log_file_error "$bin" "'git-compact --version' exited code=$rc output=${out:-<empty>}"
    return 1
  fi

  log_ok   "[71] Verified: git-compact --version -> $out"
  log_info "[71] git-compact binary path: $bin"
  return 0
}

verb_install() {
  write_install_paths \
    --tool   "git-compact" \
    --source "$INSTALL_URL (curl | sh)" \
    --temp   "${TMPDIR:-/tmp}/scripts-fixer/git-compact" \
    --target "$DEST"

  log_info "[71] Starting git-compact installer"
  if verify_installed; then
    log_ok "[71] Already installed"
    if assert_version; then
      mkdir -p "$ROOT/.installed"; touch "$INSTALLED_MARK"; return 0
    fi
    log_warn "[71] Binary present but version check failed; continuing to reinstall"
  fi

  if ! command -v git >/dev/null 2>&1; then
    log_file_error "(git)" "git not found; git-compact requires git on PATH"
    return 1
  fi

  if ! command -v curl >/dev/null 2>&1; then
    log_file_error "(curl)" "curl not found; cannot run git-compact install one-liner"
    return 1
  fi

  mkdir -p "$BIN_DIR" || { log_file_error "$BIN_DIR" "bin dir mkdir failed"; return 1; }

  # Disk-space preflight: require >=200 MB free on the target filesystem.
  if command -v df >/dev/null 2>&1; then
    free_kb=$(df -Pk "$BIN_DIR" 2>/dev/null | awk 'NR==2 {print $4}')
    need_kb=$((200 * 1024))
    if [ -n "${free_kb:-}" ] && [ "$free_kb" -lt "$need_kb" ]; then
      log_file_error "$BIN_DIR" "Insufficient disk space: $((free_kb / 1024)) MB free, 200 MB required"
      return 1
    fi
    log_info "[71] Disk space OK on $BIN_DIR ($((free_kb / 1024)) MB free, 200 MB required)"
  fi

  log_info "[71] Invoking: curl -fsSL $INSTALL_URL | sh -s -- --dir \"$BIN_DIR\""
  if ! curl -fsSL "$INSTALL_URL" | sh -s -- --dir "$BIN_DIR"; then
    log_file_error "$INSTALL_URL" "curl | sh one-liner exited non-zero (dir=$BIN_DIR)"
    return 1
  fi

  case ":$PATH:" in *":$BIN_DIR:"*) ;; *) export PATH="$BIN_DIR:$PATH" ;; esac

  if assert_version; then
    mkdir -p "$ROOT/.installed"; touch "$INSTALLED_MARK"; return 0
  fi
  log_warn "[71] Verify FAILED after install (binary not on PATH or --version failed; check $DEST)"
  return 1
}

verb_check() {
  if assert_version; then return 0; fi
  log_warn "[71] Verify FAILED"
  return 1
}
verb_repair()    { rm -f "$DEST" "$INSTALLED_MARK"; verb_install; }
verb_uninstall() {
  rm -f "$DEST" || log_file_error "$DEST" "removal failed"
  rm -f "$INSTALLED_MARK"
  log_ok "[71] Removed git-compact"
}

case "${1:-install}" in
  install)        verb_install ;;
  check)          verb_check ;;
  repair)         verb_repair ;;
  uninstall)      verb_uninstall ;;
  help|--help|-h) show_help ;;
  *) log_err "[71] Unknown verb: $1 (try --help)"; exit 2 ;;
esac
