# Specification 27 — Delta Notes from Implementation (Program 146, 2026-11-03)

> **Status: DELTA NOTES ONLY. This file does NOT rewrite the spec 27
> contract.** The six contract documents (`01`–`06`) stand as written, and
> doc 07 (Wave 6 deltas) stands as written except where this document
> explicitly corrects it (see Delta 10, harvested-stamping correction).
> A blind-AI reader should implement the contract first, then apply the
> doc 07 deltas, then apply these doc 09 deltas. Where this document
> conflicts with `01`–`06`, this document wins: it describes the system
> that is actually running, proven by program 143/144 evidence and by the
> independent program 146 Phase 0 audit
> (`02-spec/21-app/146-bug-reporting-and-tracking-specs-confirmation/evidence/phase-0-matrix.md`).
> Deltas are numbered to continue doc 07 (Deltas 1–8), so a reader can
> tell which wave introduced each divergence.

## Delta 9 (NEW, Program 146): titles, slugs, bug-NNN allocation, --latest, --by-title, --by-slug, derived suggestions

- **Contract (`01`–`06`):** doc 03 names a free-text `title` column only. No
  sequence, no slug, no retitle route, no newest-report command, no
  title/slug lookup. Doc 07 does not mention any of these.
- **Built system:**
  - **Allocation.** A session with an empty title saves as `bug-NNN`, where NNN
    is max-existing + 1 with a collision re-check. Numbers are NOT monotonic
    across renames: renaming frees the old number for reuse. Advisory preview
    via `GET /bug-reports/next-bug-title`; save-time resolution is the
    guarantee (frontend provisional titles from localStorage are advisory only).
    Implementation: `BE/routes/bug_reporting/bug_sequence.py` (`format_bug_title`,
    `next_bug_title`, save-time resolution); `src/lib/recorder/session-factory.ts`
    (provisional frontend title).
  - **Slug.** `BugSession` carries a `Slug` column
    (`BE/repos/sqlite_bug_session_queries.py`), derived from the title and
    re-derived on retitle (`BE/routes/bug_reporting/title_handler.py`).
    Migration: `BE/db/migrations/task/0035_task_bug_titles_and_backend_snippets.sql`.
  - **Routes.** `PATCH /bug-reports/sessions/{id}/title` (retitle) and
    `GET /bug-reports/next-bug-title` (`BE/routes/bug_reports.py`,
    `BE/routes/bug_reporting/title_handler.py`).
  - **Tracker UI.** Titles are editable inline on the tracker card
    (double-click / pencil); the saved title wins over the list item; the
    slug is shown under the title; the modal merges title updates
    (`src/components/recorder/BugSessionCard.tsx`,
    `src/components/recorder/PreviousBugsModal.tsx` `onTitleUpdated`).
  - **CLI.** `--latest` prints the newest report + recording (newest by created
    time, task.db first, disk fallback; on a newest session with 0 steps it
    prints honestly "no recorded session with steps" and prints NO `--step`
    suggestion line). `--by-title TEXT` and `--by-slug SLUG` find sessions
    (task.db exact-slug then substring search, then disk metadata search;
    a miss exits 1). Suggestion step numbers are ALWAYS derived from the
    session's real step count — never a hardcoded `--step 7` (the two
    hardcoded suggestion literals were removed in program 144 Wave 1C and a
    guard test asserts no `--step 7` remains in CLI suggestion code).
- **Why:** program 144 Wave 1C. Evidence:
  `02-spec/21-app/144-debugging-and-bug-fixing-instructions/evidence/wave-1c-titles-snippet.md`
  and `wave-1-fixes.md`.
- **Blind-AI rule:** implement titles as a sequence with the collision and
  rename rules above, not as free text. A free-text-only build cannot
  reproduce tracker titles, slug search, or `--latest`.

## Delta 10 (NEW, Program 146): machine override beyond doc 07 Delta 1

- **Contract + doc 07 Delta 1:** doc 07 Delta 1 specifies the manifest
  `machine.machineSource` vocabulary (`user-override` | `harvested`), the
  never-fabricate rule, the import-ignore-unknown rule, the
  import-without-field-never-clears rule, and the CLI task.db-row-over-disk-block
  authority rule. Those stand. What doc 07 does NOT specify is the override
  mechanism itself — this delta supplies it.
