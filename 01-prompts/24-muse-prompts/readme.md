# Muse Prompts (`24-muse-prompts`) — Index & Catalog
> 2026-11-14 update: read the "2026-11-14 update" section at the end of this file BEFORE using these prompts. It points to the verified-lessons sections added on 2026-11-14. Do not skip it.

> [!IMPORTANT]
> Category: `24-muse-prompts`
> Architecture: Self-Bootstrapping Autonomous Onboarding Directive
> Scope: Muse AI Session Bootstrapping, Operating Contract, and Multi-Agent Execution

---

## Overview

The `24-muse-prompts` prompt category houses the master onboarding prompt for
Muse AI sessions. Pasting the master prompt into a fresh Muse chat boots a
fully-onboarded autonomous agent: repository intake, terminal + GitHub auth
bootstrap, GitMap clone/build/learn, a memory operating-contract checklist
(turbo mode, strict no-delete guards), coding-guideline and design-system
intake — and then the standing **Task Confirmation & Multi-Agent Execution
Protocol**: every user message that is work gets a confirmed task breakdown
first (`Understood: [YES]` per task), then multiple concurrent agents complete it.

The canonical execution engine it delegates to is
[`02-execute-parent-task-with-n-steps.md`](../14-execute/02-execute-parent-task-with-n-steps.md)
(Canonical V6: `N = 300`, `A = 2`, `H = 2`, `C = 30`).

Its installable skill is `muse-master-prompt`
(`.agents/skills/muse-master-prompt/skill.md`, mirrored in `.cursor/skills/`).

---

## Directory Index & Catalog

| Prompt File | Version | Scope | Key Capabilities |
| :--- | :--- | :--- | :--- |
| [`01-muse-master-prompt.md`](01-muse-master-prompt.md) | 1.0.0 | Master Onboarding | Self-loop Phases 0–5, auth bootstrap, GitMap intake, memory contract checklist, task-confirm + multi-agent protocol, verification gates. |

---

## Directory Tree

```text
01-prompts/24-muse-prompts/
├── 01-muse-master-prompt.md   # the master prompt (paste into a fresh Muse session)
└── readme.md                   # this index
```

## 2026-11-14 update — verified lessons (read before using these prompts)

> Added 2026-11-14 after a verified live session (GitMap binary v6.681.2). The prompt files in this folder now carry a `2026-11-14 Verified Lessons` section: a root-cause analysis of verified failures (SSH mistaken for API auth, HTTP 401 on repo creation, pushes to nonexistent remotes, ignored clone flag, destructive defaults), mandatory pre-start learning (MCP server, `gitmap` skill, LLM training, `gitmap` skills — via binary `--help` and status output before acting), and how repo creation actually works (auth-state check first, verify-before-push, exact failure modes). Read that section in `01-muse-master-prompt.md` in this folder before acting. The installed binary's `--help` output is authoritative; never claim a URL without verification output.
