#!/usr/bin/env python3
"""
PowerShell Timeout Runner

Safely executes PowerShell commands with an explicit hard timeout,
proper environment variable inheritance, and no shell interpolation traps.
Writes commands to a temporary .ps1 script file before execution to prevent
command-line variable expansion ($var being evaluated before execution).
"""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
import time


def find_powershell_binary() -> str:
    """Finds pwsh (PowerShell 7+) or powershell (Windows PowerShell 5.1)."""
    pwsh = shutil.which("pwsh")
    if pwsh:
        return pwsh
    ps = shutil.which("powershell")
    if ps:
        return ps
    return "powershell.exe"


def run_pwsh_script(script_path: str, timeout: int = 15) -> int:
    """Runs a .ps1 script file with an explicit hard timeout."""
    pwsh_bin = find_powershell_binary()
    print(f"=== PowerShell Execution Guard ===")
    print(f"Engine:  {pwsh_bin}")
    print(f"Script:  {script_path}")
    print(f"Timeout: {timeout}s\n")

    cmd = [
        pwsh_bin,
        "-NoProfile",
        "-NonInteractive",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        script_path,
    ]

    start_time = time.time()
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )

        elapsed = time.time() - start_time
        print(f"--- Process Output ({elapsed:.2f}s) ---")
        if proc.stdout:
            print(proc.stdout.strip())
        if proc.stderr:
            print(f"[STDERR]\n{proc.stderr.strip()}", file=sys.stderr)

        print(f"\nExit Code: {proc.returncode}")
        return proc.returncode

    except subprocess.TimeoutExpired:
        elapsed = time.time() - start_time
        print(f"\n✗ TIMEOUT: Command exceeded {timeout}s hard limit (elapsed: {elapsed:.2f}s)", file=sys.stderr)
        return 124
    except Exception as e:
        print(f"\n✗ ERROR: Failed to execute process: {e}", file=sys.stderr)
        return 1


def run_pwsh_with_timeout(command: str, timeout: int = 15) -> int:
    """Writes command to a temporary .ps1 file and executes it via -File to avoid CLI quoting bugs."""
    temp_dir = tempfile.gettempdir()
    script_path = os.path.join(temp_dir, f"pwsh_runner_{os.getpid()}_{int(time.time()*1000)}.ps1")
    try:
        with open(script_path, "w", encoding="utf-8") as f:
            f.write(command + "\n")

        return run_pwsh_script(script_path, timeout=timeout)
    finally:
        if os.path.exists(script_path):
            try:
                os.remove(script_path)
            except OSError:
                pass


def main():
    parser = argparse.ArgumentParser(description="Run PowerShell script or command with enforced hard timeout")
    parser.add_argument("command", nargs="?", default="", help="PowerShell command string to execute")
    parser.add_argument("--file", "-f", default="", help="Path to existing .ps1 script file")
    parser.add_argument("--timeout", type=int, default=15, help="Timeout in seconds (default: 15)")
    args = parser.parse_args()

    if args.file:
        if not os.path.isfile(args.file):
            print(f"✗ File not found: {args.file}", file=sys.stderr)
            sys.exit(1)
        sys.exit(run_pwsh_script(args.file, timeout=args.timeout))

    if not args.command:
        parser.print_help()
        sys.exit(1)

    sys.exit(run_pwsh_with_timeout(args.command, args.timeout))


if __name__ == "__main__":
    main()
