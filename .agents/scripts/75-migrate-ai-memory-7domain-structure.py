#!/usr/bin/env python3
"""
75-migrate-ai-memory-7domain-structure.py

Autonomous migration engine to restructure any repository's .ai-memory/ folder
into the canonical 7-domain lean architecture:
  1. ambiguity/     - new/ (active inquiries), resolved/ (closed answers), README.md
  2. rca/           - new/ (active issues), resolved/ (compendiums/RCA), README.md
  3. avoid/         - 00-default.md (root invariants), 01-04 topic files, README.md
  4. learned/       - flat sequential .md files, default-memory.md, readme.md
  5. plans/         - pending/, active/, completed/, subtasks/ (intact)
  6. research/      - README.md (spike & investigation guidelines)
  7. screenshots/   - UI ground truth images only (assets pruned)

Purges deprecated folders:
  release/, scratch/, spec/, aspect/, error-manage/, improvements/

Usage:
  python 03-ai-scripts/75-migrate-ai-memory-7domain-structure.py [--repo <path>] [--dry-run]
"""

import argparse
import os
import re
import shutil
import sys
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(
        description="Migrate .ai-memory to 7-domain hierarchy with flat sequenced learned/"
    )
    parser.add_argument(
        "--repo",
        type=Path,
        default=Path.cwd(),
        help="Target repository root path (default: current directory)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simulate file moves and operations without modifying disk"
    )
    return parser.parse_args()


def safe_move(src: Path, dest: Path, is_dry_run: bool):
    if not src.exists():
        return
    print(f"  [MOVE] {src.relative_to(src.parent.parent)} -> {dest.name}")
    if not is_dry_run:
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(src), str(dest))


def safe_rmdir(dir_path: Path, is_dry_run: bool):
    if not dir_path.exists():
        return
    print(f"  [PURGE] {dir_path.name}/")
    if not is_dry_run:
        shutil.rmtree(str(dir_path), ignore_errors=True)


def write_lf_file(path: Path, content: str, is_dry_run: bool):
    print(f"  [WRITE] {path.name}")
    if not is_dry_run:
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(content)


def migrate_ambiguity(ai_mem: Path, is_dry_run: bool):
    print("\n--- 1. Migrating ambiguity/ ---")
    amb_dir = ai_mem / "ambiguity"
    new_dir = amb_dir / "new"
    res_dir = amb_dir / "resolved"

    if not is_dry_run:
        new_dir.mkdir(parents=True, exist_ok=True)
        res_dir.mkdir(parents=True, exist_ok=True)

    # Move loose files in ambiguity/*.md to resolved/
    if amb_dir.exists():
        for f in list(amb_dir.glob("*.md")):
            if f.name.lower() != "readme.md":
                safe_move(f, res_dir / f.name, is_dry_run)

    # Move ambiguous-questions/01-new-ambiguity/* to ambiguity/new/
    old_new = ai_mem / "ambiguous-questions" / "01-new-ambiguity"
    if old_new.exists():
        for f in list(old_new.glob("*")):
            if f.is_file():
                safe_move(f, new_dir / f.name, is_dry_run)

    # Move ambiguous-questions/02-ambiguity-resolved/* to ambiguity/resolved/
    old_res = ai_mem / "ambiguous-questions" / "02-ambiguity-resolved"
    if old_res.exists():
        for f in list(old_res.glob("*")):
            if f.is_file():
                safe_move(f, res_dir / f.name, is_dry_run)

    # Move question-and-ambiguity/* to ambiguity/resolved/
    old_qa = ai_mem / "question-and-ambiguity"
    if old_qa.exists():
        for f in list(old_qa.glob("*")):
            if f.is_file():
                dest_name = f"qa-{f.name}" if (res_dir / f.name).exists() else f.name
                safe_move(f, res_dir / dest_name, is_dry_run)

    # Clean old dirs
    safe_rmdir(ai_mem / "ambiguous-questions", is_dry_run)
    safe_rmdir(ai_mem / "question-and-ambiguity", is_dry_run)

    # Generate README.md
    new_files = sorted([f.name for f in new_dir.glob("*.md")]) if new_dir.exists() else []
    res_files = sorted([f.name for f in res_dir.glob("*.md")]) if res_dir.exists() else []

    readme_content = f"""# Ambiguity Registry

> Canonical repository of architectural, procedural, and specification ambiguities.

## Directory Structure
- `new/`: Active or pending ambiguities requiring resolution or clarifying decisions.
- `resolved/`: Clarified ambiguities with architectural decisions recorded.

## New Ambiguities ({len(new_files)})
"""
    for nf in new_files:
        readme_content += f"- [`{nf}`](new/{nf})\n"

    readme_content += f"\n## Resolved Ambiguities ({len(res_files)})\n"
    for rf in res_files:
        readme_content += f"- [`{rf}`](resolved/{rf})\n"

    write_lf_file(amb_dir / "README.md", readme_content, is_dry_run)


