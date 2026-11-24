---
name: agm-error-manager-cli
description: >-
  CLI entry for dashboard and SQLite error inspection (`agm errors` and `gitmap e|error-details`).
  Use this skill when an agent needs to read, filter, or heal errors.db without guessing commands.
---

# AGM Error Manager CLI

> **Invocation:** `@[agm-error-manager-cli](directory;.agents/skills/agm-error-manager-cli)`

Canonical inspection skill: `.agents/skills/agm-error-inspection/skill.md`.

Use these commands. Do not invent extra error domains.

## 1. AGM Error CLI Commands

```bash
agm errors list --limit 50 --json
agm errors list --severity error --json
agm errors inspect <id> --json
agm errors count
agm errors fix --dry-run --json
agm errors clear --json
```

## 2. GitMap Error Details & Diagnostic Options (Plan 112)

```bash
# View complete error details with full stack trace and cause chain
gitmap e <id>

# Export full error details to a JSON file
gitmap e <id> --export ./error-<id>.json

# View error in JSON format
gitmap e <id> --json

# View AI diagnostics with category and remediation commands
gitmap e <id> --ai

# Show untruncated details for the last 30 errors
gitmap error-details 30

# List last 30 errors grouped or filtered by types
gitmap errors --types --limit 30
```

### Paths Extraction & Suppression
- **Extracted Sources:** `SourceFile`, `RepoPath`, `InputsJson`, `ContextJson` (e.g. `filePath`, `sourceFile`, `dbPath`, `workdir`, `repoPath`).
- **Category Labels:**
  - `[Source]` (Cyan): Source code locations (`.go`, `.rs`, `.ts`, `.py`, `.js`).
  - `[Database]` (Emerald): Database paths (`.db`, `.sqlite`, `dbPath`).
  - `[Image]` (Fuchsia): Image files (`.png`, `.jpg`, `.svg`, `.webp`, `imagePath`).
  - `[Workdir]` (Indigo): Workspace root, working directories, or target repositories (`workdir`, `repoPath`).
- **Critical Suppression:** If NO paths are found, the Paths section is completely omitted.

### Reference Variables Extraction
- **Filtered Keys:** Scalar parameters from `InputsJson` and `ContextJson` excluding path keys (`filePath`, `sourceFile`, `dbPath`, `workdir`, `repoPath`).
- **Critical Suppression:** If NO reference variables exist, the section is completely omitted.

### Suggestive Commands & Interactive Pills
Error details in terminal and web visualizer (`gitmap db serve`) include suggestive navigation:
- `Next Error` (`gitmap e <id+1>`): Advance to the next sequential error.
- `Previous Error` (`gitmap e <id-1>`): Go to previous error (disabled if `ID <= 1`).
- `5 Similar by Type` (`gitmap errors --type <type> --limit 5`): Filter to 5 recent records of same type.
- `Export JSON` (`gitmap e <id> --export <path>`): Save full record to JSON file or blob download.
- `Copy CLI Command`: Copies `gitmap errors show <id>` to clipboard.

## 3. Operational Notes

- `agm errors list` reads `errors.db`.
- The GUI error drawer reads the in-memory Zustand store. Clearing `errors.db` does not clear the drawer badge.
- Codes without an `[E####]` tag are stored as `E9001`.
- `failed_to_resolve_parent` is a stale history string. Current `cmd_files` reports `invalid_path: parent directory cannot be opened`.
- `NowRunningUpNext: prompt prompt-<uuid> not found in tree` is a warning when the running strip id is missing from tree data.
