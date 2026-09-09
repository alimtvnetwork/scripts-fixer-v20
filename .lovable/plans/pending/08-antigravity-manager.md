# Antigravity & Antigravity Manager Integration Plan

## Objective
Integrate Antigravity Manager and Antigravity CLI (agy) installers into the scripts-fixer project for both Windows and Ubuntu. Include them in main dispatcher menus and appropriate profiles.

## Custom Rules & Constraints
1. **Dynamic Fetching:** Always fetch the latest release of Antigravity Manager dynamically from the GitHub API (`lbjlaq/Antigravity-Manager`) rather than hardcoding a version number.
2. **Boolean Naming:** Any boolean variables introduced in scripts should be prefixed with `is` or `has` (e.g., `isInstalled`, `hasManager`).
3. **Idempotency:** Install scripts must check if the tool is already installed before attempting to install or download it, avoiding redundant operations.
4. **Relative Paths:** All script references and documentation links must use paths relative to the repository root.

## Overview
1. **Antigravity Manager:** Create new installer scripts to install the latest `.exe` on Windows and `.deb` on Ubuntu.
2. **Antigravity CLI:** Verify and add the installer script for Windows (`scripts/69-install-antigravity/run.ps1`) using `irm https://get.antigravity.dev | iex`.
3. **Dispatcher & Registry:** Wire the new scripts into `run.sh`, `run.ps1`, and `registry.json`.
4. **Profiles:** Inject both tools into the `dev` and `dev+ai` profiles and ensure they display in help menus.

## Subtasks
- [.lovable/plans/subtasks/08-antigravity-manager/01-windows.md](.lovable/plans/subtasks/08-antigravity-manager/01-windows.md): Windows implementation details.
- [.lovable/plans/subtasks/08-antigravity-manager/02-ubuntu.md](.lovable/plans/subtasks/08-antigravity-manager/02-ubuntu.md): Ubuntu implementation details.
