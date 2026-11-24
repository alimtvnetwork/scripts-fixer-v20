# Execute V6 vs V8 — Speed Comparison

**Date:** 14-Nov-25 · **Author:** Muse (atv-yaaaey-2) · **Status:** V8 is the active engine. V6 and V7 are frozen reference — do not edit.

## Verdict in one paragraph

V6 (1014 lines, 122 KB) and V7 (1058 lines, 128 KB) are the same engine — V7 only adds the time-restriction dual modes and identity governance; its 706-line tail is byte-identical to V6, and it addresses none of the speed complaints. V8 (501 lines, 67 KB) keeps V6's results — same 3-phase pipeline, same 12-pillar quality gate, same atomic GitMap commit, same bans — and removes the wasted motion: scoped reads instead of whole-codebase reads, a parallel plan instead of one-step-at-a-time waves, batched telemetry instead of per-file logging, one evidence table instead of four, one verification pass instead of two, and a capped rebase-first push protocol instead of an unbounded push-reject loop. The prompt file itself is ~51% smaller, so every run starts cheaper. Spec writing and the GitMap command table are fully kept — they are the musts, not the fat.

## Size

| | Lines | Bytes | vs V6 |
| :--- | :--- | :--- | :--- |
| V6 `02-execute-parent-task-with-n-steps-v6.md` | 1014 | 122,296 | — |
| V7 `02-execute-parent-task-with-n-steps-v7.md` | 1058 | 128,188 | +44 lines (+4%) |
| V8 `02-execute-parent-task-with-n-steps-v8.md` | 501 | 66,939 | −513 lines (−51%) |

## What V7 changed (why V8 builds on V6, not V7)

- Dual operating modes: Option 1 Time-Restricted (weekday commits before 08:00, tz hierarchy, headless `--tz/--schedule/--auto-window` flags, recommit flow) and Option 2 Unrestricted (default). Stated twice in V7 (Dual Modes § + R12b) — V8 states it once.
- R8 rewritten: `gitmap login set ai-auto <agent-name>` teaching flow → global git identity governance (`gitmap-bot <info@rgitmap.com>`, `gitmap whoami` preflight). V8 keeps V7's R8.
- R12 anti-credit-waste: Pipeline-AI + ETA-based sleep for CI waits (5–30s). Applies only when CI verification is explicitly requested — not execution speed. V8 keeps it.
- Nothing else: same N=400, A=3, H=2, same dispatch payloads, same ledger/resume, same verification schema, same completion tables. V7 was born as the login/ai-auto + time-restriction feature (commit `f728a3a4d`, 31-Oct-26), not a speed rewrite.

## Why V6 is slow — the 10 time sinks (with V6 line refs)

