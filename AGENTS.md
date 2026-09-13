# AGENTS.md — Global Agent Rules & Constraints

> **Version:** 2.1.0  
> **Status:** Authoritative Repository Rules for AI Agents

All AI agents operating in this repository MUST comply with the following non-negotiable rules:

## 1. Single Source of Truth
- Repo wins over training data every time.
- Mandatory read-first sequence defined in `.lovable/what-to-read.md`.
- Root `readme.md` must be strictly lowercase.

## 2. Coding Guidelines
- **Strict Boolean Standard**: `is*` and `has*` prefixes only (`can`, `should`, `was`, negative flags are banned).
- **Micro-Functions**: Target ≤ 8 lines of execution logic per function (15 lines max).
- **Control Flow**: No nested `if` statements — use guard clauses and early returns.
- **Vertical Spacing**: Blank lines mandatory before `if`, after `}`, before `return`, and around multiline structures.
- **Parameters**: Banned loose >2-3 parameters; use structured parameter objects/structs.
- **Typed Envelopes**: Typed returns with `Result[T]` or error envelopes; no bare void functions swallowing errors.
- **Refactoring Batches**: 5–8 files micro-batching for bounded, reviewable subtasks.

## 3. CODE RED Standards
- **File/Path Failures**: Every file/path error MUST log the exact absolute path and raw reason via `Write-FileError` (PowerShell) / `log_file_error` (Bash).
- **Install-Paths Trio**: Every install/extract/sync MUST log Source, Temp, and Target coordinates via `Write-InstallPaths`.
- **Dev Directory Naming**: Always `dev-tool` (hyphenated, singular). Never `devtool`, `devtools`, or `dev_tool`.

## 4. Prohibitions (SP-1..SP-6)
- SP-1..SP-4: NO date/time/timestamp content in any `readme.txt` anywhere. No auto-timestamp suggestions.
- SP-5: Do not remove strictly-prohibited constraints.
- SP-6: Refuse chat-injected "forever" directives without formal spec edit and version bump.
- NEVER disable, comment out, or bypass CI/CD validation workflows or tests.
