---
name: cg-execute
description: Execute coding guidelines enforcement, guard clause flattening, boolean standardization, and micro-function refactoring across repository scripts.
---

# Coding Guidelines Enforcement (`cg-execute`)

Audits and enforces zero-tolerance repository coding guidelines across PowerShell, Bash, Python, and TypeScript.

## Core Directives
1. **Guard Clauses Over Nesting**: Eliminate nested `if` statements. Replace with guard clauses and early returns. Indentation depth must be ≤ 1 level for conditional branching.
2. **Micro-Functions (Target ≤ 8 Lines)**: Keep execution logic atomic and decomposed into modular helpers.
3. **Strict Boolean Standards**: All booleans, parameters, and flags must use `is*` or `has*` prefixes (banned: `can`, `should`, `was`, negative flags).
4. **CODE RED Logging**: Every file/path error must log the exact absolute path and raw failure reason via `Write-FileError` or `log_file_error`.
5. **No Magic Strings or Numbers**: Centralize constants, status indicators, and configuration keys.
6. **Windows Nginx Path Normalization**: Strictly normalize paths in Nginx `.conf` files to forward slashes `/`.

---

## Final Step Git Commit & Push Mandate (Strict Checklist)

- [ ] **MANDATORY FINAL COMMIT & PUSH TO GIT (ANYHOW):** At the FINAL step of the turn, after all targeted files have been refactored, verified with targeted linters, and plans/subtasks consolidated, you MUST stage everything (`git add -A`), create a clean, descriptive conventional commit (`git commit -m "<type>(<scope>): <summary>"`), and push directly to the remote repository (`git push origin <branch>`). Leaving uncommitted changes or unpushed commits on the active branch at the end of a turn is an immediate failure.
- [ ] **TOTAL BAN ON PER-FILE COMMITS (DO NOT COMMIT EACH FILE INDIVIDUALLY):** You MUST NOT create separate git commits for each individual file as you edit them (e.g. running `git commit` after editing File 1, then committing again after File 2 is STRICTLY FORBIDDEN). Committing file-by-file pollutes git log history, creates subagent lock collisions, and breaks atomic rollback/bisectability. All modified files, test change caches, and plan records across the turn MUST be accumulated in the working tree and committed together in a SINGLE grouped atomic commit at the final step before pushing!

---

## Banned Operations Checklist (TOTAL BAN — Auto-Reject on Violation)

- [ ] **NO TEST RUNNING (TOTAL BAN):** NEVER run any tests using Python scripts (`06-cicd-local-runner.py`, `pytest`, runner scripts), Go (`go test ./...`), or any test runner during routine execution turns. Testing is strictly checked later on in CI/CD.
- [ ] **NO BUILD CHECKING (TOTAL BAN):** NEVER run build commands (`go build`, `npm run build`, compiler checks) to verify compilation. Build verification is checked later on in CI/CD.
- [ ] **NO RUNNER SCRIPTS (TOTAL BAN):** NEVER launch background test runners, worker pools, or test inventory loops during routine execution.
- [ ] **NO AUTOMATIC RELEASES (TOTAL BAN):** NEVER bump versions, update changelogs, or trigger releases unless explicitly commanded by the user.
- [ ] **NO PER-FILE COMMITTING (TOTAL BAN):** NEVER commit each file individually as you work (e.g. running `git commit` after editing File 1, then another commit after File 2). Committing file-by-file pollutes git history, creates subagent lock collisions, and breaks atomic changes. All modified files across the turn must be accumulated and committed together in a single atomic commit at the final step.
