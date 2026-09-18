# Release Architecture Map

## Current Release
- **Version**: 1.37.0
- **Source of Truth**: `version.json`
- **Synchronized Mirror**: `scripts/version.json`
- **Line Ending Standard**: Strict Unix LF (`\n`) enforced via `.gitattributes` (`*.sh text eol=lf`)
- **File Naming Standard**: All markdown files MUST be lowercase (`readme.md`, `changelog.md`).
- **Dynamic Readers**: `run.ps1` (PowerShell), `scripts/run.sh` (Linux Bash)

## Features in v1.37.0
- **Profiles**: Removed `ollama` from the `ubuntu+dev+ai` profiles entirely.
- **Preview Support**: Added `profile tree <name>` preview support to `run.ps1` and `run.sh` to preview full installation hierarchies before installing. Added install examples to help text.

## Features in v1.23.0
- **Case Conflict Deduplication**: Ghost `changelog.md` and `readme.md` removed from Git index.
- **Git Normalizer Tool**: `tools/fix-git-crlf-and-case.ps1` added for one-click working tree repair.
- **Unix LF Normalization**: Universal fix across all 479 shell scripts preventing `\r` parsing failures.
