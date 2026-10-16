<!-- spec-header:v1 -->
<div align="center">

# Spec: Install WhatsApp on Windows Server

**Slug:** `install-whatsapp-on-windows-server`
**Status:** Draft → In Progress
**Date:** 2026-10-17
**Author:** MD ALIM UL KARIM

*Part of the Dev Tools Setup Scripts toolkit (scripts-fixer-v20)*

</div>

---

## 1. User Request (Verbatim)

> Install WhatsApp on Windows Server: high priority instruction, non-negotiable task. In the scripts fixture, try to install WhatsApp in Windows Server. Usually, you cannot, so try to find a goal, try different approaches, and you can do anything in this machine. It's a VM snapshot taken, so you can try out anything that you like. Make sure that we have installed WhatsApp into the Windows Server machine and also Ubuntu and Windows is easy. Regular Windows is easy. Try to do that. At the end, do a release bump and do a minor release.
>
> Install is stuck, always check with timeout.

## 2. Problem Statement

WhatsApp Desktop has no straightforward install path on Windows Server:

| Platform | Challenge |
|----------|-----------|
| Windows Server 2016/2019/2022/2025 | No Microsoft Store (Store app unavailable). WhatsApp's primary distribution is Store-based. |
| Ubuntu | No official WhatsApp client exists for Linux at all. |
| Regular Windows 10/11 | Easy — already covered by Script 49 (`scripts/49-install-whatsapp/`). |

The existing Script 49 installs via Chocolatey with fallback to the official `WhatsAppSetup.exe`, but it has no Windows Server awareness: it doesn't detect Server SKUs, doesn't skip Store-dependent paths, and doesn't try Server-viable alternatives in the right order.

Additionally: installs can hang indefinitely. Every install step MUST enforce a timeout (user: "Install is stuck, always check with timeout").

## 3. Goals

1. **Windows Server**: Reliable WhatsApp Desktop install via a Server-aware chain: Chocolatey → official `WhatsAppSetup.exe` direct download → winget (if App Installer present). Server OS detection via `Win32_OperatingSystem.ProductType` (1=Workstation, 2=DC, 3=Server).
2. **Ubuntu**: Install the `whatsapp-for-linux` unofficial client (flatpak preferred, .deb fallback).
3. **Regular Windows**: Verify existing Script 49 path still works (no regression).
4. **Timeouts everywhere**: No install step may block forever. Every download and every installer execution enforces a configurable timeout with kill-on-expiry.
5. **Release**: Commit, push, minor version bump.

## 4. Non-Goals

- Microsoft Store installation (explicitly out — Store doesn't exist on Server; already skipped per 2025-batch decision).
- WhatsApp Web browser wrapper as primary (only as last-resort documentation, not implemented).
- ARM64 Windows Server (x64 only for v1).

## 5. Design

### 5.1 Windows Server detection

```powershell
$os = Get-CimInstance Win32_OperatingSystem
$isServer = $os.ProductType -ne 1  # 2 = Domain Controller, 3 = Server
```

When `$isServer` is `$true`:
- Log clearly: "Windows Server detected — using Server install chain (no Store)"
- Skip any Store-dependent logic unconditionally

### 5.2 Server install chain (in order)

1. **Chocolatey** (`choco install whatsapp -y`): Works on Server when Chocolatey is present. Reuse existing `Install-ChocoPackage`.
2. **Official installer** (`WhatsAppSetup.exe` from `https://www.whatsapp.com/download` direct link): Standalone, no Store needed. Already implemented as fallback in `helpers/whatsapp.ps1` — promote to second in chain on Server.
3. **winget** (`winget install --id WhatsApp.WhatsApp --silent`): Only if `winget` is on PATH (App Installer sideloaded on Server 2022+).

Each step: verify `Get-WhatsAppPath` after; on failure proceed to next. All steps honor the global timeout.

### 5.3 Timeout contract (all platforms)

- Downloads: timeout via `Invoke-WebRequest -TimeoutSec` (default 300s).
- Installer execution: `Start-Process -PassThru` + `$proc.WaitForExit($timeoutMs)`; kill on expiry; log and continue to next method.
- Timeout values configurable via `config.json` (`timeouts.downloadSeconds`, `timeouts.installSeconds`).

### 5.4 Ubuntu (`scripts-linux/`)

New script following `scripts-linux/` conventions:
1. Detect Ubuntu/Debian via `/etc/os-release`.
2. Prefer flatpak: `flatpak install -y flathub io.github.eneshecan.WhatsAppForLinux` (install flatpak first if missing).
3. Fallback: download latest `whatsapp-for-linux` .deb from GitHub releases and `dpkg -i`.
4. Verify: `flatpak list` or `dpkg -s whatsapp-for-linux`.

### 5.5 Regular Windows

No changes to Script 49's existing chain. Verification only: existing Pester/config tests still pass, `run.ps1 -I 49 install` logic untouched for Workstation SKUs.

## 6. File Changes

| File | Change |
|------|--------|
| `scripts/49-install-whatsapp/helpers/whatsapp.ps1` | Add `Test-IsWindowsServer`, Server-aware chain ordering, timeout params on all steps |
| `scripts/49-install-whatsapp/config.json` | Add `serverChain` order + `timeouts` block |
| `scripts/49-install-whatsapp/log-messages.json` | Add Server-specific log messages |
| `scripts-linux/49-install-whatsapp/` (new) | Ubuntu installer (flatpak → .deb), following scripts-linux conventions |
| `02-spec/21-app/install-whatsapp-on-windows-server/` | This spec |
| `.ai-memory/plans/install-whatsapp-on-windows-server.md` | Parent plan |
| `.ai-memory/plans/subtasks/install-whatsapp-on-windows-server/` | Subtask files |

## 7. Acceptance Criteria

- [ ] `Test-IsWindowsServer` correctly identifies Server vs Workstation via ProductType
- [ ] On Server: install chain tries Chocolatey → official installer → winget, in order, stopping at first verified success
- [ ] Every download and installer step enforces a timeout; hung installer is killed and logged
- [ ] Ubuntu script installs `whatsapp-for-linux` and verifies
- [ ] Regular Windows path (Script 49) unchanged and working
- [ ] `bash -n` / PowerShell parser clean on all touched scripts
- [ ] Committed with relative paths only, pushed, minor release bumped

## 8. Risks

- **WhatsAppSetup.exe may refuse Server SKUs**: The official installer checks OS version. Mitigation: chain continues to winget; document manual fallback.
- **No Windows Server test environment here**: This Linux VM cannot execute PowerShell installers. Mitigation: syntax validation + dry-run logic review; user tests on their snapshotted VM.
- **whatsapp-for-linux is unofficial**: May lag behind WhatsApp protocol changes. Documented as best-effort for Linux.
