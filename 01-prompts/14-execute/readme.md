# Execution Prompts (`14-execute`) — Index & Catalog

> [!IMPORTANT]
> Category: `14-execute`
> Architecture: Canonical V6 Parameter-Driven Multi-Agent Protocol
> Scope: Autonomous Task Execution, Subagent Orchestration, and Continuous Self-Looping

---

## Overview

The `14-execute` prompt category houses the autonomous execution prompts for decomposing and executing complex software engineering tasks.

Two V8 variants exist — the owner picks the canonical one. [`10-execute-parent-task-with-n-steps-v8.md`](10-execute-parent-task-with-n-steps-v8.md) (condensed, v8.1.0) starts with GitMap, requires the spec, and runs a concrete step map in parallel waves under a 400-step ceiling. [`02-execute-parent-task-with-n-steps-v8.md`](02-execute-parent-task-with-n-steps-v8.md) (full engine, v8.0.0) is the speed-first rewrite of the V6 engine (`N = 400` budget, `A = 3`, `H = 2`, `C = 30`): scoped reads, mandatory spec, full GitMap table in-prompt, parallel-plan swarm, batched telemetry, single evidence table, one verification pass, and the rebase-first push-race protocol. Both enforce GitMap command primacy, mandatory Git authorship governance (`gitmap-bot <info@rgitmap.com>`), Time Restriction & Anti-Credit-Waste Dynamic Waiting Protocol, SQLite task tracking, and atomic final commits without raw git usage. [`02-execute-parent-task-with-n-steps-v7.md`](02-execute-parent-task-with-n-steps-v7.md) (V7: V6 + time restriction only) and [`02-execute-parent-task-with-n-steps-v6.md`](02-execute-parent-task-with-n-steps-v6.md) remain frozen as reference — do not edit.

> [!NOTE]
> **Archived Versions Notice:**
> Legacy execution prompt iterations have been archived to [`01-prompts/19-old-execute-prompts/`](../19-old-execute-prompts/readme.md) and [`06-archive/execute/`](../../06-archive/execute/) and are not synchronized downstream. All previous execution skills have been purged from `.agents/skills/` and `.cursor/skills/`, leaving `execute-parent-task-with-n-steps-v6` as the sole canonical execution engine.
>
> **Strict Relative Git Paths Only:** Only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well (TOTAL BAN on `file:///` URIs and absolute filesystem paths).

---

## Directory Index & Catalog

