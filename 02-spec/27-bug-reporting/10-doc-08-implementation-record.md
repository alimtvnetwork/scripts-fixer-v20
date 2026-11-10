# Specification 27.10: Doc 08 Implementation Record (Spec 147)

This document records what was actually built for doc 08
(`08-script-notification-and-alerting.md`) in program 147. It does NOT
rewrite doc 08 or doc 09: doc 08 remains the contract, doc 09 Delta 15
remains the supersession notice, and this document is the implementation
record that resolves Delta 15's implement-or-delete decision by
IMPLEMENTATION (user decision 2026-11-03).

## Delta 15 resolution

Doc 09 Delta 15 declared doc 08 SUPERSEDED pending an implement-or-delete
decision, with a faithful notifier spec and a vapor list (UNE envelope,
webhook HMAC + 5 s timeout, `BUG_NOTIFY_SCRIPT` runner, SMTP dispatch,
SQLite queue, retry/backoff, auto-flush, three CLI flags — all zero-hit
before program 147). Every vapor item is now built and proven by
execution; the checklist in doc 08 §5 is verified true except for the
flagged deltas below. No doc 08 item was silently substituted: each delta
names the exact reason and the closest honest equivalent built instead.

## Per-item record

### §2 Notification Envelope (UNE) — BUILT, exact shape

- Backend: `BE/routes/bug_reporting/notification_envelope.py`
  (`build_une_envelope`, `build_rules_breakdown_from_events`,
  `build_event_id`, `sign_payload` / `verify_signature`).
- CLI: `bin/errors-cli.py` + `03-ai-scripts/53-errors-cli.py`
  (`notify_build_envelope`, `notify_build_rules_breakdown`,
  `notify_sign_payload`) — same field spec, self-contained stdlib-only
  (the CLI cannot import BE by design).
- Cross-implementation proof: a CLI-built envelope's HMAC verifies
  under the backend verifier (proven in the spec 147 evidence file).
- Field rules, all honored: `EventId` is `evt-notif-YYYYMMDD-HHMMSS-XXXX`;
  `EventType` is exactly `BUG_RECORDING_FINALIZED`; `Severity` is ERROR
  when the session `ErrorCount` > 0, else INFO; `Machine.Source` is the
  stored `MachineSource` value when present, else `harvested`;
  `StepCount`/`ScreenshotCount` default to 0, never fabricated;
  unknown summary/artifact fields are `None`, never invented.
- RulesBreakdown comes ONLY from disk `session.json` analysisStep
  events with an identifiable rule (`ruleId`/`rule_id`/`stepName`).
  Verdict precedence per event: boolean `isPassed`/`passed`/`isPass`,
  then `status`/`verdict` string (PASS/PASSED/OK vs FAIL/FAILED/ERROR),
  then `confidenceScore` >= 80 (or >= 0.8 on a 0–1 scale). Per-rule
  verdict is FAIL if any event failed. Events without a rule identifier
  are skipped, never invented. The `BugSession` row already carries
  `Description`/`ExpectedBehavior`/`ActualBehavior`, so `Summary` is
  honestly populable from stored data.

### §3 Transport A: Webhook HTTP POST — BUILT, exact headers

- Backend: `send_webhook` in `notification_transports.py`; CLI:
  `notify_send_webhook`. Headers are exactly `Content-Type:
  application/json`, `X-Bug-Signature: sha256=<hmac_hex>`,
  `X-Correlation-Id` (always sent; a caller-supplied id wins, otherwise
  a fresh uuid per dispatch). Timeout is exactly 5 s. A 2xx status is
  success; anything else (HTTP error, timeout, network error) is a
  queueable failure recorded with an honest `LastError`, never lost.
- Config: `NOTIFY_WEBHOOK_URL` + `NOTIFY_WEBHOOK_SECRET` from
  environment. A per-request `webhookUrl` override is accepted on the
  backend notify route (loopback-only); a per-request secret is
  REJECTED with 400 (secret-in-body guard).

### §3 Transport B: Local Shell Script Execution — BUILT, two deltas

- Backend: `run_notify_script`; CLI: `notify_run_script`. Invocation
  is exactly `$BUG_NOTIFY_SCRIPT <BUNDLE_ZIP_PATH> <SESSION_ID>` with a
  30 s runner timeout. Exit 0 is success; non-zero, missing file, or
  timeout is a queueable failure with the output tail (last 500 chars)
  kept in `LastError`.
