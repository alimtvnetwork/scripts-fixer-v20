# Specification 27 — Delta Notes from Implementation (Wave 6, 2026-11-03)

> **Status: DELTA NOTES ONLY. This file does NOT rewrite the spec 27
> contract.** The six contract documents (`01`–`06`) stand as written.
> What follows is the list of places where the built system
> deliberately differs from, or extends, that contract — each with
> the reason and the wave evidence that proves it. A blind-AI reader
> should implement the contract first, then apply these deltas.

## Delta 1 (NEW, Wave 6): `manifest.machine.machineSource`

- **Contract (§04 §2):** the manifest `machine` block has
  `hostname`, `operatingSystem`, `architecture`, `cpuCount`,
  `totalMemoryGb`, `reportedBy`, `runtimeEnvironment`, `nodeVersion`,
  `pythonVersion` — no provenance field.
- **Built system:** the manifest `machine` block gains an OPTIONAL
  field `machineSource` with exactly two values:
  - `"user-override"` — the block was corrected by the user in the
    bug tracker (PATCH `/bug-reports/sessions/{id}/machine`, which
    stamps `BugSession.MachineSource = 'user-override'`).
  - `"harvested"` — the block was captured at record time.
- **Rules (both directions):**
  - Export writes the field only when the value is known; it is
    never fabricated. The browser (tracker card) path passes the
    item's stored value through. The CLI path prefers the task.db
    row (which is the corrected authority) over the disk block,
    because PATCH writes corrected values to the row while disk
    metadata still holds record-time values — shipping the flag on
    a stale block would certify wrong data as corrected.
  - Import honors the field only when it matches the vocabulary;
    any other value is ignored (row untouched, import still 200).
  - Import WITHOUT the field never clears a stored value: the
    session UPSERT does not list `MachineSource` in its
    `ON CONFLICT DO UPDATE` set.
- **Why:** Wave 5 found that re-import of an override-corrected
  session lost the override flag (no field carried it). Evidence:
  `02-spec/21-app/143-bug-reporting-feature-development/evidence/wave-6-verification.md`
  §5, with backend (8/8), CLI repo-path, CLI SQL-fallback, and
  jsdom export proofs.
- **Do not confuse with:** the CLI sync column `machine_source`
  in `.logs/errors.db` (`metadata`/`harvest`), which records how
  the CLI derived identity during sync. Different store, different
  purpose, different vocabulary.

## Delta 2 (carried): browser export filename

- **Contract (§04 §3):** export compresses into
  `<session_id>.bug.zip`.
- **Built system:** the browser (tracker card) export keeps the
  filename `cat-bug-report-<timestamp>.zip`; the CLI uses
  `<session_id>.bug.zip`. Naming divergence only; the existing
  zip-builder test pins the browser pattern. Evidence: Wave 4 §
  "Residuals" item 4.

## Delta 3 (carried): `images/sample-boards/` omitted

- **Contract (§04 §1):** the bundle contains
  `images/sample-boards/` golden reference images.
- **Built system:** omitted on both export paths — no live source
  exists (the Project type has no sample-images field). The bundle
  README states the omission; the inspection frame is the exact
  image under inspection. Evidence: Wave 4 § "Residuals" item 1.

## Delta 4 (carried): tracker export cannot recover image bytes

- **Contract (§04 §3 import step 3):** screenshots land in
  `.logs/recorded-bugs/<session_id>/screenshots/` on import.
- **Built system:** a zip exported from the tracker card carries
  file names and paths but NOT screenshot or inspection-frame PNG
  bytes, because the detail endpoint returns paths, not bytes, and
  no screenshot-serving endpoint exists. The zip README states
  this. Recover bytes from the reporting machine's session
  directory, or export from a live session. Evidence: Wave 4 §
  "Residuals" item 2.

## Delta 5 (carried): tracker event actors default to System

- **Contract (§02/§05):** events carry actor attribution.
- **Built system:** the task.db store has no actor column, so
  tracker-reconstructed events default to `System`. The zip README
  states this. Evidence: Wave 4 § "Residuals" item 3.

## Delta 6 (carried): no `screenshot_id` FK; coordinates stay JSON

- **Contract (§03):** step events link screenshots by
  `screenshot_id` FK, and all settings are per-column.
- **Built system:** events link snapshots by sequence number, not
  by FK; and `SessionEvent.ScreenCoordsJson` remains a JSON column
  (coordinates were never in any wave's normalization scope).
  Everything else in §03 (sessions, events, screenshots, bundles
  with per-column camera/light, rulesets/rules/params as child
  rows, diagnostics) IS normalized per-column. Evidence: Wave 3 §§
  4–7.

## Delta 7 (carried): CLI drill-down syntax

- **Contract (§05 §2):** `--drill-down <ID>` value form.
- **Built system:** the working syntax is
  `--session <ID> --step <N> --drill-down [--depth full|code|stack]`
  (`--depth` implies drill-down; invalid values are rejected
  naming all three). Every printed suggestion uses this form.
  The value form is a new decision if wanted, not an oversight to
  silently add. Evidence: Wave 2 §§ 2, 8.

## Delta 8 (carried): `--json` envelope scope

- **Contract (§05):** a per-step JSON envelope is implied for AI
  consumption.
- **Built system:** `--json` envelopes the error list only; there
  is no per-step JSON envelope. The step card is the human/AI
  readable surface; drill-down sections carry the machine detail.
  Evidence: Wave 2 § 8.
