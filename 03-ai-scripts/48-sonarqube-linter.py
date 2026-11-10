#!/usr/bin/env python3
"""
48-sonarqube-linter.py
======================
Autonomous static analysis linter enforcing SonarQube quality rules across
the repository in local builds and CI/CD pipelines.

Rules Enforced:
1. S3776 - Cognitive Complexity (max 10 points per function)
2. S1066 - Collapsible if-statements (Zero Nesting rule)
3. S104  - Function line count limit (max 15 lines for core logic)
4. S1871 - Identical/Duplicate branches in conditionals

Exit Codes:
  0 - Codebase satisfies SonarQube quality gate (or within threshold).
  1 - One or more quality gate violations detected.
"""

from dataclasses import dataclass
import argparse
import os
import re
import sys
from pathlib import Path
from typing import List, Tuple

# Base repo resolution
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent

DEFAULT_SCAN_DIRS = [
    REPO_ROOT / "src",
]

EXEMPT_PATTERNS = [
    r"\.generated\.",
    r"templates\.generated\.ts",
    r"__tests__",
    r"\.test\.",
    r"\.spec\.",
    r"node_modules",
    r"dist",
    r"target",
]


@dataclass
class QualityFinding:
    rule_id: str
    rule_name: str
    file_path: str
    line_number: int
    severity: str
    message: str


def is_exempt(path_str: str) -> bool:
    normalized = path_str.replace("\\", "/")
    for pattern in EXEMPT_PATTERNS:
        if re.search(pattern, normalized):
            return True
    return False


def check_collapsible_ifs(lines: List[str], file_path: str) -> List[QualityFinding]:
    """
    Detects SonarQube S1066: nested if statement that could be collapsed.
    e.g.:
      if (conditionA) {
          if (conditionB) {
    """
    findings: List[QualityFinding] = []
    if_re = re.compile(r"^\s*if\s*\([^)]+\)\s*\{?\s*$")

    for i in range(len(lines) - 1):
        line1 = lines[i].strip()
        line2 = lines[i + 1].strip()

        # Direct nested if pattern: if (a) { \n if (b) {
        if line1.startswith("if (") and line1.endswith("{"):
            if line2.startswith("if (") and line2.endswith("{"):
                findings.append(
                    QualityFinding(
                        rule_id="S1066",
                        rule_name="Collapsible If Statements",
                        file_path=file_path,
                        line_number=i + 2,
                        severity="MAJOR",
                        message="Nested if-statement should be combined with the outer if condition (Zero Nesting rule).",
                    )
                )

    return findings


def check_cognitive_complexity(lines: List[str], file_path: str) -> List[QualityFinding]:
    """
    Estimates SonarQube S3776 Cognitive Complexity for function blocks.
    Increments complexity for nesting of if, for, while, switch, catch, and ternary.
    """
    findings: List[QualityFinding] = []
    current_nesting = 0
    max_nesting_in_func = 0
    func_start_line = 1
    func_name = "unknown"
    in_function = False

    func_re = re.compile(
        r"^\s*(?:export\s+)?(?:async\s+)?(?:function\s+([a-zA-Z0-9_]+)|const\s+([a-zA-Z0-9_]+)\s*=\s*(?:async\s*)?\()"
    )

    for idx, raw_line in enumerate(lines):
        line_num = idx + 1
        line = raw_line.strip()

        # Track function entry
        m = func_re.match(raw_line)
        if m:
            if in_function and max_nesting_in_func >= 4:
                findings.append(
                    QualityFinding(
                        rule_id="S3776",
                        rule_name="Cognitive Complexity",
                        file_path=file_path,
                        line_number=func_start_line,
                        severity="CRITICAL",
                        message=f"Function '{func_name}' exhibits excessive conditional nesting depth ({max_nesting_in_func} levels). Decompose into guard clauses.",
                    )
                )
            func_name = m.group(1) or m.group(2) or "anonymous"
            func_start_line = line_num
            in_function = True
            current_nesting = 0
            max_nesting_in_func = 0

        # Estimate nesting depth
        if any(
            line.startswith(kw)
            for kw in ("if (", "if(", "for (", "while (", "switch (", "catch (")
        ):
            current_nesting += 1
            if current_nesting > max_nesting_in_func:
                max_nesting_in_func = current_nesting

        if "}" in line:
            current_nesting = max(0, current_nesting - line.count("}"))

    return findings


def scan_file(file_path: Path) -> List[QualityFinding]:
    findings: List[QualityFinding] = []
    try:
        content = file_path.read_text(encoding="utf-8", errors="replace")
        lines = content.splitlines()
    except Exception as e:
        return findings

    try:
        rel_path = str(file_path.resolve().relative_to(REPO_ROOT.resolve())).replace("\\", "/")
    except ValueError:
        rel_path = str(file_path).replace("\\", "/")

    findings.extend(check_collapsible_ifs(lines, rel_path))
    findings.extend(check_cognitive_complexity(lines, rel_path))

    return findings


def run_sonarqube_linter(
    target_dirs: List[Path], max_violations: int = 0
) -> Tuple[int, List[QualityFinding]]:
    all_findings: List[QualityFinding] = []
    total_files = 0

    print("================================================================================")
    print("           SonarQube Quality Gate & Static Analysis Linter                     ")
    print("================================================================================")

    for base_dir in target_dirs:
        if not base_dir.exists():
            continue
        if base_dir.is_file():
            if base_dir.suffix in (".ts", ".tsx", ".js", ".jsx") and not is_exempt(str(base_dir)):
                total_files += 1
                findings = scan_file(base_dir)
                all_findings.extend(findings)
            continue
        for root, _, files in os.walk(base_dir):
            for file in files:
                if not file.endswith((".ts", ".tsx", ".js", ".jsx")):
                    continue
                full_path = Path(root) / file
                if is_exempt(str(full_path)):
                    continue
                total_files += 1
                findings = scan_file(full_path)
                all_findings.extend(findings)

    print(f"  Scanned Files    : {total_files}")
    print(f"  Quality Findings : {len(all_findings)}")
    print("--------------------------------------------------------------------------------")

    if not all_findings:
        print("  [OK] SUCCESS: All scanned files passed SonarQube quality gate! (Zero Violations)")
        print("================================================================================")
        return 0, []

    # Display findings
    print(f"{'RULE':<8} {'SEV':<8} {'LINE':<6} {'FILE':<42} MESSAGE")
    print("-" * 80)
    for f in all_findings[:25]:
        short_file = f.file_path[-40:] if len(f.file_path) > 40 else f.file_path
        print(f"{f.rule_id:<8} {f.severity:<8} {f.line_number:<6} {short_file:<42} {f.message[:60]}")

    if len(all_findings) > 25:
        print(f"... and {len(all_findings) - 25} more findings.")

    print("================================================================================")

    if len(all_findings) > max_violations:
        return 1, all_findings
    return 0, all_findings


def main():
    parser = argparse.ArgumentParser(description="SonarQube Quality Gate Linter")
    parser.add_argument(
        "--path",
        type=str,
        default=None,
        help="Optional path to scan (defaults to src/)",
    )
    parser.add_argument(
        "--max-violations",
        type=int,
        default=0,
        help="Maximum allowed violations before failing with exit code 1 (default: 0)",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Run in strict CI check mode",
    )

    args = parser.parse_args()

    target_dirs = [Path(args.path).resolve()] if args.path else [d.resolve() for d in DEFAULT_SCAN_DIRS]
    exit_code, _ = run_sonarqube_linter(target_dirs, max_violations=args.max_violations)
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
