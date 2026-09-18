# Master Plan: 29-windows-server-store-plot-antigravity

## Overview
Implement OS detection (Windows Server, Windows 11, Windows 10), Windows Store installation and prerequisites handling for Windows Server, fix PlotCode and Codex installation on Windows Server, and add explicit Antigravity CLI installation to the Dev profile across platforms.

### Key Objectives
1. **OS Detection Helper (scripts/shared/os-detect.ps1)**:
   - Detects Windows Server (via CIM ProductType 2/3, registry InstallationType, Caption regex).
   - Detects Windows 11 (Build >= 22000, ProductType 1).
   - Detects Windows 10 (Build >= 10240 and < 22000, ProductType 1).
   - Provides structured Get-OSInfo, Test-IsWindowsServer, Test-IsWindows11, Test-IsWindows10, Test-HasWindowsStore.

2. **Windows Store (Microsoft Store) Installation on Windows Server**:
   - Script/helper scripts/shared/windows-store.ps1 to detect and install Microsoft Store (9WZDNCRFJBMP) on Windows Server.
   - Dual installation strategy: Winget msstore source with fallback to direct AppX dependency deployment.
   - Integrate with 14-install-winget to handle Windows Server environments.

3. **Fix PlotCode & Codex for Windows Server**:
   - Update scripts/79-install-plotcode/run.ps1 and scripts/78-install-codex/run.ps1 to detect Windows Server and ensure Store/dependencies before installing.
   - Register keywords codecs, codec, codex, plot, plotcode, store, windows-store in install-keywords.json, egistry.yaml, and completions.

4. **Add Antigravity CLI to Dev Profile**:
   - Update scripts/profile/config.json dev profile to explicitly include Antigravity CLI (gy).
   - Add explicit cli command mode to scripts/69-install-antigravity/run.ps1.
   - Update scripts-linux/12-install-all-dev-tools/profiles.json with dev profile containing Antigravity CLI.
   - Verify profile_tree.py and profile runners.

## Subtasks
- [Subtask 01: OS Detection Helper](01-os-detection-helper.md)
- [Subtask 02: Windows Store Installation for Server](02-windows-store-installer.md)
- [Subtask 03: PlotCode & Codex Server Compatibility](03-plotcode-codex-server.md)
- [Subtask 04: Antigravity CLI in Dev Profile & Verification](04-antigravity-cli-dev-profile.md)
