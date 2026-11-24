# Universal AI Memory Architecture & One-Shot Scaffolding Engine — Master Sovereign Prompt

Official Authoritative References & Technical Documentation:

• Universal Common Foundation Master Prompt Gist:
  https://gist.githubusercontent.com/alimtvnetwork/9fe8c6fb25ab0e409a22e9c2624915da/raw/00-universal-common-foundation-prompt.md
• Python Any Task Prerequisite Gist:
  https://gist.githubusercontent.com/alimtvnetwork/fd0953a5f2bfbbc91ae6e3666c5f7c37/raw/b573e3d2cd164d74350bee9c77ccc3b608250333/python-any-task-prompt.md
• WordPress Modernizing Master Prompt Gist:
  https://gist.githubusercontent.com/alimtvnetwork/11900295ef222d921bd646923fbcff3d/raw/957bb2b806d2bb6dae45f5d8f17c5fdefbe5aa55/universal-wp-modernizing-master-prompt.md
• Elementor Pixel-Perfect Loop Master Prompt Gist:
  https://gist.githubusercontent.com/alimtvnetwork/9ee32e9568d0afc4ee4c49c86bedb9e8/raw/elementor-modify-pixel-perfect-loop.md

Prompt Version: 1.0.0 (Master Autonomous Standalone Edition — 100% Sovereign Portability)
Target Audience: Autonomous AI Agents (Antigravity, Cursor, Claude, ChatGPT, Muse), Software Architects, QA Engineers
Task Slug: universal-ai-memory-folder-structure / ai-memory-scaffolding-engine
Portability Contract: Anyone can copy-paste this prompt in full into an isolated AI environment, remote IDE, GitHub Gist, or GitLab Snippet, and the agent will comprehend the complete `.ai-memory/` architecture and execute the one-shot Python scaffolding engine safely and blindly without requiring any prior codebase files.

```text
================================================================================
           AUTONOMOUS EXECUTION BUDGET & SWARM TOPOLOGY (V6/V7 RULES)
================================================================================
N = 400 (Total self-loop steps budget — default: 400)
A = 3   (MANDATORY number of spawned autonomous subagents running concurrently, default: 3)
H = 2   (Operational hands per agent: dual-task batch capacity & parallel tool dispatch, default: 2)
C = 30  (Tool calls per worker before it must report, default: 30)

PHASE_1_BUDGET = 100     (Steps 1 .. 100: Learn Architecture, Auto-Discover Root & One-Shot Scaffolding)
PHASE_2_BUDGET = 150     (Steps 101 .. 250: Plan Registration, Ambiguity Analysis & Index Construction)
PHASE_3_BUDGET = 150     (Steps 251 .. 400: Invariant Verification, Memory Persistence & Upstream Push)
================================================================================
```

---

## 🎯 1. Turn 1 Understood Showcase Protocol

Before executing any file modifications, network calls, or CLI commands, the autonomous AI agent **MUST OUTPUT** a comprehensive Turn 1 Showcase table demonstrating full comprehension across all 5 mandatory pillars:

1. **Pillar 1: Strategic Intent & Systems Reasoning:** Articulate overarching architectural goal, user intent, operational rationale, and systems integration mechanics.
2. **Pillar 2: Explicit Scope Boundaries:** Strict two-column partition defining In-Scope deliverables vs. strictly Excluded or Deferred items.
3. **Pillar 3: Non-Negotiable Constraints & Negative Guardrails:** Explicit recitation of active constraints: ban on raw searches, ban on git commands in subagents, ban on absolute paths, ban on CRLF, ban on magic strings, ban on snake_case database tables.
4. **Pillar 4: Blast Radius & Dependency Topology:** Map impacted subsystems, files, downstream callers, and prompt/skill indexes with risk containment strategies.
5. **Pillar 5: Multi-Agent Concurrency Topology:** Detail swarm structure (`A = 3`, `H = 2`, Capacity = 6), disjoint file assignments, and immediate dynamic respawn.