- **Built system:**
  - **PATCH route.** `PATCH /bug-reports/sessions/{session_id}/machine`
    (`BE/routes/bug_reports.py` → `BE/routes/bug_reporting/machine_handler.py`)
    with a fixed four-column allow-list. Validation: unknown fields,
    non-string values, and values over 255 chars → 400; unknown session → 404;
    blank/null clears the field to NULL. A successful PATCH stamps
    `BugSession.MachineSource = 'user-override'`
    (`BE/repos/sqlite_bug_session_repo.py`, `update_machine_info`).
  - **Column.** `MachineSource` on `BugSession`
    (`BE/repos/sqlite_bug_session_queries.py`; migration
    `BE/db/migrations/task/0034_task_bug_session_machine_source.sql`;
    PRAGMA-guarded backfill; pre-existing rows keep NULL, meaning
    "provenance not recorded" — never backfilled as `harvested`).
  - **CORRECTION to doc 07 Delta 1's plain reading.** Doc 07 says
    `"harvested"` = "the block was captured at record time". Read plainly,
    that tells a builder to stamp `harvested` at save time. The real system
    NEVER stamps `harvested` on the save path: the only writers of the column
    are `update_machine_info` (`user-override`, PATCH path) and
    `set_machine_source` (import path). A builder that stamps `harvested` on
    every save produces a column value the real system never produces on that
    path. Do NOT stamp at save time.
  - **UI + disclosure.** Tracker card "Edit machine" form, `corrected` badge
    condition, and a ZIP export README override-disclosure note
    (`src/components/recorder/BugSessionCard.tsx`;
    `src/lib/recorder/recorder-sqlite-repository.ts` `machineSource?` on the
    item). The card passes the item's stored `machineSource` into the export
    manifest verbatim (`src/lib/recorder/zip-builder.ts`).
  - **Import setter.** Import honors `machineSource` only on vocabulary match
    (unknown → ignored, import still 200) via `set_machine_source`
    (`BE/repos/sqlite_bug_session_repo.py`; called from
    `BE/routes/bug_reporting/import_handler.py`). The session UPSERT never
    writes the column, so import without the field never clears a stored value.
- **Why:** program 143 Waves 5–6. Evidence: `wave-5-ui.md`,
  `wave-6-verification.md` §5.
- **Do not confuse with:** the CLI sync column `machine_source` in
  `.logs/errors.db` (`metadata`/`harvest`), which records how the CLI derived
  identity during sync. Different store, different purpose, different vocabulary
  (already noted in doc 07 Delta 1; repeated here because the names collide).

## Delta 11 (NEW, Program 146): backend snippets

- **Contract:** doc 03 has `backend_file` / `backend_fn` only. No line, no
  snippet. Doc 07 does not mention them.
- **Built system:**
  - **Columns.** `BackendLine` / `BackendSnippet` on the event row
    (`BE/repos/sqlite_bug_session_queries.py`; migration 0035;
    `BE/core/db/query_binder.py`).
  - **Resolution.** Find the `def` / `async def` line for the handler function,
    take ±5 lines, never fabricate; unknown function → NULLs
    (`BE/routes/bug_reporting/backend_snippet.py`, `resolve_backend_snippet`;
    `BE/routes/bug_reporting/code_traceability.py`, `resolve_backend_code_example`,
    deliberately kept OUT of `parse_code_traceability` so its seven-column
    contract stays intact).
  - **Precedence.** Stored line/snippet wins; otherwise resolve from disk at
    render time (detail enrichment in
    `BE/routes/bug_reporting/sessions_handler.py`; writer stores both in
    `BE/routes/bug_reporting/local_persistence.py`). The CLI import path does
    NOT populate snippet columns — the card resolves from disk when NULL.
  - **Rendering.** CLI prints a `--- BACKEND CODE EXAMPLE ---` section and
    `--depth code` prints `file::fn (line N, METHOD endpoint)` + snippet
    (`bin/errors-cli.py` card and latest/by-title sections; proven against a
    real handler line in wave 1C evidence §4). The tracker card steps expansion
    renders `file::fn:line` + a `<pre>` snippet, and nothing when absent.
  - **Route map.** The traceability route map was refreshed to the decomposed
    handler paths (`BE/routes/bug_reporting/*`); the pre-decomposition
    `BE/routes/bug_reports.py` path in older traces is stale.
