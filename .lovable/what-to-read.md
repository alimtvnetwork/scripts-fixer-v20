# What to Read — AI Agent Onboarding

> Read this **first** every session. It points to every file and folder an AI needs to safely add features, fix bugs, write tests, or author specs in this repo.

---

## 1. Read-First (every session, in order)

| # | Path | Why |
|---|------|-----|
| 1 | `readme.md` | Product overview, commands, install one-liners |
| 2 | `.lovable/overview.md` | Project shape and conventions |
| 3 | `.lovable/memory/index.md` | Master index of every memory file |
| 4 | `.lovable/plan.md` | Active roadmap and pending tasks |
| 5 | `.lovable/strictly-avoid.md` | Hard prohibitions — do not violate |
| 6 | `.lovable/suggestions.md` | Open and implemented suggestions |
| 7 | `.lovable/cicd-index.md` | CI/CD issue index |
| 8 | `.lovable/prompts/index.md` | Reusable prompt registry (incl. write-memory) |
| 9 | `.lovable/prompt.md` | Top-level pointer to prompts |
| 10 | `.lovable/memory/workflow/` | Current workflow state and status markers |
| 11 | `.lovable/memory/release-architecture-map.md` | Release architecture and versioning rules |

If any of the above is missing, **create it** using the templates in `.lovable/prompts/01-write-memory.md`.

---

## 2. Folder Map

```
.lovable/
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

- `.lovable/coding-guidelines.md` — must-follow code rules (functions ≤ 8 lines, no nested ifs, no `any`, boolean `is`/`has` prefix, ≤ 100 lines/file, no magic numbers, DRY first, etc.).
- `spec/` — public spec for the area you are touching. Match an existing folder by name (`spec/<NN>-<feature>/`).
- `spec/shared/` — shared helpers (logging, install-paths, ensure-tool, tool-version, registry-backup, admin-check, fast-download, etc.). Reuse, do not re-implement.
- `spec/error-manage/` (if present) — every `catch`/error path must comply. Always log exact file path + reason (CODE RED rule).
- `.lovable/memory/preferences/` — naming, structure, banner rules.
- `.lovable/memory/constraints/` — strictly-prohibited patterns.

---

## 4. Adding a New Feature

1. Read `spec/00-generic-install-script-behavior/` end-to-end — it is the contract for every install-style script.
2. Create `spec/<NN>-<feature>/readme.md` with: purpose, commands, flags, examples, exit codes, files written.
3. Implement under `scripts/<NN>-<name>/` (Windows) **and** `scripts-linux/<name>/` (Unix). Reuse shared helpers.
4. Wire the verb into `run.ps1` and `scripts-linux/run.sh` dispatchers. Add alias entries to `$commandAliasMap` when renaming.
5. Update `readme.md` "Recently Added" table + relevant section.
6. Add memory entry under `.lovable/memory/features/<feature>.md` and link it from `.lovable/memory/index.md`.
7. Bump `version.json` + `changelog.md` per `spec/bump-version/`.

---

## 5. Adding a Unit Test

- TS/React: `src/test/*.test.ts` (vitest). Run: `bunx vitest run`.
- PowerShell: `scripts/<NN>-*/tests/*.test.ps1` (Pester style invoked from CI).
- Bash: `scripts-linux/<name>/tests/*.bats` or `*.test.sh`.
- Add CI coverage in `.github/workflows/test-script-<NN>.yml` mirroring existing ones (`test-script-53.yml`, `test-script-54.yml`).
- Never test against real network/host state — fake `Local State`, registry hives, and `installed/` ledgers under a temp dir.

---

## 6. Fixing a Bug

1. Open or create `.lovable/pending-issues/<NN>-<slug>.md` using the template in `.lovable/prompts/01-write-memory.md` §5A.
2. Reproduce — capture exact command, OS, console output.
3. Fix in the smallest possible diff. Preserve shared-helper contracts.
4. On green: **move** the file to `.lovable/solved-issues/` and append `## Solution`, `## Iteration Count`, `## Learning`, `## What NOT to Repeat`.
5. If the bug class must never recur, add a line to `.lovable/strictly-avoid.md` linking back to the solved-issue file.

---

## 7. Writing a Spec

- Public spec: `spec/<area>/readme.md`. Use existing specs as templates (see `spec/52-vscode-folder-repair/readme.md`).
- Verbatim user directive: `.lovable/memory/specs/<NN>-<slug>.md` — quote the user word-for-word, never paraphrase.
- Index every new spec in `.lovable/memory/index.md`.

---

## 8. Ending a Session

Run the **write-memory** prompt: `.lovable/prompts/01-write-memory.md`. It enforces audit → update memory → update plan/suggestions → move issues → validate index integrity → produce the final summary.

---

## 9. Hard Rules (excerpt — see `strictly-avoid.md` for the full list)

- Never create `.lovable/memories/` (with `s`). Correct path is `.lovable/memory/`.
- Never delete history — mark done, move to `## Completed`, never erase.
- Never write memory files outside `.lovable/memory/...` subfolders. No bare `mem://` writes.
- Never edit `src/integrations/supabase/client.ts`, `types.ts`, or `.env` (auto-generated).
- Never echo secrets or reference the Supabase dashboard (Lovable Cloud users have no access).
- Console-safe ASCII status glyphs only: `[OK]`, `[==]`, `[XX]`, `[--]`, `[!!]` — no wide Unicode emoji in terminal banners.
- Every `CREATE TABLE public.*` migration must include `GRANT` + `ENABLE RLS` + policies in the same file.

---

## 10. Quick Reference — Where Things Live

| You want to… | Look here |
|---|---|
| Add a new install script | `spec/00-generic-install-script-behavior/`, then `scripts/<NN>-*` + `scripts-linux/<name>/` |
| Reuse a helper (logging, paths, ensure-tool) | `spec/shared/` + `scripts/shared/` + `scripts-linux/_shared/` |
| Wire a new top-level verb | `run.ps1` `$commandAliasMap` + `$canonicalVerbs`; `scripts-linux/run.sh` dispatch |
| Add a profile | `scripts/profiles/*.json` + validator schema |
| Track an OS-clean category | `scripts/os/helpers/simple-clean.ps1` + `Confirm-DestructiveCategory` |
| Bump version | `bump-version.ps1`, `version.json`, `changelog.md`, root `readme.md` version badge |
| Capture a Lovable suggestion | `.lovable/suggestions/<NN>-<slug>.md` + `.lovable/suggestions.md` tracker |
