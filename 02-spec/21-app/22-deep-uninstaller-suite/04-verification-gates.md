# 22-deep-uninstaller-suite — Verification Gates & Acceptance Criteria

> **Spec Reference:** [01-overview.md](./01-overview.md)  
> **Status:** active

---

## 1. Acceptance Criteria Checklist

- [ ] **AC-01 (Antigravity State Backup):** Running `agy-all` or `cli uninstall agy-all` extracts project metadata and conversation names to a valid JSON file BEFORE any file deletion occurs.
- [ ] **AC-02 (Antigravity Deep Purge):** All traces of Antigravity (Programs, CLI, AppData, LocalAppData, `.gemini`, `brain`, shortcuts, PATH) are removed completely when `--all` / `agy-all` is specified.
- [ ] **AC-03 (Standard vs Deep Distinction):** `agy uninstall` without `--all` uninstalls the program without deleting the user's `.gemini` brain directory or conversation history.
- [ ] **AC-04 (Anti-Gravity Manager Uninstaller):** `cli uninstall agm` / `uninstall agm-all` removes AGM executables, updater artifacts, and shortcuts.
- [ ] **AC-05 (Windows Copilot Deep Removal):** AppX packages and provisioned packages are uninstalled, and registry policies (`TurnOffWindowsCopilot`, `ShowCopilotButton`) are applied.
- [ ] **AC-06 (Microsoft Edge Removal):** Implements Chris Titus WinUtil uninstall flags, service disablement, and `DoNotUpdateToEdgeWithChromium` registry lock.
- [ ] **AC-07 (Dev-Tool Cache Cleaner Enhanced):** `dev-clean` sweeps developer runtimes + deep AI temp artifacts, dangling task logs, and build artifacts while strictly preserving `d:\work`.
- [ ] **AC-08 (Safety Invariant):** Under NO circumstances is any file within `d:\work` or the active code repositories modified or deleted.
- [ ] **AC-09 (Standalone PowerShell Execution):** An external standalone test script `scripts/test-e2e-uninstallers.ps1` is provided and verified.
- [ ] **AC-10 (Release & Git Push):** Version bump, changelog update, git push to remote, and Gitmap DE verification completed.

---

## 2. Quality Verification Gates

1. **Syntax & Linter Checks:** Run targeted guideline checks on PowerShell and Python scripts.
2. **Dry-Run / Simulated Verification:** Execute dry-run validations for all uninstall routines ensuring 0 exceptions and proper targeting.
3. **Safety Barrier Verification:** Assert that all paths targeted for deletion reside strictly within user profile / temp / program files, never within workspace roots.
