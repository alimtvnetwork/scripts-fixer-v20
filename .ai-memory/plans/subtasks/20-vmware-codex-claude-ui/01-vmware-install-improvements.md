# Subtask 20.1: VMware Cross-Platform Installation Improvements (Windows & Linux)

> **Subtask Version:** 1.0.0  
> **Status:** Pending / Ready for Execution  
> **Parent Task:** Improve and Fix VMware Installation across Windows & Linux  
> **Specification Reference:** [01-vmware-installer-spec.md](../../../../02-spec/21-app/23-vmware-codex-claude-ui/01-vmware-installer-spec.md)

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

Refactor and harden VMware Workstation and Player installation scripts across Windows and Linux to guarantee resilient installation, automated package fallback, strict AGENTS.md CODE RED compliance, and explicit validation of standard default installation directories.

### Target Files Owned by this Subtask:
- `scripts/66-install-vmware/run.ps1`
- `scripts/os/ubuntu/install-vmware.sh`
- `scripts/os/ubuntu/install-vmware-tools.sh`
- `scripts/os/ubuntu/vmware-mount-shared.sh`

*(Note: Disjoint ownership strictly enforced. This plan does NOT touch any Claude Code UI, Codex UI, or shared registry/index files).*

---

## 3. Detailed Implementation Steps

### Step 1: Default Installation Directory Standardization
Ensure all scripts target, verify, and document standard default directories:
- **Windows Default**:
  `${env:ProgramFiles(x86)}\VMware\VMware Workstation` (or `${env:ProgramFiles}\VMware\VMware Workstation`)
  Validate presence of `vmware.exe`, `vmplayer.exe`, or `vmrun.exe`.
- **Linux Default**:
  `/usr/bin/vmware`, `/usr/bin/vmplayer`, and `/usr/lib/vmware`.

### Step 2: Multi-Tier Resilient Installation Flow (Windows)
Refactor `scripts/66-install-vmware/run.ps1` to implement a 3-tier installation pipeline:
1. **Tier 1 (Direct Official Binary)**:
   - Check `$env:VMWARE_DOWNLOAD_URL` or use the official stable release URL.
   - Download installer binary to isolated `$env:TEMP` folder.
   - Run silent installer: `Start-Process $tempPath -ArgumentList "/s /v`\"/qn REBOOT=ReallySuppress`\"" -Wait -PassThru`.
2. **Tier 2 (Chocolatey Fallback)**:
   - If direct download fails (network error, CDN 403, or invalid exit code), check if `choco` CLI is available.
   - Execute fallback: `choco install vmwareworkstation --yes --no-progress`.
   - Secondary fallback if workstation package unavailable: `choco install vmware-workstation-player --yes --no-progress`.
3. **Tier 3 (Diagnostic & Structured Error Handling)**:
   - If both tiers fail, capture exit codes and output, log CODE RED error via `Write-FileError`, and record DB failure.

### Step 3: Linux Prerequisite & Kernel Module Hardening
Enhance `scripts/os/ubuntu/install-vmware.sh`:
1. Verify prerequisites before bundle download: `build-essential`, `linux-headers-$(uname -r)`.
2. Support configurable version/build parameters with verified default mirror fallback.
3. Add kernel module build verification: trigger `vmware-modconfig --console --install-all` if kernel modules are not active.
4. Maintain `install-vmware-tools.sh` and `vmware-mount-shared.sh` compatibility for guest environments.

### Step 4: AGENTS.md CODE RED Logging Compliance
1. Invoke `Write-InstallPaths` prior to any download or installation:
   - `Source`: Download URL or Chocolatey package name.
   - `Temp`: Download destination in temp directory.
   - `Target`: Standard default installation directory.
2. Invoke `Write-FileError` (PowerShell) / `log_file_error` (Bash) on all path resolution, download, or execution errors.

### Step 5: Coding Guidelines & Structural Hygiene
1. **Strict Booleans**: Replace all non-standard flag names with `is*` and `has*` (`isInstalled`, `hasVMware`, `isChocoAvailable`, `isSuccess`).
2. **Micro-Functions**: Ensure every function is <= 8 lines of execution logic (max 15 lines).
3. **Guard Clauses**: Flatten all nested `if` statements with early returns.
4. **Vertical Whitespace**: Mandatory blank lines before `if`, after `}`, and before `return`.

---

## 4. Verification & Testing Protocol

1. **Static Analysis & Syntax Check**:
   - `pwsh -NoProfile -Command "Get-Command -Syntax (Resolve-Path scripts/66-install-vmware/run.ps1)"`
   - `bash -n scripts/os/ubuntu/install-vmware.sh`
2. **Path Logging Verification**:
   - Verify `Write-InstallPaths` output displays `[ PATH ] Install paths -- VMware Workstation`.
3. **Directory Verification**:
   - Confirm binary discovery logic checks `${env:ProgramFiles(x86)}\VMware\VMware Workstation` and `${env:ProgramFiles}\VMware\VMware Workstation`.
4. **Fallback Simulation**:
   - Test fallback trigger by simulating invalid download URL to confirm Chocolatey fallback execution.
5. **Database Bridge Synchronization**:
   - Confirm `Invoke-DbRecord` records `record-skipped` or `record-success` into SQLite storage.