### Master Turn 1 Verification Schema
```markdown
| Dimension | Standard Specification | Target Verification |
| :--- | :--- | :--- |
| **Prerequisite Gate** | Common Foundation + AI Memory Gists | Confirmed studied & internalized (50 steps memory creation) |
| **Direct References** | Unwrapped Authoritative Gist URLs | Bare URLs confirmed without markdown wrapping |
| **Encoding Standard** | `EncodingConstants` (UTF-8, ASCII) | Zero raw string encoding literals; constants enforced |
| **Line Endings** | Universal UNIX LF (`\n`) | Total ban on CRLF across all created markdown & scripts |
| **Folder Architecture** | Canonical `.ai-memory/` Hierarchy | 7 cognitive domains + 5 core indices generated |
| **Scaffolding Engine** | Embedded Python `scaffold_ai_memory.py` | 100% dependency-free; executes in one shot |
| **JSON Standard** | GitMap `data` & `attributes` Pattern | Zero underscores in JSON keys; lower camelCase |
| **Workspace Root** | Dynamic `$WORK` Resolution | Derived from `$WORK`, `$GITMAP_WORK_DIR`, or current repo root |
| **Git Hygiene** | Zero Git Bloat + Upstream Push | Temp DBs & caches git-ignored; No Push = Not Done |
```

---

## 🏛️ 2. Architectural Specification of `.ai-memory/`

The `.ai-memory/` folder is the authoritative persistent memory cortex of any modern AI-driven software project. It maintains continuous institutional knowledge across context wipes, model upgrades, and multi-agent swarm handoffs.

### 2.1 Complete Directory Hierarchy

```text
.ai-memory/
├── README.md                             # Master cognitive entrypoint & directory router
├── what-to-read.md                       # Read Memory protocol, rules 1-12 & subsystem overview
├── strictly-avoid.md                     # Code Red invariants & gateway to avoid/
├── folder-structure.md                   # Repository & 7-domain architecture map
├── coding-guidelines.md                  # Grounded coding guidelines with AI Compliance Checklist
├── manifest.json                         # Structured GitMap JSON metadata of the memory cortex
│
├── ambiguity/                            # 1. Ambiguity lifecycle (new/ -> resolved/)
│   ├── new/                              #    Active ambiguities undergoing analysis
│   └── resolved/                         #    Historical resolved ambiguities & decisions
├── rca/                                  # 2. 4-part RCA & Issue Registry (new/ -> resolved/)
│   ├── new/                              #    Active bugs & in-flight investigations
│   └── resolved/                         #    Remediated root cause analyses
├── avoid/                                # 3. Modular negative constraints (00-default.md, 01-04)
├── learned/                              # 4. Learn Memory: flat sequential knowledge (default-memory.md, readme.md, 01-*)
├── plans/                                # 5. Roadmap and execution plans
│   ├── pending/                          #    Queued implementation roadmaps (XX-<slug>.md)
│   ├── active/                           #    In-flight execution plans
│   ├── completed/                        #    Fully verified historical plans (XX-<slug>.md)
│   ├── subtasks/                         #    Granular phased subtasks (XX-<slug>/subtask-*.md)
│   └── suggestions/                      #    Autonomous AI proposals staged for review
├── research/                             # 6. Technical spikes & experimental guidelines
└── screenshots/                          # 7. Ground truth UI imagery (*.png)
```

### 2.2 Functional Responsibilities of Each Component

1. **`what-to-read.md` (Read Memory — Top Priority Context Ledger):**
   - Must be read FIRST before any code or spec is touched.
   - Contains mandatory mindset rules 1-12, Contrast Gameplay mandate, subsystems architecture, and chronological changelog.
2. **`strictly-avoid.md` (Code Red Invariants & Negative Guardrails):**
   - Direct gateway linking to modular negative constraints in `avoid/` (00-default, 01-code, 02-git, 03-shell, 04-privacy).
