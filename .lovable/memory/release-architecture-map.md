# Release Architecture Map

## Current Release
- **Version**: 1.23.0
- **Previous Version**: 1.22.0
- **Source of Truth**: `version.json`
- **Synchronized Mirror**: `scripts/version.json`
- **Line Ending Standard**: Strict Unix LF (`\n`) enforced via `.gitattributes` (`*.sh text eol=lf`)
- **File Naming Standard**: All markdown files MUST be lowercase (`readme.md`, `changelog.md`).
- **Dynamic Readers**: `run.ps1` (PowerShell), `scripts/run.sh` (Linux Bash)

## Features in v1.23.0
- **Case Conflict Deduplication**: Ghost `CHANGELOG.md` and `README.md` removed from Git index.
- **Git Normalizer Tool**: `tools/fix-git-crlf-and-case.ps1` added for one-click working tree repair.
- **Unix LF Normalization**: Universal fix across all 479 shell scripts preventing `\r` parsing failures.
