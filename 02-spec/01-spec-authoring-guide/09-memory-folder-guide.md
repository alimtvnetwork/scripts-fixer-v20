# `.ai-memory/` Folder Structure Guide

**Version:** 5.0.0 (7-Domain Lean Architecture)
**Updated:** 2026-11-25
**Source of Truth Anchor:** GitHub (`alimtvnetwork/coding-guidelines-v24`)

---

## Overview

The `.ai-memory/` directory is the **canonical persistent memory cortex** for all AI-readable project knowledge — memory, tasks, suggestions, constraints, and onboarding context. Any AI model reading this folder should be able to fully understand the project's conventions, active work, and hard constraints.

> **CRITICAL MEMORY DIRECTIVE:** For institutional knowledge, there is exactly ONE memory folder: `.ai-memory/learned/` (Learn Memory). All historical variants (`memory/`, `memories/`, `learn-memory/`) are strictly prohibited and consolidated into `.ai-memory/learned/`.

---

## Canonical Folder Structure

```text
.ai-memory/
├── README.md               # 🏠 Root Gateway & Directory Router
├── what-to-read.md         # 📖 Mandatory Reading Order, Rules 1-12 & Overview (Read Memory)
├── strictly-avoid.md       # ⛔ Gateway linking to avoid/
├── folder-structure.md     # 🗺️ Repository & 7-domain architecture map
├── coding-guidelines.md    # 📜 Standalone guidelines with AI Compliance Checklist
│
├── ambiguity/              # 1. Ambiguity lifecycle (new/ -> resolved/)
│   ├── new/                #    Active or pending questions requiring resolution
│   ├── resolved/           #    Settled decisions and historical clarifications
│   └── README.md           #    Ambiguity index & lifecycle protocol
├── rca/                    # 2. 4-part Root Cause Analysis & Issue Registry
│   ├── new/                #    Active bugs & in-flight investigations
│   ├── resolved/           #    Remediated root cause analyses
│   └── README.md           #    RCA index & 4-part RCA engineering standard
├── avoid/                  # 3. Grounded Non-Negotiable Bans (00-default.md, 01-04)
│   ├── 00-default.md       #    Root baseline invariants (LF, IDE settings, push mandate)
│   ├── 01-code-and-style.md#    Code style, boolean prefixes, function sizing, zero nesting
│   ├── 02-git-and-commits.md#   Git protocols, semantic verbs, URL rewriting, release rules
│   ├── 03-shell-and-execution.md# Native GitMap vs ps/pwsh, temp isolation, test bounds
│   ├── 04-privacy-and-credentials.md# 3-slot email security, credential isolation
│   └── README.md           #    Avoid domain catalog & index
├── learned/                # 4. Learn Memory: flat sequential knowledge
│   ├── default-memory.md   #    Baseline project governance & core invariants
│   ├── readme.md           #    Sequential index of all knowledge records
│   └── *.md                #    Flat sequential domain models & lessons (01-*, 02-*, etc.)
├── plans/                  # 5. Task Execution & Planning Backlog
│   ├── pending/            #    Queued implementation roadmaps (XX-<slug>.md)
│   ├── active/             #    In-flight execution plans
│   ├── completed/          #    Archived completed milestones
│   ├── subtasks/           #    Decomposed step manifests (XX-<slug>/subtask-*.md)
│   ├── suggestions/        #    Autonomous AI proposals staged for review
│   │   ├── 01-legacy-suggestions.md
│   │   └── README.md
│   └── readme.md           #    Plan index & progress tracker
├── research/               # 6. Technical Exploration & Spike Guidelines
│   └── README.md           #    Research rules, spike lifecycle & graduation protocol
└── screenshots/            # 7. UI/UX Verification & Ground Truth Imagery
    └── *.png               #    Visual ground truth telemetry for specifications and RCAs
```

---

## File Descriptions

### Essential Root Files (5 Invariant Files)

| File | Purpose | Read Priority |
| :--- | :--- | :--- |
| `what-to-read.md` | Mandatory onboarding sequence, Rules 1-12, Contrast Gameplay, and Subsystems Overview (Read Memory) | **READ FIRST** |
| `strictly-avoid.md` | Direct gateway to all modular avoid rules in `avoid/` | **READ FIRST** |
| `README.md` | Root directory router and domain navigation map | High |
| `folder-structure.md` | Repository-wide folder architecture and `.ai-memory/` taxonomy | High |
| `coding-guidelines.md`| Standalone coding guidelines enriched with the 10-point AI Compliance Checklist | High |

### `learned/` — Learn Memory (Flat Sequential Knowledge)

Stores domain models, architectural patterns, lessons learned, and session summaries in a clean, flat sequential series.
- **`default-memory.md`** — Baseline project invariants and core governance.
- **`readme.md`** — Canonical sequential index of all learned records (`01-*` through `30-*`).
- Files are strictly flat `.md` documents with numeric sequence prefixes. Subdirectories inside `learned/` are prohibited.

### `plans/` & `plans/suggestions/` — Task & Suggestion Lifecycle

- **Roadmaps:** 100-step master plans reside in `plans/pending/` (`XX-<slug>.md`) with decomposed subtasks in `plans/subtasks/XX-<slug>/`.
- **Archiving:** Fully verified plans move to `plans/completed/`.
- **Suggestions:** Unsolicited AI improvement proposals are staged in `plans/suggestions/XX-<slug>.md` for human review; they never enter active code without approval.

### `ambiguity/` — Decision & Ambiguity Lifecycle

- **`new/`**: Open inquiries, ambiguous requirements, or missing details filed as `XX-<slug>-ambiguity.md`.
- **`resolved/`**: When clarified, moved here with a binding `## Resolution` block appended.

### `rca/` — 4-Part Root Cause Analysis & Issue Registry

- **`new/`**: Active defects and in-flight investigations.
- **`resolved/`**: Remediated post-mortems following the strict 4-part RCA contract:
  1. Root Cause Summary (1 sentence)
  2. Investigation Trace
  3. Corrective Patch
  4. Regression Guard

### Prohibited Root Files (Permanently Deleted)

To prevent clutter, the following files are strictly banned from `.ai-memory/` root:
- `01-index.md` (duplicate of README)
- `overview.md` (consolidated into `what-to-read.md`)
- `cicd-index.md` & `cicd-timing.json` (consolidated into `rca/resolved/`)
- `prompt.md` & `prompts.md` (canonical prompts belong in `01-prompts/`)
- `plan.md` (active plans reside in `plans/`)
- `suggestions.md` (relocated to `plans/suggestions/01-legacy-suggestions.md`)
