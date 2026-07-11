# Prompts Index

> Reference file for all AI prompts. Saying "read memory" triggers onboarding; "write memory" / "end memory" triggers persistence.
>
> Kept in sync with `version.json` — bump the project minor version whenever a prompt version changes.

## Project version

Current: **1.6.0** (see `version.json`).

## Available Prompts

| ID | File | Version | Trigger | Purpose |
|----|------|---------|---------|---------|
| 01 | [01-read-prompt.md](prompts/01-read-prompt.md) | v1.1 | `read memory` | Full AI onboarding — reads Phases 1–4 (context, guidelines, spec-authoring, task-driven specs). Run `bash tools/check-read-memory-paths.sh` to verify every referenced path exists. |
| 02 | [02-write-prompt.md](prompts/02-write-prompt.md) | v1.0 | `write memory`, `end memory`, `update memory` | Persists session work — updates memory, plan, suggestions, issues with consistency validation. |

## Sync contract

- When a prompt's `## Changelog` gets a new entry, update its **Version** column above in the same commit.
- When paths inside `01-read-prompt.md` change, re-run `bash tools/check-read-memory-paths.sh` and update the checker if new paths are introduced.
- Any prompt edit is a code change → bump `version.json` minor per project rule #13.
