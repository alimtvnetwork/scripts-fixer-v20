---
name: execute-parent-task-with-n-steps-v8
description: >-
  Execute prompt. GitMap is how a run starts. The spec is required. Planning
  writes a concrete step map under a 400-step ceiling and shrinks it when the
  work is smaller. Each wave runs its disjoint steps in parallel. V6 and V7
  are not modified by this prompt.
---

# [V8] Parent Task — Spec, Step Map, Parallel Waves

```text
N_CEILING = 400   (upper bound. Never a quota. Never a one-by-one counter.)
N_PLAN    = the number of concrete steps left after vague steps are cut
A = 3             (workers in one wave)
H = 2             (files one worker may own in that wave)
CAPACITY = 6      (A x H. One wave runs up to 6 disjoint steps in the same turn.)
```

> **Prompt version:** 8.1.0
> **Canonical file:** `01-prompts/14-execute/10-execute-parent-task-with-n-steps-v8.md`
> **Invocation:** `@[execute-parent-task-with-n-steps-v8](directory;.agents/skills/execute-parent-task-with-n-steps-v8)`
> **Invocation:** `@[execute-parent-task-with-n-steps-v8](directory;.cursor/skills/execute-parent-task-with-n-steps-v8)`
> **Toolchain:** `@[gitmap](directory;.agents/skills/gitmap)`
>
> Instructions above this prompt outrank this prompt. This prompt does not edit `01-prompts/14-execute/02-execute-parent-task-with-n-steps-v6.md` or any V7 file.

[/goal](slashCommand;goal) Start with GitMap, write the spec, write a concrete step map, then execute each wave in parallel. Finish with one GitMap commit.

The slow run is the one that finishes step 1, then starts step 2, then starts step 3. V8 does not do that. A wave is every step whose files do not overlap, and that whole wave runs in one turn.

## 1. Start with GitMap

A new agent starts here, before any edit.

1. Read `@[gitmap](directory;.agents/skills/gitmap)`.
2. In one turn, run the searches for every symbol the user named. One `gitmap search "<symbol>" <dir>` per symbol, all of them together.
3. `gitmap lf <dir>` for each directory the user named, in that same turn.
4. `gitmap cat <file>` only for a file a search hit and the spec will name.

Search and listing go through GitMap. Do not use `rg`, `grep`, `Select-String`, `findstr`, or `Get-ChildItem`.

Do not pull. Do not commit. `git status -sb` once is enough to see the branch.

## 2. Write the spec

The spec is required. Code edits wait until these three files exist. They do not share a file, so write all three in the same turn. One owner per file.

- `02-spec/21-app/<nn-slug>/01-architecture-spec.md`
- `02-spec/21-app/<nn-slug>/02-component-spec.md`
- `02-spec/21-app/<nn-slug>/03-migration-and-verification-spec.md`

The architecture spec names every file later steps will change, and the change in that file. The component spec names the types and functions those steps add or edit. The verification spec names the one check that proves the change, and it names no full test suite.

A step that the architecture spec does not name does not run.

## 3. Look ahead and write the step map

Planning looks ahead across the whole job before the first code edit. The map is a table in the architecture spec. `N_PLAN` is the number of rows after the cut below. Write `N_PLAN` above the table. When the work needs 12 steps, `N_PLAN` is 12. Do not add rows to reach 400.

Each row has all of these fields:

| Field | What it holds |
| --- | --- |
| Step | `S01`, `S02`, ... |
| File | one relative path |
| Change | the function or section, and what is true when the step is done |
| Wave | `W1`, `W2`, ... |
| Owner | lead, or worker A, B, or C |

A row is vague when the file is missing, the change is a verb with no outcome, or two rows in the same wave name the same file. Vague rows are rewritten or deleted before execution. "Review the code", "look through the folder", and "improve errors" are vague.

Waves are the only sequence. `W2` starts after `W1` because it may use what `W1` wrote. Steps that share a wave do not share a file, and they run together.

`N_PLAN` above 400 means the map is still vague. Split by file until every row is one change, then cut again until `N_PLAN` is at or under 400.

## 4. Execute a wave in one turn

Do not walk `S01`, then `S02`, then `S03` when those rows share a wave.

For the current wave:

1. Spawn the workers for that wave in one `invoke_subagent` call. Up to `A = 3`. Each worker gets at most `H = 2` files, and those files appear on no other owner.
2. In that same turn, the lead edits the file the table assigns to the lead, if that file is in this wave.
3. Issue the independent GitMap reads for this wave together, not one file per turn.

When the wave's files are saved, start the next wave. Do not respawn a worker to fill idle time after the queue for this wave is empty.

Workers do not run git. One owner per file.

Keep functions at or under 15 lines, files at or under 300 lines, booleans as `is` or `has`, and errors returned with the operation name. The source is `02-spec/17-consolidated-guidelines/34-compiled-simple-coding-guidelines.md`.

Do not run `go test ./...`, `go build ./...`, `npm test`, or `npm run build`. Run the single check named in the verification spec.

## 5. One GitMap commit

After the last wave, the lead runs one command:

- feature: `gitmap cpf "<module> - <summary>"`
- fix: `gitmap cpb "<module> - <summary>"`
- chore: `gitmap cpc "<module> - <summary>"`

The message uses a hyphen. It has no square brackets and no colon. The module is the subsystem, never the word `commit`.

That command is the only push. Do not commit per step and do not commit per wave. If the push is rejected, run `gitmap pull` once, run the same GitMap command once, then stop and report the error. Do not run `gitmap sync` or `gitmap pa` unless the task is a fleet sync.

## Done

The run is done when every row in the step map is in the named file and the one GitMap command has pushed. Stop. Do not execute unused numbers up to 400. Do not edit the V6 prompt or any V7 prompt. Do not bump a version unless the user said release.
