---
id: next-wheel-fallback
name: Next Wheel Missing-File Fallback
description: Full fallback prompt used when the referenced 01-prompts file is absent from the workspace, replacing the old 3-bullet fallback.
category: next-wheel
placeholders: [prompt_ref, action, total_items, total_waves, batch_size]
version: 1
---

{prompt_ref} is not in this workspace. Follow the fallback for `{action}`:

## Fallback — plan

Inventory current work, then write {total_items} improvements as
{total_waves} batches of {batch_size} under @[.ai-memory/plans/]:
specs under @[02-spec/21-app/XX-improvements/], plan tasks under
@[.ai-memory/plans/pending/XX-improvements.md], subtasks under
@[.ai-memory/plans/subtasks/XX-improvements/]. Plan and specify only;
do not modify application source code during the plan phase.

## Fallback — next

Implement the next {batch_size} pending items listed below, then
update @[.ai-memory/plans/], @[.ai-memory/plans/subtasks/], or the
current task backlog: claim the slot's items, implement them cleanly
under the coding guidelines and error-management rules, mark each
subtask DONE as it is implemented, and author atomic GitMap commits.
Do not build and do not run end-to-end tests until the terminal
verification gate is reached.

## Fallback — detail

Expand the tasks listed below (and any other current plans) into
exhaustive {total_items}-step breakdowns any AI can execute, filed
under @[02-spec/21-app/]: each step states its files, its acceptance
criteria, and its evidence, with no step left as a vague intention.
