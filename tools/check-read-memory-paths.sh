#!/usr/bin/env bash
# Verifies every file/folder referenced by Phases 1-4 of
# .lovable/prompts/01-read-prompt.md actually exists.
# Exits 1 on the first missing path, printing the exact path + phase.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FAIL=0
red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
cyan()  { printf '\033[36m%s\033[0m\n' "$*"; }

check() {
  local phase="$1" kind="$2" path="$3"
  if [[ "$kind" == "file" && -f "$path" ]]; then
    green "  [OK]   $phase  file  $path"
  elif [[ "$kind" == "dir"  && -d "$path" ]]; then
    green "  [OK]   $phase  dir   $path"
  else
    red   "  [FAIL] $phase  $kind  MISSING: $path"
    FAIL=$((FAIL+1))
  fi
}

cyan "== Phase 1 - AI Context Layer =="
check P1 file .lovable/overview.md
check P1 file .lovable/what-to-read.md
check P1 file .lovable/strictly-avoid.md
check P1 file .lovable/memory/index.md
check P1 file .lovable/plan.md
check P1 file .lovable/suggestions.md
check P1 file .lovable/cicd-index.md
check P1 dir  .lovable/memory
check P1 dir  .lovable/memory/constraints
check P1 dir  .lovable/memory/features
check P1 dir  .lovable/memory/preferences
check P1 dir  .lovable/memory/specs
check P1 dir  .lovable/memory/workflow
check P1 dir  .lovable/cicd-issues

cyan "== Phase 2 - Consolidated Guidelines (repo-specific) =="
check P2 dir  spec/error-management
check P2 file spec/error-management/powershell-error-management.md
check P2 file spec/error-management/gap-audit.md
check P2 dir  spec/shared
for f in logging install-paths admin-check fast-download tool-version \
         registry-backup symlink-utils invoke-with-timeout ensure-summary \
         tool-version-parsers; do
  check P2 file "spec/shared/${f}.md"
done
check P2 file .lovable/memory/constraints/strictly-prohibited.md

cyan "== Phase 3 - Spec Authoring Rules =="
check P3 dir  spec/00-spec-writing-guide
check P3 file spec/00-spec-writing-guide/readme.md

cyan "== Phase 4 - Deep-Dive Source Specs =="
for d in \
  spec/00-generic-install-script-behavior \
  spec/root-dispatcher \
  spec/install-bootstrap \
  spec/doctor \
  spec/release-pipeline \
  spec/bump-version \
  spec/68-user-mgmt \
  spec/52-vscode-folder-repair \
  spec/58-install-chrome \
  spec/chrome-fix-ai \
  spec/02-app-issues \
  spec/2025-batch \
  spec/ci-cd \
  spec/models \
  spec/kimodo \
  spec/databases; do
  check P4 dir "$d"
done

echo
if [[ $FAIL -eq 0 ]]; then
  green "All read-memory paths present."
  exit 0
else
  red "$FAIL missing path(s). Fix or update .lovable/prompts/01-read-prompt.md."
  exit 1
fi
