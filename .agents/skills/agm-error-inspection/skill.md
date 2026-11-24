---
name: agm-error-inspection
description: >-
  Inspect, diagnose, filter, and heal application errors from the SQLite speed error database (errors.db) using AGM and GitMap CLI commands.
---

# AGM Error Inspection & Self-Healing Skill (`agm-error-inspection`)

> **Invocation:** `@[agm-error-inspection](directory;.agents/skills/agm-error-inspection)`

This skill provides autonomous CLI diagnostics, querying, filtering, and self-healing for errors tracked in the Antigravity Manager SQLite speed error database (`errors.db`) and the GitMap error store.

## 1. Primary CLI Commands & Usage

All AGM error commands are accessed via the `agm errors` domain (aliases: `agm error`, `agm err`).

### List Recent Errors
```bash
# View the most recent 20 errors in formatted table output
agm errors

# View recent errors with a custom limit
agm errors list --limit 50

# Filter errors by severity level ('error', 'warn', 'info')
agm errors list --severity error

# Search errors by message keyword or error code
agm errors list "database locked"
agm errors list E9001

# Output errors in machine-readable JSON format for AI parsing
agm errors list --json
agm errors list --severity error --limit 10 --json
```

### Inspect Specific Error Record by ID
```bash
# View full error record with stack trace and metadata by ID
agm errors inspect e3b0c442-98fc-1c14-9afb-4c8996fb9242

# View inspection details in machine-readable JSON
agm errors inspect e3b0c442-98fc-1c14-9afb-4c8996fb9242 --json
```

### Display Error Metrics
```bash
# Display total count of recorded errors grouped by severity
agm errors count
```

### Automated Self-Healing & Diagnostics
```bash
# Inspect system anomalies without applying changes (dry run)
agm errors fix --dry-run

# Run automated self-healing to resolve stale file locks, WAL anomalies, and permissions
agm errors fix

# Run self-healing and return structured JSON diagnostic report
agm errors fix --json
```

### Purge Error Database
```bash
# Clear recorded error history from errors.db
agm errors clear

# Clear history with JSON confirmation
agm errors clear --json
```

---

## 2. GitMap Error Details & Suggestive Commands (Plan 112)

GitMap provides enhanced error inspection via `gitmap e` (alias: `gitmap errors show`), `gitmap error-details`, and the embedded REST visualizer (`gitmap db serve`).

### Detailed Inspection & Suggestive Flags
```bash
# Inspect error details with full stack trace, cause chain, paths, and variables
gitmap e <id>

# Export complete error details to a JSON file (creates parent directories)
gitmap e <id> --export ./error-<id>.json
gitmap e <id> --export <path>

# Emit full error record in machine-readable JSON
gitmap e <id> --json

# Display AI Understanding & Diagnostics block with root cause and remediation
gitmap e <id> --ai

# Show untruncated details (stack trace + cause chain) for the last 30 errors
gitmap error-details 30

# Show last 30 errors filtered by error types or type overview
gitmap errors --types --limit 30
gitmap errors --type DbQueryError --limit 30
```

### Paths Section Behavior
- **Extraction Sources:** Checks `SourceFile`, `RepoPath`, `InputsJson`, and `ContextJson` (e.g. `filePath`, `sourceFile`, `dbPath`, `workdir`, `repoPath`).
- **Category Labels:**
  - `[Source]` (Cyan): Source code locations (`.go`, `.rs`, `.ts`, `.py`, `.js`).
  - `[Database]` (Emerald): SQLite database files (`.db`, `.sqlite`, `dbPath`).
  - `[Image]` (Fuchsia): Image files (`.png`, `.jpg`, `.svg`, `.webp`, `imagePath`).
  - `[Workdir]` (Indigo): Workspace root, working directories, or target repositories (`workdir`, `repoPath`).
- **Conditional Rule (Critical):** If NO path is found across any field, the Paths section is **strictly suppressed** (never rendered or printed).

### Reference Variables Section Behavior
- **Extraction:** Parses `InputsJson` and `ContextJson` as JSON/JS objects.
- **Path Key Filtering:** Automatically filters out path keys (`filePath`, `sourceFile`, `dbPath`, `workdir`, `repoPath`) to prevent duplication with the Paths section.
- **Rendering:** Remaining scalar key-values, parameters, and calculation metrics are rendered in a clean monospace table/grid.
- **Conditional Rule (Critical):** If NO variables exist after filtering, the Reference Variables section is **strictly suppressed** (never rendered or printed).

### Suggestive Actions & Commands Behavior
At the bottom of error details (terminal and visualizer modal), suggestive action buttons/pills allow rapid navigation:
- `Next Error` (`gitmap e <id+1>`): Loads next sequential error record.
- `Previous Error` (`gitmap e <id-1>`): Loads previous record (disabled when `ID <= 1`).
- `5 Similar by Type` (`gitmap errors --type <type> --limit 5`): Filters error grid or terminal list to matching error type.
- `Export JSON` (`gitmap e <id> --export <path>`): Downloads or saves `error-<id>.json`.
- `Copy CLI Command`: Copies `gitmap errors show <id>` to clipboard.

---

## 3. JSON Response Contract

When querying with `--json`, the output conforms to `Vec<ErrorRecord>`:

```json
[
  {
    "id": "e3b0c442-98fc-1c14-9afb-4c8996fb9242",
    "error_code": "E9001",
    "severity": "error",
    "message": "Failed to parse conversation transcript",
    "stack_trace": "Error: Failed to parse\n    at parseTranscript (src/modules/repo_db/transcript.rs:420)",
    "source": "transcript_reader",
    "trigger_action": "read_prompt_turn",
    "metadata_json": "{\"cid\":\"conv-123\",\"path\":\"transcript.jsonl\"}",
    "created_at": 1729780800000
  }
]
```

---

## 4. Best Practices for AI Agents

1. **Check Errors on Failures:** When an operation in the GUI or background task reports an anomaly, run `agm errors list --limit 5 --severity error --json` or `gitmap error-details 5` to diagnose the root cause without guessing.
2. **Use AI Diagnostics:** Run `gitmap e <id> --ai` to get instant root cause classification and recommended fix commands.
3. **Export Records for Audits:** Use `gitmap e <id> --export ./error-<id>.json` when capturing error artifacts for retrospectives or issue tracking.
4. **Run Self-Healing Before Retrying:** If an error indicates a locked SQLite database or stale process lockfile, run `agm errors fix` to trigger the automated repair ladder before re-attempting the command.
5. **Purge After Verification:** After verifying a series of surgical fixes, clear the error database via `agm errors clear` so subsequent test runs start with a clean diagnostic baseline.