- **Why:** program 144 Wave 1C. Evidence: `wave-1c-titles-snippet.md` §4,
  `wave-1-fixes.md`.

## Delta 12 (NEW, Program 146): real capture primitive, permission flow, screenshot kinds

- **Contract:** doc 01 §2 / doc 06 §2 say "HTML5 Canvas `drawImage` or screen
  capture API", "Offscreen Canvas / HTML2Canvas / Native API", and "dual
  snapshots" (full + canvas). No DOM rasterization, no consent, no kind field,
  no fallback labelling, no debug diagnostics. The string `"fullscreen"` as a
  kind never exists in the built code.
- **Built system:**
  - **Method.** Dependency-free DOM rasterization: clone the page, inline
    same-origin styles, substitute canvas bitmaps, raster via SVG foreignObject,
    capped at 4096 px per side (`src/lib/recorder/full-page-capture.ts`,
    `captureFullPageScreenshot`). Native `getDisplayMedia` was evaluated and
    REJECTED: it needs a per-step re-prompt plus a picker (cannot run per
    step), cannot be proven headless, and a whole-monitor pick would capture
    other applications. It stays documented as the future alternative for
    OS-level pixels only.
  - **Permission / opt-in flow.** A consent banner shows while recording and
    undecided (`src/components/recorder/RecorderCaptureConsent.tsx`, rendered
    by `src/components/recorder/ActivityRecorderRoot.tsx`); the decision
    persists in localStorage under `ca.recorder.fullpage-capture.v1`
    (`src/lib/recorder/full-page-capture.ts`). No raster runs until decided.
    Denial is a persisted first-class outcome, never retried silently. The
    banner carries `data-recorder-hud="true"` so its clicks are dropped as
    recorder chrome, not traced.
  - **Kind vocabulary.** Exactly `fullpage` | `diagram` | `viewport` | `crop`
    (`src/lib/recorder/screenshot-service.ts`, `kind` / `primaryKind`). Denied →
    `permission-denied`, undecided → `permission-undecided` reasons in
    `result.debug` (diagnostics-only debug branch). Real raster replaces BOTH
    snapshot slots with `FullPage`; the per-step entry point is
    `captureScreenSnapshotAsync`.
  - **Per-step path prediction.** Events carry `screenshotPath` /
    `screenshotKind` (click path stores both on the event). The frontend
    predictor mirrors the backend filename sanitizer (lowercase, 40-char cap,
    2-padded sequence, `{seq}_{source}_{title}_fullscreen.png`).
  - **COVERAGE LIMIT (build this honestly).** Only manual clicks and chrome
    traces use the async raster entry point. Tour steps, ROI-drag, and other
    handler call sites still use the sync capture, so with opt-in granted their
    steps still get diagram/viewport/crop, not the real raster. A follow-up
    call-site wiring pass to `captureScreenSnapshotAsync` is owed.
  - **FILENAME LIE (build this honestly).** The backend writer still files
    whatever is in `fullScreenDataUrl` as `*_fullscreen.png` even when the
    pixels are the synthetic diagram. Readers must pair the filename with
    `screenshotKind` until a dedicated rename wave (with round-trip proofs
    across `import_handler.py`, `prompt-path-resolver.ts`,
    `prompt-table-formatter.ts`, `zip-builder.ts`, and the frontend predictor
    plus its test) lands. Do NOT rename the filename unilaterally: import
    parity breaks.
- **Why:** program 144 Phase 1B (user decision: build the real primitive now).
  Evidence: `wave-1b-capture-ellipsis.md`, `wave-1-fixes.md`.

## Delta 13 (NEW, Program 146): dwell constant, tour numbering, ellipsis tracing

