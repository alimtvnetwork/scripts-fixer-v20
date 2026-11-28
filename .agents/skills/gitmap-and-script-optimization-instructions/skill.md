---
name: gitmap-and-script-optimization-instructions
description: "Autonomous workflow for executing GitMap and OS optimization scripts, restructuring legacy script hierarchies to hyphenated naming, purging misplaced binaries, fixing multi-instance Antigravity 20-day chat retention bugs, and isolating task-level heatmaps."
---

# GitMap and Script Optimization Instructions

> **Invocation:** `@[gitmap-and-script-optimization-instructions](directory;.agents/skills/gitmap-and-script-optimization-instructions)`
> **Canonical Specification:** [`02-spec/21-app/12-gitmap-and-script-optimization-instructions/01-architecture-spec.md`](file;02-spec/21-app/12-gitmap-and-script-optimization-instructions/01-architecture-spec.md)
> **Execution Runbook:** [`02-spec/21-app/12-gitmap-and-script-optimization-instructions/04-ai-execution-instructions.md`](file;02-spec/21-app/12-gitmap-and-script-optimization-instructions/04-ai-execution-instructions.md)
> **Verification Matrix:** [`02-spec/21-app/12-gitmap-and-script-optimization-instructions/03-migration-and-verification-spec.md`](file;02-spec/21-app/12-gitmap-and-script-optimization-instructions/03-migration-and-verification-spec.md)

---

## 1. Purpose & Overview

This skill equips autonomous AI operators to execute repository, OS, and script optimizations without causing data loss, terminal freezes, or broken conversation states. It provides end-to-end guidance for:
1. **Misplaced Binary Purge:** Locating and removing accidental copies of `gitmap.exe` or `Antigravity-Manager.exe` across workspace directories while strictly preserving canonical CLI installations and active build artifacts.
2. **Script Restructuring & Hyphenation:** Enforcing a clean directory structure under `01-os-optimization/` where Python files reside in `python/`, shell helpers in `scripts/`, and all script filenames use zero-padded hyphen-delimited naming (total ban on underscores).
3. **Multi-Instance Antigravity Chat 20-Day Retention:** Ensuring conversations active within the last 20 days are strictly preserved across primary and sandbox instances (`~/.gemini/antigravity`, `~/.gemini/antigravity-cli`, `~/.antigravity_tools/instances/*`).
4. **Stack Trace Hardening:** Eliminating thread reader errors (`Thread-5 (_readerthread)`) in PowerShell/Python bridges by enforcing conditional argument array passing and emitting structured stack traces.
5. **Task-Specific Heatmap Isolation:** Writing telemetry to task-specific slices (`.heatmap/tasks/<task-slug>/`) to avoid write contention on root ledger files.

---

## 2. Non-Negotiable Operational Invariants

1. **Mandatory Pre-Flight Pull:** Always run `gitmap pull` (or `git pull`) before inspecting or modifying code.
2. **Dry-Run First:** Always execute scripts with `-IsDryRun` / `--is-dry-run` prior to live modification.
3. **Chat Retention Invariant:** Conversations with user or AI activity within the past 20 days ($< 20\text{ days}$) MUST NEVER be deleted.
4. **Canonical Binary Protection:** The binary resolved by `where.exe gitmap` or located in `~/.gitmap/bin/` MUST NEVER be deleted.
5. **Zero Underscores in Script Names:** Every new or migrated script in `01-os-optimization/` must use hyphens (e.g., `01-purge-stale-chats.py`).
6. **Error Return Sovereignty:** Leaf functions must return strongly-typed errors; only top-level orchestrators exit.
7. **Coding Guidelines Adherence:** All code must conform to the 15-line limit, affirmative boolean naming (`is*`/`has*`), zero nested ifs, and centralized UTC ISO timestamps.

---

## 3. Autonomous Execution Workflow

### Step 1: Pre-Flight Environment Inspection
```powershell
# 1. Pull latest changes
gitmap pull

# 2. Inspect canonical gitmap and active tools
gitmap version
where.exe gitmap
```

### Step 2: Dry-Run Validation of Optimization Pipeline
```powershell
# Run the orchestrator in non-destructive dry-run mode
pwsh -File 01-os-optimization/run.ps1 -IsDryRun
```
*Verify that all candidates are logged and no files or SQLite rows are modified.*

### Step 3: Misplaced Binary Purge
```powershell
# 1. Scan for rogue gitmap.exe and tool binaries
python -B 01-os-optimization/python/03-purge-misplaced-binaries.py --is-dry-run

# 2. Review candidate list and execute live purge
python -B 01-os-optimization/python/03-purge-misplaced-binaries.py
```

### Step 4: Multi-Instance Chat Retention Audit & Purge
```powershell
# 1. Test retention boundary on synthetic records
pytest 01-os-optimization/python/tests/test_retention_boundary.py

# 2. Execute chat purger with 20-day cutoff in dry-run mode
python -B 01-os-optimization/python/01-purge-stale-chats.py --is-dry-run --max-age-days 20

# 3. Execute live chat purger
python -B 01-os-optimization/python/01-purge-stale-chats.py --max-age-days 20
```

### Step 5: Directory Structure & Environment Verification
```powershell
# Run structure and naming linter
pwsh -File 01-os-optimization/scripts/02-verify-environment.ps1
```

---

## 4. Troubleshooting & Fallback Matrix

| Issue / Symptom | Root Cause | Remediation |
| :--- | :--- | :--- |
| `Exception in thread Thread-5 (_readerthread)` at line 195 | Empty string argument `""` passed to python or `2>&1` pipe crash | Use conditional array splatting (`@pyArgs`) and wrap python execution in `try/catch` with `$_.ScriptStackTrace`. |
| Active chat deleted unexpectedly | Retention cutoff set to $< 20$ days or `has_ai_response` evaluated to false | Ensure `--max-age-days 20` is explicitly set and last-activity timestamp checks `MAX(updated_at, mtime)` across all conversation artifacts. |
| Canonical `gitmap.exe` reported as rogue | Binary path normalization failed on backslashes vs slashes | Normalize all paths with `.resolve()` and case-insensitive string comparison before flagging candidates. |
| Heatmap write collision during swarm | Multiple agents updating root `.heatmap/root.json` simultaneously | Route task telemetry to `.heatmap/tasks/<sequence>-<slug>/` and synchronize via `gitmap rc heatmap sync`. |
