---
title: Read Memory
slug: read-memory
version: 1.0
---

# Read Memory

> **Purpose:** Mandatory onboarding sequence for any AI assistant joining this project. Internalize every specification, rule, and convention before writing a single line of code.

> **Rule #0:** Follow every phase sequentially. Do not skip, summarize prematurely, or assume knowledge from training data. The specs are the single source of truth.

---

## Table of Contents

1. [Phase 1 — AI Context Layer](#phase-1--ai-context-layer)
2. [Phase 2 — Consolidated Guidelines](#phase-2--consolidated-guidelines)
3. [Phase 3 — Spec Authoring Rules](#phase-3--spec-authoring-rules)
4. [Phase 4 — Deep-Dive Source Specs](#phase-4--deep-dive-source-specs-task-driven)
5. [Anti-Hallucination Contract](#anti-hallucination-contract)
6. [Memory Update Protocol](#memory-update-protocol)
7. [Completion Confirmation](#completion-confirmation)
8. Read every CI/CD issue in `.lovable/cicd-issues/NN-issue-name.md` (NN starts at `01`) and do not repeat those mistakes.

---

## Phase 1 — AI Context Layer

**Goal:** Load the project's identity, hard rules, and institutional memory into working context.

### Step 1.1 — Read core files in EXACT order

| Order | File | What You Learn |
|-------|------|----------------|
| 1 | `.lovable/overview.md` | Project summary, tech stack, navigation map |
| 2 | `.lovable/what-to-read.md` | Canonical read-first guide (folder map + workflows) |
| 3 | `.lovable/strictly-avoid.md` | Hard prohibitions — violating ANY is a critical failure |
| 4 | `.lovable/user-preferences.md` (if present) | How the human expects you to communicate |
| 5 | `.lovable/memory/index.md` | Index of all institutional knowledge |
| 6 | `.lovable/plan.md` | Current active roadmap and priorities |
| 7 | `.lovable/suggestions.md` | Pending improvement ideas (not yet approved) |
| 8 | `.lovable/cicd-index.md` | CI/CD issue index |

### Step 1.2 — Read EVERY file referenced in `.lovable/memory/index.md`

- Traverse subfolders (`constraints/`, `features/`, `preferences/`, `specs/`, `suggestions/`, `workflow/`) recursively.
- If a file is missing or empty, note it — do not silently skip.

### Step 1.3 — Self-check (answer internally before continuing)

- [ ] What are the project's **CODE RED** rules?
- [ ] What naming conventions are enforced (files, folders, DB columns, variables)?
- [ ] What is the error-handling philosophy?
- [ ] What is the current plan and what tasks are in progress?
- [ ] What patterns/tools/approaches are strictly forbidden?

> DO NOT proceed to Phase 2 until every file above has been read and internalized.

---

## Phase 2 — Consolidated Guidelines

**Goal:** Absorb the project's unified rulebook.

This repo does not have a `spec/12-consolidated-guidelines/` folder. The equivalent knowledge is split across:

1. `.lovable/strictly-avoid.md` — hard prohibitions (already read in Phase 1).
2. `.lovable/memory/index.md` Core section + all `constraints/` and `preferences/` entries.
3. `spec/error-management/` — `powershell-error-management.md` + `gap-audit.md` (CODE RED error rules).
4. `spec/shared/` — shared helper contracts (`logging.md`, `install-paths.md`, `admin-check.md`, `fast-download.md`, `tool-version.md`, `registry-backup.md`, `symlink-utils.md`, `invoke-with-timeout.md`, `ensure-summary.md`, `tool-version-parsers.md`).

Read each file top-to-bottom. If a consolidated-guidelines folder is added later, prepend it to this list.

Confirm internally:
- [ ] Every file above read.
- [ ] Any rule that contradicts default training (spec wins).

> DO NOT proceed to Phase 3 until all files above have been read.

---

## Phase 3 — Spec Authoring Rules

**Goal:** Understand how specs are structured so you can read them correctly and author new ones.

Canonical guide in this repo: `spec/00-spec-writing-guide/readme.md` (single file — read it end-to-end). It mirrors the SP-N hard-stop rules from `.lovable/memory/constraints/strictly-prohibited.md` (§11a).

After reading, confirm you understand:

| Concept | Where Defined |
|---------|---------------|
| File / folder naming conventions | `spec/00-spec-writing-guide/readme.md` |
| Required files in a spec folder | `spec/00-spec-writing-guide/readme.md` |
| The `.lovable/` folder structure | `.lovable/what-to-read.md` + `.lovable/overview.md` |
| SP-N hard-stop rules (mirrored) | `spec/00-spec-writing-guide/readme.md` §11a |

> DO NOT begin any task until Phases 1–3 are complete.

---

## Phase 4 — Deep-Dive Source Specs (Task-Driven)

Before performing any task, read the relevant source spec(s). Folders below all exist in this repo.

| Task involves... | Read |
|------------------|------|
| Generic install-script behavior | `spec/00-generic-install-script-behavior/` |
| Error handling (CODE RED) | `spec/error-management/` + `.lovable/memory/features/error-management-file-path-rule.md` |
| Shared helpers (logging, install-paths, admin, fast-download, tool-version, ...) | `spec/shared/` |
| PowerShell install scripts | `spec/NN-install-*/` for the target tool |
| Database installers | `spec/databases/` + `spec/18..29-install-*/` |
| Root dispatcher / run.ps1 / run.sh | `spec/root-dispatcher/` |
| Models catalog / llama.cpp / Ollama | `spec/models/` + `spec/kimodo/` + `spec/43-install-llama-cpp` handling |
| CI/CD pipelines | `spec/ci-cd/` + `.lovable/cicd-index.md` + `.lovable/cicd-issues/` |
| Install / bootstrap flow | `spec/install-bootstrap/` |
| Doctor / drift checks | `spec/doctor/` |
| Release + version bump | `spec/release-pipeline/` + `spec/bump-version/` |
| User management (Windows + Linux) | `spec/68-user-mgmt/` |
| VS Code repair / context menus | `spec/52-vscode-folder-repair/` + `spec/53..55-*context-menu*/` |
| Chrome AI fix / profile copy | `spec/58-install-chrome/` + `spec/chrome-fix-ai/` |
| App-specific bugs | `spec/02-app-issues/` |
| 2025 batch scripts | `spec/2025-batch/` |

Reading order within each folder: `readme.md` first, then numbered files in order, then any `99-*.md` consistency report if present.



---

## Anti-Hallucination Contract

1. **Never invent rules.** If a spec is silent, the rule does not exist.
2. **Specs override training data.** The spec always wins.
3. **Cite sources.** Reference the specific file + section.
4. **Ask when uncertain.** Do not guess.
5. **Never merge conventions** from other projects/languages.
6. **No filler.** No "Hope this helps!" / "Let me know…" boilerplate.

---

## Memory Update Protocol

```
New information discovered
├─ Institutional knowledge (pattern/convention/decision)?
│  └─ YES → write to `.lovable/memory/<topic>/NN-name.md` + update `.lovable/memory/index.md`
├─ Must NEVER be done?
│  └─ YES → add to `.lovable/strictly-avoid.md`
├─ Suggestion (not approved)?
│  └─ YES → add to `.lovable/suggestions.md`
└─ Else → do not persist
```

Critical rules:
- The folder is `.lovable/memory/` — never `.lovable/memories/` (no trailing `s`).
- Every new memory file must be indexed the same operation.
- Never truncate or overwrite unrelated entries when modifying an existing file.

---

## Completion Confirmation

After Phases 1–3, respond with exactly this format:

```
Onboarding complete.
- Memory files read: [X]
- Consolidated guidelines read: [Y]
- Spec authoring files read: [Z]

I understand:
- CODE RED rules: [top 3–5]
- Naming conventions: [brief]
- Error handling: [one sentence]
- Active plan: [current milestone]
- Strict avoidances: [top 3–5]

Ready for tasks.
```

Then stop and wait. Do not suggest next steps.

---

## Changelog

- v1.0 — initial canonical read-memory prompt (aligns with `.lovable/what-to-read.md`).