3. **`README.md` (Root Directory Router):**
   - High-level cognitive architecture summary and directory router.
4. **`folder-structure.md` (Repository & Memory Topology Map):**
   - Official architectural relationship between project source code and the `.ai-memory/` 7 domains.
5. **`coding-guidelines.md` (Grounded Guidelines & AI Compliance Checklist):**
   - Self-contained code quality standards enriched with the prominent 10-point AI Compliance Checklist (Follow Every Turn).
6. **`learned/` (Learn Memory — Flat Sequential Knowledge Cortex):**
   - Flat sequential domain models (`01-*` through `30-*`) anchored by `default-memory.md` and `readme.md`.
7. **`plans/` & `plans/suggestions/` (Task Backlog & AI Suggestions):**
   - 100-step roadmaps (`pending/`, `active/`, `completed/`, `subtasks/`).
   - `plans/suggestions/`: Dedicated staging domain for autonomous AI proposals and architectural recommendations awaiting review.
8. **`ambiguity/` (Ambiguity Intake & Resolution):**
   - `new/`: Active questions requiring clarification (`XX-<slug>-ambiguity.md`).
   - `resolved/`: Clarified architectural decisions with permanent resolution blocks.
9. **`rca/` (Root Cause Analysis & Issue Registry):**
   - Grounded forensic post-mortems following the strict 4-part RCA contract (`new/` -> `resolved/`).

---

## ⚡ 3. One-Shot Python Scaffolding Engine

The following dependency-free Python script is designed to be executed directly to scaffold the entire `.ai-memory/` hierarchy in one shot. It enforces universal UNIX LF line endings, respects existing files, generates initial starter templates, and emits a structured `manifest.json` following the GitMap `data` and `attributes` pattern.

### Reference Implementation: `scaffold_ai_memory.py`

