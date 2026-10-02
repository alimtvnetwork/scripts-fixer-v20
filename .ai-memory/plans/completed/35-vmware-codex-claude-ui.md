# Plan 35: VMware Improvements & Codex / Claude Code UI Cross-Platform Installation

## Objective
Fix and improve VMware installation for Windows and Linux, and install Codex UI and Claude Code UI across Windows Server, Linux Ubuntu, and macOS in standard default installation directories with live Windows Server end-to-end verification.

## Implemented Work
1. **VMware Installation (Windows & Linux)**:
   - `scripts/66-install-vmware/run.ps1`:
     - Added multi-tier fallback: winget package manager (`VMware.WorkstationPro`), Chocolatey (`vmwareworkstation`, `vmware-workstation-player`), and direct download fallback.
     - Enhanced detection for standard default 64-bit and 32-bit Program Files directories (`${env:ProgramFiles}\VMware\VMware Workstation`, `${env:ProgramFiles(x86)}\VMware\VMware Workstation`).
     - Standardized CODE RED logging via `Write-InstallPaths` and `Write-FileError`.
   - `scripts/os/ubuntu/install-vmware.sh`:
     - Added prerequisite validation and installation for `build-essential`, `linux-headers-$(uname -r)`, and GL libraries.
     - Added unattended execution flags `--required --eulas-agreed`.
     - Added automated kernel module compilation via `vmware-modconfig --console --install-all`.
2. **Claude Code UI (Native Desktop GUI)**:
   - `scripts/80-install-claude-code/run.ps1`:
     - Detected Anthropic Claude Desktop GUI (`C:\Users\Administrator\AppData\Local\AnthropicClaude\claude.exe`, v1.28929.0).
     - Mirrored/junctioned to standard default directory `%LOCALAPPDATA%\Programs\Claude\Claude.exe`.
     - Installed GUI launcher shim `%USERPROFILE%\.claude\bin\claude-ui.cmd` and CLI shim `claude.cmd`.
     - Created desktop shortcuts `Claude Code UI.lnk` and registered User PATH.
   - `scripts/os/ubuntu/install-claude-code.sh`: Configured `/usr/share/applications/claude-code.desktop` and `/usr/local/bin` shims.
   - `scripts/os/mac/install-claude-code.sh`: Configured `/Applications/Claude.app` and `/usr/local/bin/claude` symlink.
3. **Codex UI (Native Desktop GUI)**:
   - `scripts/78-install-codex/run.ps1`:
     - Compiled native Windows Forms GUI application (`Codex.exe`) with `System.Windows.Forms` and dark theme interface using .NET `csc.exe /target:winexe`.
     - Installed to standard default directory `%LOCALAPPDATA%\Programs\Codex\Codex.exe`.
     - Installed GUI launcher shim `%USERPROFILE%\.codex\bin\codex-ui.cmd` and CLI shim `codex.cmd`.
     - Created desktop shortcut `Codex UI.lnk` and registered User PATH.
   - `scripts/os/ubuntu/install-codex.sh`: Configured `/usr/share/applications/codex.desktop` and `/usr/local/bin/codex-ui`.
   - `scripts/os/mac/install-codex.sh`: Configured `/Applications/Codex.app` and `/usr/local/bin/codex-ui`.
4. **End-to-End Verification**:
   - `tests/e2e-ai-ui-install.ps1`:
     - Hardened error handling in `Invoke-SafeFileError` to prevent empty FilePath crashes.
     - Hardened `Test-LaunchCodexApplication` to verify GUI process spawn and life-cycle cleanly.
     - Live execution verified: 6 out of 6 checks PASSED (exit code 0).

## Canonical Specifications
- Architecture & VMware Spec: `02-spec/21-app/23-vmware-codex-claude-ui/01-vmware-installer-spec.md`
- Codex UI & Claude Code UI Spec: `02-spec/21-app/23-vmware-codex-claude-ui/02-codex-claude-ui-spec.md`
