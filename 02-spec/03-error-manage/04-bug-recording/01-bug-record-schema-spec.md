# Bug Record Schema Spec (Canonical)

**Folder:** `02-spec/03-error-manage/04-bug-recording/`
**Task:** 324 antigravity-manager-tools-synchronization-ui-improvement
**Spec:** `Antigravity-Manager: 02-spec/21-app/324-antigravity-manager-tools-synchronization-ui-improvement/spec-03-bug-recording-css-ui-seo.md` §2.3
**Status:** Canonical target — all three recorders converge on this schema
**Version:** 1.0.0
**Updated:** 2026-11-09
**AI Confidence:** Production-Ready (schema) / Target (convergence)
**Ambiguity:** None — gaps are listed in `03-blind-readiness-audit-spec.md`, never hidden

---

## 1. Purpose

One bug record shape for every repo in the fleet. A bug recorded in
Antigravity-Manager, cat-my-v12, or gitmap-v28 must be findable, replayable,
and comparable from any surface (CLI or UI) without knowing which tool
recorded it. This document is the target all three recorders converge on;
it is not a description of what any one of them does today. Where current
behaviour falls short, the gap is named in §5 and dispositioned in the
blind-readiness audit (`03-blind-readiness-audit-spec.md`).

## 2. Schema

### 2.1 Field table

| Field | Required? | Meaning |
|---|---|---|
| `id` | REQUIRED | Stable unique identifier, never reused. Format: repo-scoped slug + sequence (e.g. `BUG-41-05` style per repo convention). |
| `number` | REQUIRED | Human-visible bug number shown in UI badges (AGM bug-number badge). Monotonic per repo. |
| `title` | REQUIRED | One line, what broke, in the user's words where possible. |
| `slug` | REQUIRED | URL/file-safe slug derived from the title; the CLI `--by-slug` lookup key. |
| `repo` | REQUIRED | Owning repo (`Antigravity-Manager`, `gitmap-v28`, `cat-my-v12`, …). |
| `status` | REQUIRED | One of `recorded`, `triaged`, `in-progress`, `fixed`, `verified`, `closed`, `reopened`. Transitions are append-only history, never in-place rewrites. |
| `severity` | REQUIRED | One of `critical`, `major`, `minor`, `cosmetic`. |
| `created_at` / `updated_at` | REQUIRED | UTC timestamps; `created_at` is immutable. |
| `reporter` | REQUIRED | Who/what recorded it (user, agent id, or `cli`/`ui`/`auto`). |
| `environment` | REQUIRED | App version, machine, instance id, OS. Without this a bug is not replayable. |
| `steps` | REQUIRED | Ordered reproduction steps. Each step: `order`, `action` (what was done), `detail` (enriched context), `target` (XPath root / DOM selector where applicable), `screenshot_ref` (nullable). |
| `screenshots` | REQUIRED | Authentic DOM captures (never mock/stock images). SVG content is sanitized before storage. Each entry: `path`, `captured_at`, `step_order`. |
| `session_ref` | REQUIRED | Recording/session that produced the bug (Cat-My `--recording` / `--session`; AGM recorder session). Nullable only for hand-filed bugs, with the reason recorded. |
| `error_code` | TARGET | Registered code from the error-code registry, when the bug maps to one. |
| `rca_ref` | TARGET | Link to the root-cause analysis (`.ai-memory/issues/` or spec RCA section) once written. |
| `offline` | REQUIRED | `true` when recorded while the backend was unreachable (Cat-My `cat:recorder:offline_sessions` path); offline records MUST sync on reconnect, never silently stay local. |

### 2.2 Status machine

```
recorded → triaged → in-progress → fixed → verified → closed
   ↑_______________ reopened (from fixed, verified, or closed) _______________|
```

- Every transition appends a history entry (`from`, `to`, `at`, `by`,
  `reason`); the current `status` is derived from the latest entry, never
  edited in place.
- `reopened` is a transition target, not a terminal state: a reopened bug
  returns to `triaged` once it is picked up again.
- Any status value found in the wild that is not one of the seven above is
  a defect against the surfacing layer: it maps to `recorded` for display
  and is filed as a bug with a spec cross-reference. No wild status is
  silently displayed as if it were canonical.

### 2.3 Rules

- **IDs are stable across surfaces.** The same bug reached via CLI
  (`--by-title`, `--by-slug`, `--show`) and via UI (previous-bugs modal)
  must show the same `id`, `number`, and `status`. A mismatch is a defect,
  not a display quirk.
- **Steps are replayable.** A step without an `action` and a `target` (or an
  explicit "no target — describe why") fails the blind-readiness audit.
- **Screenshots are evidence, not decoration.** Every screenshot must be
  traceable to the step and session that produced it; a screenshot with no
  `captured_at` or no `step_order` is untrusted and flagged by the audit.
- **No invented data.** A field is only REQUIRED when at least one
  implementation already captures it (see the trace table in §3); a field
  no implementation produces is TARGET with a named owner and date, never
  presented as if it already exists.

## 3. Capture-path trace (REQUIRED fields → real code)