```python
#!/usr/bin/env python3
"""
scaffold_ai_memory.py — Universal One-Shot AI Memory Scaffolding Engine.
Creates the canonical .ai-memory/ directory hierarchy and starter indices.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path
from typing import Final


class EncodingConstants:
    """Standard character encoding format constants."""
    UTF8: Final[str] = "utf-8"
    ASCII: Final[str] = "ascii"


class AnsiColorConstants:
    """ANSI terminal styling and color escape sequences."""
    RESET: Final[str] = "\033[0m"
    BOLD: Final[str] = "\033[1m"
    GREEN: Final[str] = "\033[32m"
    YELLOW: Final[str] = "\033[33m"
    BLUE: Final[str] = "\033[34m"
    CYAN: Final[str] = "\033[36m"
    RED: Final[str] = "\033[31m"


class LogBadgeConstants:
    """Standardized ANSI badges for console telemetry."""
    OK: Final[str] = "[  OK  ]"
    INFO: Final[str] = "[ INFO ]"
    SKIP: Final[str] = "[ SKIP ]"
    WARN: Final[str] = "[ WARN ]"


CANONICAL_DIRECTORIES: Final[list[str]] = [
    ".ai-memory",
    ".ai-memory/ambiguity",
    ".ai-memory/ambiguity/new",
    ".ai-memory/ambiguity/resolved",
    ".ai-memory/rca",
    ".ai-memory/rca/new",
    ".ai-memory/rca/resolved",
    ".ai-memory/avoid",
    ".ai-memory/learned",
    ".ai-memory/plans",
    ".ai-memory/plans/pending",
    ".ai-memory/plans/active",
    ".ai-memory/plans/completed",
    ".ai-memory/plans/subtasks",
    ".ai-memory/plans/suggestions",
    ".ai-memory/research",
    ".ai-memory/screenshots",
]


def resolve_workspace_root(override_path: str | None = None) -> Path:
    """Dynamically resolve workspace root from CLI flag, ENV vars, or CWD."""
    if override_path:
        return Path(override_path).resolve()

    env_work = os.environ.get("WORK") or os.environ.get("GITMAP_WORK_DIR")
    if env_work and Path(env_work).exists():
        return Path(env_work).resolve()

    cwd = Path.cwd().resolve()
    for parent in [cwd, *cwd.parents]:
        if (parent / ".git").exists() or (parent / ".ai-memory").exists():
            return parent
    return cwd


def write_file_lf(file_path: Path, content: str, is_force: bool = False, is_dry_run: bool = False) -> bool:
    """Write string content to file with strict UNIX LF line endings."""
    if file_path.exists() and not is_force:
        return False

    if is_dry_run:
        return True

    file_path.parent.mkdir(parents=True, exist_ok=True)
    with open(file_path, "w", encoding=EncodingConstants.UTF8, newline="\n") as handle:
        handle.write(content)
    return True


def build_what_to_read_template(project_slug: str) -> str:
    """Generate initial what-to-read.md starter document."""
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    return (
        "# What to Read — Context & Memory Ledger\n\n"
        "## Reading Protocol (MANDATORY BEFORE TOUCHING CODE)\n"
        "1. Read the most recent entries below to internalize active architectural context.\n"
        "2. Inspect `.ai-memory/strictly-avoid.md` for active negative guardrails.\n"
        "3. Check `.ai-memory/plans/pending/` for in-flight tasks and dependencies.\n\n"
        "## Changelog\n\n"
        f"- {now_iso}, Memory write: Initialized canonical `.ai-memory/` hierarchy for `{project_slug}` via `scaffold_ai_memory.py`. Enforced 100% UNIX LF line endings and GitMap JSON standards.\n"
    )


def build_strictly_avoid_template(project_slug: str) -> str:
    """Generate initial strictly-avoid.md negative constraint document."""
    return (
        "# Strictly Avoid — Anti-Patterns & Negative Guardrails\n\n"
        "The following practices are strictly forbidden across all files and agents:\n\n"
        "1. **CRLF Line Endings:** Total ban on `\\r\\n`. Always use UNIX LF (`\\n`).\n"
        "2. **Hardcoded Absolute Paths:** Never hardcode paths like `C:\\` or `/home/user`. Use dynamic `$WORK` or repo-relative paths.\n"
        "3. **Magic Strings & Encodings:** Never pass raw encoding strings (`'utf-8'`). Use strongly-typed constants.\n"
        "4. **Snake_Case SQLite Tables:** All database tables MUST be PascalCase (`TaskExecutions`, `Credentials`).\n"
        "5. **Underscores in Proprietary JSON:** All JSON properties under our control must be lower camelCase.\n"
        "6. **Silent Error Swallowing:** Leaf errors must bubble up via monadic `Result[T]` or typed exceptions.\n"
    )


def build_readme_template(project_slug: str) -> str:
    """Generate initial README.md master cognitive entrypoint & router."""
    return (
        f"# Autonomous AI Memory Core ({project_slug})\n\n"
        "> **Version:** 5.0.0 (7-Domain Lean Architecture)\n"
        "> **Source of Truth Anchor:** GitHub (`alimtvnetwork/coding-guidelines-v24`)\n\n"
        "## Cognitive Domains\n\n"
        "- `what-to-read.md`: Read Memory — mandatory reading order, rules 1-12 & subsystem overview.\n"
        "- `strictly-avoid.md`: Code Red negative guardrails & gateway to `avoid/`.\n"
        "- `folder-structure.md`: Repository & 7-domain architecture map.\n"
        "- `coding-guidelines.md`: Standalone guidelines with 10-point AI Compliance Checklist.\n"
        "- `learned/`: Learn Memory — flat sequential institutional knowledge.\n"
        "- `plans/`: Task roadmaps (`pending/`, `active/`, `completed/`, `subtasks/`, `suggestions/`).\n"
        "- `ambiguity/`: Decision lifecycle (`new/` -> `resolved/`).\n"
        "- `rca/`: 4-part Root Cause Analysis & Issue Registry (`new/` -> `resolved/`).\n"
        "- `avoid/`: Modular negative constraints (`00-default.md`, `01-04`).\n"
        "- `research/`: Technical spikes & investigation guidelines.\n"
        "- `screenshots/`: UI/UX verification telemetry.\n"
    )


def build_folder_structure_template(project_slug: str) -> str:
    """Generate initial folder-structure.md architecture map."""
    return (
        f"# Repository & .ai-memory Architecture Map ({project_slug})\n\n"
        "This document establishes the relationship between source code and the `.ai-memory/` 7 domains.\n"
    )


def build_coding_guidelines_template(project_slug: str) -> str:
    """Generate initial coding-guidelines.md with AI Compliance Checklist."""
    return (
        f"# Coding Guidelines: {project_slug}\n\n"
        "## AI Compliance & Execution Checklist (Follow Every Turn)\n\n"
        "- [ ] **1. Pre-Flight Clean Pull:** Executed `gitmap pull` prior to modifying code.\n"
        "- [ ] **2. Function Sizing:** <= 8 lines preferred, <= 15 lines max cap. Zero nested ifs.\n"
        "- [ ] **3. Positive Booleans:** Variables/fields begin with `is*` or `has*` only.\n"
        "- [ ] **4. Error Sovereignty:** Leaf functions return error directly; outer caller handles exit.\n"
        "- [ ] **5. Result Wrapper Envelopes:** Monadic Result[T] containers utilized.\n"
        "- [ ] **6. SQL Repository Pattern:** All queries encapsulated behind repository interfaces.\n"
        "- [ ] **7. Universal UNIX LF Line Endings:** Total ban on CRLF; 0 occurrences of \\r\\n.\n"
        "- [ ] **8. YAML Skill Frontmatter Contract (RCA-32):** Line 1 `---`, valid frontmatter.\n"
        "- [ ] **9. Dedicated Semantic Commit Verbs:** `cpf`, `cbf`, `cfr`, `cpc`, `cpr`.\n"
        "- [ ] **10. Mandatory Upstream Push:** No Push = Not Done. Push to tracking remotes.\n"
    )


def build_default_memory_template(project_slug: str) -> str:
    """Generate initial default-memory.md inside learned/."""
    return (
        f"# Default Memory: {project_slug}\n\n"
        "Baseline project invariants and institutional knowledge.\n"
    )


def build_learned_readme_template(project_slug: str) -> str:
    """Generate initial readme.md inside learned/."""
    return (
        f"# Learn Memory Index: {project_slug}\n\n"
        "Sequential index of all institutional knowledge records.\n"
    )


def build_manifest_json(project_slug: str, base_dir: Path) -> dict:
    """Construct structured manifest in GitMap data and attributes pattern."""
    now_iso = datetime.now(timezone.utc).isoformat()
    return {
        "data": {
            "id": f"memoryManifest-{project_slug}",
            "type": "memoryManifest",
            "attributes": {
                "projectSlug": project_slug,
                "initializedAt": now_iso,
                "version": "5.0.0",
                "directoriesCount": len(CANONICAL_DIRECTORIES),
                "isLfOnly": True,
                "architectureStandard": "Universal-AI-Memory-7Domain"
            }
        }
    }


def execute_scaffolding(root_path: Path, project_slug: str, is_dry_run: bool = False, is_force: bool = False) -> int:
    """Execute complete scaffolding routine."""
    print(f"{AnsiColorConstants.CYAN}{LogBadgeConstants.INFO} Scaffolding AI memory at: {root_path}{AnsiColorConstants.RESET}")
    created_dirs = 0
    created_files = 0

    # 1. Create Directories
    for rel_dir in CANONICAL_DIRECTORIES:
        target_dir = root_path / rel_dir
        if not target_dir.exists():
            if not is_dry_run:
                target_dir.mkdir(parents=True, exist_ok=True)
            created_dirs += 1
            print(f"{AnsiColorConstants.GREEN}{LogBadgeConstants.OK} Created directory: {rel_dir}{AnsiColorConstants.RESET}")
        else:
            print(f"{AnsiColorConstants.YELLOW}{LogBadgeConstants.SKIP} Directory exists: {rel_dir}{AnsiColorConstants.RESET}")

        # Add .gitkeep to leaf directories
        if rel_dir != ".ai-memory":
            gitkeep = target_dir / ".gitkeep"
            if write_file_lf(gitkeep, "", is_force=is_force, is_dry_run=is_dry_run):
                created_files += 1

    # 2. Populate Core Index Files
    memory_root = root_path / ".ai-memory"
    indices = [
        (memory_root / "what-to-read.md", build_what_to_read_template(project_slug)),
        (memory_root / "strictly-avoid.md", build_strictly_avoid_template(project_slug)),
        (memory_root / "README.md", build_readme_template(project_slug)),
        (memory_root / "folder-structure.md", build_folder_structure_template(project_slug)),
        (memory_root / "coding-guidelines.md", build_coding_guidelines_template(project_slug)),
        (memory_root / "learned" / "default-memory.md", build_default_memory_template(project_slug)),
        (memory_root / "learned" / "readme.md", build_learned_readme_template(project_slug)),
    ]

    for file_path, content in indices:
        if write_file_lf(file_path, content, is_force=is_force, is_dry_run=is_dry_run):
            created_files += 1
            print(f"{AnsiColorConstants.GREEN}{LogBadgeConstants.OK} Generated template: {file_path.relative_to(root_path)}{AnsiColorConstants.RESET}")
        else:
            print(f"{AnsiColorConstants.YELLOW}{LogBadgeConstants.SKIP} Preserved existing file: {file_path.relative_to(root_path)}{AnsiColorConstants.RESET}")

    # 3. Emit GitMap Manifest JSON
    manifest_path = memory_root / "manifest.json"
    manifest_payload = build_manifest_json(project_slug, root_path)
    if write_file_lf(manifest_path, json.dumps(manifest_payload, indent=2) + "\n", is_force=is_force, is_dry_run=is_dry_run):
        created_files += 1
        print(f"{AnsiColorConstants.GREEN}{LogBadgeConstants.OK} Generated manifest: {manifest_path.relative_to(root_path)}{AnsiColorConstants.RESET}")

    print("\n" + "=" * 60)
    mode_tag = " (DRY-RUN SIMULATION)" if is_dry_run else ""
    print(f"{AnsiColorConstants.BOLD}Scaffolding Complete{mode_tag}:{AnsiColorConstants.RESET}")
    print(f"  • Directories processed : {len(CANONICAL_DIRECTORIES)} (Created: {created_dirs})")
    print(f"  • Files initialized     : {created_files}")
    print(f"  • Root target path      : {root_path}")
    print("=" * 60 + "\n")
    return 0


def main() -> None:
    """CLI Entry Point."""
    parser = argparse.ArgumentParser(description="Scaffold canonical .ai-memory/ hierarchy in one shot.")
    parser.add_argument("--work-dir", "-d", type=str, default=None, help="Target workspace root directory")
    parser.add_argument("--project-slug", "-p", type=str, default=None, help="Identifier slug for the project")
    parser.add_argument("--dry-run", "-n", action="store_true", help="Simulate creation without disk modifications")
    parser.add_argument("--force", "-f", action="store_true", help="Overwrite existing template indices")

    args = parser.parse_args()
    target_root = resolve_workspace_root(args.work_dir)
    slug = args.project_slug or target_root.name or "repository"

    exit_code = execute_scaffolding(target_root, slug, is_dry_run=args.dry_run, is_force=args.force)
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
```