def migrate_rca(ai_mem: Path, is_dry_run: bool):
    print("\n--- 2. Migrating rca/ ---")
    rca_dir = ai_mem / "rca"
    new_dir = rca_dir / "new"
    res_dir = rca_dir / "resolved"

    if not is_dry_run:
        new_dir.mkdir(parents=True, exist_ok=True)
        res_dir.mkdir(parents=True, exist_ok=True)

    # Move pending-issues -> rca/new/
    old_pending = ai_mem / "pending-issues"
    if old_pending.exists():
        for f in list(old_pending.glob("*.md")):
            safe_move(f, new_dir / f.name, is_dry_run)

    # Move solved-issues -> rca/resolved/
    old_solved = ai_mem / "solved-issues"
    if old_solved.exists():
        for f in list(old_solved.glob("*.md")):
            safe_move(f, res_dir / f.name, is_dry_run)

    # Move cicd-issues -> rca/resolved/
    old_cicd = ai_mem / "cicd-issues"
    if old_cicd.exists():
        for f in list(old_cicd.glob("*.md")):
            safe_move(f, res_dir / f"cicd-{f.name}", is_dry_run)

    # Move issues/*.md -> rca/resolved/
    old_issues = ai_mem / "issues"
    if old_issues.exists():
        for f in list(old_issues.glob("*.md")):
            if f.name.lower() != "readme.md":
                safe_move(f, res_dir / f.name, is_dry_run)

    safe_rmdir(ai_mem / "pending-issues", is_dry_run)
    safe_rmdir(ai_mem / "solved-issues", is_dry_run)
    safe_rmdir(ai_mem / "cicd-issues", is_dry_run)
    safe_rmdir(ai_mem / "issues", is_dry_run)

    new_items = sorted([f.name for f in new_dir.iterdir()]) if new_dir.exists() else []
    res_files = sorted([f.name for f in res_dir.glob("*.md")]) if res_dir.exists() else []

    readme_content = f"""# Root Cause Analysis (RCA) & Issue Registry

> Canonical registry of active/resolved issues and 4-part Root Cause Analyses.

## Structure
- `new/`: Active or pending issues under investigation.
- `resolved/`: Remediated issues with 4-part RCA and architectural invariants.

## Invariant: 4-Part RCA Contract
1. **Part 1: What Happened?** Direct symptom and failure output.
2. **Part 2: Where Did It Originate?** Target file, line, and commit.
3. **Part 3: Why Did It Occur?** Underlying mechanism.
4. **Part 4: Why Will It Never Happen Again?** Architectural prevention.

## New / Active Issues ({len(new_items)})
"""
    for ni in new_items:
        readme_content += f"- [`{ni}`](new/{ni})\n"

    readme_content += f"\n## Resolved Compendiums ({len(res_files)})\n"
    for rf in res_files:
        readme_content += f"- [`{rf}`](resolved/{rf})\n"

    write_lf_file(rca_dir / "README.md", readme_content, is_dry_run)


