# Blind-Readiness Audit Spec

**Folder:** `02-spec/03-error-manage/04-bug-recording/`
**Task:** 324 antigravity-manager-tools-synchronization-ui-improvement
**Spec:** `Antigravity-Manager: 02-spec/21-app/324-antigravity-manager-tools-synchronization-ui-improvement/spec-03-bug-recording-css-ui-seo.md` §2.6
**Status:** Audit executed 2026-11-09 against the live trees (post-Wave-A/B state)
**Version:** 1.0.0
**Updated:** 2026-11-09
**AI Confidence:** Production-Ready (checklist) / Target (convergence gaps)
**Ambiguity:** None — every fail has a disposition below

---

## 1. Purpose

A reader with no prior context must be able to record, find, and replay a
bug from this spec alone. This document is the checklist and the record of
running it against Antigravity-Manager, cat-my-v12, and gitmap-v28. A fail
is a finding, not a verdict on the repo: each fail names the missing field,
the disposition, and the owner.

## 2. Checklist

- [ ] **Record:** the spec names exactly one way to start a recording per
      repo (command or UI path), with no assumed prior state.
- [ ] **Find by id:** `id` and `number` are findable from both CLI and UI
      with the exact commands/paths given in the spec.
- [ ] **Find by title/slug:** `--by-title` / `--by-slug` (or the UI
      equivalent) return the same record as lookup by id.
- [ ] **Replay:** the `steps` + `screenshots` + `session_ref` of any
      `recorded`-status bug let a stranger reproduce it without asking the
      reporter a question. Each failure names the missing field.
- [ ] **Offline:** a bug recorded with the backend down is findable after
      reconnect, with `offline: true` preserved in the record.
- [ ] **State:** the status machine (`recorded` → … → `closed`, plus
      `reopened`) is stated in the spec and every status value in the wild
      maps to exactly one state.
- [ ] **No invented data:** every field in the schema traces to a real
      capture path; fields no implementation produces are marked TARGET
      with a named owner and date, not presented as if they exist.

## 3. Results (audit run 2026-11-09)

`PASS` = verified against the live tree (file + line cited).
`PARTIAL` = the capability exists but not in the specified form.
`FAIL` = the capability does not exist. `N/A` = not applicable by design.

| Checklist item | Antigravity-Manager | cat-my-v12 | gitmap-v28 |
|---|---|---|---|
| Record | PASS — **Start Bug Recording**, navbar / mega-menu selector (`src/components/navbar/mega-menu/MegaRecorderCol.tsx:159,169`); session created by `createEmptySession` (`src/stores/recorder-store.ts:64-80`) | PASS — **Start Recording Bug** (`src/components/recorder/RecorderLauncherButton.tsx:250`; `startRecording()` at `:38,50`) | FAIL — no bug-session recorder exists; errors are recorded via `appfault` + registry. Disposition G7 (deferred by design). |
| Find by id | PASS — `agm bug-report inspect <id>` (`src-tauri/src/modules/cli/bug_report.rs:141`); `agm bug-report list` (`:111`); modal search matches `id` (`src/components/recorder/PreviousBugsModal.tsx:53-63`) | PASS — `--session ID` / `--show ID` (`bin/errors-cli.py`); `--last-recording`; modal lists sessions by `sessionId` | FAIL — no bug-record store to look up. Disposition G7. |
| Find by title/slug | PARTIAL — modal search matches summary title (`PreviousBugsModal.tsx:61`); no `--by-slug` CLI verb exists (only `list` / `inspect`). Disposition G8. | PASS — `--by-title TEXT` / `--by-slug SLUG` (`bin/errors-cli.py:21,4315,4332`); slug resolves via the `task.db` `Slug` column, then disk `summary.slug` | FAIL — no lookup surface. Disposition G7. |
| Replay | PASS — `RecorderEvent` carries `stepNumber`, `description`, `target.xpath` (`src/lib/recorder/types.ts:34-45`); `CapturedScreenshot` carries `stepNumber`, `timestamp` (`:47-58`); authentic SVG `foreignObject` capture (`src/lib/recorder/full-page-capture.ts:236,272`) | PASS — `--steps` / `--timeline` (coordinates + XPath) / `--inspect-event N` / `--export-bundle SESSION_ID` (`bin/errors-cli.py`); `BugScreenshotRecord` carries `sequenceNumber`, `diskPath`, `createdAt` (`src/lib/recorder/recorder-sqlite-repository.ts:5-16`) | FAIL — no steps, screenshots, or sessions to replay. Disposition G7. |
| Offline | PASS — sessions persist to localStorage (`src/stores/recorder-store.ts:55-57`); the recorder is local by design, so there is no backend-down loss path | PARTIAL — recorded offline is findable locally after reconnect (offline cache `cat:recorder:offline_sessions`, `src/lib/recorder/recorder-sqlite-repository.ts:76-77`; `source?: "local" \| "backend"`; modal local-first per task 324 Spec 01 WI-04). Automatic backend sync on reconnect was NOT verified in code. Disposition G6. | N/A — no sessions, no offline path |
| State | FAIL — `RecorderSession` (`src/lib/recorder/types.ts:73-91`) has no status field. Disposition G1. | FAIL — `BugSessionItem` has `isArchived` only, no status. Disposition G1. | FAIL — no bug records. Disposition G1. |
| No invented data | PASS — every REQUIRED field traces to a real capture path in `01-bug-record-schema-spec.md` §3; TARGET fields are marked with owner and date in §4 | PASS — same trace table | PASS — same trace table |