- **Contract:** dwell, tour timing, and recorder-chrome tracing are absent from
  docs 01–08. Doc 06 §2 says only "prevent recursive capture loops: check
  `!target.closest(\"[data-bug-recorder]\")`" — i.e. DROP recorder-UI clicks,
  with no exception and no traced alternative. Doc 03 has a generic
  `sequence_number` column with no tour-step distinction.
- **Built system:**
  - **Dwell.** One constant: default 1 s, range 1–10 s, no per-file literals
    (`src/lib/constants/simulation-dwell.ts`: `SIMULATION_DWELL_DEFAULT_SEC = 1`,
    `MIN = 1`, `MAX = 10`; consumed by the tour and the player-bar slider;
    Python mirror in `BE/ui_remote/registry.py`, `ui-sim-dwell` `set_range [1, 10]`).
    Scope note: dwell belongs to the guided simulation, not the recorder core —
    but a spec-27-only build would hardcode whatever timing it guessed, not
    1 s / 1–10 s.
  - **Tour numbering.** The tour passes `seqNumber: stepNumber` on every tour
    step event, so recorder sequence EQUALS tour step number
    (`src/components/guided-simulation/ProjectCreationAnalysisTour.tsx`; the
    store already honoured an explicit sequence and the tour simply never
    passed one before). Recorder step N and sim step M are shown side by side
    and never conflated: CLI `format_step_line` prints `[sim step N]`; the
    card prints `Step {sequenceNumber}` + `sim step {simulationStepNumber}`;
    detail enrichment derives sim step from disk `details.stepNumber`.
  - **Missed-before-REC + auto-start + finish.** The tour auto-starts the
    recorder on tour start; steps missed before REC get a marker event with no
    `stepNumber` ("Tour steps missed before REC: N"); the finish toast counts
    `recorded N of 23 tour steps` and returns to `/`.
  - **Ellipsis / recorder-chrome tracing (the exception to the drop rule).**
    The six drop guards in `src/lib/recorder/interceptor-click.ts` are
    unchanged (recorder-chrome clicks are still dropped as raw/resolved
    chrome). The exception is a SEPARATE path:
    `src/lib/recorder/recorder-chrome-trace.ts` (`traceRecorderChromeInteraction`,
    actor System, bypasses the drop by calling `addEvent` directly, awaited
    before menu-item actions so Discard cannot lose the trace). Enum member
    `RecorderChrome = "recorder-chrome"` (`src/lib/recorder/types.ts`,
    promoted from a literal). Overflow button / menu-item stable ids and
    handler names: source file `RecorderExportDropdown.tsx`, ids
    `btn-recorder-overflow-menu` / `ui-recorder-overflow-menu`, handlers
    `setIsDropdownOpen` / `executeItemAction` / `handleKeyDown`, item id
    prefix `btn-recorder-export-item-`.
  - **A blind-AI warning:** a spec-27-only build would either record ellipsis
    clicks as ordinary steps (breaking reproduction, since the menu is recorder
    chrome) or drop them silently (losing the trace entirely). Build the
    traced exception, not either failure mode.
- **Why:** program 144 Waves 1A/1B. Evidence: `wave-1a-dwell-tour.md`,
  `wave-1b-capture-ellipsis.md`, `wave-1-fixes.md`.

## Delta 14 (NEW, Program 146): rich audit rows (Option A) + backend import-zip route

- **Contract:** doc 03 defines `BugStackDiagnostic` (per-step error
  diagnostics) and nothing else audit-shaped. No `AuditInteraction`, no
  summary/event row split, no `/latest` endpoint. Doc 04 §3 / doc 05 §2 /
  doc 06 §4 specify CLI `--import-zip` and UI dropzone import, but no server
  route, no validation list, no idempotency rule. The modal is described as
  importing and restoring directly, not as POSTing to a server route.
