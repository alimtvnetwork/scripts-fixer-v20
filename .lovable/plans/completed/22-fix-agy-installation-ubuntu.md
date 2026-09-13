# Plan 22: Fix Antigravity (agy) Installation on Ubuntu and Windows

> **Prompt Version:** 2.2.0
> **Orchestration:** Multi-Agent Continuous N-Step Loop (N = 100)
> **Main Task Origin:** User reported failure during `./run install agy` and `./run install antigravity` on Ubuntu: `mv: cannot stat '/tmp/.../agy': No such file or directory`.
> **Completion Status:** Completed & Verified (All tests passed with exit code 0).
> **Date Completed:** 2026-09-13

---

## Root Cause Analysis (RCA)

1. **Binary Name Discrepancy**: The official `agy_cli_linux_x64.tar.gz` release archive unpacks a binary named `antigravity`, not `agy`. `scripts/os/ubuntu/install-antigravity.sh` previously ran `mv "$TMP_DIR/agy" "$INSTALL_DIR/agy"`, crashing with `No such file or directory`.
2. **Windows run.ps1 Discrepancy**: `scripts/69-install-antigravity/run.ps1` previously had the same issue, expecting `agy.exe` inside `agy_cli_windows_x64.zip` when the release asset actually contains `antigravity.exe`.
3. **Architecture & Rate-Limit Hardening**: Previous GitHub API curl lacked fallback URLs and dynamic `arm64`/`x64` resolution.

---

## Changes Implemented

1. **Ubuntu Installer (`scripts/os/ubuntu/install-antigravity.sh`)**:
   - Added CPU architecture detection (`x64` for `x86_64`/`amd64`, `arm64` for `aarch64`/`arm64`).
   - Added direct GitHub release URL fallback (`https://github.com/google-antigravity/antigravity-cli/releases/latest/download/...`) to prevent GitHub API rate-limit errors.
   - Extracted archive and moved `antigravity` to `$HOME/.antigravity/bin/antigravity`.
   - Created dual symlinks for `agy` -> `antigravity` in both `$HOME/.antigravity/bin/` and `$HOME/.local/bin/`.
   - Exported PATH in `~/.bashrc`, `~/.zshrc`, and `~/.profile`.
   - Updated binary verification to check both `antigravity` and `agy`.

2. **Windows Installer (`scripts/69-install-antigravity/run.ps1`)**:
   - Handled `antigravity.exe` and `agy.exe` extraction.
   - Copied both `antigravity.exe` and `agy.exe` into `$env:USERPROFILE\.antigravity\bin`.
   - Added API fallback URL and PATH registration.

3. **Linux Root Runner (`scripts/run.sh`)**:
   - Switched post-install logging and profile tree calls to use `$PYTHON_BIN` with safe failure guards.

---

## Verification Summary

- `bash -n scripts/os/ubuntu/install-antigravity.sh`: Pass (exit 0)
- `bash scripts/os/ubuntu/install-antigravity.sh`: Pass (exit 0, downloaded, extracted, symlinked, verified)
- `bash scripts/run.sh install agy`: Pass (exit 0, installation summary logged)
- `bash scripts/run.sh install antigravity`: Pass (exit 0, installation summary logged)