| Prompt File | Version | Scope | Key Capabilities |
| :--- | :--- | :--- | :--- |
| [`01-execute-pending-tasks.md`](01-execute-pending-tasks.md) | Canonical V6 | Backlog Execution | Parameter-driven execution loop (N=300, A=2, H=2, C=30) executing pending tasks in `.ai-memory/plans/pending/` with SQLite tracking and GitMap atomic commits. |
| [`02-execute-parent-task-with-n-steps-v8.md`](02-execute-parent-task-with-n-steps-v8.md) | Canonical V8 | Master Orchestration | Speed-first rewrite of the V6 engine (N=400 budget with plan-set actual count, A=3 pinned, mandatory spec, full GitMap table in-prompt, parallel-plan swarm, batched telemetry, single evidence table, one verification pass, rebase-first push-race protocol). Same 3-phase pipeline, 12-pillar gate, and atomic GitMap commits. See [`10-v6-vs-v8-speed-comparison.md`](10-v6-vs-v8-speed-comparison.md). |
| [`02-execute-parent-task-with-n-steps-v7.md`](02-execute-parent-task-with-n-steps-v7.md) | Prior V7 | Master Orchestration | Parameter-driven execution loop (N=400, A=3, H=2, C=30) with Tree Swarm Hierarchy, mandatory subagents, GitMap author governance (`GitMap automation <info@rgitmap.com>`), Time Restriction Protocol, SQLite task logging, and GitMap atomic commits. |
| [`02-execute-parent-task-with-n-steps-v6.md`](02-execute-parent-task-with-n-steps-v6.md) | Prior V6 Baseline | Master Orchestration | Parameter-driven execution loop (N=300, A=2, H=2, C=30) with mandatory subagents, SQLite task logging, and GitMap atomic commits. |
| [`03-execute-batched-loop.md`](03-execute-batched-loop.md) | V4 | Batched Loop | Micro-task batched multi-agent loop with file collision matrix. |
| [`04-execute-ai-instruction-writer.md`](04-execute-ai-instruction-writer.md) | V4 | Instruction Writer | Decomposes complex prompt requirements into subagents and modular specs. |
| [`05-execute-batched-loop-wor.md`](05-execute-batched-loop-wor.md) | V4 | Batched Loop (WOR) | Batched multi-agent loop without automatic release triggers. |
| [`06-execute-batched-loop-v2.md`](06-execute-batched-loop-v2.md) | V4 | Batched Loop V2 | Streamlined batched loop execution engine. |
| [`07-run.md`](07-run.md) | V6 | Run Script Orchestration | Autonomous execution of run.ps1 / run.sh with GitMap or local-install fallback. |
| [`08-execute-with-e2e.md`](08-execute-with-e2e.md) | Canonical V6 | E2E Testing & Release | Parameter-driven execution loop with mandatory local test suite verification (100% green), Turn 1 commit and test case inventory, audit log inspection, and automated minor version bump release ceremony. |
| [`09-execute-parent-task-with-n-steps-v7.md`](09-execute-parent-task-with-n-steps-v7.md) | Canonical V7 | Master Orchestration | Parameter-driven execution loop (N=400, A=3, H=2, C=30) with On-Call Skill Gates (time-restriction, autobot), recommit protocols, SQLite tracking, and GitMap atomic commits. |
| [`10-execute-parent-task-with-n-steps-v8.md`](10-execute-parent-task-with-n-steps-v8.md) | V8 parallel waves | Spec and step map | GitMap start, required spec, concrete step map under a 400-step ceiling, one parallel wave per turn. V6 and V7 stay unchanged. |
| [`118-gitmap-deployment-and-execution-instructions.md`](118-gitmap-deployment-and-execution-instructions.md) | Canonical V6 | Universal Deployment | Universal repository deployment engine: public GitLab repo scaffolding, 7-Zip LZMA2 multi-part chunking, confidential issue attachments, aria2c-accelerated client installers, dual deploy/minor bump triggers, and one-liner summaries across any fleet repository. |
| [`119-deploy-repository-and-antigravity-tools-instructions.md`](119-deploy-repository-and-antigravity-tools-instructions.md) | Canonical V6 | Public Folder Distribution | Universal public distribution engine: folder-based deployments (`r-files/<folder>/`), 7-Zip LZMA2 multi-volume chunking, automated Python sync (`54-deploy-folder-distribution.py`), native GitMap CLI integration (`gitmap deploy-folder`), and tested unauthenticated one-liners. |

---

## Directory Tree

```text
01-prompts/14-execute/
├── 01-execute-pending-tasks.md
├── 02-execute-parent-task-with-n-steps-v8.md    # Canonical V8 Orchestrator (speed-first)
├── 02-execute-parent-task-with-n-steps-v7.md    # Prior V7 (V6 + time restriction only)
├── 02-execute-parent-task-with-n-steps-v6.md    # Prior V6 Baseline
├── 03-execute-batched-loop.md
├── 04-execute-ai-instruction-writer.md
├── 05-execute-batched-loop-wor.md
├── 06-execute-batched-loop-v2.md
├── 07-run.md
├── 08-execute-with-e2e.md
├── 09-execute-parent-task-with-n-steps-v7.md    # Canonical V7 Orchestrator
├── 10-execute-parent-task-with-n-steps-v8.md    # Spec, step map, parallel waves. V6 and V7 stay frozen.
├── 10-v6-vs-v8-speed-comparison.md             # V6 vs the longer V8 rewrite
├── 118-gitmap-deployment-and-execution-instructions.md
└── readme.md

Archived:
01-prompts/19-old-execute-prompts/
├── 01-execute-robust-loop.md
├── 02-fix-subtask-naming-convention.md
├── 03-execute-parent-task-with-n-steps.md
└── 04-parent-task-in-below-steps.md

06-archive/execute/
├── 06-execute-parent-task-with-n-steps-v2.md
├── 08-excute-parent-old.md
├── 10-execute-parent-task-with-n-steps-v3.md
├── 11-execute-parent-task-with-n-steps-v4.md
└── 12-execute-parent-task-with-n-steps-v5.md
```