- DELTA B1 (config source): doc 08 allows `run.config.json` as an
  alternative script source. NOT implemented: the script path comes
  from `BUG_NOTIFY_SCRIPT` (both sides) or the backend stored
  `scriptPath` setting. Reason: no `run.config.json` loader exists
  anywhere in the codebase, and inventing a new config file format was
  out of scope; env + stored setting covers the specified behavior.
- DELTA B2 (warning log): doc 08 says a non-zero exit triggers "a
  logged warning in `.logs/telemetry.log`". Implemented as the queue
  row's `LastError` column plus a CLI stdout line, NOT a telemetry.log
  write. Reason: no telemetry.log writer exists in the codebase; the
  queue row is the durable, queryable record of the same warning.

### §3 Transport C: Email with Offline Queue — BUILT, two deltas

- Formatting: the EXISTING dual text/HTML formatter
  (`src/services/telemetry/email-notifier.ts` `formatEmailNotification`)
  is reused unchanged; the backend renders the same structure
  server-side (`render_email_bodies`) from the envelope. SMTP dispatch
  is stdlib `smtplib` with STARTTLS on port 587 and login only when
  user + password are present; the SMTP factory is injectable so tests
  never perform a real send.
- Offline storage, both halves: browser `localStorage`
  (`cat_vision_offline_email_queue`, capped at the last 50 entries,
  count-only reads before program 147) is now a real capture buffer:
  new exports `getOfflineEmailQueueEntries()` (validated array, else
  `[]`), `clearOfflineEmailQueue()`, and
  `flushOfflineEmailQueue(baseUrl)` (POSTs to
  `/bug-reports/notifications/browser-flush`, clears ONLY on success,
  never throws). Backend `BugNotificationQueue` rows carry the email
  subject/text/html in columns (never a JSON blob).
- Auto-flush: (a) best-effort drain at the start of
  `dispatchBugReportEmail`, only when `navigator.onLine` and the queue
  is non-empty, fire-and-forget with a 3 s timeout, errors swallowed,
  never delaying the send; (b) drain after a successful modal backend
  delivery (`RecorderEmailModal`, same best-effort rule, no request
  when the queue is empty); (c) CLI `--flush-notifications` as the
  next-run preflight equivalent. Browser-originated rows flush from
  their stored bodies even when the session row is gone.
- DELTA C1 (dark theme): doc 08 describes a "dark-themed styled summary
  table". NOT restyled: the pre-existing formatter's light styling is
  kept verbatim. Reason: restyling is cosmetic scope outside the
  notification system; the dual-MIME contract itself is met.
- DELTA C2 (bundle/screenshot links): doc 08 describes "direct links to
  local bundle and screenshots" in the HTML body. NOT added: the
  pre-existing formatter lists counts, not links. Reason: same as C1 —
  a pre-existing formatter gap, flagged here, not introduced by this
  program. The backend renderer likewise carries no links.

### §4 CLI Notification Command Interface — BUILT, exact forms

- `python bin/errors-cli.py --session <ID> --notify` (modifier flag,
  like `--drill-down`). Resolution: `--session` wins, else
  `--recording`, else the newest backend task.db row. Honest failure
  when no session exists (exit 1, stderr message).
- `python bin/errors-cli.py --list-offline-notifications` — lists queue
  rows newest first with status, transport, session, attempt count,
  next retry, and truncated error.
- `python bin/errors-cli.py --flush-notifications` — retries due rows
  only (pending always due; retry only past `NextRetryAt`), rebuilding
  envelopes from sessions; prints attempted/delivered/still-open.
- Both CLI copies (`bin/errors-cli.py`, `03-ai-scripts/53-errors-cli.py`)
  are byte-identical (program 143 convention, verified with `cmp`).

### §5 Blind-AI Implementation Checklist — verified

1. `NotificationConfig`: backend `resolve_notification_config`
   (webhookUrl/scriptPath/smtp*/has* + secret-presence booleans) +
   pre-existing frontend `EmailConfig` + CLI env-only config. TRUE.
2. Persistent config storage (`localStorage` AND SQLite settings):
   `NotificationSettings` table (non-secret keys only) + pre-existing
   `localStorage` email config. TRUE with a deliberate, flagged rule:
   SECRET values (webhook secret, SMTP password) are NEVER stored in
   SQLite or localStorage — environment only. A literal reading of
   "SQLite settings" for secrets would violate the program's
   no-credentials-in-storage rule, so the allow-list rejects them.
3. Payload serializer (session + breakdown into JSON envelope): backend
   + CLI builders, cross-verified. TRUE.
