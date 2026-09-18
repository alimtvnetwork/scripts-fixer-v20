# What to Read — AI Agent Onboarding

> Read this **first** every session. It points to every file and folder an AI needs to safely add features, fix bugs, write tests, or author specs in this repo.

---

## 1. Read-First (every session, in order)

| # | Path | Why |
|---|------|-----|
| 1 | `readme.md` | Product overview, commands, install one-liners |
| 2 | `.ai-memory/overview.md` | Project shape and conventions |
| 3 | `.ai-memory/memory/01-index.md` | Master index of every memory file |
| 4 | `.ai-memory/plans/01-index.md` | Master index of all plans (pending & completed) |
| 5 | `.ai-memory/strictly-avoid.md` | Hard prohibitions — do not violate |
| 6 | `.ai-memory/suggestions.md` | Open and implemented suggestions |
| 7 | `.ai-memory/cicd-index.md` | CI/CD issue index |
| 8 | `01-prompts/index.md` | Reusable prompt registry (incl. write-memory) |
| 9 | `.ai-memory/prompt.md` | Top-level pointer to prompts |
| 10 | `.ai-memory/memory/workflow/` | Current workflow state and status markers |
| 11 | `.ai-memory/memory/release-architecture-map.md` | Release architecture and versioning rules |
| 12 | `03-ai-scripts/01-index.md` | AI Automation tools & fast cached exploration index |

See `.ai-memory/plans/01-index.md` for the **Recent Completed Tasks Register** tracking the last 20 tasks.
If any of the above is missing, **create it** using the templates in `01-prompts/01-read-prompt.md`.

---

## 2. Folder Map

```
.ai-memory/
├── overview.md                  # project shape
├── what-to-read.md              # THIS file
├── plan.md                      # single roadmap file
├── strictly-avoid.md            # hard "never do" list
├── suggestions.md               # tracker (single file)
├── prompt.md                    # pointer → prompts/index.md
├── cicd-index.md                # CI/CD issue index
├── prompts/                     # reusable prompts
│   ├── index.md
│   └── 01-write-memory.md
├── memory/                      # the project brain
│   ├── index.md
│   ├── workflow/                # session/workflow state
│   ├── specs/                   # verbatim user specs
│   ├── decisions/               # captured decisions
│   ├── avoid/                   # "never do X" per topic
│   ├── constraints/             # hard constraints
│   ├── features/                # per-feature notes
│   └── preferences/             # user preferences
├── suggestions/                 # verbatim per-suggestion captures
├── pending-issues/              # open issues, one file each
├── solved-issues/               # resolved issues + learnings
├── cicd-issues/                 # per-issue CI/CD files
├── compliance-reports/          # audit outputs
├── question-and-ambiguity/      # clarifications needed
└── specs/                       # internal specs

spec/                            # public-facing specs per script/feature
├── 00-generic-install-script-behavior/
├── 01-install-vscode/ ... 68-user-mgmt/
├── shared/                      # shared-helper specs
├── 2025-batch/                  # batched feature specs
└── error-manage/                # error-management rules (if present)

scripts/                         # Windows PowerShell scripts (numbered)
scripts-linux/                   # Linux/macOS bash equivalents (numbered)
scripts-orchestrator/            # multi-host SSH orchestration
kubernetes/                      # k8s install helpers
tools/                           # repo-maintenance utilities
src/                             # React + Vite + TS dashboard
assets/                          # static assets, XX-prefixed
```

---

## 3. Before You Code — Read These

- `.ai-memory/coding-guidelines.md` — must-follow code rules (functions ≤ 8 lines, no nested ifs, no `any`, boolean `is`/`has` prefix, ≤ 100 lines/file, no magic numbers, DRY first, etc.).
- `02-spec/` — public spec for the area you are touching. Match an existing folder by name (`spec/<NN>-<feature>/`).
- `02-spec/shared/` — shared helpers (logging, install-paths, ensure-tool, tool-version, registry-backup, admin-check, fast-download, etc.). Reuse, do not re-implement.
- `02-spec/error-manage/` (if present) — every `catch`/error path must comply. Always log exact file path + reason (CODE RED rule).
- `.ai-memory/memory/preferences/` — naming, structure, banner rules.
- `.ai-memory/memory/constraints/` — strictly-prohibited patterns.

---

## 4. Adding a New Feature

