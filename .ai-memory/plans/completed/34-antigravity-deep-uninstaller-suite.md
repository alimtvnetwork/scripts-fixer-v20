# Completed Plan: Antigravity Deep Uninstaller, AGM, Copilot, Edge & Enhanced Dev-Tool Clean

Spec Reference: [02-spec/21-app/22-deep-uninstaller-suite/01-overview.md](../../../02-spec/21-app/22-deep-uninstaller-suite/01-overview.md)
Start Reference: Initialized to address complete uninstallation of Antigravity (with state preservation), Anti-Gravity Manager (AGM), Windows Copilot, Microsoft Edge, and dev-tool cache cleaning enhancement.
Execution Loops: 2 multi-agent parallel execution loops.

## Summary of Accomplished Deliverables

1. **Antigravity State Backup & Deep Uninstaller (Task-01):**
   - Implemented `Export-AntigravityState` in `scripts/69-install-antigravity/helpers/backup-state.ps1`.
   - Captures strictly project information (project path and name) and conversation names from `conversation_summaries.db` (or brain directory fallback) to JSON at `~/.scripts-fixer/antigravity-projects-backup.json` and `~/antigravity-projects-backup.json`.
   - Enhanced `scripts/69-install-antigravity/helpers/uninstall.ps1` with `-All` (`-Deep`):
     - First triggers `Export-AntigravityState`.
     - Terminates processes (`antigravity*`, `agy*`).
     - Executes official IDE silent uninstaller (`Uninstall Antigravity.exe` /currentuser /S).
     - Purges residual CLI folders, shortcuts, and PATH references.
     - Purges AppData/LocalAppData configuration and cache stores (`Antigravity`, `antigravity-updater`).
     - Purges all Gemini brain artifacts (`~/.gemini`).
     - Scrubs registry entries.
     - Standard `agy uninstall` without `-All` preserves `.gemini` brain data.
   - Enforced `d:\work` workspace safety barrier (`Test-IsSafePath`).

2. **Anti-Gravity Manager (AGM) Uninstaller (Task-02):**
   - Updated `scripts/68-install-antigravity-manager/run.ps1` with `Uninstall-AntigravityManager`.
   - Terminates running AGM processes, invokes uninstaller executable or removes `%LOCALAPPDATA%\Programs\antigravity-manager`.
   - Under `-All`, purges AppData/LocalAppData caches and registry keys.

3. **Windows Copilot Deep Uninstaller (Task-03):**
   - Implemented `scripts/os/helpers/uninstall-copilot.ps1`.
   - Terminates Copilot processes.
   - Removes current and all-user AppX packages (`Microsoft.Windows.Ai.Copilot.Provider`, `Microsoft.Copilot`).
   - Removes provisioned AppX packages.
   - Applies Group Policy blocks: `TurnOffWindowsCopilot = 1` (HKCU & HKLM), `ShowCopilotButton = 0` (Taskbar), and `HubsSidebarEnabled = 0` (Edge).

4. **Microsoft Edge Uninstaller (Task-04):**
   - Implemented `scripts/os/helpers/uninstall-edge.ps1` adhering strictly to Chris Titus WinUtil methodology.
   - Terminates Edge processes (`msedge.exe`, `MicrosoftEdgeUpdate.exe`).
   - Executes Edge `setup.exe --uninstall --system-level --verbose-logging --force-uninstall`.
   - Stops and disables `edgeupdate` and `edgeupdatem` services.
   - Disables Edge update scheduled tasks.
   - Applies registry policy block `HKLM:\SOFTWARE\Microsoft\EdgeUpdate` -> `DoNotUpdateToEdgeWithChromium = 1`.
   - Removes shortcuts from Desktop and Taskbar.

5. **Dev-Tool Cleaner Enhancement (Task-05):**
   - Enhanced `scripts/os/helpers/dev-clean.ps1`.
   - Integrated deep sweep of AI temp dumps and scratch tasks (`.system_generated/tasks`, `crashes`, `scratch`, `tempmediaStorage`).
   - Sweeps stale build caches, VS Code caches in AppData/Local, and GitMap run temp.
   - Enforced strict workspace path protection (`Test-IsSafeDevPath`) ensuring `d:\work` is never touched.

6. **Unified CLI Wrappers & Dispatcher (Task-01..05):**
   - Created root `cli.ps1` and `cli.cmd` entrypoints forwarding to `run.ps1`.
   - Updated `$uninstallTargets` in `run.ps1` with `agy`, `agy-all`, `agm`, `agm-all`, `copilot`, `copilot-all`, `edge`, `edge-all`.
   - Handled `uninstall-all` and `run.ps1 agy uninstall-all`.

7. **PowerShell Standalone E2E Test Suite (Task-06):**
   - Created `scripts/test-e2e-uninstallers.ps1`.
   - Supports safe simulated verification (`-Simulate`) and external full live removal (`-FullLiveTest`).

## Consolidated Subtasks
- Subtask 01: `01-state-backup-and-deep-uninstaller.md` -> Consolidated
- Subtask 02: `02-agm-copilot-edge-uninstallers.md` -> Consolidated
- Subtask 03: `03-dev-tool-cleaner-enhancement.md` -> Consolidated
- Subtask 04: `04-cli-wrapper-and-dispatcher.md` -> Consolidated
- Subtask 05: `05-powershell-e2e-testing-and-release.md` -> Consolidated
