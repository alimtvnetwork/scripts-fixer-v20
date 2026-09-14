#!/usr/bin/env bash
# git-compact — CLI tool to compact and prune local git repositories
set -euo pipefail

VERSION="1.0.0"

show_help() {
  cat <<'EOF'
git-compact — Compacts and prunes local git repositories

Usage:
  git-compact [options] [path]

Options:
  --aggressive  Run aggressive garbage collection and deep repacking (default)
  --quick       Quick prune without deep repacking
  --version, -v Print version information
  --help, -h    Show this help message

Arguments:
  [path]        Path to git repository (default: current directory)
EOF
}

case "${1:-}" in
  --version|-v|-V)
    echo "git-compact $VERSION"
    exit 0
    ;;
  --help|-h)
    show_help
    exit 0
    ;;
esac

TARGET_DIR="${1:-.}"
if [ "$TARGET_DIR" = "--aggressive" ] || [ "$TARGET_DIR" = "--quick" ]; then
  TARGET_DIR="${2:-.}"
fi

if [ -d "$TARGET_DIR" ]; then
  cd "$TARGET_DIR"
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: '$(pwd)' is not a git repository." >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
REPO_NAME="$(basename "$REPO_ROOT")"
echo "Compacting git repository: $REPO_NAME ($REPO_ROOT)..."

BEFORE_SIZE=$(du -sh "$REPO_ROOT/.git" 2>/dev/null | awk '{print $1}' || echo "unknown")

git reflog expire --expire=now --all
git gc --prune=now --aggressive
git repack -a -d -l --depth=250 --window=250 2>/dev/null || true
git prune-packed 2>/dev/null || true

AFTER_SIZE=$(du -sh "$REPO_ROOT/.git" 2>/dev/null | awk '{print $1}' || echo "unknown")
echo "Repository compacted: .git size went from $BEFORE_SIZE to $AFTER_SIZE."
