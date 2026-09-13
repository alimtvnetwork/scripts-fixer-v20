---
name: release-orchestrator
description: >-
  Execute full automated release orchestration, semantic version bumping, branch management, and tag creation using Python scripts.
---

# Automated Release Orchestrator & Branch Lifecycle — Release Management

## Core Rules & Version Calculation
1. Read canonical version source (`version.json` or `package.json`).
2. Default bump tier is **MINOR**: `MAJOR.MINOR.PATCH` becomes `MAJOR.(MINOR+1).0`. PATCH resets to `0`.
3. Only bump PATCH if explicitly specified.
4. Only bump MAJOR if explicitly specified.
5. State previous and new versions explicitly before touching files.

## Release Script Execution
All release operations must be executed via `03-ai-scripts/29-release-orchestrator.py`:
```bash
python 03-ai-scripts/29-release-orchestrator.py --tier <minor|patch|major> --scope "<Release summary>"
```

## Git Release Lifecycle & Invariants
1. Detect & store original branch (`git rev-parse --abbrev-ref HEAD`).
2. Bump SemVer across `version.json`, `scripts/version.json`, `package.json`, `changelog.md`, `readme.md`.
3. Stage & Commit on current branch: `release: vX.Y.Z <scope>`.
4. Create release branch: `release/vX.Y.Z` pointing to the commit.
5. Create annotated git tag: `vX.Y.Z` on that release commit.
6. Push release branch and tag to remote origin.
7. Mandatory revert back to `original_branch` in all cases (including failures).