4. Retry loop with exponential backoff: delays (60, 300, 1800, 7200,
   28800) seconds indexed by attempts already made (1-based); after
   attempt 6 fails there is no next retry (exhausted rows wait for a
   manual flush). TRUE.
5. Exact machine hostname/OS/user identity: taken from the stored
   session row, never fabricated; missing values stay `None` rather
   than re-harvesting the live machine (which would misattribute the
   recording machine). TRUE with that flagged rule.

## Design decisions (recorded, not buried)

1. **Per-column queue, envelope rebuilt at flush.** Doc 08 says
   failures "enqueue into bug_notification_queue" without specifying
   payload storage. The queue stores per-column dispatch metadata ONLY
   (program 143 normalization rule: no envelope JSON column). The
   envelope is rebuilt from the session at flush time; browser rows
   rebuild from stored subject/text/html columns. No data is lost by
   this: every field the envelope needs is either a session column or
   a stored body column.
2. **Backend task.db path, and the CLI divergence.** The backend
   resolves its db root from `APP_DB_ROOT`, then the platform state
   directory (Linux `~/.local/state/vision-app`, Windows
   `%LOCALAPPDATA%/vision-app`, macOS `~/Library/Application
   Support/vision-app`). The CLI's legacy `resolve_db_dir()` checks
   `~/.local/share` on Linux and can MISS the backend's DB — a
   pre-existing divergence, documented, NOT silently changed for all
   CLI reads. CLI notification code therefore uses a new
   `resolve_backend_taskdb_dir()` (APP_DB_ROOT → platform state dir →
   legacy fallback) so the CLI queue shares the backend's task.db.
   Live task.db on this VM: `~/.local/state/vision-app/db/task.db`.
3. **Non-secret-only stored settings.** Allow-list:
   `webhookUrl`, `scriptPath`, `smtpHost`, `smtpPort`, `smtpUser`,
   `smtpFrom`, `defaultRecipient`. Anything secret-looking in a request
   body is rejected with 400. GET config returns presence booleans +
   redacted URLs (userinfo, query, fragment dropped), never values.
4. **Unconfigured rows.** A notify with no transport configured
   enqueues ONE row with transport `unconfigured`, status `pending`,
   and an honest `LastError` (nothing to attempt with is not a
   transport failure, but the intent must not be lost). Flush resolves
   it against whatever transports are configured by then, in webhook,
   script, email order; the row keeps its original transport value so
   history still shows it was queued unconfigured.
5. **Successful dispatches also write `delivered` rows.** The queue is
   audit history, not just a retry list: every dispatch outcome lands
   in it, so `--list-offline-notifications` shows delivered work too.
6. **Flush scope.** Backend and CLI flush retry DUE rows only; a
   `retryAll` backend flag (and only that flag) retries all open rows,
   including exhausted ones. Manual flush never deletes a row whose
   session is gone — it is kept with `LastError` "session not found".
7. **Browser entries without a session id.** Legacy localStorage
   entries predate session linkage and carry no session id. They flush
   as `SessionId`-NULL email rows retried from stored bodies — never
   mapped from `ticketId` (which is not a session id). New entries
   store the dispatch session id alongside the payload (the POST body
   shape is unchanged).

## Routes (all loopback-guarded by the coordinator)

- `POST /bug-reports/notifications/notify` — dispatch now.
- `GET /bug-reports/notifications/queue` — list rows (`?status=`, `?limit=`).
- `POST /bug-reports/notifications/flush` — retry due rows (`{retryAll}` for all open).
- `POST /bug-reports/notifications/browser-flush` — drain browser entries.
- `GET /bug-reports/notifications/config` — non-secret config view.
- `POST /bug-reports/notifications/config` — store non-secret settings.

## Files

- Backend: `BE/routes/bug_reporting/notification_envelope.py`,
  `notification_transports.py`, `notification_handler.py`,
  `BE/repos/sqlite_bug_notification_queries.py`,
  `BE/repos/sqlite_bug_notification_repo.py`,
  `BE/db/migrations/task/0036_task_notification_queue.sql`,
  `BE/routes/bug_reports.py` (route wiring only),
  `BE/tests/routes/test_bug_reports_notifications.py` (21 tests).
- CLI: `bin/errors-cli.py`, `03-ai-scripts/53-errors-cli.py`
  (byte-identical).
- Frontend: `src/services/telemetry/email-notifier.ts`,
  `src/components/recorder/RecorderEmailModal.tsx`,
  `src/services/telemetry/__tests__/email-notifier-flush.test.ts`
  (7 tests).
- Evidence: `02-spec/21-app/147-doc-08-notification-implementation/evidence/notification-implementation.md`.