def migrate_avoid(ai_mem: Path, is_dry_run: bool):
    print("\n--- 3. Migrating avoid/ ---")
    avoid_dir = ai_mem / "avoid"
    if not is_dry_run:
        avoid_dir.mkdir(parents=True, exist_ok=True)

    strictly_path = ai_mem / "strictly-avoid.md"
    default_path = avoid_dir / "00-default.md"

    # If already partitioned, ensure readme exists
    if default_path.exists():
        print("  avoid/ already partitioned.")
        return

    if not strictly_path.exists():
        return

    with open(strictly_path, "r", encoding="utf-8") as f:
        content = f.read()

    lines = content.splitlines()
    if len(lines) < 100:
        return

    # Split into sections
    sections = re.split(r'\n(?=## )', content)
    rule_sections = sections[1:] if len(sections) > 1 else []

    rules_by_title = {}
    for sec in rule_sections:
        m = re.match(r'^## (.*?)\n', sec)
        if m:
            rules_by_title[m.group(1).strip()] = sec

    grouped = {
        "00-default": [],
        "01-code-and-style": [],
        "02-git-and-commits": [],
        "03-shell-and-execution": [],
        "04-privacy-and-credentials": []
    }
    assigned = set()

    default_keywords = ["crlf", "anti-gravity", "email", "linter", "python script", "wrapping", "push", "ssh"]
    for title, sec in rules_by_title.items():
        lt = title.lower()
        if any(dk in lt for dk in default_keywords) and len(grouped["00-default"]) < 8:
            grouped["00-default"].append((title, sec))
            assigned.add(title)

    for title, sec in rules_by_title.items():
        if title in assigned:
            continue
        lt = title.lower()
        if any(k in lt for k in ["bool", "if", "naming", "string", "error", "nil", "struct", "limit"]):
            grouped["01-code-and-style"].append((title, sec))
        elif any(k in lt for k in ["git", "commit", "push", "remote", "release", "repo", "branch"]):
            grouped["02-git-and-commits"].append((title, sec))
        elif any(k in lt for k in ["shell", "temp", "build", "cargo", "test", "pwsh", "powershell"]):
            grouped["03-shell-and-execution"].append((title, sec))
        else:
            grouped["04-privacy-and-credentials"].append((title, sec))

    headers = {
        "00-default": "# Baseline Strictly Avoid Rules (Root Invariants)\n\n---\n\n",
        "01-code-and-style": "# Strictly Avoid: Code Architecture & Style\n\n---\n\n",
        "02-git-and-commits": "# Strictly Avoid: Git, Commits & Release Management\n\n---\n\n",
        "03-shell-and-execution": "# Strictly Avoid: Shell Execution & Build Workflows\n\n---\n\n",
        "04-privacy-and-credentials": "# Strictly Avoid: Privacy, Credentials & External Services\n\n---\n\n"
    }

    for gname, items in grouped.items():
        if items:
            body = "\n\n---\n\n".join([sec.strip() for _, sec in items])
            write_lf_file(avoid_dir / f"{gname}.md", headers[gname] + body + "\n", is_dry_run)

    avoid_readme = f"""# Strictly Avoid Rules Catalog

> Modular repository of grounded, non-negotiable engineering bans.

| Domain File | Description | Rules Count |
| :--- | :--- | :--- |
| [00-default.md](00-default.md) | **Root Invariants** (LF, IDE settings, push mandate, email privacy) | {len(grouped['00-default'])} rules |
| [01-code-and-style.md](01-code-and-style.md) | **Code Architecture & Style** | {len(grouped['01-code-and-style'])} rules |
| [02-git-and-commits.md](02-git-and-commits.md) | **Git & Commits** | {len(grouped['02-git-and-commits'])} rules |
| [03-shell-and-execution.md](03-shell-and-execution.md) | **Shell & Execution** | {len(grouped['03-shell-and-execution'])} rules |
| [04-privacy-and-credentials.md](04-privacy-and-credentials.md) | **Privacy & Credentials** | {len(grouped['04-privacy-and-credentials'])} rules |
"""
    write_lf_file(avoid_dir / "README.md", avoid_readme, is_dry_run)

    root_strictly = """# Strictly Avoid Guidelines

> Master gateway to all project-wide non-negotiable rules, operational bans, and architectural invariants.

## Core Non-Negotiable Invariants (`00-default.md`)
1. **Windows CRLF (`\\r\\n`) Line Endings — TOTAL BAN:** Always use UNIX LF (`\\n`) everywhere.
2. **Anti-Gravity IDE Settings Deletion — TOTAL BAN:** Never delete or touch IDE configs.
3. **Generic Email Privacy Invariant:** Never hardcode personal/corporate emails in code or memory.
4. **No Push = Not Done:** Every commit must be pushed immediately to upstream remotes.

## Modular Rule Directories
All detailed rule specifications are modularized in [`.ai-memory/avoid/`](avoid/README.md):
- [**`avoid/00-default.md`**](avoid/00-default.md) — Root Baseline Invariants
- [**`avoid/01-code-and-style.md`**](avoid/01-code-and-style.md) — Code Architecture & Style
- [**`avoid/02-git-and-commits.md`**](avoid/02-git-and-commits.md) — Git & Commits
- [**`avoid/03-shell-and-execution.md`**](avoid/03-shell-and-execution.md) — Shell Safety & Builds
- [**`avoid/04-privacy-and-credentials.md`**](avoid/04-privacy-and-credentials.md) — Credentials & Security
"""
    write_lf_file(strictly_path, root_strictly, is_dry_run)


