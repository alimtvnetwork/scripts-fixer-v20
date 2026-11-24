# Canonical Folder Structure & Sizing Rules — Architecture Spec (must follow)

> **Prompt Version:** 2.1.0
> **Synchronization:** Single Source of Truth Mirror for `.ai-memory/folder-structure.md`
> **Target:** `01-prompts/00-folder-structure/01-canonical-folder-structure.md`

Every AI prompt and agent MUST strictly adhere to the central repository layout defined below and in `.ai-memory/folder-structure.md`. No invented folders, no alternate paths.

All dates are UTC. All filenames are lowercase kebab-case with a two-digit zero-padded `XX-` prefix where sequencing applies. `XX-` is monotonic within its folder scope.

```text
/                                      # Root of the repository
  02-spec/                             # Canonical layered specifications (source of truth)
    01-spec-authoring-guide/           # Meta-guide for writing and maintaining specs
    02-coding-guidelines/              # Detailed cross-language coding architectures
    03-error-manage/                   # Error management, envelopes, error codes
    04-database-conventions/          # Database schema design, ORM mappings, views
    05-split-db-architecture/          # Operational vs. configuration DB patterns
    06-seedable-config-architecture/   # Seedable configuration with versioned changelogs
    07-design-system/                  # Design tokens, UI component hierarchy, dark mode
    08-docs-viewer-ui/                 # Documentation viewer UI & presentation system
    09-code-block-system/              # Syntax highlighting pipeline & interaction system
    10-research/                       # Technology benchmarks and comparative studies
    11-powershell-integration/         # PowerShell scripting and automation conventions
    12-cicd-pipeline-workflows/        # CI/CD workflows, GitHub Actions, quality gates
    13-generic-cli/                    # Generic CLI UX, terminal colors, flag semantics
    14-update/                         # CLI self-update architecture & release delivery
    15-distribution-and-runner/        # Cross-platform installers, runners, forwarding
    16-generic-release/                # Universal release blueprint & asset matrices
    17-consolidated-guidelines/        # Single-file AI summaries of all major spec modules
    18-wp-plugin-how-to/               # WordPress plugin architecture & REST APIs
    19-main-worker-service/            # Split-tier worker service & proxy nodes
    21-app/ ... 24-app-ui-design-system/ # Application-specific business features & schemas

  .ai-memory/                            # AI metadata, cognitive memory, and automation layer
    readme.md                        # Master repository index and directory router
    02-user-preferences                # Explicit user communication preferences
    03-strictly-avoid.md               # Universal hard prohibitions & CODE RED constraints
    04-suggestions.md                  # Architectural suggestions & pending improvements
    05-plan.md                         # Active high-level roadmap and milestone tracker
    06-what-to-read.md                 # Reading sequence and entrypoint priority list
    folder-structure.md                # 📄 AUTHORITATIVE SINGLE SOURCE OF TRUTH FOR FOLDER STRUCTURE

    ai-fix-scripts/                    # Reusable high-speed Python automation toolchain
      readme.md                      # Master catalog & search tag registry
      02-shared-engine.py              # Central engine: constants, lazy regex, locks, cache
      03..20-*.py                      # Specialized linters, fixers, and local CI runners

    plans/                             # Micro-task execution center
      readme.md                      # Master registry of active and completed plans
      pending/                         # High-level active parent plans (xx-<slug>.md)
      subtasks/                        # Bounded micro-tasks (xx-<slug>/01-step.md)
      completed/                       # Archived completed parent plans & subtasks

    ambiguity/                         # Ambiguity lifecycle (new/ -> resolved/)
      new/                             # Active architectural queries
      resolved/                        # Closed decisions & resolutions
      README.md                        # Ambiguity domain gateway

    rca/                               # 4-part Root Cause Analyses and issue logs
      new/                             # Active bugs & triage
      resolved/                        # Remediated post-mortems
      README.md                        # RCA domain gateway

    avoid/                             # Modular negative constraints
      00-default.md                    # Core non-negotiable invariants
      README.md                        # Avoid domain gateway

    learned/                           # Flat sequential cross-session knowledge storage
      default-memory.md                # Project baseline learnings
      readme.md                        # Learned knowledge index

    plans/                             # Micro-task execution center
      pending/                         # High-level active parent plans (XX-<slug>.md)
      subtasks/                        # Bounded micro-tasks (XX-<slug>/01-step.md)
      completed/                       # Archived completed parent plans & subtasks
      suggestions/                     # Autonomous AI suggestions & backlog
      readme.md                        # Master registry of active and completed plans

    research/                          # Spikes, experimental benchmarks, and guidelines
      README.md                        # Research gateway

    screenshots/                       # UI Ground Truth visual captures (*.png)
      README.md                        # Visual captures gateway
```

---

## Numbering Rules (`XX-` Monotonic Sequencing)

1. Two-digit zero-padded, monotonic per folder scope (`01-`, `02-`, ...).
2. Next `XX-` = max existing `XX-` in that folder scope + 1. Never reuse or decrement.
3. Plans: `XX-` is monotonic across `pending/`, `subtasks/`, and `completed/` combined.

---

## Special Default Companion Repositories (`repo-secrets` = `rs` & `repo-cache` = `rc`)

Every workspace operates alongside two fixed special repositories in the work directory (`gitmap settings`):

1. **`repo-secrets` (shortcut: `rs` / `gitmap cd rs`):**
   - Stores all repository secrets, `.env` files, tokens, and passwords under `XX-<repo-name>/01-<slug>.ext` (`01-gitmap/01-env.txt`, `02-coding-guidelines/01-api-keys.json`) so standard repositories remain 100% free of secrets and safe to open-source.
   - Commands (`auto-commits & pushes` automatically):
     - `gitmap rs file <filepath>`
     - `gitmap rs folder <folderpath>`
     - `gitmap rs text "<secret-text>" [--slug <slug>]`
2. **`repo-cache` / `repo-storage` (shortcut: `rc` / `gitmap cd rc`):**
   - Stores reusable temporary scripts (`.ps1` PowerShell scripts, shell utilities, diagnostic test items, and benchmark harnesses) under `XX-<repo-name>/01-<slug>.ps1` so any project can reuse them without leaving temporary files in application repositories.
   - Commands (`auto-commits & pushes` automatically):
     - `gitmap rc file <script.ps1>`
     - `gitmap rc folder <folderpath>`
     - `gitmap rc text "<script-body>" --slug <slug> --ext .ps1`

## Hard Rules & Prohibitions

- **Single Authority:** [`.ai-memory/folder-structure.md`](.ai-memory/folder-structure.md) is the absolute single source of truth.
- **Strict Plurality:** Always `.ai-memory/learned/` (singular), `.ai-memory/plans/` (plural), `01-prompts/` (plural), `.ai-memory/suggestions/` (plural).
- **No Orphaned Folders:** Never invent unapproved folders (e.g., `memories/`, `tasks/`, `todos/`).
- **Relative Paths Only:** All file paths must be relative from the git root. Absolute paths (`C:\...`, `file:///...`) are banned.
