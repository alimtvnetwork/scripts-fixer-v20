# Subtask 20.2: Codex UI & Claude Code UI Cross-Platform Installation & E2E Testing (Windows Server, Ubuntu, macOS)

> **Subtask Version:** 1.0.0  
> **Status:** Pending / Ready for Execution  
> **Parent Task:** Install and Validate Codex UI and Claude Code UI across Windows Server, Ubuntu, and macOS  
> **Specification Reference:** [02-codex-claude-ui-spec.md](../../../../02-spec/21-app/23-vmware-codex-claude-ui/02-codex-claude-ui-spec.md)

---

## 1. User Request (Verbatim)

```text
# High Priority Instruction

can you please improve and fix VMware installation for Windows, Linux, and also can you please try to install Codex UI and Claude Code UI in the Windows Server, Linux Ubuntu, macOS? You test here in the Windows Server properly that Claude Code UI (not the CLI) gets installed properly and also the Codex. Do proper end-to-end testing during the process and install in the default installation directory, clear?

# Actionable Items Must Follow Non-Negotiable

1. Improve and fix VMware installation for Windows, Linux.
2. Install Codex UI and Claude Code UI on Windows Server, Linux Ubuntu, macOS.
3. Ensure Claude Code UI (not CLI) is installed properly on Windows Server.
4. Conduct proper end-to-end testing during the installation process.
5. Install all software in the default installation directory.

Must follow and spawn agent using 

@[.agents/skills/execute-parent-task-with-n-steps-v6]

## Additional Instructions

learn /learn if you have to learn something and /plan stuff before working please.
```

---

## 2. Objective & Scope

Design and implement a robust, production-grade installation and verification suite for **Claude Code UI** and **Codex UI** targeting Windows Server, Ubuntu Linux, and macOS.

### Non-Negotiable Core Principle
- **Full Desktop UI, NOT CLI**: Claude Code UI must be installed as the complete desktop graphical user interface application, NOT a command-line terminal wrapper (such as `@anthropic-ai/claude-code` npm batch shim).
- **Default Installation Directories**: Software MUST install into standard system default paths rather than ad-hoc custom directories.
- **End-to-End Validation**: Windows Server execution must be validated with an automated, non-interactive E2E test verifying executable integrity, desktop/start menu shortcuts, and process launchability.

### Target Files Owned by this Subtask:
- `scripts/80-install-claude-code/run.ps1`
- `scripts/80-install-claude-code/tests/Test-ClaudeUI-E2E.ps1`
- `scripts/78-install-codex/run.ps1`
- `scripts/78-install-codex/tests/Test-CodexUI-E2E.ps1`
- `scripts/os/ubuntu/install-claude-code.sh`
- `scripts/os/ubuntu/install-codex.sh`
- `scripts/os/macos/install-claude-code.sh`
- `scripts/os/macos/install-codex.sh`

*(Note: Disjoint ownership strictly enforced. This plan does NOT touch any VMware installer files or shared repository index manifests).*

---

## 3. Detailed Implementation Steps

### Step 1: Default Installation Directory Standardization
Enforce and validate standard filesystem coordinates across all platforms:
- **Windows Server / Windows 11**:
  - Claude Code UI: `C:\Program Files\Anthropic\Claude` (system default) or `%LOCALAPPDATA%\AnthropicClaude` (user default).
  - Codex UI: `%LOCALAPPDATA%\Programs\Codex` or `%USERPROFILE%\.codex\bin`.
  - Desktop Shortcuts: `[Environment]::GetFolderPath("Desktop")\Claude.lnk` and `Codex.lnk`.
  - Start Menu Shortcuts: `[Environment]::GetFolderPath("Programs")\Anthropic\Claude.lnk`.
- **Ubuntu Linux**:
  - Binary Directories: `/usr/local/bin` (system) or `~/.local/bin` (user).
  - Desktop Launchers: `/usr/share/applications/claude.desktop` and `/usr/share/applications/codex.desktop`.
- **macOS**:
  - Application Bundles: `/Applications/Claude.app` and `/Applications/Codex.app`.
  - CLI Companion Symlinks: `/usr/local/bin/claude` and `/usr/local/bin/codex`.

### Step 2: Multi-Tier Resilient Claude Code UI Installer (`scripts/80-install-claude-code/run.ps1`)
Refactor the Windows PowerShell installer to eliminate the npm CLI wrapper and install the genuine Desktop UI:
1. **Tier 1 (Official Winget)**:
   ```powershell
   winget install Anthropic.Claude --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
   ```
