#!/usr/bin/env bash
# scripts/shared/db.sh -- SQLite database common engine wrapper for scripts/
set -u

_DB_COMMON_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_DB_COMMON_ROOT="$(cd "$_DB_COMMON_SCRIPT_DIR/../.." && pwd)"

if [ -f "$_DB_COMMON_ROOT/scripts-linux/_shared/db.sh" ]; then
  . "$_DB_COMMON_ROOT/scripts-linux/_shared/db.sh"
fi
