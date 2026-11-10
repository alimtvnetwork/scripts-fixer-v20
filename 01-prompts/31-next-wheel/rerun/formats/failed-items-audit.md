---
id: failed-items-audit
name: Failed Items Audit Rerun
description: Context-first rerun that triages failed or carried-forward items from rerun context before restating the nudge, insert, and original task.
category: rerun
placeholders: [nudge, insert, time_effort, rerun_context, prompt, attachments, round, total]
version: 1
default: false
---

# Rerun — Round {round} of {total}

{nudge}

## Failed & Carried-Forward Items

{rerun_context}

Triage every item above in order: what failed, why (exact mechanism, not a vague excuse), the fix this round, and how it will be verified. If none are listed, the original task below is the full scope; do not invent prior results.

{insert}

{time_effort}

------######
---
Original Task:
{prompt}

{attachments}