def migrate_learned(ai_mem: Path, is_dry_run: bool):
    print("\n--- 4. Consolidating learned/ (Flat Sequential) ---")
    learned_dir = ai_mem / "learned"
    if not is_dry_run:
        learned_dir.mkdir(parents=True, exist_ok=True)

    old_mem = ai_mem / "memory"
    old_lm = ai_mem / "learn-memory"

    # Source directories to harvest from
    sources = [s for s in [old_mem, old_lm] if s.exists()]

    # 1. Baseline default-memory.md
    gov_candidates = [
        learned_dir / "default-memory.md",
        ai_mem / "memory" / "00-project-governance-and-invariants.md",
        ai_mem / "learn-memory" / "00-project-governance-and-invariants.md",
    ]
    gov_found = False
    for gc in gov_candidates:
        if gc.exists():
            if gc != learned_dir / "default-memory.md":
                safe_move(gc, learned_dir / "default-memory.md", is_dry_run)
            gov_found = True
            break

    if not gov_found and not (learned_dir / "default-memory.md").exists():
        default_mem_content = """# Baseline Project Memory & Core Invariants

> Foundation memory file defining core project identity, architecture standards, and invariants.
"""
        write_lf_file(learned_dir / "default-memory.md", default_mem_content, is_dry_run)

    # 2. Collect all other markdown files from sources and subdirectories
    raw_files = []
    for src in sources:
        for f in src.rglob("*.md"):
            if f.name.lower() in ("readme.md", "00-project-governance-and-invariants.md"):
                continue
            raw_files.append(f)

    # If learned/ already had subfolders (learned/learned or learned/sessions), harvest them too
    for sub in list(learned_dir.iterdir()):
        if sub.is_dir():
            for f in sub.rglob("*.md"):
                if f.name.lower() != "readme.md":
                    raw_files.append(f)

    # Separate into topics, lessons, sessions
    topics = []
    lessons = []
    sessions = []

    for f in raw_files:
        stem = f.stem.lower()
        if "session-summary" in stem or stem.startswith("2026-"):
            sessions.append(f)
        elif any(stem.startswith(f"{i:02d}-") for i in range(1, 10)) and ("architecture" in stem or "scanner" in stem or "git" in stem or "nodes" in stem or "database" in stem or "pipeline" in stem or "distribution" in stem or "session-programs" in stem):
            topics.append(f)
        else:
            lessons.append(f)

    topics.sort(key=lambda x: x.name)
    lessons.sort(key=lambda x: x.name)
    sessions.sort(key=lambda x: x.name)

    seq_idx = 1
    # Move topics (01-09)
    for tf in topics:
        dest_name = f"{seq_idx:02d}-{tf.stem.split('-', 1)[-1] if tf.stem[:2].isdigit() else tf.stem}.md"
        safe_move(tf, learned_dir / dest_name, is_dry_run)
        seq_idx += 1

    # Move lessons (10-25)
    for lf in lessons:
        clean_slug = lf.stem.split("-", 1)[-1] if lf.stem[:2].isdigit() else lf.stem
        dest_name = f"{seq_idx:02d}-{clean_slug}.md"
        safe_move(lf, learned_dir / dest_name, is_dry_run)
        seq_idx += 1

    # Move sessions (26-30)
    for sf in sessions:
        date_part = sf.stem.replace("session-summary-", "").replace("-session-summary", "")
        dest_name = f"{seq_idx:02d}-session-summary-{date_part}.md"
        safe_move(sf, learned_dir / dest_name, is_dry_run)
        seq_idx += 1

    # Clean old source directories and any subdirectories in learned/
    safe_rmdir(old_mem, is_dry_run)
    safe_rmdir(old_lm, is_dry_run)
    if not is_dry_run:
        for sub in list(learned_dir.iterdir()):
            if sub.is_dir():
                safe_rmdir(sub, is_dry_run)

    # Generate learned/readme.md
    seq_files = sorted([f.name for f in learned_dir.glob("[0-9][0-9]-*.md")]) if learned_dir.exists() else []
    learned_readme = f"""# Learned Knowledge & Memory Index

> Canonical repository of institutional memory, domain architectural models, forensic lessons, and session checkpoints.

## Core Baseline Memory
- [**`default-memory.md`**](default-memory.md) — Baseline project governance, engineering stack identity, and invariant mindset.

## Sequential Knowledge Records ({len(seq_files)} Files)

| Seq | File | Description / Domain |
| :--- | :--- | :--- |
"""
    for sf in seq_files:
        num = sf[:2]
        title = sf[3:-3].replace("-", " ").title()
        learned_readme += f"| **{num}** | [`{sf}`]({sf}) | {title} |\n"

    write_lf_file(learned_dir / "readme.md", learned_readme, is_dry_run)


