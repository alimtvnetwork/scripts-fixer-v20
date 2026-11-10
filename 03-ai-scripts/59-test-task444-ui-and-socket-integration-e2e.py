#!/usr/bin/env python3
"""
E2E Verification Script for Task 444: UI and Integration Feature Enhancements
Verifies:
1. Split-DB Repo Conflict Store (root_conflicts.db & <slug>/conflict.db)
2. Socket Communication Server (Handshake JSON, repos.list, conflicts, dispatch)
3. Web UI PA Dual Progress Bars & Conflict Resolution Endpoints
4. Auth Session Memory & Admin Remember Toggle
5. MCP Socket & Conflict Tool Registration
6. Binary compilation with -p 2 -ldflags="-s -w"
"""

import os
import sys
import subprocess
import time
import json

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
CLI_DIR = os.path.join(REPO_ROOT, "cli")

def run_step(title, cmd, cwd=REPO_ROOT):
    print(f"\n================================================================================")
    print(f"▶ RUNNING: {title}")
    print(f"  Command: {' '.join(cmd)}")
    print(f"================================================================================")
    start = time.time()
    res = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    duration = time.time() - start
    print(res.stdout)
    if res.stderr:
        print("STDERR:")
        print(res.stderr)
    if res.returncode != 0:
        print(f"❌ FAILED: {title} (exit code: {res.returncode}, duration: {duration:.2f}s)")
        return False
    print(f"✓ PASSED: {title} (duration: {duration:.2f}s)")
    return True

def main():
    print("⚡ Starting E2E Verification for Task 444...")
    suites = [
        ("Suite 1: Split-DB Conflict Store Unit Tests", ["go", "test", "-C", "cli", "./store/conflictstore/...", "-v"]),
        ("Suite 2: Socket Server & Handshake Unit Tests", ["go", "test", "-C", "cli", "./cmdsocket/...", "-v"]),
        ("Suite 3: Web UI PA & Conflict Endpoints", ["go", "test", "-C", "cli", "./cmdui/...", "-run=TestPARoutes", "-v"]),
        ("Suite 4: Auth Session Memory & Admin Toggle", ["go", "test", "-C", "cli", "./rbac/...", "-run=TestSessionManager", "-v"]),
        ("Suite 5: Web UI Auth Session Endpoint", ["go", "test", "-C", "cli", "./cmdui/...", "-run=TestAPISessionEndpoints", "-v"]),
        ("Suite 6: MCP Socket & Conflict Tools", ["go", "test", "-C", "cli", "./cmdmcp/...", "-run=TestMCPSocketAndConflictTools", "-v"]),
        ("Suite 7: RBAC Role Management CLI Unit Tests", ["go", "test", "-C", "cli", "./cmdrole/...", "-v"]),
        ("Suite 8: Production Binary Compilation", ["go", "build", "-C", "cli", "-p", "2", "-ldflags=-s -w", "-o", "../gitmap.exe"]),
    ]

    for title, cmd in suites:
        ok = run_step(title, cmd)
        if not ok:
            print("\n❌ Verification FAILED at step:", title)
            sys.exit(1)

    print("\n🎉 ALL SUITES PASSED! Task 444 verification completed with 100% green integrity.")

if __name__ == "__main__":
    main()