- **Built system:**
  - **Rich audit rows.** Table `AuditInteraction`
    (`BE/routes/bug_reporting/audit_storage.py`, `ensure_audit_table`;
    migration `BE/db/migrations/task/0030_task_audit_interactions.sql`).
    The live save path calls `record_audit_session` (wired since the monolith
    decomposition, `BE/routes/bug_reporting/local_persistence.py`): one summary
    row (`MethodName = "session_recorded"`, actor `"user"`) plus one INSERT
    per event, in order. `GET /bug-reports/latest` reads the newest audit row
    (`BE/routes/bug_reports.py` → `BE/routes/bug_reporting/sessions_handler.py`,
    `ORDER BY AuditInteractionId DESC LIMIT 1`).
  - **Dual-store fence.** Audit rows AND normalized tables coexist, fenced
    from each other: Waves 3/4/5 did not touch the audit shape, and the audit
    wave did not touch the normalized writers or import/export code. A blind
    AI must build both stores and keep their writers separate.
  - **Caveat (build honestly).** `/latest` asserts the newest audit row
    overall belongs to the requesting session — true in CI and at test time,
    but a concurrent real recording landing mid-test could flip it. This is a
    pre-existing endpoint property, not a bug fixed by any wave.
  - **Backend import-zip route.** `POST /bug-reports/import-zip`
    (`BE/routes/bug_reports.py`, same `reject_non_loopback` guard as siblings)
    → `BE/routes/bug_reporting/import_handler.py`: hand-rolled multipart
    parse (no `python-multipart` installed; no `request.form()` usage exists
    in `BE/`), raw-body fallback, BadZipFile → 400, manifest + session.json
    validation with the CLI's exact checks/messages, tree copied to
    `.logs/recorded-bugs/<session_id>/`, registration via the Wave 3 repo
    writers with DELETE-children idempotency (re-import keeps counts).
  - **Validation check list (shared by CLI and backend).** Manifest present +
    JSON object; non-empty `sessionId`; `bundleVersion` OR `manifestVersion`
    present; `exportedAt` present; manifest/session.json `sessionId`
    consistency. Failures print/name the failed check; no extraction happens
    on validation failure; traversal is guarded.
  - **Modal server import.** The tracker dropzone POSTs to the backend route
    and refreshes from the server (`src/components/recorder/PreviousBugsModal.tsx`
    `handleProcessFile`). The earlier local-parse-and-prepend behaviour was
    replaced because imported sessions were lost on modal close.
- **Why:** audit wave (Option A, user decision 2026-11-03) and program 143
  Wave 4. Evidence: `wave-audit-option-a.md`, `wave-4-zip.md`.

## Delta 15 (NEW, Program 146): doc 08 is SUPERSEDED — faithful notification spec + vapor list

- **Status of doc 08.** Doc 08 (`08-script-notification-and-alerting.md`) was
  added by the bot commit that created spec 146, with its §5 checklist boxes
  ticked for implementation work that was never done. A checklist in a spec
  file is not a proof of implementation. **Doc 08 must NOT be cited as a
  confirmed subsystem.** This delta supersedes its implementation claims; doc 08
  itself is left in place (delta-notes precedent: correct by delta, do not
  rewrite history) but its claims below are marked UNIMPLEMENTED until code
  lands. The spec 146 readme checkbox "Script Notification & Webhook
  Dispatched" is NOT confirmed: it describes a document, not a dispatch.
- **What ACTUALLY ships (build this, not doc 08).** A telemetry email
  notifier, user-initiated via a modal — NOT session-finalization-triggered,
  NOT "no human intervention":
  - Dual plain-text + HTML email formatting (subject + text body with rule
    table + HTML body with styled summary table)
    (`src/services/telemetry/email-notifier.ts`, `formatEmailNotification`,
    dispatched from `src/components/recorder/RecorderEmailModal.tsx` via
    `dispatchBugReportEmail`).
  - Config `EmailConfig` (`webhookUrl`, `senderEmail`, `recipientEmail`,
    `isEnabled`, `hasOfflineQueue`; defaults `telemetry@catvision.ai` /
    `support@catvision.ai` / `/api/telemetry/email`; persisted in localStorage
    under `cat_vision_email_config`). Note: `webhookUrl` here is just the POST
    URL for the email payload, not a signed webhook endpoint — and no server
    route for the default URL was proven in `src/`/`BE/`.
  - Offline storage in browser localStorage (`cat_vision_offline_email_queue`,
    capped at the last 50 entries, count-only reader). Write-only in practice:
    no flush, no drain, no retry.
