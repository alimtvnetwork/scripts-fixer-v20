# Plan: install-whatsapp-on-windows-server

## User Request (Verbatim)

Install WhatsApp on Windows Server: high priority instruction, non-negotiable task. In the scripts fixture, try to install WhatsApp in Windows Server. Usually, you cannot, so try to find a goal, try different approaches, and you can do anything in this machine. It's a VM snapshot taken, so you can try out anything that you like. Make sure that we have installed WhatsApp into the Windows Server machine and also Ubuntu and Windows is easy. Regular Windows is easy. Try to do that. At the end, do a release bump and do a minor release. Install is stuck, always check with timeout.

## Slug

`install-whatsapp-on-windows-server`

## Spec

`02-spec/21-app/install-whatsapp-on-windows-server/readme.md`

## Subtasks

| ID | Title | Owner | Files |
|----|-------|-------|-------|
| ST-01 | Windows Server detection + chain | Worker A | `scripts/49-install-whatsapp/helpers/whatsapp.ps1`, `config.json`, `log-messages.json` |
| ST-02 | Timeout hardening (all steps) | Worker A | `scripts/49-install-whatsapp/helpers/whatsapp.ps1` |
| ST-03 | Ubuntu installer (new) | Worker B | `scripts-linux/49-install-whatsapp/` (new) |
| ST-04 | Verify regular Windows path | Worker B | `scripts/49-install-whatsapp/` (read-only review) |

## Constraints (non-negotiable)

1. GitMap-exclusive search (TOTAL BAN on rg/grep/Select-String).
2. Relative Git paths only — in commits, release notes, everything.
3. AGENTS.md compliance: `is*`/`has*` booleans, micro-functions, guard clauses, CODE RED error logging.
4. Every install step enforces a timeout (user: "always check with timeout").
5. Atomic commit + push + minor release bump at the end.

## Execution

- Phase 1: 2 research subagents (disjoint: Windows Server approaches / Ubuntu approaches).
- Phase 2: 2 worker subagents (Worker A: ST-01+ST-02, Worker B: ST-03+ST-04) in disjoint file boxes.
- Phase 3: Lead verifies, commits, pushes, bumps minor release.
