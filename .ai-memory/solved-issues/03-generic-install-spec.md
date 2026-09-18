# Generic Install Spec — Awaiting Checklist Confirmation

**RESOLVED** 2026-04-23 — User confirmed defaults: probe v1..v20, HTTP HEAD, auto-redirect, log-only when no newer found. 7 spec files written under `02-spec/00-generic-install-script-behavior/`. Memory updated, version bumped 0.74.0 → 0.75.0.

## Description
User asked for a generic, cross-repo install-script behavior spec covering strict release-tag mode, main-branch fallback, and versioned-repo discovery (v1..v20 parallel). A 15-item confirmation checklist was posted in chat covering naming, discovery range, probe mechanism, strict-mode triggers, and spec file layout. Implementation is **blocked** until the user replies with per-item confirmations.

## Root Cause
Several semantic ambiguities in the original brief that must be resolved before the spec can be written generically and unambiguously:
- "Next twenty repos" was clarified to mean **fixed window v1..v20** (latest user msg) — but earlier they said "both directions current-1 + current+20". Need final lock-in.
- Whether discovery should auto-upgrade or just log.
- Exact strict-mode triggers (flag names, env-var names, URL patterns).

## Steps to Reproduce
1. User runs `quick-install` / `release-install` / `error-manage` from any repo.
2. Behavior should match the generic spec — but the spec doesn't exist yet.

## Attempted Solutions
- [x] Draft 15-item checklist posted to user — awaiting reply
- [ ] Write 7 spec files under `02-spec/00-generic-install-script-behavior/`
- [ ] Update `mem://features/install-bootstrap` to reference the generic spec
- [ ] Produce per-repo migration plan

## Priority
High — user explicitly asked for this and wants to share the spec with other AIs.

## Blocked By
None. Resolved on 2026-04-23.

## Solution
- Captured and verified 15-item user checklist.
- Authored 7 specification documents under `02-spec/00-generic-install-script-behavior/` covering strict release-tag mode, main-branch fallback, and versioned discovery across `v1..v20`.
- Updated `mem://features/install-bootstrap` and bumped version to `v0.75.0`.

## Iteration Count
2 iterations (initial ambiguous draft followed by locked 15-item user confirmation).

## Learning
- Ambiguities in cross-repo script specifications must be locked via an explicit enumerated checklist before code authoring.
- Fixed window `v1..v20` discovery is deterministic and prevents infinite redirect loops across mirrors.

## What NOT to Repeat
- Never author cross-repository bootstrap code based on implicit assumptions about discovery window size or auto-upgrade behavior.