def purge_deprecated(ai_mem: Path, is_dry_run: bool):
    print("\n--- 5. Purging Deprecated Folders ---")
    deprecated = ["release", "scratch", "spec", "aspect", "error-manage", "improvements"]
    for d in deprecated:
        safe_rmdir(ai_mem / d, is_dry_run)

    # Ensure research/README.md
    research_dir = ai_mem / "research"
    if not is_dry_run:
        research_dir.mkdir(parents=True, exist_ok=True)
    if not (research_dir / "README.md").exists():
        research_content = """# Autonomous Agent Research & Investigation Guidelines

> Canonical operational guidelines for ad-hoc technical investigations, spikes, API discovery, and external tool benchmarks.

## Scope & Operating Guidelines
1. **Ad-Hoc Spikes Only:** For exploratory notes, benchmarks, and spikes prior to specification.
2. **No Production Code:** Production scripts belong in `cli/` or `03-ai-scripts/`.
3. **Graduation:** Matured research moves into `02-spec/21-app/` or `.ai-memory/learned/`.
"""
        write_lf_file(research_dir / "README.md", research_content, is_dry_run)


def update_master_indexes(ai_mem: Path, is_dry_run: bool):
    print("\n--- 6. Updating Master Index Files ---")
    root_readme = """# Autonomous AI Memory Core (.ai-memory)

> **Version:** 5.0.0 (7-Domain Lean Architecture)
> **Source of Truth Anchor:** GitHub (`alimtvnetwork/coding-guidelines-v24`)
> **Target:** Master entrypoint, architectural taxonomy, and directory router for all autonomous agents.

---

## 1. Cognitive Architecture & 7-Domain Hierarchy

```text
.ai-memory/
├── ambiguity/              # 1. Architectural ambiguity lifecycle (new/ -> resolved/)
├── rca/                    # 2. Root Cause Analysis & Issue Registry (4-part RCA contract)
├── avoid/                  # 3. Grounded Non-Negotiable Bans (00-default.md, 01-04 topic files)
├── learned/                # 4. Flat Sequential Memory (default-memory.md, readme.md, 01-30)
├── plans/                  # 5. Task Execution & Planning Backlog (pending/, active/, completed/)
├── research/               # 6. Technical Exploration & Spike Guidelines
└── screenshots/            # 7. UI/UX Ground Truth Imagery
```

## 2. Directory Navigation Router

| Domain | Functional Purpose | Key Entrypoint |
| :--- | :--- | :--- |
| **`ambiguity/`** | Ambiguity intake, resolution tracking, and decision logs | [`ambiguity/README.md`](ambiguity/README.md) |
| **`rca/`** | Grounded 4-part Root Cause Analyses and issue compendiums | [`rca/README.md`](rca/README.md) |
| **`avoid/`** | Operational bans, hard constraints, and negative invariants | [`avoid/README.md`](avoid/README.md) |
| **`learned/`** | Flat sequential memory, domain models, lessons, and session summaries | [`learned/readme.md`](learned/readme.md) |
| **`plans/`** | 100-step execution roadmaps, active tasks, and subtasks | [`plans/readme.md`](plans/readme.md) |
| **`research/`** | Experimental spikes, external benchmarks, and investigations | [`research/README.md`](research/README.md) |
| **`screenshots/`** | Visual ground truth screenshots for UI and RCA audits | [`screenshots/`](screenshots/) |
"""
    write_lf_file(ai_mem / "README.md", root_readme, is_dry_run)

    folder_structure = """# Repository & .ai-memory Folder Architecture Map

```text
gitmap/
├── .ai-memory/                 # 🧠 7-Domain AI Cognitive Workspace
│   ├── ambiguity/              #    Ambiguity lifecycle (new/ -> resolved/)
│   ├── rca/                    #    Grounded 4-part Root Cause Analyses (new/ -> resolved/)
│   ├── avoid/                  #    Modular negative constraints & root invariants (00-04)
│   ├── learned/                #    Flat sequential memory (default-memory.md, readme.md, 01-30)
│   ├── plans/                  #    Autonomous task planning (pending/, active/, completed/)
│   ├── research/               #    Technical spikes & investigation guidelines
│   └── screenshots/            #    Ground truth visual telemetry
├── 01-prompts/                 # 📜 Canonical Prompt Catalog & Workflow Prompts
├── 02-spec/                    # 📐 Authoritative Modular Specifications
├── 03-ai-scripts/              # ⚙️ High-Speed Cross-Platform Automation Toolchain
├── .agents/skills/             # 🛠️ Antigravity & Agent Customization Skills
├── cli/                        # 💻 Primary Go Application Codebase
└── README.md                   # 🏠 Root Gateway & Project README
```

## .ai-memory/ 7-Domain Taxonomy
| Domain | Directory | Purpose | Retention Policy |
| :--- | :--- | :--- | :--- |
| **1. Ambiguity** | `ambiguity/` | Tracks open questions (`new/`) and resolved design decisions (`resolved/`). | Permanent audit record |
| **2. RCA** | `rca/` | Forensic 4-part Root Cause Analyses for active (`new/`) and remediated (`resolved/`) bugs. | Permanent engineering history |
| **3. Avoid** | `avoid/` | Grounded prohibitions (`00-default.md` baseline plus `01`-`04` topic modules). | Non-negotiable active rules |
| **4. Learned & Memory** | `learned/` | Flat sequential domain models (`01-`..`09-`), lessons (`10-`..`25-`), and session logs (`26-`..`30-`) anchored by `default-memory.md`. | Permanent institutional knowledge |
| **5. Plans** | `plans/` | 100-step master plans (`pending/`, `active/`, `completed/`) and subtasks. | Active backlog & archive |
| **6. Research** | `research/` | Scratchpad and guidelines for experimental investigations and spikes. | Graduated or pruned |
| **7. Screenshots** | `screenshots/` | Ground truth UI screenshots validating specifications and bugs. | Pruned upon issue closure |
"""
    write_lf_file(ai_mem / "folder-structure.md", folder_structure, is_dry_run)


def main():
    args = parse_args()
    repo_root = args.repo.resolve()
    ai_mem = repo_root / ".ai-memory"

    if not ai_mem.exists():
        print(f"Error: {ai_mem} does not exist. Aborting.")
        sys.exit(1)

    print(f"============================================================")
    print(f"Starting 7-Domain .ai-memory Migration on: {repo_root}")
    print(f"Mode: {'DRY-RUN (Simulation)' if args.dry_run else 'LIVE EXECUTION'}")
    print(f"============================================================")

    migrate_ambiguity(ai_mem, args.dry_run)
    migrate_rca(ai_mem, args.dry_run)
    migrate_avoid(ai_mem, args.dry_run)
    migrate_learned(ai_mem, args.dry_run)
    purge_deprecated(ai_mem, args.dry_run)
    update_master_indexes(ai_mem, args.dry_run)

    print("\n[SUCCESS] Migration completed successfully with strict UNIX LF line endings.")


if __name__ == "__main__":
    main()