| # | V6 mandate | Cost | V8 fix |
| :--- | :--- | :--- | :--- |
| 1 | L1014 closing rant: "Read the whole codebase, read every folder in `02-spec/` and `.ai-memory/`" + "preserve detailed specs verbatim with zero truncation" — contradicts L226's read budget | Unbounded full-repo read on every run; no summarising allowed | **Deleted.** The §1 read budget is the ONLY read rule: read only what you will touch; search the rest; compress prose, keep decisions verbatim |
| 2 | L39–54 + R5: mandatory 3-stage × 3-subagent dispatch, zero solo execution | Minimum 9 spawns; waves run sequentially because the plan never says what can run together | **Kept mandatory (A = 3), fixed with the Parallel Plan:** the Brain roadmap classifies every subtask PARALLEL or SEQUENTIAL with dependencies; waves dispatch ALL ready PARALLEL subtasks at once instead of one wave at a time |
| 3 | L288/L454/L458/L464/L755: STOP CALLING TOOLS + wait for `<SYSTEM_MESSAGE>` wakeup after every dispatch | Platform wakeup latency per wave; lead idle between waves | **Lead works while workers run:** queue all independent prep work before yielding; yield only for wakeup |
| 4 | L466–476: Brain roadmap — exhaustive file/function/caller inventory before any execution, in triplicate via 3 research agents | Full call-graph mapping up front; steps vague, so nobody can tell what is safe to run in parallel | **Roadmap kept and hardened:** same inventory, PLUS every subtask classified PARALLEL/SEQUENTIAL with `depends_on`, and every step names file + action + evidence — no vague steps. Research domains partitioned up front so the 3 agents don't re-read the same area |
| 5 | Per-file heatmap logging before every read/edit + join-time heatmap re-inspection (13× `heatmap log`) | A CLI call per file touch × 3+ agents | **Batched telemetry:** one log entry per completed subtask; §5 preflight inspection stays one-time (not per-file) |
| 6 | §17 four completion tables + §9 report + ledger (same data rendered 3–4×) | Evidence assembly at the end, duplicated | **ONE completion table**, derived from the ledger |
| 7 | §8 five-part push gate + §18 masked verification script (5 checks) back-to-back | Two full verification passes around one commit | **One push gate** before commit; §18 becomes 3 post-push confirmation commands |
| 8 | L748–752 micro-batches (5–8 files) + L763 lead re-verifies every worker report | Serialises parallel work | **Batches of 10–15 files; sampled verification** (diffstat + 1 file spot-check per worker) |
| 9 | L70–154 Phase 1A Turn-1 showcase: 5-pillar essay + per-task 6-part schema, template repeated for Task-01 AND Task-02 | Long authoring before any tool work | **Compact showcase:** one table for 5 pillars, one line per task, Azure field omitted when N/A |
| 10 | L278/L799 push-rejected retry: `gitmap pull` → re-run, no conflict procedure, no retry cap | Under concurrent-AI load this loops forever | **Push-race protocol (R9b):** one proactive rebase-first sync before push; max 2 attempts; then `PUSH_DEFERRED` + report. Fleet sync off the critical path |

## Why the AI does so much pulling and pushing

V6 does **not** order per-step pulls — it mandates ONE push per run and bans routine `gitmap pa` (L879). The churn has three real sources, none of them a per-step pull mandate:

1. **Push races (main cause).** Many AIs push to `main` concurrently. Each run ends with one big atomic push; each push is likely to be rejected because another bot moved remote first. Each rejection triggers `gitmap pull` → rebase → re-run — with no cap and no conflict procedure, so a contested `main` loops. V8 fixes this with R9b: rebase-first sync BEFORE the push (so the push usually succeeds first try), a 2-attempt cap, then `PUSH_DEFERRED` instead of looping.
2. **Fleet sync on the critical path.** V6's Phase 3 includes `gitmap sync` across 43 repos. V8 moves it to background/async — it never blocks the push.
3. **One giant push per turn per agent.** The single-push-at-end rule concentrates a whole long run into one collision-prone push. V8 keeps the single push (atomicity matters) but shrinks the collision window with the proactive rebase-first sync.

## Revision — 14-Nov-25 (user feedback: spec, GitMap, and parallelism are musts)

The first V8 draft cut too deep in three places and the user corrected it. The corrections are now in the V8 file:

1. **Spec writing is mandatory, not optional.** The first draft compressed the spec step and let the lead write a "lean spec" alone. Wrong: spec-before-plan-before-implementation is the repo-work rule and cannot be skipped for speed. V8 now restores V6's full §6: 3 research subagents → lead synthesis → 3 spec authors on strictly disjoint files → Brain roadmap → subtask DB → readiness gate. Zero solo spec authoring.
2. **The GitMap command table lives in the prompt.** The first draft replaced §3 with a pointer ("the full table lives in the GitMap skill"). Wrong: any AI starting cold must know how to start and where to start from the prompt itself. V8 now restores V6's full §3 table (22 commands), the search protocol, and the banned ad-hoc-scripts section verbatim.
3. **Parallelism is the main problem — the solo fast path is gone.** The first draft added a solo fast path (≤2 subtasks + ≤3 files, no spawn) and adaptive `A = min(3, ceil(subtasks/2))`. Wrong: the core complaint is that 400 steps execute one at a time, very slowly. V8 now restores A = 3 pinned, H = 2, Capacity = 6 — and adds the actual fix, the **Parallel Plan**: the Brain roadmap classifies every subtask PARALLEL (independent) or SEQUENTIAL (`depends_on: Task-XX`), waves dispatch ALL ready PARALLEL subtasks at once, and a subtask becomes ready the moment its dependencies complete. Vague steps are banned because vagueness is what forces sequential execution.
4. **N = 400 is the budget, not a computed number.** The first draft set `N = max(60, subtasks × 10)`. Wrong: N = 400 stays, and the plan sets the ACTUAL step count (≤ 400) after decomposition — fewer when the work needs fewer, never padded. Phase budgets restored to 100/150/150.

