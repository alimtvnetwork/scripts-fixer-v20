---
id: multi-03-matrix
name: Multi-Prompt Chapter 3 Matrix
description: Multi-dimensional verification matrix chapter.
category: verification-chapter
placeholders: []
version: 1
---

# 🔍 CHAPTER 3: MULTI-DIMENSIONAL VERIFICATION MATRIX

Perform and report on the following 4 verification dimensions:

### 3.1 Completeness & Feature Verification
- [ ] Are all requirements from every prompt listed in Chapter 2 completely implemented?
- [ ] Are all user-facing interactions functioning properly?
- [ ] Are state transitions, modals, hotkeys, and event handlers operational?

### 3.2 Pre-flight Quality Gates & Compilation
- [ ] Run and pass `npm run build` or typecheck locally.
- [ ] Run Rust gates if applicable: `cd src-tauri && cargo fmt -- --check` and `cargo clippy --all-targets --all-features`.
- [ ] Zero compiler errors, zero unresolved linter warnings.

### 3.3 CI/CD & Pipeline Health
- [ ] Check local runner or CI status (`gitmap pe -t` or `gitmap e d`).
- [ ] Ensure test suites and integration tests pass without flake.

### 3.4 Governance & Coding Standards
- [ ] Strictly relative repository paths used throughout.
- [ ] Positive boolean polarity enforced (no double negatives).
- [ ] All fallible operations routed through AppError / error store (no bare `catch {}`).
- [ ] Releases and changelogs attributed strictly to `@aukgit` (`(Thanks to @aukgit)`).
