# Recording Pipeline Spec (Capture → Persist → Surface)

**Folder:** `02-spec/03-error-manage/04-bug-recording/`
**Task:** 324 antigravity-manager-tools-synchronization-ui-improvement
**Spec:** `Antigravity-Manager: 02-spec/21-app/324-antigravity-manager-tools-synchronization-ui-improvement/spec-03-bug-recording-css-ui-seo.md` §2.4–§2.5
**Status:** Canonical target
**Version:** 1.0.0
**Updated:** 2026-11-09
**AI Confidence:** Production-Ready (pipeline) / Target (convergence)
**Ambiguity:** None — gaps are listed in `03-blind-readiness-audit-spec.md`, never hidden

---

## 1. Purpose

One pipeline, three stages, every repo. A bug moves through capture,
persist, and surface the same way no matter which recorder started it.
The pipeline exists so that a bug recorded anywhere is findable everywhere
in that repo, and so that a failure at any stage is visible instead of
silent.

## 2. The three stages

### 2.1 Stage 1 — Capture

Capture records the bug without blocking the user flow. Capture never
blocks; capture failure is itself recorded as an error (code
`BUG-CAPTURE-FAILED`, 18250) — no silent loss.

The Telegram fake-ack lesson from Spec 02 applies here verbatim: a failed
capture must never report success. A recorder that could not capture says
so, in the UI and in the log, with the reason attached.

| Repo | Capture implementation | Start path (exactly one per repo) |
|---|---|---|
| Antigravity-Manager | Bug Recorder (`useRecorderStore`): DOM screenshot + step enrichment + XPath root targeting; Audit Recorder (`useAuditStore`) is a separate system-level logger and is NOT a bug recorder | Navbar / mega-menu recording selector → **Start Bug Recording** (`src/components/navbar/mega-menu/MegaRecorderCol.tsx:159,169`); stopping captures the final `#N: User stopped bug recording` event and screenshot before ending the session |
| cat-my-v12 | Activity recorder: session recording + event explorer + auto-increment; past-bug inspection via the recorder store | **Start Recording Bug** (`src/components/recorder/RecorderLauncherButton.tsx:250`; `startRecording()` at `:38,50`) |
| gitmap-v28 | No bug-session capture. Errors are recorded via `appfault` wrapping with a registered code (`02-spec/03-error-manage/02-error-architecture/`); bugs are fixed as commits (`gitmap cpb` / `cbf`). Session capture is explicitly out of scope for the CLI — see the audit disposition. | N/A — no start path exists; this is a recorded gap, not an oversight |

Capture invariants (all repos):

- Start captures an initial event/screenshot (`#1: Bug recording started`
  in AGM; the first event in Cat-My).
- Stop captures a final event/screenshot before ending the session.
- Steps are strictly monotonically numbered (1-based), never renumbered
  after the fact.
- Screenshots are authentic DOM captures, never mock/stock images. SVG
  content is sanitized before storage (AGM strips scripts, noscripts,
  iframes, and external stylesheet links in
  `Antigravity-Manager: src/lib/recorder/full-page-capture.ts:272` before
  SVG `foreignObject` rasterization; a sanitize failure rejects the
  screenshot with code `BUG-SCREENSHOT-SANITIZE-FAILED`, 18253, and keeps
  the step).
- The recorder UI is excluded from its own telemetry (AGM: recorder-modal
  clicks/inputs are not captured as bug steps).

### 2.2 Stage 2 — Persist

Disk/SQLite is the source of truth. The backend, where present, is
enrichment and sync — never the only copy.

| Repo | Source of truth | Backend role |
|---|---|---|
| Antigravity-Manager | Local session store, persisted to localStorage (`src/stores/recorder-store.ts:55-57`, `PREVIOUS_SESSIONS_STORAGE_KEY`); SQLite prompt/backup DBs for the prompt side | Enrichment only; the recorder works with no backend |
| cat-my-v12 | SQLite Split-DB (`task.db`, `bug_sessions` table) plus recorded bug sessions on disk; `bin/errors-cli.py` syncs disk sessions into SQLite first (`sync_all_disk_sessions_to_sqlite`, `bin/errors-cli.py:1138`) | Enrichment and sync; the CLI reads disk/SQLite directly and works with the backend down |
| gitmap-v28 | Error records live in the appfault path (structured logs + registry codes); there is no bug-session store | N/A |

Offline rule (schema field `offline`):

- A bug recorded while the backend is unreachable persists locally first
  (Cat-My: localStorage key `cat:recorder:offline_sessions`,
  `cat-my-v12: src/lib/recorder/recorder-sqlite-repository.ts:76-77`; the
  item carries `source?: "local" | "backend"`).
- Offline records MUST sync on reconnect, never silently stay local. A
  sync failure is recorded with code `BUG-OFFLINE-SYNC-FAILED` (18255) and
  the local copy is kept.
- The `offline: true` flag is preserved in the record after sync — it is
  history, not a transient display state.

