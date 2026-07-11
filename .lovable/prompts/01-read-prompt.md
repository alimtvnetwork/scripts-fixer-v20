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

1. Navigate to `spec/12-consolidated-guidelines/` (if present in this repo).
2. Read files in numeric order (`01-*.md` through `NN-*.md`).
3. Each file is a self-contained policy document.

Confirm internally:
- [ ] Total number of guideline files read.
- [ ] One-sentence summary of each file's key rule.
- [ ] Any rules that contradict default training (spec wins).

> DO NOT proceed to Phase 3 until all consolidated guideline files have been read.

---

## Phase 3 — Spec Authoring Rules

**Goal:** Understand how specs are structured so you can read them correctly and author new ones.

1. Navigate to `spec/00-spec-writing-guide/` (canonical in this repo) or `spec/01-spec-authoring-guide/` if it exists.
2. Read every file in numeric order.

After reading, confirm you understand:

| Concept | Where Defined |
|---------|---------------|
| File / folder naming conventions | Spec authoring guide |
| Required files in every spec folder (`00-overview.md`, `99-consistency-report.md`) | Spec authoring guide |
| The `.lovable/` folder structure and its purpose | Memory-folder guide |
| Linter infrastructure requirements | Spec authoring guide |

> DO NOT begin any task until Phases 1–3 are complete.

---

## Phase 4 — Deep-Dive Source Specs (Task-Driven)

Before performing any task, read the relevant source spec(s).

| Task involves... | Read |
|------------------|------|
| Writing / reviewing code | `spec/02-coding-guidelines/` (or repo equivalent) |
| Error handling | `spec/03-error-manage/` / `spec/02-app-issues/` |
| Database schema | `spec/04-database-conventions/` |
| Configuration systems | `spec/06-seedable-config-architecture/` |
| PowerShell scripts | `spec/10-powershell-integration/` + `spec/NN-install-*` |
| CI/CD pipelines | `spec/13-cicd-pipeline-workflows/` + `.lovable/cicd-issues/` |
| Self-update / bootstrap | `spec/14-self-update-app-update/` |
| App-specific features | `spec/21-app/` |
| App bugs | `spec/22-app-issues/` |

Reading order within each folder: `00-overview.md` → numbered files → `99-consistency-report.md`.

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
