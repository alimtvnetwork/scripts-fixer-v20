#!/usr/bin/env python3
"""E2E Test Suite for Database SQL Query Remediation & DB Path Surface.

Verifies:
1. 'gitmap dbsql master "SELECT RepoName, AbsolutePath FROM Repositories LIMIT 10;"'
   surfaces the resolved database path, suggests the closest matching table 'Repo',
   provides copy-paste command with 95% confidence, and never emits generic 'gitmap doctor'.
2. Missing column queries suggest the closest column and table schema PRAGMA inspection.
3. The suggested corrected query runs cleanly with exit code 0.
"""

import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")
sys.stderr.reconfigure(encoding="utf-8")

def run_cmd(cmd_list):
    proc = subprocess.run(cmd_list, capture_output=True, text=True, shell=True)
    return proc.returncode, proc.stdout, proc.stderr

def test_missing_table_remediation():
    print("[TEST 1] Missing table 'Repositories' remediation...")
    cmd = 'gitmap dbsql master "SELECT RepoName, AbsolutePath FROM Repositories LIMIT 10;"'
    code, stdout, stderr = run_cmd(cmd)
    combined = stdout + stderr

    assert "no such table: Repositories" in combined, f"Expected 'no such table: Repositories', got:\n{combined}"
    assert "execute query on" in combined, f"Expected DB path indicator 'execute query on', got:\n{combined}"
    assert "gitmap.db" in combined, f"Expected 'gitmap.db' in output, got:\n{combined}"
    assert 'gitmap dbsql master "SELECT RepoName, AbsolutePath FROM Repo LIMIT 10;"' in combined, f"Expected corrected command in output, got:\n{combined}"
    assert "Confidence: 95%" in combined, f"Expected 95% confidence, got:\n{combined}"
    assert "SELECT name FROM sqlite_master WHERE type='table';" in combined, f"Expected sqlite_master inspection suggestion, got:\n{combined}"
    assert "gitmap doctor" not in combined, f"Generic 'gitmap doctor' suggestion must NOT be present, got:\n{combined}"
    print("  ✓ Missing table correctly suggests 'Repo' with DB path and 95% confidence")

def test_missing_column_remediation():
    print("[TEST 2] Missing column 'RepName' remediation...")
    cmd = 'gitmap dbsql master "SELECT RepName, AbsolutePath FROM Repo LIMIT 10;"'
    code, stdout, stderr = run_cmd(cmd)
    combined = stdout + stderr

    assert "no such column: RepName" in combined, f"Expected 'no such column: RepName', got:\n{combined}"
    assert 'SELECT RepoName, AbsolutePath FROM Repo LIMIT 10;' in combined, f"Expected column correction 'RepoName', got:\n{combined}"
    assert "PRAGMA table_info(Repo);" in combined, f"Expected PRAGMA table_info inspection, got:\n{combined}"
    print("  ✓ Missing column correctly suggests 'RepoName' with PRAGMA inspection")

def test_suggested_query_execution():
    print("[TEST 3] Running suggested corrected query...")
    cmd = 'gitmap dbsql master "SELECT RepoName, AbsolutePath FROM Repo LIMIT 3;"'
    code, stdout, stderr = run_cmd(cmd)
    combined = stdout + stderr

    assert code == 0, f"Expected exit code 0, got {code}:\n{combined}"
    assert "RepoName" in combined and "AbsolutePath" in combined, f"Expected tabular output, got:\n{combined}"
    print("  ✓ Corrected query executed successfully with code 0")

def main():
    print("Starting Database SQL Query Remediation E2E Verification...")
    test_missing_table_remediation()
    test_missing_column_remediation()
    test_suggested_query_execution()
    print("\nALL 3 SUITES 100% GREEN - Database remediation and path verified!")

if __name__ == "__main__":
    main()
