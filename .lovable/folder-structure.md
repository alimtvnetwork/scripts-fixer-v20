# Canonical Folder Structure: `.lovable/`

> **Version:** 2.1.0  
> **Status:** Canonical Reference  
> **Updated:** 2026-09-13  
> **Scope:** Repository-wide AI metadata, planning, tracking, memory, and specifications.

---

## 1. Directory Tree Overview

```
.lovable/
├── 01-index.md                  # Root orchestration index & master state
├── overview.md                  # Project shape, conventions, and high-level architecture
├── what-to-read.md              # Mandatory AI onboarding guide (read first every session)
├── folder-structure.md          # THIS file: Canonical directory map and folder contracts
├── coding-guidelines.md         # Mandatory coding rules, quality gates, and anti-patterns
├── plan.md                      # Unified roadmap file (when single-file roadmap is active)
├── strictly-avoid.md            # Hard prohibitions, anti-patterns, and never-repeat rules
├── suggestions.md               # Unified suggestions ledger (Active & Implemented)
├── prompt.md                    # Root prompt pointer -> prompts/index.md
├── cicd-index.md                # CI/CD workflows and issue index
├── temp/                        # Gitignored scratch, plans generation, and runtime state cache
├── prompts/                     # Standardized reusable system prompts
│   ├── index.md                 # Index of prompt templates
│   ├── 01-read-prompt.md        # Session startup & onboarding prompt
│   └── 02-write-prompt.md       # Session wrap-up & memory persistence prompt
├── memory/                      # Institutional memory (the project brain)
│   ├── 01-index.md              # Master memory catalog & cross-reference index
│   ├── index.md                 # Legacy/synced index pointer
│   ├── 01-nginx-domain-manager-sqlite.md # Direct session directives & specifications
│   ├── workflow/                # Session and workflow execution states
│   ├── learned/                 # Permanent architectural learnings and solutions
│   ├── specs/                   # Verbatim user directives and input requirements
│   ├── decisions/               # Key architectural decisions & rationale
│   ├── constraints/             # Hard project and technical constraints
│   ├── preferences/             # User and team formatting/coding preferences
│   ├── features/                # Per-feature architectural reference documentation
│   └── suggestions/             # Per-script granular suggestions archive
├── plans/                       # Structured multi-agent planning directory
│   ├── 01-index.md              # Master plans catalog & status tracker
│   ├── index.md                 # Plan index pointer
│   ├── pending/                 # Active and drafted plans under evaluation
│   ├── completed/               # Completed plans moved upon 100% verification
│   └── subtasks/                # Microscopic atomic subtask decomposition folders
│       ├── 18-nginx-wordpress-laravel/
│       └── 19-nginx-domain-manager-sqlite/
├── ambiguous-questions/         # Ambiguity lifecycle tracking
│   ├── 01-index.md              # Ambiguity status ledger
│   ├── 01-new-ambiguity/        # Open questions requiring user clarification
│   └── 02-ambiguity-resolved/   # Resolved ambiguities moved with resolution blocks
├── pending-issues/              # Active bugs & runtime failures (one file per issue)
├── solved-issues/               # Resolved issues moved with root causes & learnings
├── cicd-issues/                 # CI/CD pipeline issues and test harness failures
├── compliance-reports/          # Static audit and automated policy compliance outputs
├── spec/                        # Internal specifications and command references
│   └── commands/                # Granular command syntax and CLI behavior specs
└── assets/                      # Static metadata assets (diagrams, screenshots)

01-prompts/                      # Standardized AI prompt modules and workflows
spec/                            # Authoritative specifications and command documentation
03-ai-scripts/                   # High-speed Python automation toolchain & shared utilities
.agents/skills/                  # Antigravity native skill blueprints & orchestration agents
scripts/                         # Windows PowerShell scripts (numbered)
scripts-linux/                   # Linux/macOS bash equivalents (numbered)
tools/                           # Node.js maintenance utilities and validators
```

---

## 2. Detailed Folder Roles & Contracts

### 2.1 Root Metadata
- `01-index.md`: Real-time session checkpoint tracking active master plans, active file locks, and pending failures.
- `what-to-read.md`: Mandatory reading sequence for every incoming AI session. Kept strictly synchronized with root `readme.md`.
- `folder-structure.md`: Definitive mapping of `.lovable/` folder purposes and lifecycle rules.
- `coding-guidelines.md`: Strict quality standards (functions ≤ 8 lines, no nested ifs, explicit boolean prefixes, CODE RED logging).
- `strictly-avoid.md`: Append-only collection of prohibited patterns, anti-patterns, and hard stops. Never overwritten.
- `suggestions.md`: Unified ledger of proposed and implemented features.

### 2.2 `memory/` (Institutional Knowledge)
> **Hard Rule:** Always `.lovable/memory/`, NEVER `.lovable/memories/` or `memories/`.
- `01-index.md`: Master catalog mapping every file across all memory subdirectories.
- `workflow/`: Captures execution state (`Done`, `In Progress`, `Pending`, `Blocked`).
- `learned/`: Deep architectural lessons, cross-platform pitfalls (e.g. BOM handling, PowerShell 5.1 quirks), and permanent solutions.
- `constraints/`: Explicit constraints (e.g. SP-1..SP-6 prohibitions, console banner limits, directory naming).
- `preferences/`: Developer preferences (naming conventions, casing, helper module conventions).
- `features/`: Deep-dive reference documents for repository capabilities and subsystems.

### 2.3 `plans/` (Multi-Agent Lifecycle)
- `01-index.md`: Master table of completed and pending plans.
- `pending/`: Plans in draft or execution phase (`XX-<slug>.md`).
- `completed/`: Fully executed and verified plans. Moved from `pending/` only after verification tests pass.
- `subtasks/XX-<slug>/`: Decomposed microscopic subtask steps (`01-task.md`, `02-task.md`, etc.).

### 2.4 `ambiguous-questions/` (Clarification Lifecycle)
- `01-index.md`: Index of all ambiguity files.
- `01-new-ambiguity/`: Files capturing underspecified user requirements or conflicting directives.
- `02-ambiguity-resolved/`: Files moved via `mv` once resolved, containing a required `## Resolution` block.

### 2.5 `pending-issues/` & `solved-issues/` (Issue Lifecycle)
- `pending-issues/`: Active reproducible bugs (`XX-<slug>.md`).
- `solved-issues/`: Resolved issues moved from `pending-issues/` containing `## Solution`, `## Iteration Count`, `## Learning`, and `## What NOT to Repeat`.

### 2.6 `spec/commands/` (CLI Specifications)
- Granular command definitions, argument schemas, exit codes, and cross-platform behaviors for CLI subcommands.

---

## 3. File Naming Conventions
1. **Numeric Prefixes:** All sequential files use two-digit or three-digit prefixes (`01-`, `02-`, `001-`).
2. **Kebab-Case:** Lowercase alphanumeric characters separated strictly by hyphens (e.g., `19-nginx-domain-manager-sqlite.md`).
3. **No Upper-Case in Paths:** All filenames and folder names under `.lovable/` must be lowercase.
