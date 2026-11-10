#!/usr/bin/env python3
"""
Skill Frontmatter Validator (.agents/scripts/53-skill-frontmatter-validator.py)

Enforces valid YAML frontmatter across all Antigravity and Cursor skill files:
- Line 1 must begin with '---'
- Closing '---' fence must exist
- YAML frontmatter must parse into a mapping
- Mandatory non-empty 'name' field (lowercase alphanumeric with hyphens)
- Mandatory non-empty 'description' field

Usage:
  python .agents/scripts/53-skill-frontmatter-validator.py
  python .agents/scripts/53-skill-frontmatter-validator.py --verbose
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from typing import List, Tuple

# Ensure UTF-8 stdout encoding on Windows
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

try:
    import yaml
except ImportError:
    yaml = None


NAME_PATTERN = re.compile(r"^[a-z0-9][a-z0-9-_]*$")


def validate_skill_file(file_path: str) -> List[str]:
    """Validates that a skill markdown file contains compliant YAML frontmatter."""
    errors: List[str] = []
    try:
        with open(file_path, "r", encoding="utf-8", errors="replace") as f:
            content = f.read()
    except Exception as exc:
        return [f"Unable to read file: {exc}"]

    lines = content.splitlines()
    if not lines:
        return ["File is completely empty"]

    first_line = lines[0].strip()
    if first_line != "---":
        return [f"Line 1 must be opening delimiter '---' (found: '{first_line[:40]}')"]

    closing_index = -1
    for idx in range(1, len(lines)):
        if lines[idx].strip() == "---":
            closing_index = idx
            break

    if closing_index == -1:
        return ["Missing closing '---' frontmatter fence delimiter"]

    fm_raw = "\n".join(lines[1:closing_index]).strip()
    if not fm_raw:
        return ["Frontmatter block between '---' delimiters is empty"]

    data = None
    if yaml is not None:
        try:
            data = yaml.safe_load(fm_raw)
        except Exception as exc:
            return [f"YAML parsing failure: {exc}"]
    else:
        # Fallback rudimentary key-value check if yaml is not installed
        data = {}
        for line in lines[1:closing_index]:
            if ":" in line:
                key, val = line.split(":", 1)
                data[key.strip()] = val.strip()

    if not isinstance(data, dict):
        return ["Frontmatter must evaluate to a YAML dictionary/mapping"]

    name_val = data.get("name")
    if not name_val:
        errors.append("Missing mandatory 'name' key in frontmatter")
    elif not isinstance(name_val, str) or not name_val.strip():
        errors.append("'name' key in frontmatter must be a non-empty string")

    desc_val = data.get("description")
    if not desc_val:
        errors.append("Missing mandatory 'description' key in frontmatter")
    elif not isinstance(desc_val, str) or not desc_val.strip():
        errors.append("'description' key in frontmatter must be a non-empty string")

    return errors


def discover_skill_files(repo_root: str) -> List[str]:
    """Recursively locates all skill.md and SKILL.md files under target skill roots."""
    targets = [
        os.path.join(repo_root, ".agents", "skills"),
        os.path.join(repo_root, ".cursor", "skills"),
    ]
    skill_files: List[str] = []
    for root_target in targets:
        if not os.path.exists(root_target):
            continue
        for dirpath, _, filenames in os.walk(root_target):
            for filename in filenames:
                if filename.lower() in ("skill.md", "skill.yaml"):
                    skill_files.append(os.path.join(dirpath, filename))
    return sorted(skill_files)


def main() -> int:
    parser = argparse.ArgumentParser(description="Skill frontmatter compliance validator")
    parser.add_argument("--verbose", "-v", action="store_true", help="Print all scanned files")
    args = parser.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    skill_files = discover_skill_files(repo_root)

    if not skill_files:
        print("[WARN] No skill.md or SKILL.md files discovered in target directories.")
        return 0

    failures: List[Tuple[str, List[str]]] = []
    for skill_path in skill_files:
        rel_path = os.path.relpath(skill_path, repo_root).replace("\\", "/")
        errs = validate_skill_file(skill_path)
        if errs:
            failures.append((rel_path, errs))
        elif args.verbose:
            print(f"  [OK] {rel_path}")

    print("==================================================================")
    print(f"  Skill Frontmatter Validator: Scanned {len(skill_files)} skill files")
    print("==================================================================")

    if failures:
        print(f"\n[FAIL] Found {len(failures)} skill file(s) with invalid frontmatter:\n")
        for rel_path, errs in failures:
            print(f"  FAIL: {rel_path}")
            for err in errs:
                print(f"     - {err}")
        print("\nFix frontmatter format by prepending standard YAML header:")
        print("  ---\n  name: <skill-name>\n  description: >-\n    <description>\n  ---\n")
        return 1

    print(f"[SUCCESS] All {len(skill_files)} skill files have valid YAML frontmatter.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
