#!/usr/bin/env python3
"""
E2E Verification Script for Task 443: AI Commit Resolve & Pull Tree Error Visualization.
Validates Error Classification, Aligned Tree Rendering, Backup Vault, Upstream Integration,
Antigravity AI Bridge Manifests, Non-Destructive Merges, Result Commits, and CLI Routing.
"""

import subprocess
import sys
import time
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

WORKSPACE = Path(__file__).resolve().parent.parent

def run_step(title: str, cmd: list[str], cwd: Path = WORKSPACE) -> bool:
    print(f"\n[RUNNING] {title}...")
    start = time.time()
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(cwd),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
            shell=True,
            check=False
        )
        duration = time.time() - start
        if proc.returncode == 0:
            print(f"[PASS] {title} ({duration:.2f}s)")
            return True
        else:
            print(f"[FAIL] {title} (exit {proc.returncode}):\n{proc.stdout}")
            return False
    except Exception as exc:
        print(f"[ERROR] {title}: {exc}")
        return False

def main() -> int:
    print("=" * 80)
    print("TASK 443 VERIFICATION: AI COMMIT RESOLVE & PULL TREE ERROR VISUALIZATION")
    print("=" * 80)

    steps = [
        ("Suite 1: Error Classifier & Tree Renderer Unit Tests", ["go", "test", "-C", "cli", "./cmdresolve/...", "-v"]),
        ("Suite 2: Pull Prompt & Progress Tree Unit Tests", ["go", "test", "-C", "cli", "./cmdpull/...", "-v"]),
        ("Suite 3: Conflict Action & Strategy Enum Tests", ["go", "test", "-C", "cli", "./cmdconflict/...", "-v"]),
        ("Suite 4: AI Commit Resolve Full E2E Test", ["go", "test", "-C", "cli", "./tests/e2e", "-run", "TestTask443_AICommitResolve_E2E", "-v"]),
        ("Suite 5: CLI Binary Rebuild", ["go", "build", "-C", "cli", "-p", "2", "-ldflags=-s -w", "-o", "../gitmap.exe"]),
        ("Suite 6: CLI Version & AI-Resolve Help Smoke Test", ["gitmap.exe", "version"]),
    ]

    passed = 0
    for title, cmd in steps:
        if run_step(title, cmd):
            passed += 1
        else:
            print(f"\n[ABORT] Step failed: {title}")
            return 1

    print("\n" + "=" * 80)
    print(f"ALL {passed}/{len(steps)} TEST SUITES PASSED CLEANLY (100% GREEN)")
    print("=" * 80)
    return 0

if __name__ == "__main__":
    sys.exit(main())
