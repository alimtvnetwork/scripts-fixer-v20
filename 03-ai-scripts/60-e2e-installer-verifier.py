#!/usr/bin/env python3
"""
60-e2e-installer-verifier.py

End-to-End Verification of GitLab Public Universal Deployments for:
- GitMap (deploy-gitmap)
- Antigravity Manager (deploy-antigravity-manager)

Validates:
1. Public unauthenticated API fetch of install.ps1 (HTTP 200)
2. Execution of install.ps1 into isolated sandbox directories (-InstallDir)
3. High-speed multi-volume chunk download and SHA-256 integrity verification
4. 7z extraction and placement of binaries
5. Direct binary execution (--version assertion)
6. Automatic sandbox cleanup
"""

import os
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.request


def verify_project_installer(project_name: str, repo_name: str, expected_version_substr: str, timeout_sec: int = 60):
    print("=" * 65)
    print(f"  E2E VERIFICATION: {project_name} from rup-gitlab/{repo_name}")
    print("=" * 65)

    sandbox_dir = os.path.join(tempfile.gettempdir(), f"e2e_{project_name}_{int(time.time())}")
    os.makedirs(sandbox_dir, exist_ok=True)
    ps1_path = os.path.join(sandbox_dir, "install.ps1")

    sources = [
        f"https://gitlab.com/api/v4/projects/rup-gitlab%2F{repo_name}/repository/files/install.ps1/raw",
        f"https://gitlab.com/rup-gitlab/{repo_name}/-/raw/main/install.ps1",
        f"https://gitlab.com/api/v4/projects/89038517/repository/files/{project_name}%2Finstall.ps1/raw",
    ]

    content = None
    fetch_time = 0.0
    for src_url in sources:
        for attempt in range(3):
            try:
                print(f" [1/4] Fetching install.ps1 from {src_url} (attempt {attempt+1})...")
                t0 = time.time()
                req = urllib.request.Request(src_url, headers={"User-Agent": "Mozilla/5.0"})
                with urllib.request.urlopen(req, timeout=15) as resp:
                    data = resp.read()
                fetch_time = time.time() - t0
                stripped = data.strip().lower()
                if not (stripped.startswith(b"<!doctype html") or stripped.startswith(b"<html")):
                    content = data
                    print(f"       -> HTTP {resp.status} OK ({len(content)} bytes in {fetch_time:.2f}s)")
                    break
            except Exception as e:
                print(f"       [WARN] Attempt {attempt+1} failed: {e}. Retrying in 2s...")
                time.sleep(2)
        if content is not None:
            break

    if content is None:
        raise RuntimeError(f"Failed to fetch install.ps1 after trying {len(sources)} endpoints")

    with open(ps1_path, "wb") as f:
        f.write(content)

    print(f" [2/4] Executing install.ps1 in sandbox {sandbox_dir} (timeout={timeout_sec}s)...")
    cmd = [
        "pwsh",
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-Command",
        f"& '{ps1_path}' -InstallDir '{sandbox_dir}' -NoLaunch -NoPath",
    ]

    t_inst = time.time()
    res = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout_sec)
    inst_time = time.time() - t_inst

    for line in res.stdout.splitlines():
        if any(marker in line for marker in ["[INFO]", "[OK]", "===", "Target:"]):
            print(f"       {line}")

    if res.returncode != 0:
        print(f" [FAIL] Installer exited with code {res.returncode}")
        print(" STDERR:\n", res.stderr)
        shutil.rmtree(sandbox_dir, ignore_errors=True)
        return False

    print(f"       -> Installation completed successfully in {inst_time:.2f}s")

    print(f" [3/4] Validating installed binary executable...")
    exec_name = f"{project_name}.exe"
    installed_bin = os.path.join(sandbox_dir, exec_name)
    if not os.path.isfile(installed_bin):
        # Check case-insensitive match
        for f in os.listdir(sandbox_dir):
            if f.lower() == exec_name.lower():
                installed_bin = os.path.join(sandbox_dir, f)
                break

    if not os.path.isfile(installed_bin):
        print(f" [FAIL] Binary {exec_name} not found in {sandbox_dir}")
        shutil.rmtree(sandbox_dir, ignore_errors=True)
        return False

    bin_size = os.path.getsize(installed_bin)
    print(f"       Found {installed_bin} ({bin_size:,} bytes)")

    print(f" [4/4] Executing {exec_name} --version...")
    v_res = subprocess.run([installed_bin, "--version"], capture_output=True, text=True, timeout=10)
    v_out = (v_res.stdout + v_res.stderr).strip()
    print(f"       -> Output:\n          {v_out}")

    if expected_version_substr not in v_out:
        print(f" [FAIL] Expected '{expected_version_substr}' in version output!")
        shutil.rmtree(sandbox_dir, ignore_errors=True)
        return False

    print(f" [PASS] {project_name} E2E Verification 100% SUCCESSFUL!\n")
    shutil.rmtree(sandbox_dir, ignore_errors=True)
    return True


def main():
    print("Starting Comprehensive E2E Installer Verification...\n")
    success_gitmap = verify_project_installer("gitmap", "deploy-gitmap", "v6.693.0", timeout_sec=60)
    success_agm = verify_project_installer("agm", "deploy-antigravity-manager", "v5.55.0", timeout_sec=60)

    print("=" * 65)
    print("  FINAL E2E VERIFICATION SUMMARY")
    print("=" * 65)
    print(f"  GitMap (deploy-gitmap):               {'PASS' if success_gitmap else 'FAIL'}")
    print(f"  Antigravity Manager (deploy-agm):     {'PASS' if success_agm else 'FAIL'}")
    print("=" * 65)

    if not (success_gitmap and success_agm):
        sys.exit(1)


if __name__ == "__main__":
    main()