2. **Tier 2 (Official Anthropic CDN Direct Download & Silent Install)**:
   - Download installer binary from verified Anthropic distribution endpoint.
   - Stage in isolated temp folder under `Get-ScriptTempDirectory`.
   - Run installer silently: `Start-Process $installer -ArgumentList "/S", "--silent" -Wait -PassThru`.
3. **Tier 3 (Shortcut & Environment Registration)**:
   - Ensure desktop shortcut `Claude.lnk` is created via COM `WScript.Shell`.
   - Ensure Start Menu shortcut is populated.
   - Add default executable directory to user `PATH` if not present.

### Step 3: Codex UI Installer Refactoring (`scripts/78-install-codex/run.ps1`)
1. Target default directory `%LOCALAPPDATA%\Programs\Codex` or `%USERPROFILE%\.codex\bin`.
2. Deploy dedicated GUI executable / launcher `codex-ui.exe`.
3. Create native desktop shortcut `Codex.lnk` targeting the UI binary.
4. Verify non-CLI behavior: ensure launcher spawns graphical window, not just a bare cmd prompt.

### Step 4: Ubuntu Linux & macOS Shell Scripts Parity
1. **Ubuntu (`scripts/os/ubuntu/install-claude-code.sh`)**:
   - Install desktop application package / AppImage / native archive.
   - Deploy `/usr/share/applications/claude.desktop` with freedesktop standard `Terminal=false`.
   - Register desktop icons in `/usr/share/icons/hicolor/`.
2. **Ubuntu (`scripts/os/ubuntu/install-codex.sh`)**:
   - Install graphical Codex UI binary into `/usr/local/bin/codex-ui`.
   - Deploy `/usr/share/applications/codex.desktop`.
3. **macOS Scripts (`install-claude-code.sh`, `install-codex.sh`)**:
   - Download and mount/extract native `.app` bundles directly into `/Applications`.
   - Establish CLI bridge links in `/usr/local/bin`.

### Step 5: Windows Server End-to-End Automated Testing Harness
Implement automated testing scripts:
- `scripts/80-install-claude-code/tests/Test-ClaudeUI-E2E.ps1`
- `scripts/78-install-codex/tests/Test-CodexUI-E2E.ps1`

Validation checkpoints:
1. **Binary Check**: Assert `claude.exe` / `codex-ui.exe` exists in default path.
2. **Non-CLI Gate**: Assert file extension is `.exe` (not `.cmd`/`.bat`) and file size > 1 MB.
3. **Shortcut Validation**: Assert `.lnk` file exists on Desktop and COM target path equals verified executable.
4. **Process Launch Smoke Test**: Launch executable with safe timeout, verify running process, then gracefully terminate.

### Step 6: AGENTS.md CODE RED Logging Compliance
1. Invoke `Write-InstallPaths` prior to any install attempt:
   - `Source`: Winget package ID or CDN URL.
   - `Temp`: Isolated temp staging path.
   - `Target`: Standard default installation directory.
2. Invoke `Write-FileError` (PowerShell) / `log_file_error` (Bash) on any failure.
3. Enforce strict boolean conventions (`is*`, `has*` only) and micro-functions (<= 8-15 lines).

---

## 4. Verification & Testing Protocol

1. **Static Analysis & Syntax Check**:
   - `pwsh -NoProfile -Command "Get-Command -Syntax (Resolve-Path scripts/80-install-claude-code/run.ps1)"`
   - `pwsh -NoProfile -Command "Get-Command -Syntax (Resolve-Path scripts/78-install-codex/run.ps1)"`
   - `bash -n scripts/os/ubuntu/install-claude-code.sh`
   - `bash -n scripts/os/ubuntu/install-codex.sh`
2. **Path Logging Verification**:
   - Ensure `Write-InstallPaths` output appears in console logs.
3. **End-to-End Test Execution**:
   - `pwsh -NoProfile -File scripts/80-install-claude-code/tests/Test-ClaudeUI-E2E.ps1`
   - `pwsh -NoProfile -File scripts/78-install-codex/tests/Test-CodexUI-E2E.ps1`
4. **Default Directory Verification**:
   - Verify `$env:ProgramFiles\Anthropic\Claude` or `$env:LOCALAPPDATA\AnthropicClaude`.
   - Verify `$env:LOCALAPPDATA\Programs\Codex` or `$env:USERPROFILE\.codex\bin`.