## 4. Gaps and dispositions

| Gap | Finding | Disposition | Owner | Date |
|---|---|---|---|---|
| G1 | No status machine anywhere: no `status` field on AGM sessions, Cat-My sessions, or gitmap records | TARGET — the machine in `01-bug-record-schema-spec.md` §2.2 is the convergence target. Until it lands, wild statuses map to `recorded` per §2.2. | AGM repo chat / cat-my-v12 repo chat / gitmap-v28 repo chat | 2026-11-09 |
| G2 | No bug severity anywhere (Cat-My's `--level` classifies errors, not bug severity) | TARGET — severity is assigned at triage, not at capture; the capture path must not block on it. | AGM repo chat / cat-my-v12 repo chat | 2026-11-09 |
| G3 | No repo-monotonic bug number: AGM's `NN-bug` is a per-session sequence (`src/stores/recorder-store.ts:67`); Cat-My has no number (`--recent-bugs` lists `session_id` only) | TARGET — a repo-monotonic counter needs a shared sequence source per repo; until then the session id is the stable key and the badge shows the session sequence. | AGM repo chat / cat-my-v12 repo chat | 2026-11-09 |
| G4 | No canonical `updated_at` (AGM: derivable from last event timestamp; Cat-My: `persistedAt` is last-write time, not a canonical field) | TARGET — lands with the status machine (G1). | AGM repo chat / cat-my-v12 repo chat | 2026-11-09 |
| G5 | AGM sessions carry no environment block (app version, machine, instance id, OS live in app config, not on the record) | TARGET — attach the environment block at session creation. | AGM repo chat | 2026-11-09 |
| G6 | Cat-My offline→backend sync on reconnect not verified in code (offline findability verified; the sync step itself not traced) | OPEN GAP, filed as a follow-up for the lead: verify or implement the reconnect sync in `cat-my-v12: src/lib/recorder/` and record the result here. Cross-reference: `01-bug-record-schema-spec.md` §3 (`offline` row), pipeline spec §2.2. Not fixed in this wave. | cat-my-v12 repo chat (via lead) | 2026-11-09 |
| G7 | gitmap-v28 has no bug-session recorder (no capture, no store, no listing surface) | DEFERRED BY DESIGN with reason: a CLI tool records errors via `appfault` + the registry; session recording (screenshots, DOM steps) has no meaning in that surface. gitmap adopts the schema for error records only. If a gitmap bug-session need ever arises, this gap is the design input — it is not a defect today. | gitmap-v28 repo chat | 2026-11-09 |
| G8 | AGM has no `--by-slug` CLI verb (`agm bug-report` offers `list` / `inspect` only) | TARGET — add a slug lookup verb or document the modal search as the slug path. | AGM repo chat | 2026-11-09 |
| G9 | Cat-My `--recent-bugs` prints the returned-row count as `(Total: N)`, not the database total | SPEC WORDING CORRECTED — the pipeline spec §3 states the paging procedure precisely. Not a code defect. | — (closed in this wave) | 2026-11-09 |

## 5. Executed checks (this wave)

- **Parity check, Cat-My CLI:** `python bin/errors-cli.py --recent-bugs`
  run on this machine → exit 0, `No recorded bug sessions found.` There
  is no `task.db` on this machine, so both surfaces show zero records:
  parity holds vacuously (0 = 0). A non-empty parity comparison needs a
  machine with recorded sessions; that run is deferred to the user's
  machine and is recorded here as not-yet-executed, not as passed.
- **Registry validation:** `node 02-spec/03-error-manage/03-error-code-registry/08-linter-scripts/validate-master-stats.mjs`
  and `detect-collisions.mjs` run after registering the `BUG` codes —
  see §6.
- **No absolute paths:** all references in the new spec files are relative
  Git paths in the `repo: path` form (AC-03-06).

## 6. Verification log

| Check | Command (repo-relative) | Result |
|---|---|---|
| Registry stats validate | `node 02-spec/03-error-manage/03-error-code-registry/08-linter-scripts/validate-master-stats.mjs` | exit 0 — "Master index stats are consistent (987 codes, 168 retryable)" |
| Registry collision detect | `node 02-spec/03-error-manage/03-error-code-registry/08-linter-scripts/detect-collisions.mjs` | exit 0 — "VALIDATION PASSED — no collisions detected"; unallocated gap `[18300-18999]` confirms the BUG range carve |
| Index schema validate | `python3 -c "jsonschema.validate(...)"` against `07-schemas/error-codes-index.schema.json` | valid — first attempt failed on a top-level `Name` property the schema forbids (`additionalProperties: false`); the property was removed and the index re-validated |
| CLI parity probe | `python bin/errors-cli.py --recent-bugs` (cat-my-v12) | exit 0, `No recorded bug sessions found.` (empty store on this machine) |

## 7. Cross-references

- Schema: `01-bug-record-schema-spec.md`
- Pipeline and parity: `02-recording-pipeline-spec.md`
- Parent folder: `../readme.md`
- Parent task spec: `Antigravity-Manager: 02-spec/21-app/324-antigravity-manager-tools-synchronization-ui-improvement/spec-03-bug-recording-css-ui-seo.md`
