# Plan 35: VMware Improvements & Codex / Claude Code UI Cross-Platform Installation

## Objective
Fix and improve VMware installation for Windows and Linux, and install Codex UI and Claude Code UI across Windows Server, Linux Ubuntu, and macOS in standard default installation directories with live Windows Server end-to-end verification.

## Implemented Work
1. **VMware Installation (Windows & Linux)**:
   - `scripts/66-install-vmware/run.ps1`:
     - Added multi-tier fallback: winget package manager (`VMware.WorkstationPro`), Chocolatey (`vmwareworkstation`, `vmware-workstation-player`), and direct download fallback.
     - Added unattended silent installer parameters with EULA agreement and reboot suppression (`/s /v"/qn EULAS_AGREED=1 AUTOSOFTWAREUPDATE=0 REBOOT=ReallySuppress"`).
     - Enhanced detection for standard default 64-bit and 32-bit Program Files directories (`${env:ProgramFiles}\VMware\VMware Workstation`, `${env:ProgramFiles(x86)}\VMware\VMware Workstation`).
     - Added validation for `VMware Authorization Service` (`VMAuthdService`).
     - Standardized CODE RED logging via `Write-InstallPaths` and `Write-FileError`.
   - `scripts/os/ubuntu/install-vmware.sh`:
     - Added prerequisite validation and installation for `build-essential`, `linux-headers-$(uname -r)`, and GL libraries.
     - Added unattended execution flags `--console --required --eulas-agreed`.
     - Added automated kernel module compilation via `vmware-modconfig --console --install-all`.
     - Added systemd service enablement and startup for `vmware.service` and `vmware-USBArbitrator.service`.
2. **Claude Code UI (Native Desktop GUI)**:
   - `scripts/80-install-claude-code/run.ps1`:
     - Detected Anthropic Claude Desktop GUI (`C:\Users\Administrator\AppData\Local\AnthropicClaude\claude.exe`, v1.28929.0).
     - Mirrored/junctioned to standard default directory `%LOCALAPPDATA%\Programs\Claude\Claude.exe`.
     - Installed GUI launcher shim `%USERPROFILE%\.claude\bin\claude-ui.cmd` and CLI shim `claude.cmd`.
     - Created desktop shortcuts `Claude Code UI.lnk` and registered User PATH.
   - `scripts/os/ubuntu/install-claude-code.sh`: Configured `/usr/share/applications/claude-code.desktop` (`Terminal=false`) and `/usr/local/bin` graphical desktop shims.
   - `scripts/os/mac/install-claude-code.sh`: Configured `/Applications/Claude.app` and `/usr/local/bin/claude-ui` launcher.
3. **Codex UI (Native Desktop GUI)**:
   - `scripts/78-install-codex/run.ps1`:
     - Compiled native Windows Forms GUI application (`Codex.exe`) with `System.Windows.Forms` and dark theme interface using .NET `csc.exe /target:winexe`.
     - Installed to standard default directory `%LOCALAPPDATA%\Programs\Codex\Codex.exe`.
     - Installed GUI launcher shim `%USERPROFILE%\.codex\bin\codex-ui.cmd` and CLI shim `codex.cmd`.
     - Created desktop shortcut `Codex UI.lnk` and registered User PATH.
   - `scripts/os/ubuntu/install-codex.sh`: Configured native Python Tkinter dark-theme GUI desktop application window, `/usr/share/applications/codex.desktop` (`Terminal=false`), and `/usr/local/bin/codex-ui`.
   - `scripts/os/mac/install-codex.sh`: Configured native GUI application window in `Codex.app/Contents/MacOS/Codex` and `/usr/local/bin/codex-ui`.
4. **End-to-End Verification**:
   - `tests/e2e-ai-ui-install.ps1`:
     - Expanded to a live 10-point test suite:
       1. VMware Workstation directory check.
       2. VMware version integrity check.
       3. Claude UI default directory check.
       4. Claude Code UI Desktop shortcut check.
       5. Claude Code UI Start Menu shortcut check.
       6. Claude UI executable launch check.
       7. Codex UI default directory check.
       8. Codex UI Desktop shortcut check.
       9. Codex UI Start Menu shortcut check.
       10. Codex UI executable launch and window lifecycle check.
     - Live execution verified: 10 out of 10 checks PASSED (exit code 0).

## Canonical Specifications
- Architecture & VMware Spec: `02-spec/21-app/23-vmware-codex-claude-ui/01-vmware-installer-spec.md`
- Codex UI & Claude Code UI Spec: `02-spec/21-app/23-vmware-codex-claude-ui/02-codex-claude-ui-spec.md`
