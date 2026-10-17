<!-- spec-header:v1 -->
<div align="center">

<img src="../../assets/icon-v1-rocket-stack.svg" alt="Script 49 — Install Whatsapp" width="128" height="128"/>

# Script 49 — Install Whatsapp

**Part of the Dev Tools Setup Scripts toolkit**

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)](https://github.com/alimtvnetwork/gitmap-v6#requirements)
[![Windows](https://img.shields.io/badge/Windows-10%2F11%20%7C%20Server-0078D6?logo=windows&logoColor=white)](https://github.com/alimtvnetwork/gitmap-v6#requirements)
[![Script](https://img.shields.io/badge/Script-49-8b5cf6)](https://github.com/alimtvnetwork/gitmap-v6/blob/main/scripts/registry.json)
[![License](https://img.shields.io/badge/License-MIT-eab308)](https://github.com/alimtvnetwork/gitmap-v6/blob/main/LICENSE)
[![Version](https://img.shields.io/badge/Version-v1.58.0-f97316)](https://github.com/alimtvnetwork/gitmap-v6/blob/main/scripts/version.json)
[![Changelog](https://img.shields.io/badge/Changelog-Latest-ec4899)](https://github.com/alimtvnetwork/gitmap-v6/blob/main/changelog.md)
[![Repo](https://img.shields.io/badge/Repo-gitmap--v6-22c55e?logo=github&logoColor=white)](https://github.com/alimtvnetwork/gitmap-v6)

*Mandatory spec header — see [02-spec/00-spec-writing-guide](../00-spec-writing-guide/readme.md).*

</div>

---

## Overview

Implementation folder for **Script 49 — Install Whatsapp**. Installs WhatsApp Desktop across Windows Server (2019/2022/2025) and client Windows (10/11):
- **Windows Server Engine**: Solves the Microsoft Store / Winget platform rejection (`0x803fb104`) on Windows Server by compiling and deploying a native application launcher at `%LOCALAPPDATA%\WhatsApp\WhatsApp.exe` backed by an isolated Chromium profile (`%LOCALAPPDATA%\WhatsApp\User Data`), desktop shortcuts, Start Menu integration, and `whatsapp://` URL protocol handling.
- **Client Windows Waterfall**: Orchestrates automated installation on Windows 10/11 through a multi-tiered pipeline:
  1. **Winget MSStore**: Installs package `9NKSQGP7F2NH` with `--disable-interactivity --accept-package-agreements --accept-source-agreements --silent` bounded by a 60-second watchdog.
  2. **Chocolatey Fallback**: Deploys `whatsapp` package via Chocolatey if winget is unavailable or unverified.
  3. **Official Installer Fallback**: Downloads official setup payload, validating against corrupted stubs (< 1MB) with a 30-second watchdog.
  4. **Native Engine Fail-Safe**: Falls back to the Windows Server Native Desktop Launcher engine if all external package channels are exhausted.
- **Strict Watchdog Enforcement**: All external operations have strict timeout bounds (60s for winget, 30s for installers) to prevent unattended automation hangs.

## Quick start

```powershell
# From repo root
.\run.ps1 -I 49 install

# Direct alias invocation
.\run.ps1 install whatsapp
.\run.ps1 install wa

# Uninstall (sweeps registry, launcher executable, shortcuts, and tracking)
.\run.ps1 -I 49 uninstall
```

## Windows Server Engine

Windows Server environments lack consumer Microsoft Store packages and reject MSIX Store packages with error `0x803fb104`. Script 49 automatically detects Windows Server editions (`Test-IsWindowsServer`) and activates the Native Desktop Launcher Engine:
1. Detects available Chromium browser (Google Chrome or Microsoft Edge).
2. Compiles a native Windows executable at `%LOCALAPPDATA%\WhatsApp\WhatsApp.exe` via `Add-Type`.
3. Creates isolated user profile directory `%LOCALAPPDATA%\WhatsApp\User Data`.
4. Creates Start Menu and Desktop shortcuts with safe desktop path resolution.
5. Registers the `whatsapp://` URL protocol handler in the user registry.

## Layout

| File | Purpose |
|------|---------|
| `run.ps1` | Entry point dispatched by the root `run.ps1`. |
| `helpers/whatsapp.ps1` | Core logic for Windows Server engine, winget, Chocolatey, official fallback, and cleanup. |
| `config.json` | Configuration containing timeout bounds, package names, registry keys, and shortcut paths. |
| `log-messages.json` | Localized and structured log catalog for winget, timeouts, and engine status. |
| `manifest.json` | Script manifest metadata conforming to schema 1.0. |
| `readme.md` | User documentation and usage guide. |

---

## Author & Enterprise Stewardship

Designed and maintained as part of the **Dev Tools Setup Scripts toolkit**.

### Author & Core Architecture
- **Lead Architect:** MD ALIM UL KARIM
- **GitHub:** [@alimtvnetwork](https://github.com/alimtvnetwork)

### Riseup Asia LLC
[Riseup Asia LLC](https://riseup-asia.com) is a top-leading software company headquartered in Wyoming, USA.

| | |
|---|---|
| **Website** | [riseup-asia.com](https://riseup-asia.com) |
| **Facebook** | [riseupasia.talent](https://www.facebook.com/riseupasia.talent/) |
| **LinkedIn** | [Riseup Asia](https://www.linkedin.com/company/105304484/) |
| **YouTube** | [@riseup-asia](https://www.youtube.com/@riseup-asia) |

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](../../LICENSE) file for the full text.

```
Copyright (c) 2026 Alim Ul Karim
```
