# Error Management — Acceptance Criteria

**Version:** 3.2.0
**Updated:** 2026-04-16

---

## AC-01: Structured Error Response

**GIVEN** any CLI backend encounters an error during request processing
**WHEN** the error response is generated
**THEN** it contains: `Code` (numeric), `Message` (human-readable), `Details` (technical), and `Stack` (up to 40 frames)
**AND** the error code falls within the tool's assigned range per the Error Code Registry

**Edge Cases:**

- **GIVEN** the error originates from a third-party library **WHEN** the stack trace is captured **THEN** both the library frames and the application frames are included with clear delineation
- **GIVEN** the error code is not registered in the Error Code Registry **WHEN** it is returned **THEN** a fallback generic code within the tool's range is used and a warning is logged
- **GIVEN** the error `Details` field contains sensitive data (file paths, credentials) **WHEN** the response is generated **THEN** sensitive values are redacted before sending to the client

---

## AC-02: Frontend-Backend Verification Protocol

**GIVEN** the frontend receives an error response from the backend
**WHEN** the error is displayed in the error modal
**THEN** the user can see the backend error code, the frontend component that triggered the request, and the timestamp
**AND** "Copy All" copies both frontend and backend context

**Edge Cases:**

- **GIVEN** the clipboard API is unavailable **WHEN** "Copy All" is clicked **THEN** a fallback textarea is shown with the content pre-selected
- **GIVEN** the backend returns an error with no `Code` field **WHEN** the frontend processes it **THEN** a synthetic code `GEN-1000` is assigned and a parsing warning is logged

---

## AC-03: Retrospective Document Structure

**GIVEN** a production bug has been resolved
**WHEN** a retrospective document is created
**THEN** it contains: Root Cause, Timeline, Resolution Steps, Prevention Measures, and Related Error Codes

---

## AC-04: Verification Pattern Application

**GIVEN** a developer implements a fix for a known error pattern
**WHEN** they consult the verification patterns documentation
**THEN** they find step-by-step verification instructions specific to the error category

---

## AC-05: Debugging Guide Coverage

**GIVEN** a developer encounters a backend error
**WHEN** they follow the language-specific debugging guide
**THEN** they can identify common issues and each issue links to the relevant specification

---

## AC-06: Quick Resolution

**GIVEN** a common error scenario
**WHEN** the developer consults the cheat sheet
**THEN** they find a 3-step resolution procedure: Identify → Diagnose → Fix
**AND** each step includes the exact command or code to run

---

## AC-BUG-001: Bug-recording spec folder exists and is linked

**GIVEN** the canonical bug-recording spec (task 324, Spec 03 Part 1)
**WHEN** the `04-bug-recording/` folder is inspected
**THEN** it contains `01-bug-record-schema-spec.md`, `02-recording-pipeline-spec.md`, `03-blind-readiness-audit-spec.md`, `readme.md`, and the machine-readable `error-codes.json` index
**AND** the parent folder readme categories table and this criteria file link it

---

## AC-BUG-002: Schema traced to real capture paths

**GIVEN** the canonical bug record schema
**WHEN** each REQUIRED field is checked against the trace table
**THEN** every REQUIRED field cites a real capture path (file + line) in Antigravity-Manager, cat-my-v12, or gitmap-v28
**AND** every TARGET field is marked with a named owner and date, never presented as if it already exists

---

## AC-BUG-003: Blind-readiness audit executed per repo

**GIVEN** the blind-readiness checklist
**WHEN** it is run against Antigravity-Manager, cat-my-v12, and gitmap-v28
**THEN** every item has a pass/fail per repo
**AND** every fail has a disposition (fixed in the wave, deferred as TARGET with owner and date, or filed as a bug with a spec cross-reference)

---

## AC-BUG-004: CLI/UI parity rule stated with an executable check

**GIVEN** the CLI/UI parity rule
**WHEN** the pipeline spec is read
**THEN** the rule states the executable check (CLI list vs UI list, compare id sets)
**AND** the Cat-My modal case is the worked example and Spec 01's local-first fix is referenced, not re-specified

---

## AC-BUG-005: Spec synced to coding-guidelines-v24

**GIVEN** the gitmap-v28 bug-recording spec
**WHEN** the fleet sync mechanism mirrors `02-spec/03-error-manage/` to coding-guidelines-v24
**THEN** the mirrored files are byte-identical and the cross-links resolve
**AND** any conflict with an existing coding-guidelines rule is resolved in favour of the coding-guidelines rule, with the amendment recorded in the spec

---

## AC-BUG-006: No absolute filesystem paths

**GIVEN** the new spec files
**WHEN** they are scanned for absolute paths
**THEN** no absolute filesystem paths appear; all references are relative Git paths in the `repo: path` form

---

## AC-BUG-007: Bug-recording error codes registered

**GIVEN** the `BUG` error codes (18250–18255) in the schema spec
**WHEN** the error-code registry is checked
**THEN** the `BUG` prefix is registered in `03-error-code-registry/error-codes-master.json` (range 18250–18299) and in `02-registry.md`
**AND** the registry validators pass with no collisions

---

## Cross-References

- [Overview](./readme.md)
