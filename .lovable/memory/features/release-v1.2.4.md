---
name: Release v1.2.4
description: Release marker for v1.2.4 -- chrome-profile-copy suite (Win+Linux), taskbar-align-left, smoke tests
type: feature
---

# Release: v1.2.4 (2026-06-19)

Pinned in:
- `scripts/version.json` -> `1.2.4`
- `version.json` -> `1.2.4`
- `readme.md` Version badge -> `v1.2.4`
- `changelog.md` -> top entry `[v1.2.4] -- 2026-06-19`

## Highlights
- `chrome-profile-copy` suite shipped for Windows (`scripts/58-install-chrome/helpers/profile-copy.ps1`) and Linux/macOS (`scripts-linux/chrome-profile-copy/profile-copy.sh`), wired into both top-level dispatchers (`run.ps1`, `scripts-linux/run.sh`). Offline-first: strips GAIA/sync bindings, SQLite ledger.
- `scripts/taskbar-align-left.ps1` + sample pinned in root readme.
- Smoke tests added under `scripts-linux/_shared/tests/`.

## Still pending after this release
- E2E verifications requiring real shells (`-Version` flag, auto-discovery redirect, 4-filter chain, Speed column alignment).

## Done post-release (in v1.2.4 line)
- Task K — Windows Pester smoke tests at `scripts/58-install-chrome/tests/profile-copy.test.ps1` (sandboxed `$env:LOCALAPPDATA`, covers copy/strip-account/Local-State-register/dry-run/export+import round-trip).
