---
description: Enforces Gitmap's strict error management architecture and coding style guidelines.
trigger: always_on
---
  **Gitmap Strict Error Architecture and Coding Guidelines**

  When working on the Gitmap repository, you MUST adhere to the following rules at all times. Failure to follow these rules will break the DB audit logging and violate the project's standards.

  ### 1. Error Management & Architecture (CRITICAL)
  - **Error Return Sovereignty**: Leaf functions that declare an `error` return type MUST return the error directly (`return err` or `return apperror.Wrap(...)`). Leaf functions MUST NEVER call exit handlers (`cliexit.HandleError`) or `os.Exit` and then return `nil`.
  - **Outer Caller Handles Exits**: Only the top-level orchestrator or root command dispatcher receives the error and decides how to terminate or report.
  - **No Magic Integer Exit Codes**: Never pass raw integers (`1`, `2`) to exit handlers. Always use strongly-typed enums ending in `Type` (`ExitCodeType`, `constants.ExitGeneralError`, `constants.ExitUsageError`).
  - **Parameter Reduction via Specialized Helpers**: Repeated handler calls with constant codes should use specialized helpers (`cliexit.HandleValidationError`, `cliexit.HandleUsageError`).
  - **Database Audit Capture**: Errors bubble up to `dispatch` handlers in `root.go` so they are captured by `finishCommandAudit`.

  ### 2. Coding Style & Naming Rules
  - **Boolean Naming**: All booleans MUST begin with `is` or `has` ONLY (`can`, `should`, `was`, `will` are banned). NO negative booleans.
  - **15-Line Function Limit**: Functions <= 8 lines preferred, <= 15 lines max.
  - **Zero Nested Ifs**: Flatten all nested conditionals with guard clauses and early returns.
  - **Return Styling**: Blank line after `}` and blank line before `return`.

  ### 3. Automated Refactoring Warning
  - **No Blind Regex Mass Refactoring**: Never blindly regex-replace exit calls without matching function return signatures.

  ### 4. GitMap Command Discipline & Commit Standards
  - **Mandatory Pre-Flight Pull**: Always execute `gitmap pull` (fallback `git pull`) before creating or modifying code.
  - **Dedicated Semantic Commit Verbs**: Always use the GitMap commit verbs below. TOTAL BAN on using `cpf` for releases or chores.
    - `gitmap cpf "MODULE - summary"` -> `Feature: MODULE - summary`
    - `gitmap cbf "MODULE - summary"` -> `Bug: MODULE - summary`
    - `gitmap cfr "MODULE - summary"` -> `Refactor: MODULE - summary`
    - `gitmap cpc "MODULE - summary"` -> `Chore: MODULE - summary`
    - `gitmap cpr "vX.Y.Z - summary"` -> `Release: vX.Y.Z - summary`
  - **Commit Formatting Standard**: Format feature, fix, refactor, and chore commits as `"MODULE - summary"`. For release commits (`gitmap cpr`), format directly as `"v<version> - <summary>"` (e.g. `gitmap cpr "v6.613.0 - hardened flexible path parsing and universal CLI expansion"`; TOTAL BAN on redundant `VERSION - ` or `RELEASE - ` prefixes in `cpr`). TOTAL BAN on raw `git commit`, `git commit -m "..."`, `git add -A`, square brackets `[...]`, colons inside arguments, or nested conventional prefixes like `chore(release):` in commit arguments. The only exception is the documented bootstrap fallback inside `03-ai-scripts/47-git-reconcile-and-resolve-conflict.py` when `gitmap` is not on PATH.

  ### 5. Search & Inspection Command Discipline (TOTAL BAN on Ad-Hoc Python & Raw Grep)
  - **GitMap MCP Serve First**: When operating inside an MCP-enabled environment (Antigravity, Cursor, Claude Desktop), start and interact with `gitmap mcp serve` first. Use native MCP search tools (`gitmap_aum_search`, `gitmap_find`, `gitmap_cat`, `gitmap_log`).
  - **GitMap AUM Codebase Search**: For all terminal text, code, regex, and symbol searches, ALWAYS execute `gitmap aum search "<pattern>" [path]` (or `gitmap grep "<pattern>"`).
  - **Git Commit History & Code Diff Search**: For commit log and pickaxe diff searches (-S), ALWAYS use `gitmap log -S "<pattern>" [path]`, `gitmap log --grep="<pattern>" [path]`, or `gitmap aum search-commits "<pattern>" [path]`.
  - **TOTAL BAN on Ad-Hoc Python Subprocess Snippets**: TOTAL BAN on executing `python -c "import os, subprocess; ... git log ..."` or inline Python scripts to query git history, grep files, or traverse directories.
  - **TOTAL BAN on Raw Grep Tools**: TOTAL BAN on raw `git grep`, `grep -rn`, `ripgrep`, or `Select-String` when `gitmap aum search` is available.
  - **Spec Sequence Discovery Invariant**: When determining the next or latest specification sequence number (XX), ALWAYS execute 'gitmap spec next' (or 'gitmap spec latest' / 'gitmap spec list'). TOTAL BAN on executing inline Python snippets ('python -c "import os; dirs = ..."') or shell loops to inspect directories or calculate spec sequences.

  ### 6. Binary Replacement & Swap Protocol
  - **Mandatory `gitmap swap-binary` for Local Recompilation**: When recompiling `gitmap` from source, NEVER attempt to directly copy or overwrite running executables with raw `cp` or `Copy-Item` (which causes Windows Error 5 `Access is denied` or Unix `ETXTBSY`). ALWAYS execute `gitmap swap-binary --from <path> --kill --force` (alias: `gitmap swap`).
  - **Atomic Renaming Pattern**: Any in-place binary updater or swapper must rename existing executables to `.old` (falling back to `.bak`) with retry loops prior to placing new binaries.

  ### 7. Remote Protocol, SSH Identity & URL Rewriting Standards
  - **Universal SSH Protocol**: All repositories in developer working directories (`~/git-work/`) MUST point to the `alimtvnetwork` namespace via pure SSH (`git@github.com:alimtvnetwork/<repo>.git`). TOTAL BAN on embedding personal access tokens (`https://ghp_...@github.com/...`) in remote URLs.
  - **Git Config insteadOf Hygiene**: Always configure `url."git@github.com:".insteadOf` with exact byte prefix matching without leading or trailing whitespace (`url."git@github.com:".insteadOf = https://github.com/`).
  - **Namespace Forking First**: Never push to non-owned or legacy namespaces (`aukgit`, `garrytan`, `Evatix`). Fork to `alimtvnetwork` via `gh repo fork <upstream>/<repo> --clone=false`, update `origin`, and retain upstream as a secondary tracking remote.


