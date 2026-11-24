---
name: execute-parent-task-with-n-steps-v8
description: >-
  Execute prompt. GitMap starts the run, the spec is required, and planning
  writes a concrete step map under a 400-step ceiling. Each wave runs in
  parallel. Canonical text is
  01-prompts/14-execute/10-execute-parent-task-with-n-steps-v8.md.
---

# Execute parent task V8

Read and follow `01-prompts/14-execute/10-execute-parent-task-with-n-steps-v8.md`.

Also read `@[gitmap](directory;.agents/skills/gitmap)` before the first edit. V6 and V7 stay unchanged.

- Start with GitMap. Search every named symbol in one turn with `gitmap search`. List named directories with `gitmap lf`. Open a file with `gitmap cat` only when the spec will name it.
- Write the three spec files in `02-spec/21-app/<nn-slug>/` in one turn, before any code edit.
- In the architecture spec, write the step map. Each row has a step id, one relative path, the change, a wave, and an owner. Cut vague rows. `N_PLAN` is the row count. Shrink it under 400. Do not add rows to reach 400.
- Execute one wave per turn. Up to 3 workers, 2 files each, spawned in one call, while the lead edits the lead's own file. Do not finish one step and then start the next step of the same wave.
- One `gitmap cpf`, `cpb`, or `cpc` after the last wave. That is the only push.

Full engine (long form, same rules, plus push-race protocol, batched telemetry, and single evidence table): `01-prompts/14-execute/02-execute-parent-task-with-n-steps-v8.md`.
