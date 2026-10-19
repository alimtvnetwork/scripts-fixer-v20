# Script 81 — Install TortoiseGit

## Overview

Installs **TortoiseGit 2.4.0.2** on Windows -- the Windows Explorer shell interface for Git.
Supports installation via Chocolatey or direct standalone extraction from the official Chocolatey `.nupkg` package MSI.

## Usage

```powershell
# Install TortoiseGit (default)
.\run.ps1 -I 81
.\run.ps1 install tortoisegit
.\run.ps1 install tgit

# Check installation status
.\run.ps1 -I 81 -- check

# Show help
.\run.ps1 -I 81 -- -Help

# Uninstall TortoiseGit
.\run.ps1 -I 81 -- uninstall
```

## Features

- **Dual-Engine Installation**: Uses Chocolatey package `tortoisegit 2.4.0.2` when available, with automatic fallback to direct MSI extraction from the package `.nupkg` archive.
- **Integrity Verified**: Uses Chocolatey official release `https://community.chocolatey.org/packages/TortoiseGit/2.4.0.2`.
- **System Overlay Support**: Sets up context menu shell extensions, diff tools (`TortoiseGitMerge.exe`), blame viewer, and status overlays.