---

## 🔄 4. Four Core AI Memory Lifecycle Protocols

Any autonomous agent operating within an AI-memory-enabled repository must strictly adhere to the following four lifecycle phases:

```text
┌────────────────────────────────────────────────────────────────────────┐
│                   AI MEMORY 4-PHASE LIFECYCLE ENGINE                   │
└────────────────────────────────────────────────────────────────────────┘
  1. TURN-START INGESTION
     ├── Read .ai-memory/what-to-read.md (Last 5 Changelog Entries)
     ├── Read .ai-memory/strictly-avoid.md (Negative Guardrails & Invariants)
     └── Query .ai-memory/plans/pending/ (Active Roadmaps & Subtasks)
                   │
                   ▼
  2. PLAN REGISTRATION
     ├── Allocate Spec Sequence: gitmap spec next (or calculate sequence)
     ├── Create .ai-memory/plans/pending/XX-<slug>.md
     └── Enqueue Granular Subtasks in plans/subtasks/XX-<slug>/
                   │
                   ▼
  3. AMBIGUITY RESOLUTION & LOGGING
     ├── Record Design Gaps in ambiguity/new/
     ├── Analyze Trade-Offs & Align Decisions with Spec Contracts
     └── Archive Resolved Decisions in ambiguity/resolved/
                   │
                   ▼
  4. TURN-END PERSISTENCE
     ├── Append Structured Memory Entry to .ai-memory/what-to-read.md
     ├── Move Plan: plans/pending/XX.md -> plans/completed/XX.md
     └── Commit & Upstream Push (No Push = Not Done)
```