Every REQUIRED field traces to at least a partial capture path. "Partial"
is stated explicitly where the current capture does not yet meet the full
definition — the audit dispositions each partial as a convergence gap.

| Field | Antigravity-Manager | cat-my-v12 | gitmap-v28 |
|---|---|---|---|
| `id` | `src/lib/recorder/types.ts:73` (`RecorderSession.id`); `src/stores/recorder-store.ts:66` (`rec-<base36>-<rand>`) | `src/lib/recorder/recorder-sqlite-repository.ts:14-16` (`BugSessionItem.sessionId`, `bugSessionId`) | No bug-session recorder; error records carry appfault codes, not bug ids — TARGET, owner gitmap-v28 repo chat, 2026-11-09 |
| `number` | PARTIAL — `src/stores/recorder-store.ts:67,71` (`bugSeq` `NN-bug`, a per-session sequence, not a repo-monotonic bug number); badge shown per 323 spec §3.1 | GAP — no human-visible bug number; `--recent-bugs` lists `session_id` only (`bin/errors-cli.py:1135-1147`) | No bug number — TARGET, owner gitmap-v28 repo chat, 2026-11-09 |
| `title` | `src/lib/recorder/types.ts:60-66` (`BugReportSummary.title`) | `src/lib/recorder/recorder-sqlite-repository.ts:16` (`BugSessionItem.title`); `--by-title` (`bin/errors-cli.py:21`) | Error titles exist in appfault records, not bug titles — TARGET |
| `slug` | `src/stores/recorder-store.ts:71,394,408` (`slug: bugSeq`, renameable inline) | `task.db` `Slug` column + disk `summary.slug` (`bin/errors-cli.py:21`); `--by-slug` (`bin/errors-cli.py:4332`) | No slug — TARGET |
| `repo` | Inherent — the recorder runs inside AGM | Inherent — the recorder runs inside cat-my-v12 | Inherent — error records carry the tool name |
| `status` | GAP — `RecorderSession` (`src/lib/recorder/types.ts:73-91`) has no status field | GAP — `BugSessionItem` has `isArchived` only, no status | GAP — no bug records — TARGET, owners per repo, 2026-11-09 |
| `severity` | GAP — no severity on sessions | GAP — `--level` (`error`/`warn`/`info`) classifies errors, not bug severity | GAP — TARGET, owners per repo, 2026-11-09 |
| `created_at` | `src/lib/recorder/types.ts:76,78` (`startedAt`, `stoppedAt`, epoch ms) | `src/lib/recorder/recorder-sqlite-repository.ts:48-49` (`createdAt`, `persistedAt`); `bug_sessions.created_at` (`bin/errors-cli.py:1143`) | Error records carry timestamps; no bug `created_at` — TARGET |
| `updated_at` | GAP — no `updated_at` on sessions; derivable from the last event timestamp until the field lands | GAP — `persistedAt` is the last-write time, not a canonical `updated_at` | GAP — TARGET, owners per repo, 2026-11-09 |
| `reporter` | `src/lib/recorder/types.ts:9` (`RecorderActorType`: `user` \| `cli` \| `telegram` \| `system`) | `bin/errors-cli.py:1142` (`machine_username` in the listing); actor is the recording user | `appfault` records carry the operation (`WithOp`); no bug reporter — TARGET |
| `environment` | PARTIAL — no environment block on the session record; app version, machine, and instance id live in app config, not on the record | `src/lib/recorder/recorder-sqlite-repository.ts:30-34` (`machineHostname`, `machineOs`, `machineUsername`, `machineArch`, `machineSource`) | Partial — CLI records carry host context in diagnostics, not a structured environment block — TARGET |
| `steps` | `src/lib/recorder/types.ts:34-45` (`RecorderEvent`: `stepNumber`, `description`, `target` with `xpath`, `details`) | `--steps` / `--timeline` / `--inspect-event` (`bin/errors-cli.py`); timeline carries coordinates and XPath | No step capture — TARGET |
| `screenshots` | `src/lib/recorder/types.ts:47-58` (`CapturedScreenshot`: `stepNumber`, `timestamp`, `dataUrl`); `src/lib/recorder/full-page-capture.ts:272` strips scripts/noscripts/iframes/external stylesheet links before SVG `foreignObject` rasterization | `src/lib/recorder/recorder-sqlite-repository.ts:5-16` (`BugScreenshotRecord`: `sequenceNumber`, `diskPath`, `createdAt`); `screenshot_count` in `bug_sessions` | No screenshot capture — TARGET |
| `session_ref` | The session IS the record (`RecorderSession.id`) | `--session ID` / `--recording ID_OR_PATH` (`bin/errors-cli.py`); `sessionId` on every row | No sessions — TARGET |
| `offline` | Sessions persist to localStorage (`src/stores/recorder-store.ts:55-57`, `PREVIOUS_SESSIONS_STORAGE_KEY`); the recorder is local by design, so there is no backend-down path to lose | `src/lib/recorder/recorder-sqlite-repository.ts:76-77` (`OFFLINE_SESSIONS_KEY = "cat:recorder:offline_sessions"`); `source?: "local" \| "backend"` on `BugSessionItem`; modal is local-first (task 324 Spec 01 WI-04) | N/A — no sessions, no offline path |

