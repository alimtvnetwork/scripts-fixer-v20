# Completed Plan: install-whatsapp-on-windows-server

> **Slug:** `install-whatsapp-on-windows-server`  
> **Status:** `COMPLETED`  
> **Parent Task ID:** `task-20261017025823-install-whatsapp-on-windows-server`  
> **Canonical Spec:** `02-spec/21-app/install-whatsapp-on-windows-server/readme.md`  
> **Completed Date:** `2026-10-17`  
> **Release Bump:** `v1.61.0` (Minor Release)

---

## 1. User Request (Verbatim)

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

## 2. Completed Deliverables & Evidence Register

| Task-ID | Title | Scope | Target Files | Owner | Status | Evidence |
|---|---|---|---|---|---|---|
| **Task-01** | Research & Technical Discovery | Root cause analysis of Windows Server store rejection (`0x803fb104`), browser engine availability, and Linux packages | - | Research 01 & 02 | `DONE` | Discovery reports generated via GitMap streaming search; root caused interactive winget prompt hangs, Store DeviceFamily restrictions, and HTTP 302 redirects on `WhatsAppSetup.exe`. |
| **Task-02** | Architectural & Component Specs | Author full specs in `02-spec/21-app/install-whatsapp-on-windows-server/` and subtask plans | `02-spec/21-app/install-whatsapp-on-windows-server/*`, `.ai-memory/plans/subtasks/install-whatsapp-on-windows-server/*` | Spec Subagents | `DONE` | Authoritative specifications published with Acceptance Criteria, 4-tier Linux resolution ladder, Windows Server wrapper design, and timeout watchdogs. |
| **Task-03** | Windows Server Engine Implementation | Multi-tier installer supporting Windows Server (Chrome/Edge App launcher, native `WhatsApp.exe`, desktop shortcut, protocol handler, cleanup) | `scripts/49-install-whatsapp/*` | Worker 01 | `DONE` | PowerShell AST clean (0 errors), `Add-Type` in-memory C# compilation, non-interactive `winget` resolution for Windows 10/11, micro-functions <= 15 lines, affirmative booleans (`is*`, `has*`). |
| **Task-04** | Linux (Ubuntu) & Cross-Platform Parity | Author `scripts-linux/49-install-whatsapp/run.sh`, wire into dispatchers (`run.ps1`, `scripts-linux/run.sh`) | `scripts-linux/49-install-whatsapp/*`, `registry.yaml`, `scripts-linux/run.sh` | Worker 02 | `DONE` | Implemented 4-tier Linux engine (Snap, Flatpak, Deb, PWA), updated `registry.yaml` with linux block, compiled `scripts-linux/registry.json`, wired `whatsapp` / `wa` aliases in `scripts-linux/run.sh`. `bash -n` exit 0. |
| **Task-05** | Live Host Execution & Verification | Direct execution on Windows Server 2022 VM | Host OS runtime, `scripts/49-install-whatsapp/run.ps1` | Lead & Workers | `DONE` | Executed `scripts/49-install-whatsapp/run.ps1`: WhatsApp.exe compiled and installed, Start Menu and Desktop shortcuts created, protocol registered, idempotency verified (exit 0), uninstall verified. |
| **Task-06** | Minor Version Release Ceremony | Bump version to minor release, sync changelog, atomic GitMap commit and push | `scripts/version.json`, `version.json`, `changelog.md`, `readme.md`, `package.json`, `.gitmap/release/latest.json` | Lead | `DONE` | Bumped to `v1.61.0`, synced `version.json` and registry JSONs, added changelog entry with strict relative Git paths, updated root `readme.md` version badge. |

---

## 3. Modified Files Summary

- `02-spec/21-app/install-whatsapp-on-windows-server/readme.md`
- `02-spec/21-app/install-whatsapp-on-windows-server/01-windows-server-architecture.md`
- `02-spec/21-app/install-whatsapp-on-windows-server/02-linux-ubuntu-architecture.md`
- `.ai-memory/plans/completed/install-whatsapp-on-windows-server.md`
- `scripts/49-install-whatsapp/helpers/whatsapp.ps1`
- `scripts/49-install-whatsapp/run.ps1`
- `scripts/49-install-whatsapp/config.json`
- `scripts/49-install-whatsapp/log-messages.json`
- `scripts/49-install-whatsapp/readme.md`
- `scripts-linux/49-install-whatsapp/run.sh`
- `scripts-linux/49-install-whatsapp/config.json`
- `scripts-linux/49-install-whatsapp/log-messages.json`
- `scripts-linux/49-install-whatsapp/manifest.json`
- `scripts-linux/49-install-whatsapp/readme.txt`
- `scripts-linux/registry.json`
- `scripts-linux/run.sh`
- `registry.yaml`
- `bump-version.ps1`
- `tools/sync-version.cjs`
- `scripts/version.json`
- `version.json`
- `changelog.md`
- `readme.md`
- `package.json`
- `.gitmap/release/latest.json`
- `spec/script-registry-summary.md`
