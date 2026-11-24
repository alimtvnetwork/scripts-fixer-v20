#!/usr/bin/env python3
"""
76-remap-legacy-ai-memory-paths.py

Autonomous AI script to scan and remap legacy .ai-memory folder paths
across 02-spec/, 01-prompts/, .agents/skills/, .agents/rules/, and .ai-memory/.

Canonical 7-domain hierarchy:
  - ambiguity/ (new/ -> resolved/)
  - rca/ (new/ -> resolved/)
  - avoid/
  - learned/
  - plans/ (pending/, active/, completed/, subtasks/, suggestions/)
  - research/
  - screenshots/

Strictly enforces:
  - Longest-prefix-first replacement to avoid substring collision
  - Universal UNIX LF (\\n) line endings (0 CRLF)
  - Detailed directory-by-directory modification tally and reporting
"""

import os
import sys
import argparse
from typing import Dict, List, Tuple

# Ordered from most specific / longest path to shortest
MAPPING_RULES: List[Tuple[str, str]] = [
    # Ambiguity
    (".ai-memory/ambiguous-questions/01-new-ambiguity/", ".ai-memory/ambiguity/new/"),
    (".ai-memory/ambiguous-questions/02-ambiguity-resolved/", ".ai-memory/ambiguity/resolved/"),
    (".ai-memory/ambiguous-questions/", ".ai-memory/ambiguity/"),
    (".ai-memory/ambiguous-questions.md", ".ai-memory/ambiguity/README.md"),
    (".ai-memory/question-and-ambiguity/", ".ai-memory/ambiguity/resolved/"),
    ("ambiguous-questions/01-new-ambiguity/", "ambiguity/new/"),
    ("ambiguous-questions/02-ambiguity-resolved/", "ambiguity/resolved/"),
    (".ai-memory/01-new-ambiguity/", ".ai-memory/ambiguity/new/"),
    (".ai-memory/02-ambiguity-resolved/", ".ai-memory/ambiguity/resolved/"),
    ("01-new-ambiguity/", "ambiguity/new/"),
    ("02-ambiguity-resolved/", "ambiguity/resolved/"),
    ("question-and-ambiguity/", "ambiguity/"),

    # RCA and Issues
    (".ai-memory/pending-issues/", ".ai-memory/rca/new/"),
    (".ai-memory/solved-issues/", ".ai-memory/rca/resolved/"),
    (".ai-memory/resolved-issues/", ".ai-memory/rca/resolved/"),
    (".ai-memory/cicd-issues/", ".ai-memory/rca/resolved/"),
    (".ai-memory/issues/", ".ai-memory/rca/resolved/"),
    ("cicd-issues/", "rca/resolved/"),

    # Memory and Learned
    (".ai-memory/memory/learned/", ".ai-memory/learned/"),
    (".ai-memory/learned/learned/", ".ai-memory/learned/"),
    (".ai-memory/learn-memory/", ".ai-memory/learned/"),
    (".ai-memory/memories/", ".ai-memory/learned/"),
    (".ai-memory/memory/", ".ai-memory/learned/"),

    # AI Memory Root Files
    (".ai-memory/suggestions.md", ".ai-memory/plans/suggestions/01-legacy-suggestions.md"),
    (".ai-memory/01-index.md", ".ai-memory/what-to-read.md"),
    (".ai-memory/overview.md", ".ai-memory/what-to-read.md"),
    (".ai-memory/cicd-index.md", ".ai-memory/rca/README.md"),
    (".ai-memory/cicd-timing.json", ".ai-memory/rca/resolved/"),
    (".ai-memory/prompt.md", "01-prompts/README.md"),
    (".ai-memory/prompts.md", "01-prompts/README.md"),
    (".ai-memory/plan.md", ".ai-memory/plans/readme.md"),
]

TARGET_DIRS = [
    "02-spec",
    "01-prompts",
    ".agents/skills",
    ".cursor/skills",
    ".agents/rules",
    ".ai-memory",
]

IGNORE_DIRS = {
    ".git",
    "node_modules",
    "bin",
    "build",
    "dist",
    "temp",
    "temp-agents",
}


def process_file(file_path: str, dry_run: bool) -> Tuple[int, int]:
    """Process a single file, applying all mapping rules. Returns (hit_count, rule_count)."""
    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {file_path}: {e}", file=sys.stderr)
        return (0, 0)

    original = content
    total_hits = 0
    rules_applied = 0

    for old_path, new_path in MAPPING_RULES:
        if old_path in content:
            count = content.count(old_path)
            content = content.replace(old_path, new_path)
            total_hits += count
            rules_applied += 1

    if total_hits > 0 and not dry_run:
        # Enforce UNIX LF line endings
        content = content.replace("\r\n", "\n").replace("\r", "\n")
        with open(file_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(content)

    return (total_hits, rules_applied)


def run_remapping(root_path: str, dry_run: bool = False) -> None:
    print(f"=== Starting Legacy Path Remapping (Dry Run: {dry_run}) ===")
    overall_hits = 0
    overall_files_changed = 0
    dir_stats: Dict[str, Dict[str, int]] = {}

    for target in TARGET_DIRS:
        target_full = os.path.join(root_path, target)
        if not os.path.exists(target_full):
            continue

        dir_stats[target] = {"scanned": 0, "changed": 0, "hits": 0}

        for root, dirs, files in os.walk(target_full):
            # Prune ignored directories
            dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]

            for file in files:
                if not file.endswith((".md", ".txt", ".json", ".yaml", ".yml")):
                    continue

                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(file_path, root_path).replace("\\", "/")

                # Exclude the architecture spec and plan for 515 itself from mutating its own reference tables
                if "515-folder-structure-and-coding-guideline-update" in rel_path and "01-architecture-spec.md" in rel_path:
                    continue
                if "515-folder-structure-and-coding-guideline-update.md" in rel_path:
                    continue

                dir_stats[target]["scanned"] += 1
                hits, _ = process_file(file_path, dry_run)
                if hits > 0:
                    dir_stats[target]["changed"] += 1
                    dir_stats[target]["hits"] += hits
                    overall_hits += hits
                    overall_files_changed += 1

    print("\nDirectory Breakdown:")
    print("-" * 65)
    print(f"{'Directory':<25} | {'Scanned':<8} | {'Modified':<8} | {'Hits':<8}")
    print("-" * 65)
    for target, stat in dir_stats.items():
        print(f"{target:<25} | {stat['scanned']:<8} | {stat['changed']:<8} | {stat['hits']:<8}")
    print("-" * 65)
    print(f"Total: {overall_files_changed} files updated with {overall_hits} replacements.")
    print("=== Path Remapping Complete ===")


def main():
    parser = argparse.ArgumentParser(description="Remap legacy AI memory paths")
    parser.add_argument("--dry-run", action="store_true", help="Report matches without modifying files")
    parser.add_argument("--path", default=".", help="Root repository path (default: current directory)")
    args = parser.parse_args()

    run_remapping(args.path, args.dry_run)


if __name__ == "__main__":
    main()
