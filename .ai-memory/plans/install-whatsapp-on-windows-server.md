# Master Plan: install-whatsapp-on-windows-server

> **Slug:** `install-whatsapp-on-windows-server`  
> **Status:** `ACTIVE`  
> **Parent Task ID:** `task-20261016180011-install-whatsapp-on-windows-server`  
> **Budget:** 300 steps (Phase 1: 150, Phase 2: 150)

---

## User Request (Verbatim)

```
# Install WhatsApp on Windows Server: high priority instruction, non-negotiable task

In the scripts fixture, try to install WhatsApp in Windows Server. Usually, you cannot, so try to find a goal, try different approaches, and you can do anything in this machine. It's a VM snapshot taken, so you can try out anything that you like. Make sure that we have installed WhatsApp into the Windows Server machine and also Ubuntu and Windows is easy. Regular Windows is easy. Try to do that. At the end, do a release bump and do a minor release.

## slug: install-whatsapp-on-windows-server

# Actionable Items Must Follow Non-Negotiable

1. Write spec under 02-spec/21-app/install-whatsapp-on-windows-server/ and enqueue plan task in .ai-memory/plans/install-whatsapp-on-windows-server.md (subtasks in .ai-memory/plans/subtasks/install-whatsapp-on-windows-server/) first
2. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String
3. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well
4. Use `gitmap` AI agents to enter data
5. Task completion includes committing and pushing to Git
6. Ensure WhatsApp is installed on Windows Server, Ubuntu, and regular Windows. Perform a release bump and a minor release.

## Must follow and spawn agent using

@[.agents/skills/execute-parent-task-with-n-steps-v6]

## Additional Instructions

- /plan first before doing the work to reduce the credits.
- /learn from @[.agents/skills/gitmap] skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- Only add the relative paths, never add the absolute path during your work; this should be respected on the release page and in release notes as well.
```

---

## Discrete Deliverables & Task Breakdown

| Task-ID | Title | Scope | Target Files | Owner | Status |
|---|---|---|---|---|---|
| **Task-01** | Research & Technical Discovery | Root cause analysis of Windows Server store rejection (`0x803fb104`), browser engine availability, and Linux packages | - | Research 01 & 02 | `DONE` |
| **Task-02** | Architectural & Component Specs | Author full specs in `02-spec/21-app/install-whatsapp-on-windows-server/` and subtask plans | `02-spec/21-app/install-whatsapp-on-windows-server/*`, `.ai-memory/plans/subtasks/install-whatsapp-on-windows-server/*` | Spec Subagents | `IN_PROGRESS` |
| **Task-03** | Windows Server Engine Implementation | Multi-tier installer supporting Windows Server (Chrome/Edge App launcher, native `WhatsApp.exe`, desktop shortcut, protocol handler, cleanup) | `scripts/49-install-whatsapp/*` | Worker 01 | `QUEUED` |
| **Task-04** | Linux (Ubuntu) & Cross-Platform Parity | Author `scripts-linux/49-install-whatsapp/run.sh`, wire into dispatchers (`run.ps1`, `scripts-linux/run.sh`) | `scripts-linux/49-install-whatsapp/*`, `run.ps1`, `scripts-linux/run.sh` | Worker 02 | `QUEUED` |
| **Task-05** | Verification & Coding Guidelines Linter | Affirmative booleans (`is*`, `has*`), functions <= 8-15 lines, strict relative paths, timeouts on all executions | Modified files | Lead & Workers | `QUEUED` |
| **Task-06** | Minor Version Release Ceremony | Bump version to minor release via `bump-version.ps1`, sync changelog, atomic GitMap commit and push | `version.json`, `changelog.md`, `scripts/version.json` | Lead | `QUEUED` |

---

## Phase Budget Allocation

- **Phase 1 (Planning & Specs):** Steps 1 .. 40
- **Phase 2 (Parallel Execution & Testing):** Steps 41 .. 120
- **Phase 3 (Consolidation, Verification & Release):** Steps 121 .. 150
