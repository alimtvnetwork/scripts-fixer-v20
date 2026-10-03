---
name: Universal Subcommand Help and Windows Server UI Deployment
description: Ingestion of help routing invariants, Windows Server csc.exe WinForms compilation, and VMware guest detection
type: learned
---

# Universal Subcommand Help & Windows Server AI UI Deployment

> **Date:** 2026-10-03  
> **Repository Version:** v1.57.0  
> **Author:** Antigravity AI  

---

## 1. Universal Command Help Routing Invariant (`<command> help`)

1. **The Invariant**: Running `<command> help` (or `<command> space help`, `-h`, `--help`, `/?`) across any supported OS (PowerShell on Windows, Bash on Linux/macOS) MUST cleanly display that command's subcommands and options rather than failing or treating `help` as an install keyword or model name.
2. **PowerShell Dispatcher Implementation (`run.ps1`)**:
   - Extract and detect help tokens (`help`, `-h`, `--help`, `/?`, `?`) from the positional arguments (`$Install`) before keyword resolution.
   - For recognized subcommand groups (`db`, `services`, `models`, `clean`, `clear`, `startup`, `schedule`, `macro`, `storage`, `cluster`, `nginx`, `agy`, `os`, `gitmap`), route directly to that group's dedicated help renderer.
   - For arbitrary install keywords (`vscode`, `python`, `node`, `php`, `docker`, etc.), intercept trailing help tokens and invoke `Show-RootHelp -Filter $keyword` (or the tool's usage) instead of throwing `[ FAIL ] Unknown keyword: 'help'`.
3. **Linux / Bash Dispatcher Implementation (`scripts-linux/run.sh`)**:
   - In `models|model)`: Intercept `help`, `-h`, `--help` before delegating to `model-pull.sh`, displaying models CLI usage and filter tags directly without requiring `jq` or failing.
   - Add explicit handlers for `db`, `services`, `clean`, `clear`, `startup`, `schedule`, `macro`, `storage`, `cluster` so trailing `help` renders contextual CLI options instead of falling through to the root 500-line help catalog.

---

## 2. Windows Server Standalone WinForms Compilation (`Codex.exe`)

1. **Context & Constraints**:
   - Windows Server 2025 / 2022 Datacenter editions do not ship with the consumer Microsoft Store or AppX/MSIX package deployment infrastructure.
   - Attempting to install desktop GUI wrappers via Store APIs or Windows Package Manager winget can fail or encounter blocked policy constraints.
2. **Authoritative Compilation Pattern**:
   - Use the built-in Microsoft .NET Framework C# compiler:
     `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe`
   - Compile a native C# WinForms GUI client with zero external runtime dependencies (`System.Windows.Forms.dll`, `System.Drawing.dll`).
   - Output binary to `%LOCALAPPDATA%\Programs\Codex\Codex.exe`.
   - Register COM desktop and start menu shortcuts via `WScript.Shell`.

---

## 3. VMware Hypervisor Host vs. Virtual Guest Detection

1. **Runtime Discrimination**:
   - On Windows Server **virtual machine guests**, verify `VMware Tools` via:
     `C:\Program Files\VMware\VMware Tools\VMwareToolboxCmd.exe -v`
     and verify the running status of services `VMTools` and `VM3DService`.
   - Probes for `vmrun.exe`, `vmware-vdiskmanager.exe`, or VMware Workstation/Player registries apply strictly to **physical hypervisor hosts** and must not fail guest audit suites.

---

## 4. PowerShell StrictMode Array Safety

1. **The Issue**: Under `Set-StrictMode -Version Latest`, evaluating `$null.Count` throws a terminating `PropertyNotFoundException`.
2. **The Invariant**: When accessing `.Count` on variables that may be null or single-object scalars, always wrap in an array subexpression: `@($staleFiles).Count`.
