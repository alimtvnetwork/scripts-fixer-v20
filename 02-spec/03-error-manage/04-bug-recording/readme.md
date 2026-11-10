# Bug Recording

. **CRITICAL AI INSTRUCTION:** This `readme.md` file is the primary entry point for this directory. AI agents MUST read this file first before exploring other files in this folder.

**Version:** 1.0.0
**Updated:** 2026-11-09
**AI Confidence:** Production-Ready (schema, pipeline, checklist) / Target (convergence gaps)
**Ambiguity:** None — gaps are listed in `03-blind-readiness-audit-spec.md`, never hidden

---

## Keywords

`bug-recording` · `bug-record` · `recorder` · `bug-sessions` · `blind-readiness` · `cli-ui-parity` · `offline-sessions` · `replay` · `bug-schema`

---

## Scoring

| Criterion | Status |
|-----------|--------|
| `readme.md` present | ✅ |
| AI Confidence assigned | ✅ |
| Ambiguity assigned | ✅ |
| Keywords present | ✅ |
| Scoring table present | ✅ |

---

## Purpose

The canonical bug-recording specification for the fleet, reverse-engineered
from the three live recorders (Antigravity-Manager bug recorder, cat-my-v12
recorder + `bin/errors-cli.py`, gitmap error recording via `appfault` +
registry). It defines one bug record shape, one capture → persist → surface
pipeline, the CLI/UI parity rule, and the blind-readiness audit that proves
a stranger can record, find, and replay a bug from the spec alone.

This folder is the **single canonical location** for bug-recording
documentation. Recorder implementations converge on it; they do not each
redefine it.

---

## Document Inventory

| # | File | Purpose |
|---|------|---------|
| 01 | [01-bug-record-schema-spec.md](./01-bug-record-schema-spec.md) | Canonical bug record schema: field table, status machine, rules, capture-path trace per repo, TARGET fields, registered `BUG` error codes |
| 02 | [02-recording-pipeline-spec.md](./02-recording-pipeline-spec.md) | Capture → persist → surface pipeline mapped to each repo; CLI/UI parity rule with the executable check; Cat-My modal defect as the worked example |
| 03 | [03-blind-readiness-audit-spec.md](./03-blind-readiness-audit-spec.md) | Blind-readiness checklist, audit results per repo (2026-11-09), gaps with dispositions and owners |
| 04 | [error-codes.json](./error-codes.json) | Machine-readable `BUG` code index (18250–18255) in the registry's per-module index format; the registry collision detector reads this file |

---

## Quick Reference

| Question | Answer (one line) |
|---|---|
| What is a bug record? | The schema in `01-bug-record-schema-spec.md` §2 — `id`, `number`, `title`, `slug`, `repo`, `status`, `severity`, timestamps, `reporter`, `environment`, `steps`, `screenshots`, `session_ref`, `offline`, plus TARGET `error_code` / `rca_ref`. |
| Where is the source of truth? | Disk/SQLite, always. The backend is enrichment and sync, never the only copy (`02-recording-pipeline-spec.md` §2.2). |
| Do CLI and UI agree? | They must: the parity rule (`02-recording-pipeline-spec.md` §3) makes any id-set delta a filed bug (code 18254). |
| Can a stranger replay it? | That is the audit (`03-blind-readiness-audit-spec.md`): `steps` + `screenshots` + `session_ref` must reproduce the bug with no questions to the reporter. |
| What if the backend is down? | Record locally first (`offline: true`), sync on reconnect, never silently stay local. |
| What if capture fails? | The failure is recorded as an error (code 18250) and reported as failure — never a fake success. |

---

## Core Principles

### 1. Disk/SQLite is the source of truth

The backend enriches and syncs; it is never the only copy. A surface that
can only show what the backend returns will lie when the backend is down
— that is the Cat-My modal defect, documented as the worked example in
`02-recording-pipeline-spec.md` §4.

### 2. Zero swallowed errors

Every caught error is resolved with structured context logging or wrapped
in `*appfault.AppError` and returned (parent folder policy). No empty
catch/except, no blank-identifier discards, no fallback defaults masking
an error. A failed capture, persist, or sync reports failure with its
registry code — never success.

### 3. No invented data

A field is REQUIRED only when at least one implementation captures it
(trace table in `01-bug-record-schema-spec.md` §3). Fields no
implementation produces are TARGET with a named owner and date. Status,
severity, repo-monotonic number, and `updated_at` are TARGET today — the
spec says so plainly instead of pretending otherwise.

### 4. IDs are stable across surfaces

The same bug via CLI (`--by-title`, `--by-slug`, `--show`) and via UI
(previous-bugs modal) shows the same `id`, `number`, and `status`. A
mismatch is a defect, not a display quirk.

---

## Cross-References

- [Parent Overview](../readme.md) — Error Management root
- [Error Architecture](../02-error-architecture/readme.md) — Cross-stack error handling, `appfault`, response envelope
- [Error Code Registry](../03-error-code-registry/readme.md) — `BUG` codes 18250–18255 live here
- [Error Resolution](../01-error-resolution/readme.md) — Debugging guides, retrospectives, verification patterns
- Parent task spec: `Antigravity-Manager: 02-spec/21-app/324-antigravity-manager-tools-synchronization-ui-improvement/spec-03-bug-recording-css-ui-seo.md`

---

## Verification

_Auto-generated section — see `02-spec/03-error-manage/97-acceptance-criteria.md` for the full criteria index (AC-BUG-001…AC-BUG-007)._

### AC-BUG-001: Bug-recording spec exists and is linked

**Given** The `04-bug-recording/` folder with its three spec files, readme, and code index.
**When** The parent folder readme categories table and `97-acceptance-criteria.md` are checked.
**Then** The folder is listed and linked from both.

**Verification command:**

```bash
ls 02-spec/03-error-manage/04-bug-recording/
```

**Expected:** `01-bug-record-schema-spec.md`, `02-recording-pipeline-spec.md`, `03-blind-readiness-audit-spec.md`, `readme.md`, `error-codes.json` all present.

_Verification section last updated: 2026-11-09_