- **What DOES NOT EXIST (do NOT build doc 08's version unless implementing it
  as new work).** Each item was searched at head `2481b536` with zero
  implementation hits:
  - The Universal Notification Envelope (UNE) with `EventId`, `EventType`
    (`BUG_RECORDING_FINALIZED`), `TimestampUtc`, `Severity`, `Machine{...}`,
    `Session{...}`, `Summary{...}`, `Artifacts{...}`, `RulesBreakdown[...]`.
  - Webhook POST with `X-Bug-Signature: sha256=<hmac_hex>` +
    `X-Correlation-Id`, 5000 ms timeout, failure → SQLite offline queue.
    (The notifier's `fetch` sets only `Content-Type: application/json`, with
    no abort/timeout.)
  - `BUG_NOTIFY_SCRIPT` runner (`$BUG_NOTIFY_SCRIPT <BUNDLE_ZIP_PATH>
    <SESSION_ID>`, exit 0 = success, non-zero = logged warning + retry marking).
  - SMTP / multipart MIME dispatch. (The notifier POSTs JSON to a URL; it never
    speaks SMTP.)
  - SQLite offline queue table `bug_notification_queue` (no migration, no DDL,
    no writer, no reader).
  - Retry loop with exponential backoff; auto-flush when `navigator.onLine`
    fires or at next-run preflight.
  - CLI flags `--notify`, `--list-offline-notifications`,
    `--flush-notifications` (confirmed absent in live `--help`).
  - Doc 08 §5 checklist items 2–4 as ticked: persistent notification config in
    localStorage AND SQLite settings (SQLite half missing), UNE payload
    serializer (missing), retry loop with backoff (missing).
- **Decision for a future implementer.** Either implement the doc 08 system as
  specified (UNE + HMAC webhook + script runner + SMTP + SQLite queue + flush
  + three CLI flags) and then mark this delta resolved, or keep the faithful
  notifier above as the specified system and delete doc 08. Until one of those
  happens, a blind AI must build the notifier in this delta, not doc 08.

## Delta 16 (NEW, Program 146): contract corrections — where the build wins over docs 01–06

