---
id: next-wheel-execution
name: Next Wheel Bulletproof Execution
description: Bulletproof next-batch execution prompt for the next action, with time/effort mandate, rerun context, and discipline groupings.
category: next-wheel
placeholders: [count, slot, total_waves, rerun_context, time_effort]
version: 1
---

# Actionable Items Must Follow Non-Negotiable

{time_effort}

## Rerun Context

{rerun_context}

Carry forward every unfinished or failed item listed above; items not
listed as unfinished are not assumed done. When no prior-round items are
listed, treat the pending-task list in the dispatched prompt as the full
scope and do not invent prior results.

## Discipline Groupings

Apply every grouping below to this slot. The groupings compose: a slot
may carry discipline plus UI plus code checks together, and all of them
must pass before the slot is marked done.

### Discipline — Root Cause & Acceptance Audit

- Why was anything not done? Why were things not completed? Why was it
  not planned? Perform a thorough Root Cause Analysis (RCA) for every
  gap: state the exact mechanism of failure, not a vague excuse.
- Audit all acceptance criteria for every claimed item against grounded
  file inspection, with line-numbered references. Finish the task cleanly
  without making excuses, and report anything unfinished as FAILED with
  actionable diagnostics — never as silently done.

### UI — Layout & Polish

- Why is the UI broken or unrefined? Check responsive layout, padding,
  font contrast, button styling, hover states, and alignment.
- Complete the UI improvements immediately; verify the result in the
  real interface, not from memory of how it should look.

### Code — Hygiene & Error Routing

- Why was code written without proper planning and hygiene? Eliminate
  duplicates, keep functions at most 15 lines with a single
  responsibility, use positive booleans, and route all errors through
  the error channel (no silent catches, no swallowed failures).
- Verify thoroughly: every change must be checkable against a file and
  a line, not asserted without evidence.

## Execution Steps

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Claim the next {count} unexecuted improvements from @[.ai-memory/plans/pending/] and @[.ai-memory/plans/subtasks/] matching the slot range (Slot {slot}/{total_waves}).
3. Fast-Forwarding Protocol: strictly NO-BUILD and NO-TEST execution during implementation turns until the terminal verification gate is reached.
4. Strictly enforce the 8-Pillar Coding Guideline Matrix (*appfault.AppError, monadic Result envelopes, parameter structs, string constants/enums, 8-15 line functions, 150-300 line files, vertical spacing rhythm, positive booleans).
5. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String.
6. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute filesystem paths.
7. Must follow non negociable - follow coding guidelines @[.agents/skills/follow-coding-guidelines/skill.md] and @[02-spec/02-coding-guidelines].
8. Must follow non negociable - @[02-spec/03-error-manage/readme.md] and @[02-spec/03-error-manage] proper to the letter.
9. Update subtask statuses to DONE in @[.ai-memory/plans/subtasks/] upon implementing each item and author atomic GitMap conventional commits.

## Evidence Contract

Close the slot with a scorecard: slot number, items claimed, items
completed, files changed with line references, and verification status
per item. Any item without evidence stays open and is carried forward
as rerun context for the next slot — it is never dropped.

## Terminal Gate

Builds and end-to-end tests become mandatory only at the terminal
verification gate appended to this prompt. Until that gate is reached,
the wave rule in step 3 stands.
