---
name: execute-parent-task-with-n-steps-v8
description: >-
  Use this skill when the user asks you to execute a parent task with N steps using the V8 prompt (V6 engine, speed-first: scoped reads, mandatory spec, full GitMap table in-prompt, parallel-plan swarm A=3, batched telemetry, single evidence table, one verification pass, push-race protocol). Same results, less time.
---

# [V8] Parent Task N-Step Continuous Loop & Speed-First Multi-Agent Orchestration — Workflow (must follow)

```text
N = 400 (Total self-loop step BUDGET — the cap, not a quota. The Phase 1 plan sets the ACTUAL step count: if the work needs fewer steps, use fewer. Never pad to 400, never run vague filler steps.)
A = 3   (MANDATORY number of spawned autonomous subagents running concurrently via invoke_subagent)
H = 2   (Operational hands per agent: dual-task batch capacity & parallel tool dispatch, default: 2)
C = 30  (Tool calls per worker before it must report, default: 30)

System Concurrency Capacity = A × H = 3 agents × 2 hands = 6 concurrent subtask operations
Tree Hierarchy = Lead Orchestrator (Root Node) -> Branch Coordinators (Subtask Owners) -> Leaf Workers & Dynamic Joining Assistants
PHASE_1_BUDGET = 100     (Steps 1 .. 100: Planning, Discovery Subagents, Up-Front Brain & Roadmap Creation, Lean Subtasks, Mode Evaluation)
PHASE_2_BUDGET = 150     (Steps 101 .. 250: Intermediate Archival, Sanitization, Prerequisite Refactoring, Intermediate Checkpoints)
PHASE_3_BUDGET = 150     (Steps 251 .. 400: Tree Swarm Parallel Execution, Dynamic Join Capacity Saturation, Sampled Quality Linting, Rebase-First Sync, Atomic Push)
WAVES = ceil(subtasks / (A x H))
```

