#!/usr/bin/env python3
"""
53-skill-frontmatter-validator.py - Automated Skill Frontmatter Validator & Linter

Validates YAML frontmatter across all Antigravity (.agents/skills) and Cursor
(.cursor/skills) skill definitions to prevent malformed skill files from breaking
agent parsing or skill indexing.

Enforces:
1. Line 1 must be '---' frontmatter fence.
2. A closing '---' fence exists.
3. Frontmatter parses as valid YAML.
4. Non-empty 'name:' and 'description:' fields are present.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from enum import Enum
from importlib import import_module
import os
from pathlib import Path
import sys
from typing import Any, Sequence

# Set output encoding to UTF-8
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

# DRY import from 02-shared-engine.py
sys.path.insert(0, str(Path(__file__).resolve().parent))
engine = import_module("02-shared-engine")

ExitCodeType = engine.ExitCodeType
DEFAULT_ENCODING = engine.DEFAULT_ENCODING

try:
    import yaml
    IS_YAML_AVAILABLE = True
except ImportError:
    yaml = None
    IS_YAML_AVAILABLE = False


class ValidationStatusType(str, Enum):
    """Enumeration for skill validation status codes."""
    VALID = "VALID"
    INVALID = "INVALID"
    FIXED = "FIXED"


@dataclass
class ValidationResult:
    """Outcome of skill frontmatter validation."""
    file_path: Path
    is_valid: bool
    failure_reason: str = ""


def get_repo_root() -> Path:
    """Returns canonical repository root path."""
    return Path(__file__).resolve().parent.parent


def get_default_scan_dirs(repo_root: Path) -> list[Path]:
    """Returns standard skill directories in repository."""
    candidate_dirs = [
        repo_root / ".agents" / "skills",
        repo_root / ".cursor" / "skills",
    ]

    return [p for p in candidate_dirs if p.exists()]


def find_closing_fence(lines: list[str]) -> int:
    """Finds line index of closing frontmatter fence."""
    for index, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            return index

    return -1


def extract_frontmatter(content: str) -> tuple[str, str, str]:
    """Extracts frontmatter text and remaining content or failure reason."""
    lines = content.splitlines(keepends=True)

    if not lines:
        return "", "", "File is empty"

    if lines[0].strip() != "---":
        return "", "", "Line 1 must be '---' frontmatter fence"

    closing_index = find_closing_fence(lines)

    if closing_index == -1:
        return "", "", "Missing closing '---' frontmatter fence"

    fm_text = "".join(lines[1:closing_index])
    body_text = "".join(lines[closing_index + 1:])

    return fm_text, body_text, ""


def parse_frontmatter_yaml(fm_text: str) -> tuple[dict[str, Any] | None, str]:
    """Parses frontmatter string as YAML using PyYAML."""
    try:
        parsed = yaml.safe_load(fm_text)
        return parsed, ""
    except Exception as exc:
        return None, f"YAML parse error: {exc}"


def parse_frontmatter_fallback(fm_text: str) -> tuple[dict[str, str], str]:
    """Fallback frontmatter parser when PyYAML is unavailable."""
    data: dict[str, str] = {}
    for line in fm_text.splitlines():
        trimmed = line.strip()

        if trimmed.startswith("name:"):
            data["name"] = trimmed[5:].strip().strip("\"'")
        elif trimmed.startswith("description:"):
            data["description"] = trimmed[12:].strip().strip("\"'")

    return data, ""


def parse_frontmatter(fm_text: str) -> tuple[Any, str]:
    """Dispatches frontmatter parsing to PyYAML or fallback parser."""
    if IS_YAML_AVAILABLE:
        return parse_frontmatter_yaml(fm_text)

    return parse_frontmatter_fallback(fm_text)


def validate_frontmatter_dict(data: Any) -> str:
    """Validates that parsed YAML frontmatter contains required non-empty fields."""
    if not isinstance(data, dict):
        return "Frontmatter does not evaluate to a YAML dictionary mapping"

    name_value = str(data.get("name", "")).strip()

    if not name_value:
        return "Missing or empty 'name:' field in frontmatter"

    desc_value = str(data.get("description", "")).strip()

    if not desc_value:
        return "Missing or empty 'description:' field in frontmatter"

    return ""


def validate_skill_file(file_path: Path) -> ValidationResult:
    """Validates frontmatter structure and mandatory fields for a skill file."""
    try:
        content = file_path.read_text(encoding=DEFAULT_ENCODING, errors="ignore")
    except Exception as exc:
        return ValidationResult(file_path, is_valid=False, failure_reason=f"Read error: {exc}")

    fm_text, _, extract_err = extract_frontmatter(content)

    if extract_err:
        return ValidationResult(file_path, is_valid=False, failure_reason=extract_err)

    parsed_data, parse_err = parse_frontmatter(fm_text)

    if parse_err:
        return ValidationResult(file_path, is_valid=False, failure_reason=parse_err)

    field_err = validate_frontmatter_dict(parsed_data)

    if field_err:
        return ValidationResult(file_path, is_valid=False, failure_reason=field_err)

    return ValidationResult(file_path, is_valid=True)


def sanitize_description_field(val: str) -> str:
    """Escapes internal quotes and produces safe quoted description."""
    stripped = val.strip()

    if (stripped.startswith('"') and stripped.endswith('"')) or (stripped.startswith("'") and stripped.endswith("'")):
        stripped = stripped[1:-1].strip()

    escaped = stripped.replace('\\', '\\\\').replace('"', '\\"')

    return f'"{escaped}"'


def fix_frontmatter_lines(lines: list[str]) -> tuple[list[str], bool]:
    """Normalizes description field in frontmatter lines."""
    has_modified = False
    new_lines: list[str] = []
    for line in lines:
        trimmed = line.strip()

        if not trimmed.startswith("description:"):
            new_lines.append(line)
            continue

        raw_val = trimmed[len("description:"):].strip()

        if raw_val in (">", ">-", "|", "|-"):
            new_lines.append(line)
            continue

        formatted_val = sanitize_description_field(raw_val)
        new_line = f"description: {formatted_val}"
        new_lines.append(new_line)
        has_modified = bool(has_modified or (new_line != trimmed))

    return new_lines, has_modified


def write_fixed_skill_file(file_path: Path, new_lines: list[str], body_text: str) -> bool:
    """Writes sanitized frontmatter and body back to skill file."""
    candidate_fm = "\n".join(new_lines) + "\n"

    if IS_YAML_AVAILABLE:
        try:
            yaml.safe_load(candidate_fm)
        except Exception:
            return False

    new_content = f"---{engine.LINE_SEPARATOR}{candidate_fm}---{engine.LINE_SEPARATOR}{body_text}"
    try:
        file_path.write_text(new_content, encoding=DEFAULT_ENCODING, newline="\n")
        return True
    except Exception:
        return False


def try_fix_skill_file(file_path: Path) -> bool:
    """Attempts to automatically repair malformed skill frontmatter."""
    try:
        content = file_path.read_text(encoding=DEFAULT_ENCODING, errors="ignore")
    except Exception:
        return False

    fm_text, body_text, extract_err = extract_frontmatter(content)

    if extract_err:
        return False

    new_lines, has_modified = fix_frontmatter_lines(fm_text.splitlines())

    if not has_modified:
        return False

    return write_fixed_skill_file(file_path, new_lines, body_text)


def collect_skill_files(target_paths: Sequence[Path]) -> list[Path]:
    """Recursively locates all skill.md and SKILL.md files under target paths."""
    discovered: list[Path] = []
    for target in target_paths:
        if target.is_file() and target.name.lower() == "skill.md":
            discovered.append(target)
            continue

        if not target.is_dir():
            continue

        for root_dir, _, filenames in os.walk(target):
            for filename in filenames:
                if filename.lower() == "skill.md":
                    discovered.append(Path(root_dir) / filename)

    return sorted(discovered)


def format_relative_path(path: Path, repo_root: Path) -> str:
    """Returns normalized relative path string from repository root."""
    try:
        return str(path.relative_to(repo_root)).replace("\\", "/")
    except ValueError:
        return str(path).replace("\\", "/")


def emit_verbose_pass(rel_path: str, is_verbose: bool) -> None:
    """Prints verbose pass notification when verbose flag is set."""
    if is_verbose:
        print(f"[PASS] {rel_path}")


def attempt_fix_and_validate(file_path: Path, rel_path: str) -> bool:
    """Attempts autofix and verifies resolution."""
    has_fixed = try_fix_skill_file(file_path)

    if not has_fixed:
        return False

    is_resolved = validate_skill_file(file_path).is_valid

    if is_resolved:
        print(f"[FIXED] {rel_path}")

    return is_resolved


def process_single_skill(
    file_path: Path,
    repo_root: Path,
    is_fix_enabled: bool,
    is_verbose: bool,
) -> tuple[bool, str]:
    """Validates or fixes single skill file and returns status."""
    rel_path = format_relative_path(file_path, repo_root)
    result = validate_skill_file(file_path)

    if result.is_valid:
        emit_verbose_pass(rel_path, is_verbose)
        return True, ""

    if is_fix_enabled and attempt_fix_and_validate(file_path, rel_path):
        return True, ""

    error_msg = f"[FAIL] {rel_path}: {result.failure_reason}"
    print(error_msg, file=sys.stderr)

    return False, error_msg


def run_validation(
    skill_files: list[Path],
    repo_root: Path,
    is_fix_enabled: bool,
    is_verbose: bool,
) -> int:
    """Runs validation loop across all discovered skill files."""
    has_failures = False
    passed_count = 0

    for file_path in skill_files:
        is_ok, _ = process_single_skill(file_path, repo_root, is_fix_enabled, is_verbose)

        if is_ok:
            passed_count += 1
        else:
            has_failures = True

    total_count = len(skill_files)

    if has_failures:
        print(f"\n[ERROR] Frontmatter validation failed: {passed_count}/{total_count} passed.", file=sys.stderr)
        return int(ExitCodeType.VIOLATIONS_FOUND)

    print(f"[SUCCESS] Validated {total_count} skill files across scanned directories (0 violations).")

    return int(ExitCodeType.SUCCESS)


def parse_cli_arguments() -> argparse.Namespace:
    """Parses command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Validates YAML frontmatter across all Antigravity and Cursor skill files.",
    )
    parser.add_argument(
        "paths",
        nargs="*",
        type=Path,
        help="Optional paths or directories to scan (defaults to .agents/skills and .cursor/skills).",
    )
    parser.add_argument(
        "--fix",
        action="store_true",
        dest="is_fix_enabled",
        help="Automatically fix common frontmatter syntax and quoting issues.",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        dest="is_verbose",
        help="Print verbose validation status for every skill file.",
    )

    return parser.parse_args()


def main() -> int:
    """Main CLI entrypoint."""
    args = parse_cli_arguments()
    repo_root = get_repo_root()
    target_paths = args.paths

    if not target_paths:
        target_paths = get_default_scan_dirs(repo_root)

    skill_files = collect_skill_files(target_paths)

    if not skill_files:
        print("[WARN] No skill.md or SKILL.md files found in specified directories.")
        return int(ExitCodeType.SUCCESS)

    return run_validation(
        skill_files,
        repo_root,
        is_fix_enabled=args.is_fix_enabled,
        is_verbose=args.is_verbose,
    )


if __name__ == "__main__":
    sys.exit(main())
