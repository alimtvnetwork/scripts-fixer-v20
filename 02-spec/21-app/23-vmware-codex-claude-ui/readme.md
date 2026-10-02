# 23-vmware-codex-claude-ui — Master Specification

> **Feature Version:** 2.0.0  
> **Status:** Active / Authoritative  
> **Domain:** Virtualization Infrastructure, AI Development Tooling & Cross-Platform Desktop UI Automation  
> **Target Environments:** Windows Server (Live host), Linux Ubuntu, macOS

---

## 1. Scope & Architecture Overview

This specification establishes the authoritative cross-platform installation, desktop integration, and end-to-end verification standards for:
1. **VMware Workstation Pro & VMware Workstation Player**:
   - Multi-tier resilient installation (Local cache -> Winget -> Chocolatey -> Verified archive mirror).
   - System PATH registration (`Add-ToMachinePath`) for CLI tools (`vmrun.exe`, `vmware-vdiskmanager.exe`, `vmware.exe`).
   - Ubuntu 24.04 compatibility (`libaio1t64`, `git`, `dkms`) and modern Linux kernel (6.5+, 6.8+) module compilation fallback via `mkubecek/vmware-host-modules`.
2. **Claude Code UI (Desktop GUI Application — NOT CLI)**:
   - Explicit architectural distinction between the `@anthropic-ai/claude-code` CLI and the Claude Desktop GUI application.
   - Default directory installation on Windows Server (`%LOCALAPPDATA%\Programs\Claude`), Ubuntu (`/usr/share/applications`, `~/.local/share/applications`), and macOS (`/Applications/Claude.app`).
   - Desktop and Start Menu shortcut creation with explicit `WorkingDirectory` targeting the Electron `app-*` binary directory and `app.ico` icon registration.
   - Command-line GUI launcher `claude-ui` registered in system PATH.
3. **Codex UI (Native Cross-Platform AI Assistant GUI)**:
   - Windows Server: Compiled native WinForms dark-mode UI (`Codex.exe`) installed in `%LOCALAPPDATA%\Programs\Codex`, with both Desktop and Start Menu shortcuts, and `codex-ui` shim in system PATH.
   - Linux Ubuntu: Python/Tkinter dark-mode GUI (`codex-ui.py`) with `python3-tk` validation, `$DISPLAY` availability guards, and `.desktop` application menu integration.
   - macOS: Native `.app` bundle (`/Applications/Codex.app` and `~/Applications/Codex.app`) with ad-hoc code signing (`codesign --force --deep --sign -`).
4. **Live Windows Server E2E Verification Suite**:
   - Comprehensive multi-point live testing (`tests/e2e-ai-ui-install.ps1`) covering directory structures, executable version info, non-hanging GUI process launches via watchdog timers, and process tree termination (`taskkill /F /T /PID`).

---

## 2. Specification Index

| Document | Focus Area | Key Implementation Files |
| :--- | :--- | :--- |
| [01-vmware-installer-spec.md](01-vmware-installer-spec.md) | VMware Workstation/Player Windows & Linux Installer | `scripts/66-install-vmware/run.ps1`, `scripts/os/ubuntu/install-vmware*.sh` |
| [02-codex-claude-ui-spec.md](02-codex-claude-ui-spec.md) | Codex UI & Claude Code UI Cross-Platform & E2E Testing | `scripts/78-install-codex/run.ps1`, `scripts/80-install-claude-code/run.ps1`, `scripts/os/ubuntu/*`, `scripts/os/mac/*`, `tests/e2e-ai-ui-install.ps1` |

---

## 3. Standard Default Installation Directories

| Tool | Windows Server (Default Directory) | Linux Ubuntu (Default Directory) | macOS (Default Directory) |
| :--- | :--- | :--- | :--- |
| **VMware Workstation** | `C:\Program Files (x86)\VMware\VMware Workstation` | `/usr/bin/vmware`, `/usr/lib/vmware` | N/A |
| **Claude Code UI** | `%LOCALAPPDATA%\Programs\Claude\app-*\claude.exe` | `~/.local/bin/claude-ui.py`, `/usr/share/applications` | `/Applications/Claude.app` |
| **Codex UI** | `%LOCALAPPDATA%\Programs\Codex\Codex.exe` | `~/.local/bin/codex-ui.py`, `/usr/share/applications` | `/Applications/Codex.app` |
| **Global Shims** | `%USERPROFILE%\.claude\bin`, `%USERPROFILE%\.codex\bin` | `/usr/local/bin`, `~/.local/bin` | `/usr/local/bin`, `~/.local/bin` |
