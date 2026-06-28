#!/usr/bin/env bash
# Points this clone's git hooks at .githooks/ (versioned).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
chmod +x .githooks/* 2>/dev/null || true
git config core.hooksPath .githooks
echo "[OK] core.hooksPath -> .githooks"
echo "     Hooks active: $(ls .githooks | tr '\n' ' ')"