1. Read `02-spec/00-generic-install-script-behavior/` end-to-end — it is the contract for every install-style script.
2. Create `spec/<NN>-<feature>/readme.md` with: purpose, commands, flags, examples, exit codes, files written.
3. Implement under `scripts/<NN>-<name>/` (Windows) **and** `scripts-linux/<name>/` (Unix). Reuse shared helpers.
4. Wire the verb into `run.ps1` and `scripts-linux/run.sh` dispatchers. Add alias entries to `$commandAliasMap` when renaming.
5. Update `readme.md` "Recently Added" table + relevant section.
6. Add memory entry under `.ai-memory/memory/features/<feature>.md` and link it from `.ai-memory/memory/index.md`.
7. Bump `version.json` + `changelog.md` per `02-spec/bump-version/`.

---

## 5. Adding a Unit Test

- TS/React: `src/test/*.test.ts` (vitest). Run: `bunx vitest run`.
- PowerShell: `scripts/<NN>-*/tests/*.test.ps1` (Pester style invoked from CI).
- Bash: `scripts-linux/<name>/tests/*.bats` or `*.test.sh`.
- Add CI coverage in `.github/workflows/test-script-<NN>.yml` mirroring existing ones (`test-script-53.yml`, `test-script-54.yml`).
- Never test against real network/host state — fake `Local State`, registry hives, and `installed/` ledgers under a temp dir.

---

## 6. Fixing a Bug

1. Open or create `.ai-memory/pending-issues/<NN>-<slug>.md` using the template in `01-prompts/01-write-memory.md` §5A.
2. Reproduce — capture exact command, OS, console output.
3. Fix in the smallest possible diff. Preserve shared-helper contracts.
4. On green: **move** the file to `.ai-memory/solved-issues/` and append `## Solution`, `## Iteration Count`, `## Learning`, `## What NOT to Repeat`.
5. If the bug class must never recur, add a line to `.ai-memory/strictly-avoid.md` linking back to the solved-issue file.

---

## 7. Writing a Spec

- Public spec: `spec/<area>/readme.md`. Use existing specs as templates (see `02-spec/52-vscode-folder-repair/readme.md`).
- Verbatim user directive: `.ai-memory/memory/specs/<NN>-<slug>.md` — quote the user word-for-word, never paraphrase.
- Index every new spec in `.ai-memory/memory/index.md`.

---

## 8. Ending a Session

Run the **write-memory** prompt: `01-prompts/01-write-memory.md`. It enforces audit → update memory → update plan/suggestions → move issues → validate index integrity → produce the final summary.

---

## 9. Hard Rules (excerpt — see `strictly-avoid.md` for the full list)

- Never create `.ai-memory/memories/` (with `s`). Correct path is `.ai-memory/memory/`.
- Never delete history — mark done, move to `## Completed`, never erase.
- Never write memory files outside `.ai-memory/memory/...` subfolders. No bare `mem://` writes.
- Never edit `src/integrations/supabase/client.ts`, `types.ts`, or `.env` (auto-generated).
- Never echo secrets or reference the Supabase dashboard (Lovable Cloud users have no access).
- Console-safe ASCII status glyphs only: `[OK]`, `[==]`, `[XX]`, `[--]`, `[!!]` — no wide Unicode emoji in terminal banners.
- Every `CREATE TABLE public.*` migration must include `GRANT` + `ENABLE RLS` + policies in the same file.

---

## 10. Quick Reference — Where Things Live

| You want to… | Look here |
|---|---|
| Add a new install script | `02-spec/00-generic-install-script-behavior/`, then `scripts/<NN>-*` + `scripts-linux/<name>/` |
| Reuse a helper (logging, paths, ensure-tool) | `02-spec/shared/` + `scripts/shared/` + `scripts-linux/_shared/` |
| Wire a new top-level verb | `run.ps1` `$commandAliasMap` + `$canonicalVerbs`; `scripts-linux/run.sh` dispatch |
| Add a profile | `scripts/profiles/*.json` + validator schema |
| Track an OS-clean category | `scripts/os/helpers/simple-clean.ps1` + `Confirm-DestructiveCategory` |
| Bump version | `bump-version.ps1`, `version.json`, `changelog.md`, root `readme.md` version badge |
| Capture a Lovable suggestion | `.ai-memory/suggestions/<NN>-<slug>.md` + `.ai-memory/suggestions.md` tracker |

---

## Changelog

- `2026-09-13T07:44:14Z` — Added `folder-structure.md`, `coding-guidelines.md`, and `02-spec/commands/02-nginx-domain-manager.md`. Pointed master memory and plans to `01-index.md`. Synchronized root `readme.md` AI onboarding table.
