---
name: Multi-Agent Orchestration Workflow
description: Orchestrates and executes parent tasks by decomposing them into subtasks and running a continuous N-step self-loop with strict 2-agent concurrency.
---

# Parent Task N-Step Continuous Loop & Multi-Agent Orchestration Workflow

**Prompt Version:** 2.1.0

## Master Task Checklist (Atomic Numbered Steps)
1. Phase 1 (Planning & Spec Generation): Spawn exactly 2 planning subagents (max 2 threads each) to scan the codebase and draft `.lovable/plans/pending/XX-<slug>.md`.
2. Phase 1 (Subtask Decomposition): Decompose the master plan into microscopic, actionable subtasks in `.lovable/plans/subtasks/XX-<slug>/*.md`.
3. Phase 1 (Strict Folder Bounding): Restrict all planning logs, active locks, and status reports strictly within `.lovable/` (`.lovable/plans/`, `.lovable/01-index.md`).
4. Phase 1 (Zero-Stop Transition): Immediately upon completing Phase 1, self-loop and transition directly into Phase 2 execution mode without pausing or stopping.
5. Phase 2 (Execution & Code Refactoring): Spawn exactly 2 execution subagents (max 2 threads each) to execute subtasks on disjoint files in parallel.
6. Phase 2 (Failure Memory & Error Recovery): If a subagent fails, record the failure log in `.lovable/plan.md` and `.lovable/memory/issues/`; subsequent agents MUST read the failure log first to remediate root causes.
7. Phase 2 (Quality Gate Verification): Execute local linters and `python 03-ai-scripts/06-cicd-local-runner.py` ensuring `exit 0` before finishing.
8. Ingest `.lovable/memory/01-index.md` for project memory index and past learnings.
9. Ingest `.lovable/strictly-avoid.md` for banned anti-patterns and strict constraints.
10. Ingest `02-spec/02-coding-guidelines/` for domain-specific architectural specifications.
11. Ingest `02-spec/03-error-manage/` for error handling architectures and AppError.
12. Ingest `.lovable/coding-guidelines.md` for master consolidated coding guidelines.
13. Create or update agent rules in the repository if missing from agent memory.

`PHASE_1_STEPS = N / 2`, `PHASE_2_STEPS = N / 2`. 
*N, PHASE_1_STEPS, and PHASE_2_STEPS are read-only after initialization. Never modify them mid-execution.*

## 1. 2-Agent Concurrency & Ruthless Orchestration
- **Strict 2-Agent Limit (Max 2 Threads Each):** Spawn at most 2 sub-agents concurrently, with no more than 2 threads per agent.
- **Strict Folder Bounding (.lovable/):** Subagents are strictly restricted to writing planning files, subtasks, status reports, and logs inside `.lovable/`.
- **Context Diet:** Give subagents the absolute minimal instruction (e.g., "Read subtask file `.lovable/plans/subtasks/XX-slug/01-task.md` and execute it"). Do not paste huge files into agent prompts.
- **Fail Fast & Kill Stalls:** If a sub-agent stalls or provides garbage code, kill it immediately, rollback its dirty working tree, and spawn a new one.

## 2. Phase 1: Planning Mode & Subtask Generation FIRST
1. **Scan & Discover:** Spawn 2 planning subagents to deeply scan the codebase.
2. **Master Spec Generation:** Save the master architectural plan into `.lovable/plans/pending/XX-<slug>.md`.
3. **Task-Specific Rule Set:** Write down 3–5 custom rules or constraints unique to this task inside the spec file.
4. **Subtask Decomposition:** Break down the plan into granular subtask files in `.lovable/plans/subtasks/XX-<slug>/01-task.md`, `02-task.md`, etc.
5. **Strict Relative Git Paths:** All markdown links and file paths in subtasks MUST be strictly relative to the repository root. Zero absolute paths or `file:///` URIs.
6. **MANDATORY AUTO-LOOP (DO NOT STOP):** As soon as Phase 1 planning completes, immediately self-loop and transition directly into Phase 2 execution mode.

## 3. Phase 2: Execution Mode & Parallel Refactoring
1. **Parallel Dispatch:** Spawn 2 execution subagents (max 2 threads each) assigned to disjoint subtasks.
2. **File Locking:** Verify subagents operate on distinct files using `.lovable/01-index.md`.
3. **Execution & Coding Guidelines:** Subagents refactor code following all coding guidelines (<= 8–15 line functions, single return types, universal `*AppError` wrapping, Unix LF line endings).
4. **Failure Memory & Feedback Loop:** If a subagent fails, rollback dirty changes and write the failure error log to `.lovable/plan.md` and `.lovable/memory/issues/XX-failure.md`. Next subagent MUST read the failure log first.
5. **Progress & Completion:** Move completed subtasks to `.lovable/plans/completed/` and update `.lovable/plans/01-index.md`.
6. **Local CI Verification:** Run `python 03-ai-scripts/06-cicd-local-runner.py` and ensure `exit 0`.

## 4. AI Fix Scripts Memory (Reusable Tooling)
- **Reuse First:** Scan `03-ai-scripts/01-index.md` before writing temporary code.
- **Strict In-Repository Execution:** All Python scripts executed strictly within the codebase repository root.
- **Strict .lovable/ Folder Storage:** All helper scripts, local runners, and linters stored in `03-ai-scripts/`.
- **Native File Manipulator:** Use `python 03-ai-scripts/03-file-manipulator.py <command>` for mass file operations.
- **Go Generate Sync:** If Go constants or enums are modified, run `go generate ./...` in the relevant package.

## 5. Non-Negotiable Coding Guidelines Checklist
- Master Guidelines: Fully enforced every file in `02-spec/02-coding-guidelines/` and `.lovable/coding-guidelines.md`.
- Error Management: Enforced `02-spec/03-error-manage/` using domain-specific `AppError`.
- Boolean Conventions: All booleans begin with `is` or `has` ONLY. NO negatives (e.g. `!isSuccess` is banned; use `isFail`).
- Semantic Naming: Zero generic garbage names (`temp`, `data`, `obj`). Behavior-driven unit test names.
- Multi-Line Arguments (Rule 9a/9b): Signatures and call sites with >2 arguments formatted one argument per line with trailing commas.
- Line Endings & Encoding: Strictly Unix LF (`\n`) and UTF-8 without BOM.
- Function Sizing: Functions <= 8 lines preferred (hard cap 15 lines).
- Strict Relative Git Paths: Zero absolute paths or `file:///` URIs.

## 6. Anti-Hallucination & Blast Radius Checklist
- Echo Back the Spec: Verified Acceptance Criteria from the Spec file verbatim.
- Pre-Commit Diff Proof: Verified `git status` shows actual modified files before committing.
- No Placeholder Search: Confirmed zero `TODO` or `\[.*\]` placeholders remain in modified files.
- Index Sync Deadman Switch: Every new file is explicitly linked in `readme.md` and enqueued in `.lovable/what-to-read.md`.
- Blast Radius Acknowledgment: Global search across codebase performed to update all callers of modified symbols.
- Continuous Loop Maintained: Continuous self-loop executed until 100% complete with local CI green.
