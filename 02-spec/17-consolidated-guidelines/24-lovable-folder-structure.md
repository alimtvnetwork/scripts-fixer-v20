# Consolidated: `.ai-memory/` Folder Structure

**Version:** 4.0.0
**Updated:** 2026-08-31
**Source:** [`02-spec/01-spec-authoring-guide/09-memory-folder-guide.md`](../01-spec-authoring-guide/09-memory-folder-guide.md)

---

## Purpose

This is the **standalone consolidated reference** for the `.ai-memory/` folder structure — the AI context layer. An AI reading only this file must be able to create, maintain, and navigate the `.ai-memory/` directory correctly.

---

## Canonical Structure

```
.ai-memory/
├── README.md                        # 🏠 Root Gateway & Router
├── what-to-read.md                  # 📖 Mandatory Reading Order, Rules 1-12 & Overview (Read Memory)
├── strictly-avoid.md                # ⛔ Gateway linking to avoid/
├── folder-structure.md              # 🗺️ Repository & 7-domain architecture map
├── coding-guidelines.md             # 📜 Standalone guidelines with AI Compliance Checklist
│
├── ambiguity/                       # 1. Ambiguity lifecycle (new/ -> resolved/)
│   ├── new/                         #    Active questions requiring clarification
│   ├── resolved/                    #    Settled decisions & historical clarifications
│   └── README.md                    #    Ambiguity lifecycle protocol
├── rca/                             # 2. 4-part Root Cause Analysis & Issue Registry
│   ├── new/                         #    Active defects & open investigations
│   ├── resolved/                    #    Remediated post-mortems
│   └── README.md                    #    RCA index & 4-part contract
├── avoid/                           # 3. Modular negative constraints (00-default.md, 01-04)
├── learned/                         # 4. Learn Memory: flat sequential knowledge (default-memory.md, readme.md, 01-*)
├── plans/                           # 5. Execution hub & roadmap backlog
│   ├── pending/                     #    Queued implementation roadmaps (XX-<slug>.md)
│   ├── active/                      #    In-flight execution plans
│   ├── completed/                   #    Archived completed plans
│   ├── subtasks/                    #    Bounded micro-tasks (XX-<slug>/subtask-*.md)
│   ├── suggestions/                 #    Autonomous AI proposals staged for review
│   └── readme.md                    #    Master plan index
├── research/                        # 6. Technical exploration & spike guidelines
└── screenshots/                     # 7. UI/UX verification & ground truth imagery (*.png)
```

---

## Critical Rules

> **There is exactly ONE memory folder: `.ai-memory/learned/` (Learn Memory).** The variants `memory/`, `memories/`, and `learn-memory/` are **prohibited**. If found, migrate contents and delete them.

> **`learned/readme.md` is the single source of truth** for all learned knowledge records. Every memory file must be listed there sequentially.

---

## AI Reading Order

1. `what-to-read.md` → Read Memory: understand the project & mindset rules 1-12
2. `strictly-avoid.md` → know what NOT to do (links to `avoid/`)
3. `folder-structure.md` → understand directory architecture
4. `coding-guidelines.md` → review 10-point AI Compliance Checklist
5. `learned/readme.md` → survey all flat sequential knowledge
6. `plans/pending/` → understand current work context

---

## Naming Conventions

- **Folders:** kebab-case, 2-digit zero-padded prefix when sequenced (`01-prompts-category/`, `ai-fix-scripts/`)
- **Files:** strictly lowercase, kebab-case, numeric prefix where sequenced (`readme.md`, `02-shared-engine.py`)
- **No spaces**, no uppercase letters, no camelCase in filenames.

---

## Workflows

### Tasks: `05-plan.md` → `plans/pending/` → `plans/completed/`

1. High-level items tracked in `05-plan.md` as a roadmap.
2. When work begins, create a detailed file in `plans/pending/` and decompose into `plans/subtasks/XX-<slug>/`.
3. On completion, move to `plans/completed/` with results noted.

---

*Consolidated .ai-memory folder structure — v4.0.0 — 2026-08-31*

---

## §X Project Memory — Active Core Rules (Mirror)

This section **mirrors** the operational rules stored in `.ai-memory/learned/readme.md` Core section. A blind AI receiving only the consolidated folder would otherwise miss these — and violate at least three on its first PR. This mirror is **read-only documentation** of the rules; the canonical source remains `mem://index.md`.

### X.1 Code-Red Quality Rules

| Rule | Enforced By |
|------|-------------|
| Never swallow errors. Zero-nesting (no nested `if`). Max 2 operands per condition. Positively named guard functions. | `linter-scripts/validate-guidelines.py` |
| Functions: 8–15 lines. Files: < 300 lines. React components: < 100 lines. | `linter-scripts/validate-guidelines.py` |

### X.2 Sync & Repo Rules

| Rule | Notes |
|------|-------|
| **Never** sync `01-app`, `02-app-issues`, `03-general`, `03-tasks`, or `12-consolidated-guidelines` from upstream sibling repos | All maintained locally |
| **Skip** from spec audits: `21-app`, `22-app-issues`, `23-app-db`, `24-app-ui-design-system` are intentional stubs | Never write 97/99 files for them; never demote to `_drafts/`; exclude from corpus averages |
| Repo identity: `alimtvnetwork/coding-guidelines-v24` | Install scripts live at repo root (`install.ps1` / `install.sh`) |

### X.3 Naming Rules

| Domain | Convention | Exception |
|--------|------------|-----------|
| Internal IDs, DB, JSON, Types | PascalCase | Rust uses `snake_case` identifiers |
| DB tables | PascalCase, **singular** | — |
| DB primary keys | `{TableName}Id` (INTEGER PRIMARY KEY AUTOINCREMENT) | No UUIDs |

### X.4 DB Boolean Rules

- **Forbidden** prefixes: `Not`, `No`
- **Approved Inverses** (allowed despite negative semantics): `IsDisabled`, `IsInvalid`, `IsIncomplete`, `IsUnavailable`, `IsUnread`, `IsHidden`, `IsBroken`, `IsLocked`, `IsUnpublished`, `IsUnverified`
- Inverses are derived in code via Rule 9 codegen (never stored as separate columns)

### X.5 DB Descriptive Column Rules (Rules 10/11/12)

| Table Type | Required Columns |
|------------|------------------|
| Entity tables | `Description TEXT NULL` |
| Transactional tables | `Notes TEXT NULL` + `Comments TEXT NULL` |

Enforcement: see `18-database-conventions.md` §18 (rule presence) and §19 (waiver syntax).

### X.6 Workflow Rules

| Rule | Pattern |
|------|---------|
| Spec changes | Spec-First — edit `02-spec/` then implement |
| Bug fixes | Issue-First — create `03-issues/<issue>.md` then fix |
| `.ai-memory/` structure | Single-file convention — `plan.md`, `suggestions.md`, `strictly-avoid.md` each hold their full history. **Never** create per-task folders |
| Multi-step requests | Break into discrete tasks. Wait for "next" prompt to continue |

### X.7 Dependency Pinning

| Package | Allowed Versions | Blocked |
|---------|------------------|---------|
| `axios` | `1.14.0`, `0.30.3` | `1.14.1`, `0.30.4` (security; never bump) |

Enforced by `linter-scripts/check-axios-version.sh`.

### X.8 Why This Mirror Exists

The canonical memory lives at `mem://index.md` and is automatically loaded into every Lovable AI session. External AIs have no access to that memory — this section is the only way they will learn these rules.

When updating: edit `mem://index.md` first, then sync this section. The mirror is allowed to lag by at most one minor version.
