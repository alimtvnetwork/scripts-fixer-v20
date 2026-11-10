---
id: style-release-blocker-1
name: Release Blocker Round 1
description: Production release blocker gates chapter, round 1.
category: verification-chapter
placeholders: [round, total]
version: 1
---

## 🛑 PRODUCTION RELEASE BLOCKER: GOVERNANCE & QUALITY GATES INSPECTION
> **Writing Style:** `release-blocker` | **Round:** {round} of {total}

### Non-Negotiable Release Gates:
Before certifying release readiness, the following gates MUST pass without exception:
1. **Atomic Version Sync:** Check all 14 version manifest locations for `vX.Y.Z` parity.
2. **Strict Attribution Invariant:** Verify that ONLY `@aukgit` is credited in changelogs.
3. **Pre-flight Quality Gates:** Run `cargo fmt`, `cargo clippy`, and `npm run build`.
4. **Error Visibility Invariant:** Confirm all fallible operations route into `AppError` or `useErrorStore`.

| Release Gate | Verification Command | Gate Criteria | Result | Blocker Status |
| :--- | :--- | :--- | :---: | :---: |
| Rust Formatting | `cargo fmt -- --check` | Exit code 0 | PASS | CLEAR |
| Rust Clippy | `cargo clippy --all-features` | Zero warnings | PASS | CLEAR |
| Frontend Build | `npm run build` | Clean bundle, zero TS errors | PASS | CLEAR |
| Error Visibility | Static inspection | Zero bare `catch {}` | PASS | CLEAR |
