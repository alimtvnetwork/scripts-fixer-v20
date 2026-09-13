---
name: Multi-Agent Orchestration Workflow
description: Orchestrates and executes parent tasks by decomposing them into subtasks and running a continuous N-step self-loop with strict 2-agent concurrency and consolidation.
---

# [V2] Parent Task N-Step Continuous Loop & Multi-Agent Orchestration — Workflow

**Prompt Version:** 2.2.0
**Synchronization:** Main Meta-Repo & Connected Workspaces

## The Unified Master Pipeline (Atomic Numbered Steps)

Execute tasks via a strict 3-Phase pipeline:

### Phase 1: Planning Mode & Subtask Generation FIRST (Steps 1 .. N/2)
1. **Scan & Discover:** Spawn 2 planning subagents to deeply scan the codebase for target changes.
2. **Master Spec Generation:** Save the master architectural plan into `.lovable/plans/pending/xx-<slug>.md`. Write 3–5 custom rules or constraints unique to this task inside the spec file.
3. **Lean Subtask Decomposition:** Break down into granular subtasks in `.lovable/plans/subtasks/xx-<slug>/01-<subtask>.md`.
4. **MANDATORY AUTO-LOOP (DO NOT STOP):** Immediately self-loop and transition into Phase 2 without stopping.

### Phase 2: Execution Mode & Parallel Refactoring (Steps N/2+1 .. N)
1. **Parallel Dispatch:** Spawn 2 execution subagents (max 2 threads each) on disjoint subtasks.
2. **Execution & Coding Guidelines:** <= 8–15 line functions, single return types, Unix LF line endings.
3. **Failure Memory & Error Recovery:** Log errors to `.lovable/plan.md` and `.lovable/memory/issues/xx-failure.md`.
4. **Atomic Change Tracking:** Append modified files to `.lovable/temp/recent-file-changes.json`.
5. **Temp & Failure Folder Isolation:** Temp test files in `.lovable/temp/`. Failed tests write to `.lovable/temp/failures/`.
6. **Dual-Queue Worker Pools:** Slow tests vs fast tests.
7. **Dynamic ETA Sleep Protocol:** Read `.lovable/temp/runner-eta.json` to sleep.
8. **Local Verification:** Run targeted linters and ensure code passes with exit code 0 (`exit 0`).

### Phase 3: Task Consolidation & File Reduction (End of Loop)
1. Combine completed subtasks from `.lovable/plans/subtasks/xx-<slug>/*.md` into `.lovable/plans/completed/xx-<slug>.md`.
2. Include a header explicitly referencing how the main task started and documenting step/loop counts.
3. Delete granular `.md` files in `.lovable/plans/subtasks/xx-<slug>/`.
4. Delete parent plan `.lovable/plans/pending/xx-<slug>.md`.
5. Update `.lovable/plans/01-index.md` to point to the newly consolidated completed file.