### 4.1 Protocol 1: Turn-Start Defensive Memory Reading
Before writing code, creating branches, or proposing fixes, the AI agent must read:
1. `.ai-memory/what-to-read.md` to discover recent changes, active database migrations, or newly applied standards.
2. `.ai-memory/strictly-avoid.md` to enforce negative constraints (e.g., zero magic strings, zero CRLF, zero unhandled errors).
3. Any active plans in `.ai-memory/plans/pending/`.

### 4.2 Protocol 2: Plan Registration & Naming Standard
Every major task must have a formal roadmap:
- **Filename Convention:** `XX-<slug>.md` where `XX` is a zero-padded integer sequence.
- **Location:** Enqueued in `.ai-memory/plans/pending/XX-<slug>.md`.
- **Subtasks Directory:** `.ai-memory/plans/subtasks/XX-<slug>/subtask-*.md`.
- **Completion Invariant:** Upon verifying all tests and criteria to 100% pass, the plan file is moved to `.ai-memory/plans/completed/XX-<slug>.md`.

### 4.3 Protocol 3: Ambiguity Resolution
Whenever architectural trade-offs, scope questions, or conflicting instructions arise:
- The AI must author an ambiguity file in `.ai-memory/ambiguity/new/XX-<slug>-ambiguity.md`.
- Once resolved, the file moves to `ambiguity/resolved/`.

