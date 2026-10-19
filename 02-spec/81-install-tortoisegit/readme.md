<!-- spec-header:v1 -->
<div align="center">

<img src="../../assets/icon-v1-rocket-stack.svg" alt="Script 81 — Install TortoiseGit" width="128" height="128"/>

# Script 81 — Install TortoiseGit

**Part of the Dev Tools Setup Scripts toolkit**

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)](https://tortoisegit.org/)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?logo=windows&logoColor=white)](https://tortoisegit.org/)
[![Script](https://img.shields.io/badge/Script-81-8b5cf6)](https://community.chocolatey.org/packages/TortoiseGit/2.4.0.2)
[![License](https://img.shields.io/badge/License-GPL--2.0-eab308)](https://tortoisegit.org/about/)
[![Package](https://img.shields.io/badge/Choco-2.4.0.2-22c55e?logo=chocolatey&logoColor=white)](https://community.chocolatey.org/packages/TortoiseGit/2.4.0.2)

</div>

---

# Install TortoiseGit (Script 81)

## Overview

Script 81 installs **TortoiseGit 2.4.0.2** on Windows -- the Windows Explorer shell interface for Git.
It provides icon overlays showing Git file status, Windows Explorer context menus, visual commit and diff dialogs (`TortoiseGitProc.exe`, `TortoiseGitMerge.exe`), and revision graphs.

Installation leverages Chocolatey package `tortoisegit` version `2.4.0.2` ([community.chocolatey.org/packages/TortoiseGit/2.4.0.2](https://community.chocolatey.org/packages/TortoiseGit/2.4.0.2)) with automatic fallback to direct MSI extraction from the package `.nupkg` archive when Chocolatey is absent.

## Install commands

```powershell
# Windows, via the root dispatcher
.\run.ps1 -I 81
.\run.ps1 install tortoisegit
.\run.ps1 install tgit

# Check installation status
.\run.ps1 -I 81 -- check

# Help
.\run.ps1 -I 81 -- -Help

# Uninstall TortoiseGit
.\run.ps1 -I 81 -- uninstall
```

## Commands

| Command | Windows | Behaviour |
|---------|---------|-----------|
| `install` (default) | yes | Installs TortoiseGit 2.4.0.2 via Chocolatey or direct MSI fallback |
| `check` | yes | Probes for `TortoiseGitProc.exe` and reports path |
| `uninstall` | yes | Uninstalls package via Chocolatey and purges `.installed/` record |

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success: installed, already installed, check passed, or uninstalled cleanly |
| `1` | Failure: download failed, MSI exit code error, or non-admin execution |

## Config (`config.json`)

| Key | Description |
|-----|-------------|
| `tortoisegit.enabled` | Enable/disable the script |
| `tortoisegit.chocoPackage` | Chocolatey package name (`tortoisegit`) |
| `tortoisegit.version` | Pinned package version (`2.4.0.2`) |
| `tortoisegit.nupkgUrl` | Upstream nupkg URL (`https://packages.chocolatey.org/TortoiseGit.2.4.0.2.nupkg`) |
| `tortoisegit.chocoUrl` | Chocolatey community page URL |

Default Windows install directory: `C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe`.