## 4. TARGET fields

| Field | Owner | Date | Disposition |
|---|---|---|---|
| `error_code` | gitmap-v28 repo chat (registry) | 2026-11-09 | ADOPTED — `BUG` codes 18250–18255 registered (see §5). Recorders attach the code when the bug maps to one; unmapped bugs carry no code rather than an invented one. |
| `rca_ref` | Owning repo's chat per bug | 2026-11-09 | ADOPTED as a link field. The RCA lives in `.ai-memory/issues/` (fleet convention) or a spec RCA section; the record stores the relative path, never a copy of the analysis. |
| `status` (full machine) | AGM repo chat / cat-my-v12 repo chat / gitmap-v28 repo chat | 2026-11-09 | DEFERRED with reason: no implementation has a status field today. The machine in §2.2 is the convergence target; until it lands, wild statuses map to `recorded` per §2.2. |
| `severity` | AGM repo chat / cat-my-v12 repo chat | 2026-11-09 | DEFERRED with reason: no implementation grades bug severity today. Severity is assigned at triage, not at capture; the capture path must not block on it. |
| `number` (repo-monotonic) | AGM repo chat / cat-my-v12 repo chat | 2026-11-09 | DEFERRED with reason: AGM's `NN-bug` is a per-session sequence; Cat-My has no number. A repo-monotonic counter needs a shared sequence source per repo; until then the session id is the stable key and the badge shows the session sequence. |
| `updated_at` | AGM repo chat / cat-my-v12 repo chat | 2026-11-09 | DEFERRED with reason: derivable from the last event/persist time today; a canonical field lands with the status machine. |

## 5. Bug-recording error codes (registry)

Registered in `02-spec/03-error-manage/03-error-code-registry/error-codes-master.json`
(prefix `BUG`, integer range 18250–18299, carved from the unallocated
18250–18999 block) and in `02-spec/03-error-manage/03-error-code-registry/02-registry.md`.
The machine-readable per-module index is
`02-spec/03-error-manage/04-bug-recording/error-codes.json` (schema:
`02-spec/03-error-manage/03-error-code-registry/07-schemas/error-codes-index.schema.json`;
the registry collision detector reads it — the `IndexFile` in the master
entry must always point at a JSON index, never at a Markdown spec).
Go, Rust, Python, and TypeScript recorders use the integer code; the
`BUG-xxxxx` label is the human form. Codes are never invented inline.

| Code | Label | Meaning | Retryable |
|---|---|---|---|
| 18250 | `BUG-CAPTURE-FAILED` | Capture failed; the record was not started. The failure is itself recorded as an error — never a silent loss, never a success report. | No |
| 18251 | `BUG-PERSIST-FAILED` | Persist to disk/SQLite failed after a successful capture. The in-memory record is retained and the failure is surfaced; the user is told the bug was NOT saved. | Yes |
| 18252 | `BUG-SESSION-NOT-FOUND` | Lookup by id, slug, title, or session ref missed on every source (disk, SQLite, local cache). | No |
| 18253 | `BUG-SCREENSHOT-SANITIZE-FAILED` | SVG screenshot content failed sanitization; the screenshot is rejected, the step is kept, the rejection is recorded. | No |
| 18254 | `BUG-PARITY-MISMATCH` | CLI/UI parity check found an id-set delta. The delta is a filed bug against the surfacing layer, not a data problem. | No |
| 18255 | `BUG-OFFLINE-SYNC-FAILED` | An offline record failed to sync on reconnect. The local copy is kept and the failure is surfaced; the record is never silently left local. | Yes |

## 6. Spec corrections (this spec vs. the parent spec-03 §2.3)

- **REQUIRED framing corrected.** Parent spec-03 §2.3 states REQUIRED fields
  are "already captured by at least one implementation". That is not
  literally true for `number` (partial), `status`, `severity`, and
  `updated_at` (absent everywhere), and for `environment` in AGM. The
  corrected rule is §2.3 above: REQUIRED means required in the target
  schema with at least a partial capture path in one implementation; the
  trace table (§3) states exactly how partial each path is, and the audit
  dispositions each gap. No field is presented as captured when it is not.

## 7. Cross-references

- Pipeline and parity: `02-recording-pipeline-spec.md`
- Audit results: `03-blind-readiness-audit-spec.md`
- Parent folder: `../readme.md`
- Error-code registry: `../03-error-code-registry/readme.md`
- Parent task spec: `Antigravity-Manager: 02-spec/21-app/324-antigravity-manager-tools-synchronization-ui-improvement/spec-03-bug-recording-css-ui-seo.md`
- AGM recorder: `Antigravity-Manager: 02-spec/21-app/319-bug-and-audit-recorder-separation/01-bug-and-audit-recorder-separation-spec.md`
- Cat-My recorder: `cat-my-v12: src/lib/recorder/recorder-sqlite-repository.ts`