- **DDL table/column names (doc 03 §2).** The canonical store is task.db with
  PascalCase tables, NOT the lowercase names in doc 03: `BugSession`,
  `BugScreenshot`, `SessionEvent`, `SessionSnapshot` (no spec equivalent),
  `BugProjectBundle`, `BugStackDiagnostic`, plus child tables
  `BugBundleRuleset`, `BugBundleRule`, `BugBundleRuleParam`,
  `BugBundleLightChannel` (`BE/repos/sqlite_bug_session_queries.py`). The
  lowercase names exist only in the CLI-side `.logs/errors.db` mirror, not the
  canonical store. A verbatim spec build cannot interoperate with the backend
  or the CLI's task.db paths. Column mappings that differ: `EventCount` (not
  `step_count`); `ElementLabel` (not `clean_label`); `BugScreenshot` carries
  `SequenceNumber`, `FileName`, `DiskPath`, `RelPath`, `Title`, `Descriptor`,
  `TargetComponent` — no `step_number`, no `mime_type`, no width/height
  (dimensions live on `SessionSnapshot`). Bundle settings are MORE normalized
  than spec: per-column camera fields (`CameraDeviceId`, `CameraExposureMs`,
  `CameraGain`, `CameraFrameRate`) + child rows for rulesets/rules/params/light
  channels — doc 03 §1 ("never store giant unindexed JSON blobs") contradicts
  its own §2 bundle DDL, which stores exactly those blobs. Build the child
  rows. Remaining known gaps: `screenshot_id` FK has 0 hits in `BE/` (events
  link snapshots by sequence number, not FK — doc 07 Delta 6); `ScreenCoordsJson`
  remains a JSON column (never in any wave's normalization scope); no category
  index (built indexes: session id, created time, hostname, event session id,
  event source file).
- **CLI syntax (doc 05 §2/§4).** `--drill-down` is a BOOLEAN modifier only:
  `--session <ID> --step <N> --drill-down [--depth <LEVEL>]`. The value form
  `--drill-down <ID>` does not exist (doc 07 Delta 7, carried divergence).
  `--depth LEVEL` implies `--drill-down`. `--json` envelopes the ERROR LIST
  only; no per-step JSON envelope exists (doc 07 Delta 8, carried divergence).
  `--limit` is a generic error-query flag, not a `--recent-bugs`-scoped option
  (`--recent-bugs` prints 20 sessions by default).
- **Bundle manifest (doc 04 §1/§2).** Neither writer emits `$schema`,
  `generator`, or any checksum. Browser manifest: `manifestVersion`,
  `bundleVersion`, `sessionId`, `title`, `category`, `sessionSummary`,
  `projectAttached`, optional `machine`, `exportedAt`. CLI manifest: same two
  version keys. Import accepts `bundleVersion` OR `manifestVersion`. Browser
  export OMITS the machine block entirely when no saved block exists, rather
  than synthesising one (the honest behaviour installed after removing the
  synthetic `window.location.hostname` / hardcoded `"operator"` block — a blind
  AI following §2 literally would fabricate the block; do not).
- **Listener list (doc 06 §2).** `startGlobalInterception` registers `click`,
  `mouseover` (hover, extra), `change`, `error`, `unhandledrejection`
  (`src/lib/recorder/event-interceptor.ts`). No `input`, `keydown`, or
  `popstate`/`hashchange` listener is registered there. (Input handling exists
  via the `change` path; route changes are captured through other telemetry —
  but the spec's listener list is not what is wired. Build the wired list.)
- **Loader skeleton (doc 02 §1).** Doc 02 prescribes a `Loader2` skeleton with
  `data-testid="recorder-launcher-skeleton"`. That test id has 0 hits in `src/`
  and the launcher has no `isMounted` gate: the launcher renders idle state
  from `isBusy` + store state. The skeleton prescription is dead — do not build
  it. (The actual loading pill the user photographed is the guided-simulation
  button inside the shell actions pill; see Delta 17.)
- **Step-card machine block (doc 05 §3).** The card's machine context comes
  from the session header / latest report, not a per-card HOST & REPORTER
  section as drawn. The data is reachable; the layout is not the spec's.
- **Store divergence (doc 05 assumption).** Spec 27 assumes one store behind
  `--recent-bugs` and `--step`. Reality: `--recent-bugs` reads
  `.logs/errors.db` after syncing disk sessions into it, while `--step` /
  `--export-bundle` resolve from disk dirs only. A session listed by
  `--recent-bugs` whose disk dir was cleaned fails `--step` with "not found".
  A future wave must pick one: DB fallback for `--step`, or pruning of
  disk-less rows from the synced list. Until then, build both resolution paths
  and document the divergence to the user.
- **1-click rerun (doc 04 §3 step 5 / doc 02 §3).** "Load Project & Re-Run
  Inspection in 1 click" after import is UNVERIFIED: import proves registration
  and listing, not the rerun action. Do NOT claim it without a click-level
  proof. (Tracker "Resend Email" and "Cloud Sync" actions likewise do not exist
  as tracker buttons; the only cloud surface found is a Supabase settings
  toggle, and email dispatch is the Delta 15 modal notifier, not a tracker
  "Resend".)

## Delta 17 (NEW, Program 146): loader + teardown runtime contracts

These contracts live in program 146 evidence, not in spec 27's original design.
A blind AI rebuilding the current app must honour them, or it reintroduces the
two user-facing defects program 146 fixed.

- **Loading pill identity.** The top-bar pill the user photographed (spinner +
  "LOADING", immediately left of the `Healthy` badge, then theme toggle, then
  OS window controls) is the guided-simulation button inside the shell actions
  pill (`src/components/layout/shell/ShellActionsPill.tsx`) — NOT the recorder
  launcher button. The recorder button's only loading state is `isBusy` →
  `SAVING...` while stopping a recording, and it renders `Record Bug`, enabled,
  immediately. The `Healthy` badge itself (`TopBarErrorButton`,
  `data-testid="topbar-error-status-pill"`) was untouched by the fix: no healthy
  state is faked.
- **Never-expiring waits are banned.** Three such waits caused the photographed
  symptoms; each now has a bounded replacement:
  - Simulation loading state (`useShellMenu` `isSimulationLoading`, previously
    changed only on a `ca:guided-simulation-state` event with no timeout):
    8000 ms watchdog (above the tour start's ~6700 ms worst normal path);
    refresh re-arms it; clearing/running events and unmount clear it; running
    and loading are exclusive. A lost clearing event now clears the spinner by
    +10 s at the latest instead of never.
  - Pre-hydration splash (previously gated on project-store hydration + a
    2500 ms cap on top of bundle load while menu markup was already in the
    DOM): the splash now dismisses on React mount; hydration continues in the
    background and data fills in. The 6 s no-JS watchdog stays. (This
    deliberately supersedes spec 146 doc 02 Invariant 2; the program doc was
    left unedited per fence, and this delta records the supersession.)
  - Bug-session fetch (previously no `AbortSignal`/timeout — a hung backend
    left "Querying task.db…" spinning forever, and failures showed a misleading
    "No sessions" empty state): 8000 ms timeout via `AbortController` + race,
    with an honest "could not be loaded in time — not shown as empty" fallback
    and a Retry button. Same defect class remains one layer deeper: tracker
    card step-detail fetches (6 call sites) still have no timeout — a follow-up
    item, not a reason to reintroduce an unbounded wait at the entry path.
- **Teardown probe semantics.** The supervision probe must test WINDOW existence,
  not process existence: a recorded PID counts only with a visible main window
  (no WMI call on the cheap path); the delegation fallback counts visible
  app-titled windows; CIM scanning is throttled to 1 call per 2 s and returns
  loop-neutral null when throttled; a command-line match counts only if the PID
  also owns a window. Rationale: the old probe returned true for any Chrome
  process whose command line contained the app URL, even with no window, so
  background processes and leftovers from stuck runs kept the supervision loop
  alive forever and the terminal exit unreachable — each stuck run planted a
  probe-positive process for the next run. The tree kill must verify + retry
  and return a gone/refused contract (never print "terminated cleanly"
  unconditionally); reused-service PIDs recorded at startup and the browser PID
  file join the cleanup kill list; cleanup verifies tracked PIDs + both ports
  (8787 backend, 5173 frontend) and warns instead of falsely claiming success.
  Backend browser kill must be a direct spawn that survives the backend's
  50 ms suicide (no daemon-thread fire-and-forget). Windows live close runs
  (OS X click, Alt+F4, in-app Exit) remain owed on the user's machine: a Linux
  simulation is not a Windows proof.
- **Why:** program 146 Phases 2–3. Evidence:
  `02-spec/21-app/146-bug-reporting-and-tracking-specs-confirmation/evidence/phase-2-topmenu.md`
  and `phase-3-close.md`.

## How to verify this delta (blind-AI checklist, for Phase 4)

A fresh reader with ONLY spec 27 (docs 01–06 + 07 + this 09) should be able to
trace each of these to a section without opening the codebase: bug-NNN allocation
+ collision + rename rule (Delta 9); slug derivation + retitle routes (Delta 9);
`--latest` / `--by-title` / `--by-slug` + derived suggestions (Delta 9); PATCH
machine validation + `corrected` badge + README note + never-stamp-`harvested`
(Delta 10); backend snippet columns + ±5-line resolution + precedence + CLI/card
rendering (Delta 11); raster method + consent banner + storage key + kind
vocabulary + fallback honesty + path prediction + async-coverage limit +
filename lie (Delta 12); dwell constant + `seqNumber = stepNumber` + sim-step
surfacing + missed stamp + auto-start + chrome traced exception + enum + ids
(Delta 13); audit table + row shape + `/latest` + dual-store fence (Delta 14);
import-zip route + validation list + idempotency + modal server import
(Delta 14); faithful email notifier + the full vapor list it replaces
(Delta 15); PascalCase table/column names + child-row bundles + drill-down
boolean form + error-list-only `--json` + manifest without `$schema`/generator/
checksums + wired listener list + dead skeleton prescription (Delta 16); pill
identity + watchdog + splash-on-mount + sessions timeout + window-existence
probe + verified tree kill (Delta 17). Any item that cannot be traced is a gap
in this delta, not in the reader.