### 2.3 Stage 3 — Surface

Two surfaces, one record: the CLI and the UI both read the same persisted
record; neither invents fields the other cannot see.

| Repo | CLI surface | UI surface |
|---|---|---|
| Antigravity-Manager | `agm bug-report list` / `agm bug-report inspect <id>` (`src-tauri/src/modules/cli/bug_report.rs:111,141`, Universal Response Envelope output) | Previous-bugs modal (`src/components/recorder/PreviousBugsModal.tsx`), reading `previousSessions` from the recorder store (`:44`); search matches id, route, and summary title (`:53-63`); inline rename persists the slug |
| cat-my-v12 | `bin/errors-cli.py` — `--recent-bugs`, `--session ID`, `--recording ID_OR_PATH`, `--last-recording`, `--by-title TEXT`, `--by-slug SLUG`, `--show ID`, `--steps`, `--timeline`, `--inspect-event N`, `--export-bundle SESSION_ID`, `--import-zip PATH`, `--json` (Universal Response Envelope JSON) | Previous-bugs modal (`src/components/recorder/PreviousBugsModal.tsx`), local-first since task 324 Spec 01 WI-04: sync local paint → facade merge → backend enrichment; reads local bug sessions first (`:216`) |
| gitmap-v28 | No bug-listing CLI surface (error inspection is `appfault` log/registry based) | No bug-listing UI surface |

## 3. CLI/UI parity rule

- Every bug visible in the CLI MUST be visible in the UI, and vice versa.
- The parity check is executable:

```
# 1. List via CLI with a limit large enough to cover the set (default 20;
#    raise --limit until the returned count stops growing).
python bin/errors-cli.py --recent-bugs --limit 1000        # Cat-My
agm bug-report list                                          # AGM

# 2. List via UI: open the previous-bugs modal, clear the search box,
#    count the rows.
# 3. Compare the id sets. Any delta is a filed bug against the
#    surfacing layer (code BUG-PARITY-MISMATCH, 18254), not a data problem.
```

- Notes on the check as written: Cat-My's `--recent-bugs` prints
  `(Total: N)` where N is the number of rows returned in that page, not
  the database total — page with `--limit` until the count stabilises
  before comparing. AGM's `agm bug-report list` returns the audit-entry
  list; the modal lists recorder sessions — the two id sets must be
  compared on session id, which both surfaces carry.
- The check runs against the local CLI on the current machine; no live
  backend is required (disk/SQLite is the source of truth).

## 4. Worked example — the Cat-My modal defect

The defect that motivated this rule: Cat-My's `PreviousBugsModal` was
BE-first and near-empty while the backend was down, while
`bin/errors-cli.py` showed everything from disk. Same record, two
surfaces, different answers — because the modal read the backend and the
CLI read the disk.

The fix is local-first surfacing (task 324 Spec 01 WI-04): the modal
paints local sessions synchronously, merges the facade, then enriches
from the backend — it never waits on the backend to show what is already
on disk. The parity rule in §3 is the regression guard: if the modal and
the CLI ever disagree again, the delta is filed against the surfacing
layer with code 18254.

## 5. Failure reporting (no fake success)

- A failed capture, persist, or sync reports failure with the reason and
  the registry code (§5 of the schema spec). It never reports success.
- A failed surface read (CLI or UI) reports the failure and shows what it
  could load; it never shows an empty list as if there were no bugs when
  the read itself failed. An empty result after a successful read is a
  legitimate empty state and says so ("No recorded bug sessions found.").
- Every failure path is logged with structured context (operation, inputs,
  code) per the folder's zero-swallowed-errors policy
  (`../readme.md`).

## 6. Spec corrections (this spec vs. the parent spec-03 §2.4–§2.5)

- **Parity-check total-count wording corrected.** Parent spec-03 §2.5 says
  to list via CLI "`--limit` unbounded or paginated with a total count".
  Cat-My's `--recent-bugs` prints the returned-row count as its total,
  not the database total. The executable check in §3 states the paging
  procedure precisely instead of assuming an unbounded list or a DB total.
- **AGM CLI surface corrected.** Parent spec-03 §2.4 names AGM's surface
  as "`agm bug-report|bugs`". The implemented verbs are `agm bug-report
  list` and `agm bug-report inspect <id>` (`bug_report.rs:111,141`); no
  `bugs` alias was found in the CLI module. The table in §2.3 names the
  real verbs.

## 7. Cross-references

- Schema: `01-bug-record-schema-spec.md`
- Audit results: `03-blind-readiness-audit-spec.md`
- Parent folder: `../readme.md`
- Cat-My local-first fix: task 324 Spec 01 WI-04
  (`Antigravity-Manager: 02-spec/21-app/324-antigravity-manager-tools-synchronization-ui-improvement/spec-01-cat-my-ui-backend-simulation.md`)
- AGM recorder separation: `Antigravity-Manager: 02-spec/21-app/319-bug-and-audit-recorder-separation/01-bug-and-audit-recorder-separation-spec.md`
