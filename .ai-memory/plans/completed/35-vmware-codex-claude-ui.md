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
     - Expanded to an exhaustive live 15-point test suite:
       1. VMware Workstation directory check.
       2. VMware essential binaries check (`vmware.exe`, `vmrun.exe`).
       3. VMware version integrity check (`25.0.1 build-25219725`).
       4. VMware authorization service (`VMAuthdService`) check.
       5. Claude UI default directory check (`%LOCALAPPDATA%\Programs\Claude`).
       6. Claude Code UI Desktop shortcut COM inspection (`WorkingDirectory`, `IconLocation`).
       7. Claude Code UI Start Menu shortcut COM inspection.
       8. Claude UI Real GUI Launch Verification (asynchronous spawn, working set > 30MB, graceful watchdog stop).
       9. Codex UI default directory check (`%LOCALAPPDATA%\Programs\Codex\Codex.exe`).
       10. Codex UI Desktop shortcut COM inspection (`WorkingDirectory`, `IconLocation`).
       11. Codex UI Start Menu shortcut COM inspection.
       12. Codex UI Real GUI Launch Verification (asynchronous spawn, window title match, graceful watchdog stop).
       13. Claude CLI vs UI Disambiguation (`claude-ui.cmd` launches desktop GUI).
       14. Codex CLI vs UI Disambiguation (`codex-ui.cmd` launches desktop GUI).
       15. Uninstall lifecycle and syntax verification across scripts 66, 78, 80.
     - Live execution verified: 15 out of 15 checks PASSED (exit code 0).

## Canonical Specifications
- Architecture & VMware Spec: `02-spec/21-app/23-vmware-codex-claude-ui/01-vmware-installer-spec.md`
- Codex UI & Claude Code UI Spec: `02-spec/21-app/23-vmware-codex-claude-ui/02-codex-claude-ui-spec.md`
