---
id: sectioned-audit
name: Sectioned Audit Rerun
description: Opt-in sectioned rerun with time/effort mandate, rerun context, and discipline groupings; round/total stamped in the header.
category: rerun
placeholders: [nudge, insert, time_effort, rerun_context, prompt, attachments, round, total]
version: 1
default: false
---

# Rerun — Round {round} of {total}

{nudge}

{insert}

{time_effort}

## Rerun Context

{rerun_context}

Carry forward every unfinished or failed item above. If none are listed, the original task below is the full scope; do not invent prior results.

## Discipline Groupings

- Discipline: root-cause analysis for every gap, acceptance-criteria audit with line-numbered evidence, no excuses.
- UI: responsive layout, padding, font contrast, button styling, hover states, alignment.
- Code: no duplicates, functions at most 15 lines, positive booleans, all errors routed, verified thoroughly.

------######
---
Original Task:
{prompt}

{attachments}
