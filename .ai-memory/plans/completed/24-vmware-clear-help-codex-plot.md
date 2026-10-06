# Completed Plan: 24-vmware-clear-help-codex-plot

> **Status:** COMPLETED  
> **Slug:** 24-vmware-clear-help-codex-plot  
> **Date Completed:** 2026-10-03  
> **Target Release:** v1.57.0  
> **Specifications:**  
> - [01-clear-and-help-routing-spec.md](../../02-spec/21-app/24-vmware-clear-help-codex-plot/01-clear-and-help-routing-spec.md)  
> - [02-codex-plot-vmware-release-spec.md](../../02-spec/21-app/24-vmware-clear-help-codex-plot/02-codex-plot-vmware-release-spec.md)  
> - [03-universal-subcommand-help-routing-spec.md](../../02-spec/21-app/24-vmware-clear-help-codex-plot/03-universal-subcommand-help-routing-spec.md)  

---

## 1. Executive Summary

This plan successfully delivered and verified:
1. **VMware Installation Verification & State Confirmation**:
   - Distinguished host VMware Workstation/Player hypervisors from guest additions (`VMware Tools`).
   - Verified that `VMware Tools` is installed and running (`VMTools`, `VM3DService`, `VMwareToolboxCmd.exe` version 13.0.10.0 build-25056151), and hardened checks across VMware scripts.
2. **Clear Commands Harmonization**:
   - Fixed `dev-clean.ps1:391` `$staleFiles.Count` null-evaluation failure under `Set-StrictMode -Version Latest` using `@($staleFiles).Count`.
   - Harmonized `run.ps1` so both `.\run.ps1 devtools clear` and `.\run.ps1 clear devtools` route cleanly to `clean-dev` and sweep developer tool caches.
3. **Subcommand Help Routing Across Windows & Linux**:
   - Added native `gitmap` command routing in `run.ps1` and `scripts-linux/run.sh`.
   - Created `scripts/dispatcher/help/gitmap-help.ps1` displaying GitMap subcommands cleanly.
   - Updated `scripts/dispatcher/early-help.ps1` exemption list so `gitmap help` / `gitmap -h` / `gitmap --help` are never swallowed by filtered root help.
   - Fixed `scripts-linux/run.sh os help` to display OS help instead of delegating to `machine-info.sh "help"` and corrupting the system machine alias.
4. **Universal Subcommand & Keyword Help Routing Parity**:
   - Implemented dedicated help routing in `run.ps1` for `db help` (database tools) and `services help` (services menu).
   - Added universal tool/keyword help interception in `run.ps1`: running `.\run.ps1 <tool> help` (e.g. `vscode help`, `python help`) filters root help or shows tool usage rather than failing with `Unknown keyword: 'help'`.
   - In `scripts-linux/run.sh`, implemented dedicated help routing for `models help` (without `jq` dependency), `db help`, `services help`, `clean help`, `startup help`, `schedule help`, `macro help`, `storage help`, and `cluster help`.
5. **Codex UI & PlotCode UI on Windows Server**:
   - Verified native standalone C# WinForms compilation of `Codex.exe` via `csc.exe` (`scripts/78-install-codex/run.ps1`), bypassing Windows Server AppX / Microsoft Store limits.
   - Verified PlotCode UI prerequisites and desktop shortcut creation (`scripts/79-install-plotcode/run.ps1`).
   - Ran live 16-point E2E verification suite (`tests/e2e-ai-ui-install.ps1`) on the Windows Server host with 100% pass rate.
6. **Release Finalization (v1.57.0)**:
   - Synchronized all version manifests (`version.json`, `scripts/version.json`, `package.json`, `.gitmap/release/latest.json`) to `v1.57.0`.
   - Prepend detailed release notes to `changelog.md`.

---

## 2. Subtask Execution & Verification Record