What survived the revision unchanged: scoped read budget (the deleted L1014 rant), batched telemetry, one evidence table, one verification pass, bigger batches with sampled checks, compact Turn-1 showcase, push-race protocol R9b. Net effect of the revision: V8 grows from 372 lines to ~500 lines (the restored §3 table + §5/§6), still ~50% smaller than V6's 1014 lines — the size saving now comes from deduplication and the compact showcase, not from cutting the spec or the GitMap table.

## What V8 keeps unchanged (same results)

- 3-phase pipeline (Plan → Execute → Consolidate + atomic push); spec-before-plan-before-implementation.
- 12-pillar quality gate (§1.1.E), 15-line functions, 300-line files, relative paths, lowercase, positive booleans.
- GitMap primacy; banned raw search (`rg`, `grep`, `Select-String`, `git grep`); worker git ban (`.git/index.lock` safety).
- Atomic single commit+push at end; hyphen format `<Module> - <summary>`; no colons, no third brackets, no `commit` module; no raw git commits.
- Zero builds / zero tests / zero CI unless explicitly asked (R1); CI only via Pipeline-AI + ETA sleep when asked (R12).
- Ledger + `.ai-memory/plans/` as source of truth; ambiguity protocol (autonomous continuation, never ask the user); RCA on failure; evidence-or-it-didn't-happen (R3).
- V7's dual operating modes (time restriction) and identity governance (R8) — carried over, deduplicated.
- Anti-sloppiness teeth: verbatim decisions, no placeholders, no omitted items, indexes synced in the same turn. Speed is not an excuse for sloppiness — unfocused depth is the thing being removed.

## What V8 deliberately drops

- The L1014 closing rant (unbounded whole-codebase read + zero truncation). This is the single largest speed win and the most deliberate break from V6.
- Sequential waves: V6 never said which steps could run together, so they ran one at a time. V8's Parallel Plan replaces that with PARALLEL/SEQUENTIAL classification + dependency-first dispatch.
- The duplicated rule restatements (banned-search list ~10×, commit format 5×, "no push = not done" 3×, zero-build ban 4×). Every rule is stated once in §2 and cited by ID.
- The "N = 400 as a quota" reading: N = 400 is the budget cap; the plan sets the actual step count (fewer when the work needs fewer, never padded).

## What V8 deliberately does NOT drop (the musts)

- **The spec.** Spec writing is mandatory (§6): 3 research subagents → lead synthesis → 3 spec authors on disjoint files → Brain roadmap → subtask DB. No spec, no execution.
- **The GitMap command table.** The full §3 table (22 commands), search protocol, and banned ad-hoc-scripts section stay in the prompt, because any AI starting cold must know how to start and where to start.
- **The pinned swarm.** A = 3, H = 2, Capacity = 6, 100% duty cycle while work remains. Solo execution stays an auto-reject failure.

## How to use V8

Invoke `@[execute-parent-task-with-n-steps-v8](directory;.agents/skills/execute-parent-task-with-n-steps-v8)`. Skills installed at `.agents/skills/execute-parent-task-with-n-steps-v8/skill.md` and `.cursor/skills/execute-parent-task-with-n-steps-v8/skill.md`. V6 (`02-...-v6.md`) and V7 (`02-...-v7.md`) remain frozen in the same folder for reference.