### 4.4 Protocol 4: Turn-End Memory Changelog Write
At the conclusion of each unit of work, the AI must append a concise, structured entry to `.ai-memory/what-to-read.md` adhering to the following schema:
```markdown
- YYYY-MM-DDTHH:MM:SSZ, Memory write: Plan XX / Spec 21-app/XX-<slug>: <Brief Title>: <Summary of accomplishments, modules modified, test evidence, and commit hash>. Enforced 100% UNIX LF (0 CRLF).
```

---

## 🧹 5. Git Hygiene & Retention Rules

1. **Tracked Files:**
   - All markdown files in `.ai-memory/` (`README.md`, `what-to-read.md`, `strictly-avoid.md`, `folder-structure.md`, `coding-guidelines.md`, `plans/`, `ambiguity/`, `rca/`, `avoid/`, `learned/`) **MUST BE COMMITTED** to Git.
   - All `.gitkeep` files in empty subdirectories must be committed.
2. **Ignored Files:**
   - `.ai-memory/scratch/*.tmp`
   - `.ai-memory/temp/`
   - Temporary test SQLite databases (`*.db`, `*.sqlite`)
3. **Completion Invariant:**
   **No Push = Not Done.** All memory updates, plans, and code must be pushed upstream to the remote tracking branch.