### Subtask 24.1: Clear Commands Harmonization & GitMap Subcommand Help Routing
- **Owner:** Worker 01
- **Files Modified:** `scripts/os/helpers/dev-clean.ps1`, `run.ps1`, `scripts/dispatcher/early-help.ps1`, `scripts/dispatcher/help/gitmap-help.ps1`, `scripts-linux/run.sh`
- **Evidence:**
  - `.\run.ps1 devtools clear --dry-run` -> exit 0
  - `.\run.ps1 clear devtools --dry-run` -> exit 0
  - `.\run.ps1 gitmap help` -> renders GitMap subcommands menu
  - `.\run.ps1 gitmap --help` -> renders GitMap subcommands menu without early-help interception
  - `bash scripts-linux/run.sh gitmap help` -> renders GitMap subcommands on Linux
  - `bash scripts-linux/run.sh os help` -> displays OS subcommands without modifying machine alias

### Subtask 24.2: Codex UI, PlotCode UI, VMware Host Verification & Release v1.56.0
- **Owner:** Worker 02
- **Files Modified:** `scripts/78-install-codex/run.ps1`, `scripts/79-install-plotcode/run.ps1`, `tests/e2e-ai-ui-install.ps1`, `version.json`, `scripts/version.json`, `package.json`, `.gitmap/release/latest.json`, `changelog.md`
- **Evidence:**
  - `pwsh -File tests/e2e-ai-ui-install.ps1` -> all 16 checks passed:
    - [ CHECK 01 ] VMware installation directory: True
    - [ CHECK 02 ] VMware essential binaries: True
    - [ CHECK 03 ] VMware version integrity: True
    - [ CHECK 04 ] VMware service status: True
    - [ CHECK 05 ] Claude UI default directory: True
    - [ CHECK 06 ] Claude Code UI desktop link: True
    - [ CHECK 07 ] Claude Code UI start menu: True
    - [ CHECK 08 ] Claude UI GUI live launch: True
    - [ CHECK 09 ] Codex UI default directory: True
    - [ CHECK 10 ] Codex UI desktop link: True
    - [ CHECK 11 ] Codex UI start menu: True
    - [ CHECK 12 ] Codex UI GUI live launch: True
    - [ CHECK 13 ] Claude CLI/UI disambiguation: True
    - [ CHECK 14 ] Codex CLI/UI disambiguation: True
    - [ CHECK 15 ] PlotCode UI installation: True
    - [ CHECK 16 ] Uninstall lifecycle & syntax: True

### Subtask 24.3: Universal Subcommand Help Routing Parity in run.ps1 and run.sh
- **Owner:** Worker 01
- **Files Modified:** `run.ps1`, `scripts/dispatcher/early-help.ps1`, `scripts-linux/run.sh`
- **Evidence:**
  - `.\run.ps1 db help` -> renders database installer options cleanly (exit 0)
  - `.\run.ps1 services help` -> renders services overview cleanly (exit 0)
  - `.\run.ps1 vscode help` -> renders filtered VS Code help without unknown keyword error (exit 0)
  - `.\run.ps1 python help` -> renders filtered Python help without unknown keyword error (exit 0)
  - `bash scripts-linux/run.sh models help` -> renders models help without requiring `jq` (exit 0)
  - `bash scripts-linux/run.sh db help` -> renders database installers (exit 0)
  - `bash scripts-linux/run.sh services help` -> renders services overview (exit 0)
  - `bash scripts-linux/run.sh clean help` -> renders multi-layer cache cleaner options (exit 0)

### Subtask 24.4: Live Verification & Release v1.57.0 Ceremony
- **Owner:** Worker 02
- **Files Modified:** `version.json`, `scripts/version.json`, `package.json`, `.gitmap/release/latest.json`, `changelog.md`
- **Evidence:**
  - Multi-manifest version parity: `1.57.0` verified across all 4 manifests.
  - `changelog.md` updated with comprehensive v1.57.0 release notes.
  - All 16 live E2E AI UI tests verified on host.