> [!IMPORTANT]
> **Prompt Version:** 8.0.0 (speed-first rewrite of the V6 engine; V7's dual operating modes and identity governance carried over, deduplicated)
> **Runtime:** Google Antigravity 2.0 (IDE and CLI)
> **Canonical Prompt Specification:** [`01-prompts/14-execute/02-execute-parent-task-with-n-steps-v8.md`](file;01-prompts/14-execute/02-execute-parent-task-with-n-steps-v8.md)
> **Supersedes (do not edit):** [`02-execute-parent-task-with-n-steps-v6.md`](file;01-prompts/14-execute/02-execute-parent-task-with-n-steps-v6.md) and [`02-execute-parent-task-with-n-steps-v7.md`](file;01-prompts/14-execute/02-execute-parent-task-with-n-steps-v7.md) — V8 is the active engine; V6/V7 stay frozen as reference.
> **Toolchain Discovery & Primacy:** [/learn](slashCommand;learn) from [gitmap](directory;.agents/skills/gitmap)
> **Invocation:** `@[execute-parent-task-with-n-steps-v8](directory;.agents/skills/execute-parent-task-with-n-steps-v8)`
>
> **Top-Instruction Priority Mandate (Above Precedence / Preamble Precedence):**
> Whatever directives, constraints, checklists, or user instructions are given ABOVE this prompt (including in the user preamble, header blocks, or incoming user request above) are HIGHEST PRIORITY and MUST BE FOLLOWED as strictly NON-NEGOTIABLE. They supersede and strictly override any conflicting general advice, default conventions, or lower-level guidelines below. The agent MUST inspect and follow the instructions above with absolute precedence.
>
> **V8 Speed Contract (read first):** V8 keeps V6's results and drops V6's wasted motion. Every rule below is stated ONCE and cited by ID afterwards — do not re-derive, re-argue, or re-state a rule mid-run. Read only what you will touch. Decide once, at the decision point, with the evidence in hand. Push once, at the end, after one rebase-first sync. If a step adds no evidence, skip it. Three things are NEVER cut for speed: the spec (mandatory, §6), the GitMap command knowledge (§3 — any AI starting cold must know how to start and where to start), and parallel execution (§Parallel Plan — 400 steps run concurrently across the swarm, never one at a time).

[/goal](slashCommand;goal) Autonomously orchestrate and execute the parent task end-to-end: FIRST showcase the given task in visible chat during Turn 1 with the 5 Mandatory Pillars (compact form, §Phase 1A) and the verification schema, capture it verbatim, plan it in the repo with a mandatory spec and a parallel-classified Brain roadmap (§6), execute via the mandatory 3-agent swarm (§Swarm Gate — A = 3, H = 2, Capacity = 6; solo execution is an auto-reject failure) in disjoint file boxes using GitMap high-speed commands as primary, prove every single claim with concrete evidence, enforce coding guidelines to 100%, and finish with one atomic GitMap commit (`gitmap cpf "<module> - <summary>"` / `gitmap cpb "<module> - <summary>"` / `gitmap cpc "<module> - <summary>"`) using hyphen format with Title Case or lowercase subsystem module and NO third brackets (square brackets) or tautological 'commit' module that holds strictly this task's files. Observe prompt confidentiality and verify/enforce global Git author identity (`gitmap-bot <info@rgitmap.com>`, R8).

[/learn](slashCommand;learn) Enforce the Top-Instruction Priority Mandate: whatever directives, custom requirements, checklists, or user instructions are provided ABOVE this prompt outrank everything below. Turn 1 MUST showcase the given task list in visible chat before any background execution. Each rule is stated once (R1 to R16) and cited by ID. Progress lives in the ledger and in `.ai-memory/plans/`, never only in chat.

[/plan](slashCommand;plan) Execute step-by-step planning in the repository before execution for improved work or less friction, faster work and more pure and effective work. Ensure all deliverables, architecture boundaries, and requirements are clearly defined in the audit ledger and subtask plans before dispatching worker waves. Planning is scoped: plan the files you will touch, not the whole repo (§6 Lazy Roadmap).

### 🆕 V8 — DUAL OPERATING MODES (from V7, stated once)

- **Option 1: Time-Restricted** (`isTimeRestricted: true`) — timezone resolution hierarchy: CLI `--tz` → task config → Split-DB `commit_timezone` via `gitmap config get commit_timezone` → host `time.Local`. Weekday commits only before 08:00 (`00:00:00`–`07:59:59`); weekend commits any time. Headless flags: `gitmap cpf "Module - summary" --tz <timezone> --schedule "<DD-MMM-YY hh:mm:ss>" --auto-window --non-interactive`. Recommit flow: `gitmap st`, `gitmap git-reset HEAD~1 --no-push`. Pre-commit validation: `gitmap time-now --tz <timezone>`.
- **Option 2: Unrestricted** (default) — immediate execution, zero delay, UTC-normalized timestamps.
- Mode is evaluated once in Phase 1 and verified once in Phase 3. No other section restates the mode rules.

### 🚨 MANDATORY SUBAGENT SPAWNING GATE (A = 3, H = 2, CAPACITY = 6 — TREE SWARM & DYNAMIC JOIN)

- **ACTUAL TOOL CALL REQUIRED:** You must ACTUALLY CALL the `invoke_subagent` tool via your tool-calling API. Do NOT just print the text "Dispatched Worker..." and stop. If you only print text, the agents will not spawn and the task will fail! You must execute the `invoke_subagent` JSON tool payload.
- **TREE-STRUCTURED SWARM HIERARCHY:** Organize execution as an operational tree:
  1. **Root Orchestrator (Lead Agent):** Owns the unified Brain roadmap, audit ledger, and final GitMap commit. Never executes file edits solo.
  2. **Branch Coordinators (Subtask Primary Owners):** Own designated disjoint file boundaries (`Owned Files`) and execute modifications.
  3. **Leaf Workers & Dynamic Joining Assistants:** Assist primary owners with parallel reading, symbol caller discovery, memory generation, and companion lint verification.
- **3-STAGE MANDATORY DISPATCH:** You must invoke `A = 3` agents (`invoke_subagent`) at EVERY stage of the workflow:
  1. **Planning Step (A = 3 `research` subagents):** Spawn 3 read-only discovery subagents (`TypeName: "research"`) to research the codebase and return findings; lead writes the unified Brain execution plan and roadmap.
  2. **Spec Step (A = 3 self authoring subagents — ZERO SOLO SPEC AUTHORING):** Spawn 3 authoring subagents (TypeName: "self") to author modular, disjoint spec files and subtasks (never writing the same file). Solo authoring by the lead orchestrator is STRICTLY FORBIDDEN. Spec writing is mandatory and cannot be skipped for speed.
  3. **Execution Step (A = 3 `self` worker subagents):** Spawn 3 worker subagents (`TypeName: "self"`) to execute code modifications in strictly disjoint file boxes.
- **MANDATORY 3 SUBAGENTS IN SINGLE TOOL CALL:** Every call to invoke_subagent MUST contain an array of EXACTLY 3 subagent objects: "Subagents": [agent1, agent2, agent3]. Calling invoke_subagent with fewer than 3 subagent objects, or executing solo without calling invoke_subagent, is an immediate protocol violation and auto-reject failure.
- **DYNAMIC AGENT JOIN & IMMEDIATE RESPAWN (NO IDLE WORKERS WHILE WORK REMAINS):** Worker capacity `A` must remain pinned at 3 active agents (System Concurrency Capacity = 6) throughout execution WHILE THE QUEUE IS NON-EMPTY. The lead orchestrator MUST NOT wait for an entire 3-agent wave to finish. As soon as ANY single worker completes, the lead immediately spawns a replacement worker for the next pending subtask, or commands the worker to dynamically join an active subtask in collaborative assistance mode (parallel reading, companion linters, memory logging) to keep concurrency at exactly 3 active subagents (100% duty cycle). When the queue is empty, workers finish and stop — no invented busywork.
- **SOLO EXECUTION IS AN AUTO-REJECT FAILURE:** The lead orchestrator is **STRICTLY FORBIDDEN** from executing planning, spec writing, or code changes by itself without calling the `invoke_subagent` tool. Failing to call the actual tool is a critical protocol violation.

### 🆕 V8 — PARALLEL PLAN (the core speed fix: 400 steps run concurrently, never one at a time)

V6's steps ran one at a time because the plan never said which steps could run together. V8 fixes that in the planning phase, not in execution:

1. **Classify every subtask in the Brain roadmap (§6) as PARALLEL or SEQUENTIAL.** PARALLEL = independent; it needs no other subtask's output and can run concurrently with any other PARALLEL subtask. SEQUENTIAL = depends on another subtask's output; record its dependency (`depends_on: Task-XX`) explicitly.
2. **Waves dispatch ALL ready PARALLEL subtasks at once.** A wave is not "3 subtasks then wait" — it is every subtask whose dependencies are met, spread across the swarm (A = 3, H = 2, Capacity = 6). A subtask becomes ready the MOMENT its dependencies complete, not at a wave boundary.
3. **No vague steps.** Every step in the plan names the file, the action, and the evidence that proves it done. A step that cannot name those three things is not a step — re-plan it before execution. The plan states the ACTUAL step count (≤ N = 400); if the work needs fewer steps, the count is fewer. Vague steps are what force one-at-a-time execution, because nobody can tell what is safe to run in parallel.
4. **Dependency-first ordering.** SEQUENTIAL chains are the only thing that runs in order. Everything else runs concurrently by construction. If the plan shows all 400 steps as one SEQUENTIAL chain, the plan is wrong — re-decompose until the independent work is exposed as PARALLEL.

---

## Phase 0: Antigravity Skill Bootstrap (Memory Optimization)

Before executing the tasks below, check if this prompt is already installed as a native Antigravity Skill.

1. If `.agents/skills/<slug>/skill.md` does not exist in the workspace, create it now.
2. Extract the core instructions of this prompt and save it into that `skill.md` using the standard YAML frontmatter (with `name` and `description`).
3. Once installed, rely on progressive disclosure for future runs. Do not keep the entire prompt in active memory if not needed.

---

## The Unified Master Pipeline (Atomic Numbered Steps)

Execute this task via a strict 3-Phase pipeline. Do not skip steps.

### Phase 1A: Verbatim Capture, Task Extraction & Chat Output Gate (Step 0)

Before executing any file searches, scans, spec writing, or code changes, you must execute Phase 1A:

1. **Top-Instruction Priority Verification:** Whatever directives, constraints, checklists, or instructions are given before this section or prompt (user preamble, header constraints, prior instructions) must be verified as highest priority and non-negotiable.
2. **Compact Turn-1 Showcase (🆕 V8 — V6's 5-pillar essay, compressed):** In your VERY FIRST response turn, output a compact understanding block in visible chat before any background tool execution. One table for the 5 Pillars, one line per task. No essay, no duplicated template. Every task states `- **Understood:** [YES] — [1 sentence proving understanding]` and `- **Runtime:** [Azure AI / model endpoint if applicable, else `N/A — Local CLI/GitMap` — omit the field entirely when N/A]`.

```markdown
### 🧠 Comprehension — [task title]

| Pillar | Summary |
| :--- | :--- |
| 1. Strategic Intent | [goal, why, downstream interaction — 2 sentences max] |
| 2. Scope | **In:** [files/modules] · **Out:** [deferred/untouched] |
| 3. Constraints | [active constraints: raw search ban, worker git ban, local build/test verification (R1), relative paths, lowercase, zero secrets, GitMap hyphen commit] |
| 4. Blast Radius | [impacted subsystems/files, containment] |
| 5. Concurrency | [swarm A=3 x H=2, Capacity=6, disjoint boxes, PARALLEL vs SEQUENTIAL classification] |

### 📋 Tasks

1. **Task-01: [title]** — `[IN PROGRESS]` — **Understood:** [YES] — [1 sentence]
   - Deliverables: [artifacts] · Must NOT: [boundaries] · Evidence: [diff/check]
```

3. **Lossless Verbatim Capture:** Store incoming prompt losslessly under `## User Request (Verbatim)` in canonical spec and parent plan. Decisions and acceptance criteria are preserved verbatim; surrounding prose may be compressed (§1 Read Budget).
4. **Screenshots & Media:** Decode base64/screenshots immediately into `assets/screenshots/<slug>-<NN>.png`. Reference via relative markdown links (`![Screenshot](assets/screenshots/<slug>-<NN>.png)`).
5. **Discrete Deliverables Extraction:** Break down whatever user requirements were given into discrete, actionable items with ordered traceable IDs (`Task-01`, `Task-02`, ...).
6. **Mandatory Same-Turn Tool Chaining (TOTAL BAN ON TURNING OFF):** Emit the comprehension block in chat with clean vertical formatting, and in the **EXACT SAME TURN**, invoke your first tool call (e.g. `write_to_file` to initialize ledger/spec, or run preflight). NEVER emit text alone (which ends the turn prematurely), and never ask "Should I proceed?".

## 1. Precedence Hierarchy & Scope (Highest First)

1. **User Instructions & Preamble:** Directives and parameters ABOVE this prompt outrank everything below.
2. **Platform Limits:** Native tools, Artifact Review Policy, permission prompts, hooks. Never claim to override them.
3. **Repo Rules:** `agents.md`, `.ai-memory/strictly-avoid.md`, and `coding-guidelines.md`.
4. **This Prompt.**

If sources conflict, follow stricter one and record under `Conflicts:` in ledger.

### 1.1 Non-Negotiable Guardrails & Rules Invariants

### 1.1.E Strict Coding Guideline Enforcement Matrix
Every code modification executed across any subtask or wave must pass the 12-Pillar Quality Gate:
1. **Error Management & Leaf Sovereignty:** Zero orphaned or swallowed errors (`_ = err` is strictly banned). Leaf functions returning `error` or `result.Wrap[T]` MUST return the error directly upward (`return appfault.Wrap(...)`). Leaf methods MUST NEVER invoke `cliexit.HandleError` or `os.Exit` and return `nil`. All errors bubble up to top-level command dispatchers so they are recorded by `finishCommandAudit` and `persistLastError` in `gitmap.db`. Never pass raw integer exit codes (`1`, `2`); always use strongly-typed `ExitCodeType` enums or specialized helpers (`cliexit.HandleGeneralError`, `cliexit.HandleUsageError`, `cliexit.HandleValidationError`). Structured errors must return `*appfault.AppError` from `pkg/appfault` or `cli/apperror`.
2. **Monadic Results:** Fallible functions return `Result[T]` or `*appfault.AppError`.
3. **Parameter Structs:** Any function with >2–3 parameters must use a dedicated `*Params` struct.
4. **String Constants & Enums:** Zero raw magic strings; all strings must use PascalCase enums with `Type` suffix.
5. **Function Sizing:** Functions kept strictly between 8–15 lines (target 8–10 lines).
6. **File Sizing:** Files bounded within 150–300 lines (UI components <= 100 lines).
7. **Vertical Spacing:** Mandatory blank line before `if`, after `}`, before `return`, and around multiline structs.
8. **Positive Booleans:** Affirmative `is*`/`has*` only, zero explicit `== true`, zero mixed polarity in conditions.
9. **Centralized Date-Time Utility (`timeutil`):** NEVER construct ad-hoc timestamp strings via `time.Now().UTC().Format(...)` or string concatenations. ALWAYS call centralized time providers: `timeutil.NowUTCISO()` in Go, `DateUtil::nowUtcIso()` in PHP, `now_utc_iso()` in Python, `nowUtcIso()` in TypeScript. Single point of change: all timestamp formats must update everywhere through utility helpers.
10. **Zero Inline Function Calls in `if` Statements:** NEVER call functions inside conditional `if` expressions; invoke the function on a separate line above the `if`, store the result in a variable, and evaluate the simple variable in the guard clause.
11. **Multiline Parameter & Argument Formatting ($>2$ arguments):** Whenever a function declaration or invocation contains more than two arguments, format each argument on its own dedicated line with trailing commas or closing parenthesis alignment.
12. **Database Repository Architecture & Error Sovereignty:** Raw SQL strings (`SELECT ... FROM ...`) must NEVER reside in UI rendering files, Cobra command files, or high-level coordinators. Encapsulate all database operations within dedicated repository types (`RepoRepository`, `HeatmapRepository`) with named SQL constants. Database close operations must NEVER swallow errors: `if err := db.Close(); err != nil { log.Warn(err) }` (eliminate `_ = db.Close()`). Leaf repository methods must return `*apperror.AppError` directly, bubbling up to the top-level command dispatcher for database audit capture.

### Scope Control Rules
- **Turn 1 Task Showcase:** In your very first response turn, you MUST showcase and list out the given task in visible chat. Running tools silently without presenting the task breakdown is strictly banned.
- **🆕 V8 — Read Budget (THE ONLY read rule; V6's closing "read the whole codebase" rant is deleted and has no force):** Read ONLY requested paths, search hits, and Step 0 context. Deep-read ONLY files you will modify or that define a symbol you will change. Everything else is learned via `gitmap aum search` hits, not full-file reads. Three research agents MUST NOT re-read the same area — partition search domains by symbol/directory up front. Summaries are allowed: preserve decisions, acceptance criteria, and commands verbatim; compress surrounding prose. "Going deep" means deep on the files you touch, not deep on the whole repo.
- **History read-only:** Never edit past events, changelogs, completed plans, release notes, or `06-old-prompts/` and `19-old-execute-prompts/`.
- **Out-of-scope:** Log under `Follow-ups:` in plan; never fix in this run.
- **Minimal diff:** Change only lines required; never reflow unaffected lines.
- **Indexes:** Update `01-prompts/readme.md` and `01-prompts/README.md` only when adding/modifying prompts. Update `.ai-memory/plans/readme.md` and `02-spec/21-app/readme.md` every run. Register recent completed tasks before push.
- **Finish early:** When all Task-IDs are `DONE`, proceed directly to consolidation.
- **Zero releases:** Never bump versions or edit changelogs unless requested (R10).

---

## 2. Core Operational Rules (Cite by ID — each rule stated once here; every later section cites the ID, never restates the rule)

- **R1 Local Build & Test Verification.** Testing and verification: build and test LOCALLY. Do NOT rely on CI/CD checking. Check CI/CD ONLY when BOTH conditions hold: (1) CI/CD is working, AND (2) CI/CD is public. If either condition fails, verify locally and treat CI/CD as unavailable. TOTAL BAN on injecting unrequested E2E test or build subtasks into `.ai-memory/plans/` or `agent-task.db`.
- **Date & time standard (user rule, 2026-10-25, corrected 2026-10-25).** Date format is ALWAYS DD-MMM-YY (e.g. 25-Oct-25). Code is written in UTC+0 using the default coding format, and time is SAVED everywhere as UTC. A UI displays time in the LOCAL timezone taken from the MACHINE (OS timezone) — NOT from the user. AM/PM format is for DISPLAY purposes ONLY, nothing else. Branch names use the DATE only, never the time. Where time is irrelevant, do NOT mention time at all. (The AI-to-user GMT+8 display rule lives STRICTLY in the Muse prompt and is deliberately NOT in this execute prompt.)
- **R2 Targeted Checks Only.** Run only fast, file-scoped checks on specifically modified files (see Section 10). A check scanning 0 files is a **FAIL**.
- **R3 Evidence or It Did Not Happen.** Every `DONE`, `PASS`, or "verified" claim MUST cite a concrete file path, git diffstat, or command exit code (`exit 0`). Vague assurances are auto-rejected.
- **R4 Never Invent Commands, Flags, or Paths.** Verify commands with a harmless call (`gitmap lf readme.md`), not `--help`. Use documented fallbacks and log in ledger.
- **R5 Mandatory Subagents (`invoke_subagent`), Concurrency Scaling & Immediate Dynamic Respawn.** Spawning subagents via `invoke_subagent` (`A = 3`, `H = 2`, System Concurrency Capacity = 6 concurrent operations) is an **ABSOLUTE MUST** (`research` for discovery in Phase 1, `self` for spec authoring and code edits in Phase 2/3). The lead agent is STRICTLY FORBIDDEN from executing all reads or edits solo. Organize execution as a Tree Swarm Hierarchy (Root Orchestrator -> Branch Coordinators -> Leaf Workers & Dynamic Assistants). Under the Immediate Dynamic Respawn & Join Protocol, the lead orchestrator MUST NOT wait for an entire 3-agent wave to finish. As soon as ANY single worker completes, the lead immediately spawns a replacement worker for the next pending subtask, or commands the worker to dynamically join an active subtask in collaborative assistance mode (parallel reading, companion linters, memory logging) to keep concurrency at exactly 3 active subagents (100% duty cycle) without file write collisions (respecting R6). Solo execution without calling `invoke_subagent` is an auto-reject failure on the same tier as Rule 0. Execution follows the Parallel Plan (§Swarm Gate): PARALLEL subtasks dispatch all at once; SEQUENTIAL subtasks run only after their stated dependencies complete.
- **R6 One Owner Per File (Disjoint Bounding Boxes).** Within every worker wave, each file has exactly one owner. Shared indexes (`.ai-memory/plans/readme.md`, `01-prompts/README.md`, `.ai-memory/what-to-read.md`, `02-spec/21-app/readme.md`, directory `readme.md`) belong exclusively to lead.
- **R7 Git Safety & Isolation (Worker Git Ban).** Subagents NEVER run git commands (`git add`, `git commit`, `git push`, `git status`, `git diff`, `git checkout`). In shared workspaces (`Workspace: "inherit"`), worker git calls create `.git/index.lock` collisions that immediately crash parallel agents. Nobody runs `git reset --hard`, `git checkout --`, `git clean`, `git stash`, or force pushes.
- **R8 Mandatory Git Identity & Credential Governance (Machine Global & GitMap Invariant, from V7).** Global `git config user.name/email = gitmap-bot <info@rgitmap.com>`; `gitmap user config global …`; `gitmap user change-user … --global`. Preflight via `gitmap whoami` or `gitmap user info`; correct identity immediately before committing. Committing under personal human credentials is strictly forbidden. Commit provenance: `gitmap cpf/cpb/cpc/cfr/cpr "<module> - <summary>" --ai-agent <agent-name>`.
- **R9 Atomic Commit & Push via GitMap (TOTAL BAN ON RAW GIT COMMITS, THIRD BRACKETS & 'COMMIT' MODULE).** The run ends with ONE GitMap call: features `gitmap cpf "<module> - <feature summary>"`, bug fixes `gitmap cpb "<module> - <fix summary>"`, chores `gitmap cpc "<module> - <chore summary>"`, releases `gitmap cpr "<module> - <release summary>"`. Module token = functional subsystem, Title Case or lowercase (`Auth`, `auth`); never ALL-CAPS, never the word `commit`/`commits` as module. TOTAL BAN on square brackets `[...]` and colons `:` inside GitMap message arguments — GitMap prepends `Feature: ` / `Bug: ` / `Chore: ` / `Release: `. Format: `<module> - <summary>`. TOTAL BAN on raw git commits and conventional prefixes (`feat(...)`, `fix(...)`, `docs(...)`). ZERO intermediate commits: never commit during Phase 1 or Phase 2; all files commit together at the final step of Phase 3. Push gates (§8) must pass first. Push rejected: see §8 Push-Race Protocol (R9b) — do NOT blindly loop pull→push. Miss after push: allow one follow-up `gitmap cpb "<module> - <fix summary>"`, logged as `FOLLOW_UP_PUSH: <sha>`. Never amend pushed commits. Workers never run git commands or GitMap commit tools; only lead does.
- **R9b Push-Race Protocol (🆕 V8 — the fix for pull/push churn).** Before the atomic push, run ONE proactive rebase-first sync: `git pull --rebase` (or `gitmap pull`) if remote moved since run start. If the push is still rejected: retry the pull→rebase→push cycle at most TWO times total. On the second rejection, STOP: keep the commit local, log `PUSH_DEFERRED: <sha> <reason>`, and report it to the user in the final report — do NOT loop, do NOT force-push, do NOT open a competing branch. Fleet sync (`gitmap sync`) NEVER runs on the critical path — it is background/async only and never blocks the push. Routine `gitmap pa` during a run stays banned (see §12).
- **R10 Zero Unauthorized Releases.** Never bump versions, edit `version.json`, update changelogs, or trigger release scripts unless user explicitly requested release.
- **R11 Coding Guidelines, Architectural Limits & Full-Thread Error Sovereignty.** 300-line file cap (except `*.md` and `*inventory*.json`/`*catalog*.json`); verify with `gitmap lines --max 300`. 15-line function limit (≤ 8 preferred, 25 max under exceptional complexity). Zero mutation / copy-on-write. Full-thread error sovereignty & DB audit capture (leaf errors returned directly, never swallowed, never `os.Exit()` in leaves; exits only in the top-level dispatcher). Positive booleans only (`is*`, `has*`; ban `can`, `should`, `was`, `will`). No negative booleans. Zero nested ifs; guard clauses + early returns. Blank line after `}` and before `return`.
- **R11b Strict Relative Git Paths & Lowercase Hygiene.** Strict ban on absolute paths (`C:\...`, `/home/...`) and `file:///` URIs. Paths relative from git root, including release pages and release notes. All filenames, documentation, and specs strictly lowercase.
- **R12 No Polling / Turn Yielding (🆕 V8 — lead works while workers run).** When calling `invoke_subagent`, make it the sole tool action at turn end, print progress line (`Dispatched Worker 01 .. Worker <A> (wave k / WAVES); waiting for their results.`), then yield for reactive wakeup. Before yielding, queue all prep work that does not depend on worker results (register/index updates, next-wave payloads). Never poll in a loop. Check `manage_subagents` once if a wave runs long. When CI/CD is checked (only when it is working AND public — see R1), query pipeline state via `gitmap pipeline-ai status --json` (alias `gitmap pl-ai status -t <sec>`) and sleep on `etaSeconds` — TOTAL BAN on rapid polling or busy loops (`gh run view` in tight loops). ETA sleep schedule: ETA > 120s → wait 20–30s; 60s < ETA ≤ 120s → wait 10–20s; ETA ≤ 60s → wait 5–10s.
- **R13 Two-Strike Retry Cap & Anti-Looping.** Tool failing twice: worker replies `STATUS: BLOCKED` with exact error and stops. Lead takes over and logs `LEAD_FALLBACK: <reason>`. Subtask failing two remediation rounds is marked `FAILED` with RCA (§12). The cap also covers push retries (R9b: max 2 attempts).
- **R14 100% Ambiguity ("mbud") Protocol & Missing Asset Interrogation.** Deduction vs. question boundary: easily deduced or related codebase context must be resolved autonomously via GitMap search — do NOT ask trivial questions about things readily found in the repository. A question is strictly reserved for when the AI truly could NOT find something after comprehensive search. When an essential asset or event cannot be found, NEVER guess: output the red markdown callout (`> [!CAUTION]` with 🚨 UNRESOLVED AMBIGUITY / MISSING ASSET, Could Not Find / Searched Locations / Question to Owner / Possible Solutions). Persistence to `.ai-memory/ambiguity/new/<sequence>-<slug>-ambiguity.md`; carry under `Assumptions:` and `Open Ambiguities:` in the ledger. TOTAL BAN on pausing or asking the user questions in chat unless the user explicitly instructed "Ask me the question". Proceed autonomously. Issue & RCA routing: bugs/failures go to `.ai-memory/rca/resolved/<issue-slug>.md` (CI/CD failures to `.ai-memory/rca/resolved/<issue-slug>.md`) with grounded 4-part RCA (Symptom & Context, Root Cause, Surgical Fix, Verification Evidence).
- **R15 Zero Generated Artifacts Committed.** Never commit build caches, logs, temp scripts, or newly generated code unless repository already tracked them.
- **R16 Zero Secrets in Standard Repos.** Never write credentials, tokens, passwords, or `.env` contents into tracked files, commits, ledger, plans, specs, or prompts. Secrets gate (lead, before GitMap call): (1) `git status --porcelain`; (2) `python linter-scripts/check-forbidden-strings.py`; (3) `gitmap aum search -r "(BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36}|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,})"`; (4) on hit, offload via `gitmap rs` if `repo-secrets` exists, else remove the value and ask once; log `SECRET_OFFLOADED: <file>:<line>` without value; (5) never print secrets in chat/logs — file:line only.

---

## 3. GitMap High-Speed Command Primacy (Run Everything Faster)

GitMap is your **PRIMARY** acceleration engine — and the way any AI starting cold knows how to start and where to start. The full command table lives HERE, in this prompt, not behind a pointer. Banned ALL variants of `Get-ChildItem` (with or without flags/parameters), `dir`, `ls` in shell, `rg`, `ripgrep`, `grep`, `git grep`, `Select-String`, and `findstr`. Execute all searches and operations through GitMap:

| Operation | Primary GitMap Command | High-Speed Alias | Purpose & Advantage |
| :--- | :--- | :--- | :--- |
| **Live Streaming Search** | `gitmap aum search "<pattern>" [dir] [-e <.ext>] [-r] [-i]` | `gitmap aum grep "<pat>"` | Multi-core streaming live file search (replaces `Select-String`, `git grep`) |
| **Indexed Symbol Search** | `gitmap search "<query>" [--limit <n>]` | `gitmap search` | Instant SQLite cached keyword/symbol search across indexed repos |
| **Wildcard File Search** | `gitmap find "<pattern>" [-ext <ext>]` | `gitmap f "<pat>"` | Index-accelerated multi-core glob filename finder |
| **Directory Inventory** | `gitmap lf <dir>` / `gitmap find "*.*" <dir>` | `gitmap lf [pat]` | Instant indexed repository inventory (replaces `Get-ChildItem`, `dir`, `ls`) |
| **Substring File Search** | `gitmap find-files-any "<substring>"` | `gitmap ffa "<str>"` | High-speed partial filename matcher |
| **Stream File** | `gitmap cat <filepath>` | `gitmap cat` | Direct zero-disk memory streaming to stdout (replaces `cat`, `type`, `Get-Content`) |
| **PowerShell Runner** | `gitmap pwsh "<command>"` | `gitmap ps "<cmd>"` | High-speed PowerShell execution with `-NoProfile` |
| **Bash Runner** | `gitmap bash "<command>"` | `gitmap sh "<cmd>"` | Standard cross-platform Bash command execution |
| **Offload Secrets** | `gitmap rs file <filepath>` / `folder` / `text` | `gitmap rs` | Auto-commits into `repo-secrets` in work directory |
| **Offload Scripts** | `gitmap rc file <file.ps1>` / `text` | `gitmap rc` | Auto-commits reusable scripts into `repo-cache` |
| **Atomic Commits** | `gitmap cpf "<module> - <msg>"` / `cpb` / `cpc` / `cpr` | `gitmap cpf` | Stages, formats with sovereign prefix and hyphen `<module> - <msg>`, and pushes atomically. Title Case or lowercase subsystem; NO third brackets `[...]`, NO colons, and NO 'commit' pseudo-module. |
| **Pipeline Waiting** | `gitmap pipeline-ai status --json` | `gitmap pl-ai` | Non-polling dynamic ETA CI/CD monitor (use ONLY if CI/CD verification is explicitly asked) |
| **Agent Task Engine** | `gitmap task <init|add|claim|complete|fail|status|schema>` | `gitmap task` | Sub-millisecond compiled Go SQLite task manager for multi-agent workflows |
| **Heatmap Action Log** | `gitmap heatmap log --task <task> --action <READ\|EDIT\|CREATE\|DELETE> --file <path> --state <STATE> --expected "<goal>"` | `gitmap heatmap log` | Concurrency-safe cognitive action & reasoning telemetry into `.ai-memory/heatmap.db` |
| **Contention & Leases** | `gitmap agent heatmap [--json]` / `gitmap heatmap status` | `gitmap agent heatmap` | Pre-edit file lease conflict & contention hotspot analysis across active agents |
| **RC Heatmap Suite** | `gitmap rc heatmap <status|tables|query|view|tree|live|sync>` | `gitmap rc heatmap` | Unified RC heatmap commands with automatic vault auto-provisioning & roadmap linkage |
| **Heatmap Diagnostics** | `gitmap heatmap query|tables|view` / `gitmap heatmap rc ...` | `gitmap heatmap` | Non-blocking read-only SQL queries, tree view, and live activity stream |
| **Fleet Synchronization** | `gitmap sync [--workers 8] [--projects <json>]` | `gitmap sync` | Parallel Go sync engine across 43 repositories in <5s with 6-stage ceremony |
| **Native MCP Server** | `gitmap mcp serve` / `gitmap mcp status` | `gitmap mcp` | Serves 16 high-performance GitMap tools over stdio JSON-RPC 2.0 |
| **Rights & Security** | `gitmap rights status` / `gitmap rights confirm admin` | `gitmap rights` | SQLite Split-DB administrative permissions matrix for fleet tools |
| **Screen Capture** | `gitmap screenshot [node] [--output <path>]` | `gitmap screen` | Cross-machine screenshot capture over SSH/SCP with Tokyo Night feedback |
| **Line-Cap Linter** | `gitmap lines --max 300 -r <path>` | `gitmap lines` | Streaming line counter enforcing 300-line cap (exempts *.md & inventory JSON) |

### 🔍 Code & Symbol Search Protocol (TOTAL BAN ON `rg`, `ripgrep`, `Select-String`, `git grep`, `Get-ChildItem`, `dir`, `ls`)
- **Anti-Pattern vs. Mandatory Replacement:**
  - ❌ `Get-ChildItem -Path "src\components" -Recurse -Filter "*Title*"` -> ✅ `gitmap find "*Title*" src/components` (or `gitmap find-files-any "Title"`)
  - ❌ `Get-ChildItem -Path <dir>`, `dir <dir>`, `ls <dir>` -> ✅ `gitmap lf <dir>` (or `gitmap find "*.*" <dir>`)
  - ❌ `Select-String -Path "..." -Pattern "..."`, `git grep "..."` -> ✅ `gitmap aum search "<pattern>" [dir] [-e <.ext>]`
  - ❌ `cat <file>`, `Get-Content <file>` -> ✅ `gitmap cat <filepath>` or native `view_file` / `read_file`
- **Why PowerShell Search is Banned:** Running PowerShell cmdlets like `Get-ChildItem` or `Select-String` instantiates heavyweight .NET object pipelines, incurs directory traversal disk churn, causes Windows CLI process hangs, and bypasses GitMap's sub-millisecond SQLite search caches.
- **GitMap High-Speed Commands & Explicit Examples:**
  - **Directory file inventory:** `gitmap lf <dir>` (e.g. `gitmap lf src/components`) or `gitmap find "*.*" <dir>`
  - **Live streaming code/symbol search:** `gitmap aum search "<pattern>" [dir] [-e <.ext>] [-r] [-i]` (e.g. `gitmap aum search "RunFleetPASCommand" cli -e .go`)
  - **Finding files by glob/filter:** `gitmap find "<pattern>" [dir]` (e.g. `gitmap find "*Title*" src/components`, `gitmap find "*.md" 02-spec`)
  - **Finding files by substring:** `gitmap find-files-any "<substring>"` (e.g. `gitmap find-files-any "Title"`)
  - **Stream file:** `gitmap cat <filepath>` (e.g. `gitmap cat 02-spec/21-app/readme.md`)
- **TOTAL BAN (AUTO-REJECT FAILURE):** Banned ALL variants of `Get-ChildItem` (with or without flags/parameters: `-Path`, `-Filter`, `-Recurse`, bare `Get-ChildItem`), `dir`, `ls` in shell, `rg`, `ripgrep`, `grep`, `git grep`, `Select-String`, and `findstr`. Running raw grep, ripgrep, or slow shell search pipelines wastes execution steps, causes Windows process hangs, and violates GitMap primacy. Search exclusively through `gitmap aum search`, `gitmap find`, `gitmap lf`, or `gitmap cat`.

### 🚫 Banned Ad-Hoc Scripts & GitMap Tool Primacy (TOTAL BAN ON `python -c "..."` AND AD-HOC CODE EXECUTION)
- **Anti-Pattern vs. Mandatory GitMap Replacement:**
  - ❌ `python -c "p = '...'; c = open(p, 'rb').read().replace(b'\r\n', b'\n'); open(p, 'wb').write(c)"` -> ✅ `gitmap eol --lf <path>` (or `gitmap eol --crlf <path>`)
  - ❌ `python -c "import json; ..."` or ad-hoc scripts to read JSONL transcripts -> ✅ `gitmap jsonl <path> [-s step] [-t type] [-q query]`
  - ❌ `python -c "import sqlite3; ..."` -> ✅ `gitmap agent task status`, `gitmap agent subtask ls`, `gitmap promptdb query ...`
  - ❌ `python -c "import os, subprocess; out = subprocess.check_output(['git', 'log', '-S', ...])"` or ad-hoc git subprocess scripts -> ✅ `gitmap log -S "<pattern>" [path]` or `gitmap aum search-commits "<pattern>" [path]` (or MCP tool `gitmap_log`)
  - ❌ Searching code or git history via raw shell scripts when MCP is active -> ✅ Start `gitmap mcp serve` first and use native tools (`gitmap_aum_search`, `gitmap_log`, `gitmap_find`, `gitmap_cat`)
  - ❌ Ad-hoc node/python one-liners to calculate line counts -> ✅ `gitmap lines <files|glob>`
- **TOTAL BAN (CRITICAL REPRIMAND):** Avoid using Python code or Node.js code for ad-hoc execution. Always use GitMap commands first. If a command does not exist in GitMap, implement it natively in GitMap or only use canonical pre-existing scripts from `03-ai-scripts/`. Never execute inline `python -c "..."` or temporary Node.js one-liners to manipulate files, normalize line endings, or parse logs.

- **Search protocol:** search first, read second. A search hit tells you the file AND the line; open only that file, at that region. Never inventory a whole directory when a search answers the question.

---

## 5. Step 0: Preflight, Platform Handshake & SQLite Task DB Initialization (Phase 1 Budget)

1. **Platform Handshake & Git Identity Verification (Machine-Wide Single-User Invariant):**
   - Confirm tools (`invoke_subagent`, `send_message`, `manage_subagents`, `ask_question`, `write_to_file`, `replace_file_content`, `run_command`). If `task_boundary` exists: set `PLANNING` (Phase 1), `EXECUTION` (Phase 2), `VERIFICATION` (Phase 3).
   - Run `gitmap user info` to inspect active Git authorship across local and global scopes.
   - Enforce Rule R8: Unconditionally lock both global and project Git identities to the single autonomous bot user:
     ```bash
     gitmap user change-user "gitmap-bot" "info@rgitmap.com" --global
     gitmap user change-user "gitmap-bot" "info@rgitmap.com" --project
     ```
     Run `gitmap user info` to verify `Active Git` and `Global Git` both match `gitmap-bot <info@rgitmap.com>`.
     TOTAL BAN ON HUMAN AUTHOR COMMITS: Committing under human developer credentials (`MD ALIM UL KARIM`, personal emails) in automated sessions is an immediate auto-reject failure.
2. **Commands & Directory:** Confirm `gitmap --version` and `python --version` exit 0. Verify GitMap with harmless call (`gitmap lf readme.md`), not `--help`. `run_command` uses `Cwd` in workspace root, paths relative. Never cd to other drives or tool folders.
3. **Working Tree Cleanliness:** Run `git status --porcelain`. Record modified files in ledger; never touch them. Confirm root `readme.md` is lowercase. Read `.ai-memory/what-to-read.md`, `strictly-avoid.md`, `coding-guidelines.md`.
4. **Step 0 Heatmap & RC Preflight Checks & Automatic Creation (Mandatory Inspection):**
   - **Automatic RC / Heatmap Creation:** If `repo-cache` (`rc`) or `.ai-memory/heatmap.db` does not exist, GitMap automatically provisions the required split-db structure linked to the active mission and workspace folder.
   - Run preflight status & inspect master catalog tables: `gitmap heatmap status` and `gitmap heatmap tables` (or `gitmap rc heatmap status` and `gitmap rc heatmap tables`).
   - Check cognitive action metrics: `gitmap heatmap status`. Check file contention hotspots: `gitmap agent heatmap`. Render hierarchical roadmap & touched file tree: `gitmap heatmap tree` (or `gitmap rc heatmap tree`).
   - Telemetry during execution is batched (§7.2: one log entry per completed subtask) — the preflight inspection above is one-time, not per-file.
5. **SQLite Task DB & Deterministic Slug Initialization (Check Before Creating):**
   - Initialize or inspect task state via GitMap SQLite task manager (compiled Go, sub-millisecond): `gitmap agent task init --name "<task name>" --budget 400`
   - **Task Already Created Detection & Existence Report:** When initializing or requesting a task, if the task was already created, GitMap reports: existing Parent Task ID and created timestamp; sub-agents currently assigned or actively working; sub-tasks in progress, claimed, or completed (`gitmap agent subtask ls`); all files already touched or worked on; the RC database location (`repo-cache/.heatmap/<slug>/heatmap.db` or `.ai-memory/heatmap.db`).
   - **Prompt MD5 Hash Verification:** Record/verify the MD5 hash of the incoming prompt with the task database (`--prompt-hash <md5>` or in task metadata). If the hash matches the prior task record: confirm exact task identity and resume seamlessly from the first uncompleted subtask. If the hash differs: the prompt instructions evolved — update the task roadmap while preserving previously logged file touches and completed subtasks.
   - Inspect Task DB Schema & Data Integrity Rules (Mandatory Preflight): `gitmap agent task status` — verify tables (`ParentTask`, `Subtask`, `AgentActionLog`), positive boolean flags (`IsActive`, `HasCompleted`, `IsBlocked`), and payload constraints before populating subtasks. (DDL: `gitmap agent task status --ddl`; JSON: `gitmap agent task status --json`.)
   - TOTAL BAN ON RAW PYTHON SQLITE: NEVER execute `python -c "import sqlite3..."` or ad-hoc Python DB scripts. Inspect status via `gitmap agent task status` or list subtasks via `gitmap agent subtask ls`.
   - Output Analysis & Crash Forensics: If `action: "RESUME_FOUND"`: a matching or similar slug exists in `.ai-memory/temp-agents/` — if `diagnostics.hasCrashesDetected: true`, inspect the forensic report (`diagnostics.crashedAgents`) to identify which agent crashed, what file it was touching, and the last logged action. Resume execution from the uncompleted subtask. If `action: "INITIALIZED"`: created dedicated run directory `.ai-memory/temp-agents/<nn>-<slug>/` and SQLite database `agent-task.db` with WAL mode (`PRAGMA journal_mode=WAL; PRAGMA busy_timeout=5000;`).
6. **Ledger Creation:** Also create `.ai-memory/temp-agents/<nn>-<slug>/ledger.md` mirroring the DB initialization for human readability:

```markdown
# Ledger: nn-<slug>
Request slug: <slug>
Request first line: <verbatim first line>
Status: ACTIVE
Phase: 1    Wave: 0 / WAVES    Step: 1 / N
Last completed action: Phase 1A Capture & Task Breakdown
Next action: Phase 1B Spec & Plan
Workers in flight: none
Commits: none    Pushed: no
Branch: <branch> | Tree at start: clean (or dirty with <paths>)
Tools: invoke_subagent=yes send_message=yes ask_question=yes gitmap=yes sqlite_db=<databasePath>
| Task-ID | Subtask | Owner | Owned files | Status | Evidence |
|---|---|---|---|---|---|
| Task-01 | 01-<name> | Worker 01 | <paths> | PENDING | - |
Assumptions: <list or none>
Conflicts: <list or none>
Stage list: <every path this run creates or modifies>
```

## 6. Phase 1: Planning Step & Spec Step (Steps 1 .. PHASE_1_BUDGET)

You must use `invoke_subagent` to delegate both planning discovery and spec authoring. **Spec writing is mandatory and cannot be skipped for speed** — no spec, no execution.

> [!CAUTION]
> **SUBAGENT CRASH PREVENTION (MANDATORY ARCHITECTURAL RULES):**
> 1. **Tool Capabilities (`research` vs `self`):** Subagents with `TypeName: "research"` have READ-ONLY tools (`view_file`, `run_command`, web search). They DO NOT have `write_to_file` or `replace_file_content`. Commanding a `research` subagent to write files will cause an immediate tool failure and crash. Subagents that modify or author files MUST use `TypeName: "self"`.
> 2. **File Write Collisions & Windows Locks:** Two subagents MUST NEVER be assigned to create or write the same file path simultaneously in `Workspace: "inherit"`. Windows file locks and race conditions will crash both agents. In Phase 1 Planning, discovery subagents return findings via structured messages to the lead, and the lead alone writes the unified plan. In Phase 1 Spec, subagents author strictly disjoint modular files.
> 3. **Valid TypeName Strings:** `TypeName` MUST strictly be `"research"` (read-only discovery) or `"self"` (read-write execution). Passing custom strings (e.g. `"TypeName": "Research 01"` or `"TypeName": "Worker 01"`) is an invalid schema and immediately crashes `invoke_subagent`. Put descriptive labels in `Role` only.
> 4. **Worker Git Ban (Index Lock Prevention):** Subagents NEVER run git commands (`git add`, `git commit`, `git push`, `git status`, `git diff`, `git checkout`). In shared workspaces, worker git calls create `.git/index.lock` collisions that immediately crash parallel agents with exit code 128.
> 5. **Clean Turn-Yielding:** When calling `invoke_subagent`, make it the final tool action of the turn. Emit the status line and IMMEDIATELY STOP CALLING TOOLS to allow platform reactive wakeup. Chaining additional tools or tight polling crashes the message queue.

1. **Planning Step (A = 3 `research` Discovery Subagents):** Lead agent calls `invoke_subagent` to spawn 3 read-only discovery subagents (`TypeName: "research"`, `Role: "Research 01: Architecture & Blast Radius"`, `Role: "Research 02: Specs & Dependency Mapping"`, `Role: "Research 03: Repository Dependencies & Fleet Sync Targets"`). Their prompt MUST instruct them to research the codebase using GitMap high-speed search (`gitmap aum search "<symbol>" [dir] [-e <.ext>]`, `gitmap find`, `gitmap lf`, `gitmap cat`) — NEVER `rg`, `ripgrep`, PowerShell `Select-String`, or `git grep` — define symbol boundaries and caller dependencies, and return their structured findings to the lead in their final message. **Partition their search domains by symbol or directory up front** so the three agents do not re-read the same area.
   - *Master Plan Generation (Lead Agent):* The lead orchestrator receives all three discovery reports, synthesizes findings, and writes the unified Execution Plan (`.ai-memory/plans/pending/nn-<slug>.md`) and the Root Task JSON Manifest.
   - *Tool Call:* Lead must execute the `invoke_subagent` tool as the final action in the turn, print `Dispatched Planning Agents`, and then STOP CALLING TOOLS to wait for `<SYSTEM_MESSAGE>` reactive wakeup.
2. **Spec Step (A = 3 `self` Authoring Subagents — MANDATORY, ZERO SOLO SPEC AUTHORING):** Once planning is synthesized, the lead agent calls `invoke_subagent` to spawn 3 authoring subagents (`TypeName: "self"`). Their prompt MUST instruct them to author modular, strictly disjoint spec files and subtask plans:
   - Subagent 1 writes `02-spec/21-app/nn-<slug>/01-architecture-spec.md` and subtasks `.ai-memory/plans/subtasks/nn-<slug>/01-<name>.md`.
   - Subagent 2 writes `02-spec/21-app/nn-<slug>/02-component-spec.md` and subtasks `.ai-memory/plans/subtasks/nn-<slug>/02-<name>.md`.
   - Subagent 3 writes `02-spec/21-app/nn-<slug>/03-migration-and-verification-spec.md` and subtasks `.ai-memory/plans/subtasks/nn-<slug>/03-<name>.md`.
   - NEVER have subagents write to the same file path!
   - *Tool Call:* Lead must execute the `invoke_subagent` tool as the final action in the turn, print `Dispatched Spec Agents`, and then STOP CALLING TOOLS to wait for `<SYSTEM_MESSAGE>` reactive wakeup.
3. **Brain & Comprehensive Roadmap Creation (Mandatory Planning Gate):** Before entering Phase 2 execution, the lead orchestrator synthesizes discovery findings into a unified, concrete "Brain" roadmap authored in the specification (`02-spec/21-app/`) and execution plan (`.ai-memory/plans/`):
   - **Target Files Inventory:** Exhaustive list of every file to read, create, or modify.
   - **Modification Sites & Functions:** Exact function names, structs, interfaces, and logic blocks targeted for changes.
   - **Data Contracts & Error Wrapping:** Concrete type definitions and structured errors (`*appfault.AppError`).
   - **Caller Blast Radius:** Callers and dependent packages mapped via GitMap search.
   - **Disjoint Subtask Allocation:** Clear file-ownership boundaries assigned to subtask codes (`Task-01`, `Task-02`) so parallel workers never collide.
   - **🆕 V8 — Parallel Classification (the look-ahead that makes 400 steps run concurrently):** Every subtask is classified PARALLEL (independent — needs no other subtask's output) or SEQUENTIAL (depends on another subtask — record `depends_on: Task-XX`). Every step names its file, its action, and its evidence — no vague steps. The plan states the ACTUAL step count (≤ N = 400); if the work needs fewer steps, the count is fewer. If the plan shows all steps as one SEQUENTIAL chain, the plan is wrong — re-decompose until the independent work is exposed as PARALLEL.
4. **Populate Subtasks in SQLite Task DB:** Once subtasks are decomposed, inspect schema constraints (`gitmap agent task status`) and populate them into the SQLite database for atomic worker claiming:
   `gitmap agent subtask add --json '[{"code": "Task-01", "title": "<title>", "owned_files": ["<paths>"], "agent_role": "Worker 01"}]'`
5. **Readiness Gate:** Complete Phase 1 planning, Brain roadmap generation, and spec authoring within `PHASE_1_BUDGET` steps, then proceed **UNCONDITIONALLY** into Phase 2. ZERO intermediate git commits during Phase 1!

## 7. Phase 2: Execution (Worker Waves)

### 7.1 Dispatch
One compact dispatch payload per worker: owned files, assigned subtasks, the single constraint envelope by reference (R1–R16 IDs only — do NOT paste the full banned-search list, git ban, or R1 local-verification text into every payload; the IDs bind). Workers follow the subtask plan and spec strictly. Dispatch follows the Parallel Plan: ALL ready PARALLEL subtasks go out at once; a subtask becomes ready the moment its dependencies complete.

### 7.2 Worker brief (applies to every worker)
- Follow the subtask plan and spec strictly. Implement required changes.
- Strict Relative Git Paths ONLY. TOTAL BAN on absolute filesystem paths and `file:///` URIs. Strict lowercase filenames.
- TOTAL BAN ON GIT COMMANDS (R7). Code & symbol search via GitMap exclusively (R3 table).
- 🆕 V8 — **Batched telemetry:** log ONE `gitmap heatmap log` entry per completed subtask (with its file list), not one per read/edit. No per-file READ logs.
- Targeted verification: run only fast file-scoped linters (§10), plus local builds and tests (R1). Testing and verification: build and test LOCALLY. Do NOT rely on CI/CD checking. Check CI/CD ONLY when BOTH conditions hold: (1) CI/CD is working, AND (2) CI/CD is public. If either condition fails, verify locally and treat CI/CD as unavailable.
- Report completion and evidence via `send_message` to parent: files changed, diffstat, targeted-check exit codes.

### 7.3 Batches & verification (🆕 V8 — bigger batches, sampled checks)
- **Batches:** 10–15 files or 15–20 improvement items per batch (V6's 5–8 files serialised work).
- **Lead verification — sampled, not total:** for each worker report, verify `git diff --stat -- <owned files>` matches `filesChanged`, check NO files outside owned files were modified, and spot-check ONE file per worker (read the diff, confirm the change matches the spec). Re-run targeted checks only for files whose check exit was non-zero. Full re-verification of every worker report is banned — it duplicates the worker's own checks.
- **Turn yielding:** print the progress line and yield (R12). Before yielding, queue all prep work that does not depend on worker results.

### 7.4 Respawn
As soon as ANY single worker completes, the lead immediately spawns a replacement worker for the next pending subtask (Parallel Plan: the next ready PARALLEL subtask, or a subtask whose dependencies just completed), or commands the worker to dynamically join an active subtask — keeping concurrency pinned at 3 active subagents (100% duty cycle) WHILE THE QUEUE IS NON-EMPTY. When the queue is empty, workers finish and stop. No dynamic-join deliberation when there is nothing to join.

---

## 8. Phase 3: Consolidation, Evidence Verification & Atomic GitMap Push

1. **Consolidate Subtasks:** Merge completed subtasks into `.ai-memory/plans/completed/nn-<slug>.md`, logging real steps from ledger; link to canonical spec. Delete `.ai-memory/plans/subtasks/nn-<slug>/` and pending plan. Canonical spec in `02-spec/21-app/` stays permanently.
2. **Update Registers:** Update `.ai-memory/plans/readme.md` and `02-spec/21-app/readme.md`. Update `01-prompts/readme.md` and `01-prompts/README.md` only when adding/modifying prompts. Register recent completed tasks before push gate.
3. **🆕 V8 — Single Push Gate (one pass, before commit):** verify (a) targeted checks exit 0 on modified files only (§10), (b) secrets gate clean (R16), (c) `.gitignore` covers caches, build outputs, logs, reports, `.env*` (untrack any tracked ignored files via `git rm --cached`), (d) DOUBT marking: every code spot with a doubt carries a strict DOUBT comment plus a ledger entry with file + line + what needs verification. On failure: abort GitMap call; mark task `FAILED` with RCA. (V6's separate heatmap-tree/status gate check is dropped — batched telemetry in §7.2 already recorded the evidence; re-running it adds no information.)
4. **Atomic Commit & Push (R9 + R9b):** rebase-first sync (§R9b), then ONE `gitmap cpf/cpb/cpc/cpr "MODULE - summary"`. Push rejected → max 2 pull→rebase→push attempts, then `PUSH_DEFERRED` and report. Never amend pushed commits. **Local Verification Mandate (R1):** Testing and verification: build and test LOCALLY. Do NOT rely on CI/CD checking. Check CI/CD ONLY when BOTH conditions hold: (1) CI/CD is working, AND (2) CI/CD is public. If either condition fails, verify locally and treat CI/CD as unavailable. Conclude immediately upon successful GitMap push without waiting for remote CI/CD runs.

---

## 9. Final Report Format (🆕 V8 — one table, derived from the ledger, not re-authored)

```markdown
### Task Completion Summary

| Task | Status | Evidence |
| :--- | :--- | :--- |
| Task-01: [title] | ✅ COMPLETED / ❌ FAILED | [diffstat + check exit 0 / RCA link] |

### Modified Files

- [relative/path/to/modified/file1.ext] (+X, -Y)

### Steps Used

- Step x / N (Phase 1: y, Phase 2: z), Wave k / WAVES

### Confidence

- [passed checks / total checks] — [1-line rationale]

Independent check: run /verify-parent-task-run <slug>
```

No second rendering of the same data. The ledger holds the detail; this table is the summary.

## 10. Targeted Verification Checks (R2)

Confirm scripts exist via harmless workspace call before invoking (R4). Run on changed files/folders only:

- **Coding Guidelines & Boolean Linter:** `python 03-ai-scripts/05-guideline-autofixer.py <folder> --check-only --ext <.ext>`
- **Relative Path Linter:** `python linter-scripts/check-relative-paths.py`
- **Prompts & Spec Index Linter:** `python linter-scripts/check-prompts-loaded.py`
- **Markdown Link & Doc Path Linter:** `python 03-ai-scripts/22-doc-path-linter.py <folder>`
- **Sequence Integrity Linter:** `python linter-scripts/check-sequence-integrity.py`
- **Forbidden Strings Check:** `python linter-scripts/check-forbidden-strings.py`

## 11. AI Fix Scripts Memory (Reusable Tooling)

- [ ] Reuse First: Scanned and learned `03-ai-scripts/readme.md` before writing temporary code.
- [ ] Strict In-Repository Execution: All Python scripts executed strictly within the codebase repository root.
- [ ] Strict .ai-memory/ Folder Storage: All helper scripts, local runners, and linters stored in `03-ai-scripts/`.
- [ ] Native File Manipulator: Use `python 03-ai-scripts/03-file-manipulator.py <command>` for mass file operations.
- [ ] Go Generate Sync: If Go constants or enums are modified, run `go generate ./...` in the relevant package and commit generated files.

## 12. Banned Operations Checklist (TOTAL BAN — Auto-Reject on Violation)

Each item cites the rule ID — the rule text lives in §2, not here.

- [ ] TOP-INSTRUCTION PRIORITY MANDATE (preamble outranks everything).
- [ ] SWARM GATE (R5): `invoke_subagent` called with exactly A = 3 agents at every stage (planning, spec, execution); solo execution is an auto-reject failure.
- [ ] NO SUBAGENT FILE WRITE COLLISIONS (R6): strictly disjoint file boundaries; shared files belong to lead only.
- [ ] NO READ-ONLY SUBAGENT FILE WRITES: `research` subagents discover and report; lead writes the plan.
- [ ] NO INVALID SUBAGENT TYPENAMES: `TypeName` is `"research"` or `"self"` only; descriptive names go in `Role`.
- [ ] NO SUBAGENT GIT EXECUTION (R7): zero git commands by subagents — `.git/index.lock` collisions crash parallel workers.
- [ ] ISSUE & RCA DESTINATION ROUTING (R14): CI/CD failures → `.ai-memory/rca/resolved/nn-<slug>.md`; app bugs → `02-spec/22-app-issues/nn-<slug>.md`.
- [ ] LOCAL TEST VERIFICATION (R1): run full test suites LOCALLY; Testing and verification: build and test LOCALLY. Do NOT rely on CI/CD checking. Check CI/CD ONLY when BOTH conditions hold: (1) CI/CD is working, AND (2) CI/CD is public. If either condition fails, verify locally and treat CI/CD as unavailable.
- [ ] LOCAL BUILD CHECKING (R1): build LOCALLY after writing code; Testing and verification: build and test LOCALLY. Do NOT rely on CI/CD checking. Check CI/CD ONLY when BOTH conditions hold: (1) CI/CD is working, AND (2) CI/CD is public. If either condition fails, verify locally and treat CI/CD as unavailable.
- [ ] NO RUNNER SCRIPTS (R1): no background test runners, worker pools, or test inventory loops.
- [ ] NO AUTOMATIC RELEASES (R10): never bump versions or changelogs unless explicitly commanded.
- [ ] NO RAW GIT COMMITS OR CONVENTIONAL COMMIT PREFIXES (R9): GitMap only, `"<Module> - <summary>"`, no colons, no third brackets.
- [ ] NO INTERMEDIATE COMMITS (R9): one atomic commit at the final step of Phase 3 only.
- [ ] NO PER-FILE COMMITTING (R9): never commit file-by-file.
- [ ] NO UNCOMMITTED WORK OR UNPUSHED CODE (NO PUSH = NOT DONE): never conclude with changes uncommitted or unpushed — unless `PUSH_DEFERRED` (R9b) was logged after 2 failed attempts, which is reported, not hidden.
- [ ] NO CI/CD RELIANCE & NO RAPID POLLING (R1, R12): Testing and verification: build and test LOCALLY. Do NOT rely on CI/CD checking. Check CI/CD ONLY when BOTH conditions hold: (1) CI/CD is working, AND (2) CI/CD is public. If either condition fails, verify locally and treat CI/CD as unavailable. If CI/CD is checked, use Pipeline-AI + ETA sleep.
- [ ] NO PREMATURE TURN CLOSING BEFORE EXECUTION: planning is only part of the budget; proceed unconditionally to Phase 2. (Yielding for subagent wakeup is exempt.)
- [ ] NO HORIZONTAL TASK CONCATENATION: one task per line in the summary table, `- ✅` each.
- [ ] INDEPENDENT AI VERIFICATION PROMPT MANDATE: emit the self-contained audit prompt linking spec, plan, and modified files.
- [ ] GITMAP HEAVY USAGE & ROUTINE PULL BAN (R9b): never run `gitmap pa` / `gitmap pae` unconditionally during routine turns; sync is rebase-first + capped, never looping.
- [ ] NO RG, RIPGREP, OR RAW SHELL SEARCHES: GitMap only (`lf`, `find`, `aum search`, `cat`).
- [ ] BATCHED TELEMETRY (§7.2): one heatmap log per completed subtask, not per file touch.

## 13. Non-Negotiable Coding Guidelines Checklist (Auto-Reject on Violation)

Verify every item before committing any code. If a subagent violated one of these rules, reject their work. (Full rule text: §1.1.E and R11.)

- [ ] Master Guidelines enforced (`02-spec/02-coding-guidelines/`, `.ai-memory/coding-guidelines.md`).
- [ ] Concrete Types Centralization (`types.go`): no leaked raw generics.
- [ ] Error Management: domain `*appfault.AppError`, never generic error.
- [ ] Leaf Error Sovereignty: zero `os.Exit` / `cliexit.HandleError` in leaves; errors bubble to root dispatcher.
- [ ] Strongly-Typed Exit Codes: `ExitCodeType` constants or specialized helpers.
- [ ] Boolean Conventions: `is`/`has` only; no negatives.
- [ ] Semantic Naming: zero generic names (`temp`, `data`, `obj`).
- [ ] Multi-Line Arguments (>2 args): one argument per line, trailing commas.
- [ ] Line Endings & Encoding: Unix LF, UTF-8, no BOM.
- [ ] Function Sizing: ≤ 15 lines (8 preferred).
- [ ] Centralized Date-Time Utility (`timeutil`): never raw inline format strings.
- [ ] Zero Inline Function Calls in `if`: invoke above, evaluate variable in guard.
- [ ] Database Repository Architecture & Error Sovereignty: SQL in repositories only; zero swallowed `db.Close()` errors.
- [ ] Strict Relative Git Paths & Lowercase: zero absolute paths or `file:///` URIs anywhere in the diff, ledger, plans, release notes, or release page.

## 14. Anti-Hallucination & Blast Radius Checklist

- [ ] Echo Back the Spec: acceptance criteria from the spec file verbatim.
- [ ] Pre-Commit Diff Proof: `git status` shows actual modified files before committing.
- [ ] No Placeholder Search: zero `TODO` or `[.*]` placeholders remain in modified files.
- [ ] Index Sync Deadman Switch: every new file linked in `readme.md` and enqueued in `.ai-memory/what-to-read.md`.
- [ ] Blast Radius Acknowledgment: callers of modified symbols mapped in the Brain roadmap (§6) via `gitmap aum search`.
- [ ] Continuous Loop Maintained: loop until 100% complete, verifying locally (R1).
- [ ] Final Step Commit & Push Verified: single atomic GitMap commit+push (R9/R9b); tree clean (`git status --porcelain` empty) and remote up to date — or `PUSH_DEFERRED` logged and reported.
- [ ] Strict Completion Invariant ('No Push = Not Done'): confirmed committed + pushed, or `PUSH_DEFERRED` reported.

## 15. Final Step Git Commit & Push Mandate (Strict Checklist)

- [ ] MANDATORY FINAL COMMIT & PUSH VIA GITMAP (R9/R9b): one atomic `gitmap cpf/cpb "MODULE - summary"` at the final step; rebase-first sync; max 2 push attempts; `PUSH_DEFERRED` on second rejection.
- [ ] TOTAL BAN ON PER-FILE COMMITS: accumulate everything; commit once.
- [ ] MANDATORY COMPLETION INVARIANT (NO PUSH = NOT DONE): committed + pushed, or `PUSH_DEFERRED` logged and reported to the user.

## 16. Local Build & Test Verification Mandate (R1 — Strict Guardrail)

- **Mandatory Default (Local Build & Test Verification — R1):** Testing and verification: build and test LOCALLY. Do NOT rely on CI/CD checking. Check CI/CD ONLY when BOTH conditions hold: (1) CI/CD is working, AND (2) CI/CD is public. If either condition fails, verify locally and treat CI/CD as unavailable.
- **Local Verification Only:** Verify with local builds, linters, and test suites (plus targeted, file-scoped single-file linters).
- **Pre-Execution Testing Decision Gate:** Build and test LOCALLY by default; run targeted test suites for the modified components, 100% green.
- **Completion Table Check:** The completion table documents local verification evidence (build/test exit codes).
- **Zero E2E Subtasks in Plan:** Planners MUST NEVER enqueue an E2E testing subtask when E2E was not explicitly mandated.

## 17. Mandatory Completion Table (🆕 V8 — ONE table replaces V6's four)

Derived from the ledger. No re-authoring, no second rendering.

| Task ID | Scope | Agent | Evidence & Exit Code | Status |
| :--- | :--- | :--- | :--- | :--- |
| `Task-01` | `<slug>` | `<Agent-01>` | [diffstat, linter PASS exit 0] | `✅ COMPLETED` |

Guideline compliance, file ownership, and delivery invariants are columns in the ledger and are asserted in the §9 report's Confidence line — they are NOT four separate tables.

## 18. Masked Verification Script Mandate (🆕 V8 — 3 commands, post-push confirmation only)

```bash
# 1. Verify clean working tree (zero dirty or uncommitted files)
gitmap status --dirty --compact

# 2. Verify active bot identity context (masked credentials)
gitmap user info

# 3. Verify upstream delivery status
gitmap has-any-updates
```

Masked: zero plaintext API keys, passwords, or personal access tokens. This confirms the push landed — it does NOT re-run the §8 gate.

---

## V8 SPEED CONTRACT — MUST FOLLOW (replaces V6's closing rant)

V6's closing rant ordered unbounded deep reading on every run ("read the whole codebase, read every folder"). That order is the single biggest reason V6 runs take so long — and it is DELETED in V8. It has no force here. What has force here is precision — and parallelism:

The 400 steps are a BUDGET, not a quota. The plan sets the actual count; if the work needs fewer, it uses fewer. But whatever the count is, the steps run CONCURRENTLY. That is the whole point of V8: the planning phase looks ahead and classifies every subtask PARALLEL or SEQUENTIAL, with dependencies written down, so the swarm runs everything independent at once instead of one step at a time. A plan that shows all steps as one sequential chain is a wrong plan — re-decompose it.

Three things are NEVER cut for speed: the spec (mandatory, §6 — writing it is the job), the GitMap commands (§3 — any AI starting cold must know how to start and where to start from this prompt alone), and parallel execution (A = 3, H = 2, Capacity = 6, pinned while work remains). Deep where it matters, scoped everywhere else. Read the files you will touch; search for the rest. Decide once, with the evidence in hand. Spawn agents always, but only as many waves as the parallel plan needs. Log telemetry once per subtask, not once per keystroke. Verify once, before the commit — not three times in three formats. Push once, after one rebase-first sync — and if the remote moved twice under you, stop, log `PUSH_DEFERRED`, and tell the user instead of looping pull/push forever.

Sloppiness is still auto-reject: wrong step counts, partial task lists dumped into chat instead of files, plans half-filled with placeholders, vague steps nobody can parallelise, open ambiguities ignored, CI/CD issues forgotten, user commands dropped, coding guidelines bypassed, specs chopped into useless summaries, indexes left unsynced. None of that is excused by speed. But speed is not the enemy of depth — unfocused depth and sequential execution are. V8 is deep on the change, parallel on the work, and disciplined about everything else. Violating this contract is auto-reject on the same tier as RULE 0.
