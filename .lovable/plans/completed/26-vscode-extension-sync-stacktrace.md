# Completed Plan: 26-vscode-extension-sync-stacktrace.md

> **Parent Task Initiated:** 2026-09-14 11:25:36 (User reported missing error stacktrace and failed extensions `golang.Go`, `vscode.debug-auto-launch`, `vscode.emmet`, `ms-vscode-remote.remote-ssh`)  
> **Total Execution Steps / Loops:** 12 atomic steps (Completed in 1 continuous self-loop)  
> **Status:** 100% Completed & Verified  
> **Scope:** VS Code Extension Installation Error Stacktrace & Sync Hardening

---

## 1. Executive Summary & Root Cause Analysis

### A. Root Causes Resolved
1. **Silent Stderr Suppression (`>/dev/null 2>&1`)**:
   - `scripts/os/ubuntu/dep-vscode-settings.sh` previously redirected both stdout and stderr of `code --install-extension "$ext" --force` to `/dev/null`. When an extension failed, only `✖ Failed: $ext` was displayed without any error details or stacktrace.
   - **Fix**: Captured full command output `2>&1` and exit code. On failure, indented and formatted the exact raw error lines / stacktrace under a clear section header (`Stacktrace / Error Details:`).
2. **Naive Regex Extracted `"disabled"` Extensions**:
   - `grep -o '"[^"]*"' "$sync_dir/extensions.json"` matched all quoted strings, erroneously extracting and attempting to install all disabled extensions (`vscode.debug-auto-launch`, `vscode.emmet`, `ms-vscode-remote.remote-ssh`, `infeng.vscode-react-typescript`, etc.).
   - **Fix**: Replaced naive grep with structured Python/jq parser that targets only `.extensions[]` and explicitly removes any item present in `.disabled[]`.
3. **Attempting to Install Built-In Extensions**:
   - Built-ins (`vscode.debug-auto-launch`, `vscode.emmet`) are internal components of VS Code, not hosted on the marketplace.
   - **Fix**: Filtered out all extension IDs matching `vscode.*`.
4. **Duplicate Variant Clash (`golang.go` vs `golang.Go`)**:
   - `base_exts` had `"golang.Go"` while `extensions.json` had `"golang.go"`. Case-sensitive sort (`sort -u`) scheduled both variants concurrently, causing concurrency failure for `golang.Go`.
   - **Fix**: Normalized `base_exts` to `"golang.go"`, converted all IDs to lowercase, and deduplicated before dispatch.
5. **Cross-Platform Alignment**:
   - Updated `scripts-linux/11-install-vscode-settings-sync/run.sh` to capture and log error details rather than discarding to `/dev/null`.
   - Updated `scripts/11-vscode-settings-sync/helpers/sync.ps1` to filter out built-in `vscode.*` and disabled extensions.

---

## 2. Granular Subtasks Consolidated

### Subtask 01: Fix Ubuntu VS Code Extension Sync & Stacktrace Capture
- **Target File:** `scripts/os/ubuntu/dep-vscode-settings.sh`
- **Changes:**
  - Added `read_extensions_python()` and `read_json_extensions()` to parse `extensions.json` properly.
  - Implemented `format_error_output()`, `build_failure_message()`, and `is_install_success()`.
  - Captured full CLI output in `install_extension_worker()`, emitting atomic multiline error blocks with indented stacktrace lines.
  - Guarded `main "$@"` with `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi`.

### Subtask 02: Fix Modular Linux Sync & Cross-Check PowerShell
- **Target Files:** `scripts-linux/11-install-vscode-settings-sync/run.sh`, `scripts/11-vscode-settings-sync/helpers/sync.ps1`
- **Changes:**
  - `scripts-linux/11-install-vscode-settings-sync/run.sh`: Captured CLI error output on failure and logged with `log_warn`, filtered out `vscode.*` built-ins.
  - `scripts/11-vscode-settings-sync/helpers/sync.ps1`: Excluded disabled extensions and built-in `vscode.*` extensions from JSON loading.
  - Normalized `sync.ps1` to Unix LF line endings.

---

## 3. Verification & Proof of Resolution

1. **Successful Installation Run**:
   - Curated extensions verified and installed cleanly without any errors:
     ```text
     ✔ Installed: esbenp.prettier-vscode
     ✔ Installed: eamodio.gitlens
     ✔ Installed: bmewburn.vscode-intelephense-client
     ✔ Installed: timonwong.shellcheck
     ✔ Installed: rust-lang.rust-analyzer
     ✔ Installed: tamasfe.even-better-toml
     ✔ Installed: ms-python.python
     ```
2. **Stacktrace on Failure Verified**:
   - Tested intentionally failing extension (`nonexistent.fake-test-extension`):
     ```text
     ✖ Failed: nonexistent.fake-test-extension
       Stacktrace / Error Details:
         Installing extensions...
         Extension 'nonexistent.fake-test-extension' not found.
         Make sure you use the full extension ID, including the publisher, e.g.: ms-dotnettools.csharp
         Failed Installing Extensions: nonexistent.fake-test-extension
     ```
3. **Syntax & Line Endings**:
   - `bash -n` exited with code 0 on all modified bash scripts.
   - CRLF line count = 0 across all modified files.
