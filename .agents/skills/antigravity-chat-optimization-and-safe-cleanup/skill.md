---
name: antigravity-chat-optimization-and-safe-cleanup
description: Antigravity Chat Optimization, Safe Cleanup, and Memory Re-Indexing protocol. Preserves active running conversations, traces cross-project memory sources, cleans non-running chats project-by-project, and pins core prompts using literal @[<relative-path>] syntax.
---

# Antigravity Chat Optimization & Safe Cleanup Protocol

## Critical Execution Order (Non-Negotiable)

1. **Step 1 (First Action Before Any Cleanup):** Inspect and modify existing cleanup scripts in `02-antigravity-chat-optimization` so active/currently running conversations are strictly detected, excluded, and NEVER closed or removed.
2. **Step 2 (Only After Step 1 Is Verified):** Execute updated scripts to clean up idle/completed chats project-by-project across `repo-cache`, leaving all running chats untouched.
3. **Step 3:** Pin common/essential conversations per project and re-run memory indexing using strict `@[<relative-path-to-read-prompt>]` format.

## Core Directives & Guardrails

- **Preserve Active Sessions:** Multi-tier running detection (presence lock, SQLite `not_fully_idle = 1` or `CASCADE_RUN_STATUS_RUNNING` / `RUNNING` / `PENDING`, in-flight step type 14 prompt detection, and active coordinator UUID immunity).
- **Audit Memory Source:** Trace and document the 7 Antigravity storage layers and isolate memory by repository.
- **Project-by-Project Cleanup:** Clean non-running/stale chats project-by-project.
- **Strict Reference Format:** Recreate and invoke read prompts using literal syntax: `@[<relative-path-of-read-prompt>]`.
- **GitMap Primacy:** Search exclusively via GitMap (`gitmap aum search`, `gitmap find`, `gitmap cat`, `gitmap ps`, `gitmap py`); total ban on `rg`, `ripgrep`, `grep`, `Select-String`.
- **Coding Guidelines:** Functions $\le 15$ lines, positive booleans (`is*`/`has*`), zero nested `if`s, monadic `Result[T]` with strongly-typed `AppError`.
