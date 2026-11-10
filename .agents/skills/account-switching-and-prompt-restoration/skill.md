---
name: account-switching-and-prompt-restoration
description: >-
  Autonomously diagnose, test, and resolve running prompt backup and multi-project restoration across account switching in Antigravity Manager, ensuring all running projects have their prompts sent directly to each project's IDE UI window via DevTools CDP.
---

# Account Switching and Prompt Restoration Across All Running Projects

> **Invocation:** `@[account-switching-and-prompt-restoration](directory;.agents/skills/account-switching-and-prompt-restoration)`

This skill governs the end-to-end lifecycle of prompt backup and restoration during account switching:
1. **Multi-Project In-Flight Sweep**: When an account switch or auto-rotation is triggered, sweep all running and in-flight prompts across every project open on that instance into `backed_up` status in both `active_prompts` (`repo_prompts.db`) and `prompt_backups` (`prompt_backups.db`).
2. **Multi-Project Per-Repo Dispatch**: Replace single-prompt restrictions with multi-project per-repo dispatch (`dispatch_all_latest_prompts_per_project`). Every project that was running a prompt prior to switch gets its prompt restored and dispatched to that project's IDE UI window.
3. **CDP Window Focus & Multi-Target Routing**: Target DevTools CDP page targets matching each project's repository name and project ID. Retry up to 4 attempts with exponential backoff so that delayed Electron window title initialization does not abort prompt delivery.
4. **Window Focus Invariant**: Ensure the OS window for each workspace is activated and focused before typing so the active composer accepts keystrokes.
5. **Caller Session Protection**: Never terminate the developer's working session (`lara-pub-6067`). Always run test verifications in transient sandboxes (`agm instances test-create` / `test-clean`).
