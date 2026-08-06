<!-- spec-header:v1 -->
<div align="center">

<img src="../../assets/icon-v1-rocket-stack.svg" alt="Script 71 — Install git-compact" width="128" height="128"/>

# Script 71 — Install git-compact

**Part of the Dev Tools Setup Scripts toolkit**

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)](https://github.com/alimtvnetwork/git-compact#requirements)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?logo=windows&logoColor=white)](https://github.com/alimtvnetwork/git-compact#requirements)
[![Script](https://img.shields.io/badge/Script-71-8b5cf6)](https://github.com/alimtvnetwork/git-compact)
[![License](https://img.shields.io/badge/License-MIT-eab308)](../../LICENSE)
[![Repo](https://img.shields.io/badge/Repo-git--compact-22c55e?logo=github&logoColor=white)](https://github.com/alimtvnetwork/git-compact)

</div>

---

# Install git-compact (Script 71)

## Overview

Script 71 installs the **git-compact CLI**, a small tool that compacts and prunes local
git repositories (aggressive `gc`, `reflog expire`, `repack`). It uses the upstream
remote installer from `alimtvnetwork/git-compact`, with a release-ZIP fallback on Windows.

## Install commands

```powershell
# Windows, via the root dispatcher
.\run.ps1 -I 71
.\run.ps1 install git-compact

# Pin a ref (branch / tag / commit)
.\run.ps1 -I 71 -Tag v1.2.0

# Help
.\run.ps1 -I 71 -- -Help

# Direct upstream one-liner (standalone)
irm https://raw.githubusercontent.com/alimtvnetwork/git-compact/main/install.ps1 | iex
```

```bash
# Linux / macOS
./scripts-linux/71-install-git-compact/run.sh install
./scripts-linux/71-install-git-compact/run.sh install --tag v1.2.0
./scripts-linux/71-install-git-compact/run.sh --help

# Direct upstream one-liner (standalone)
curl -fsSL https://raw.githubusercontent.com/alimtvnetwork/git-compact/main/install.sh | sh
```

## Commands

| Command | Windows | Linux / macOS | Behaviour |
|---------|---------|---------------|-----------|
| `install` (default) | yes | yes | Remote installer, then ZIP fallback (Windows) |
| `check` | yes | yes | Runs `git-compact --version` and reports the resolved binary |
| `repair` | no | yes | Removes the binary and reinstalls |
| `uninstall` | yes | yes | Removes the binary and purges tracking |

## Ref pinning

Precedence on Windows: `-Tag` / `-Version` flag > `gitCompact.releaseTag` > `gitCompact.fallbackTag` > `main`.
Precedence on Linux: `--tag` flag > `$GIT_COMPACT_TAG` > `install.releaseTag` > `main`.
Numeric refs such as `1.2.0` are normalised to `v1.2.0`; branch names pass through unchanged.

## Config (`config.json`)

| Key | Description |
|-----|-------------|
| `devDir.mode` / `devDir.default` / `devDir.override` | Windows install-directory resolution |
| `gitCompact.enabled` | Enable/disable the install |
| `gitCompact.installUrl` | Remote installer URL template (`{tag}` placeholder) |
| `gitCompact.repo` | Upstream GitHub repository |
| `gitCompact.releaseZipUrl` | ZIP fallback URL template (`{tag}` placeholder) |
| `gitCompact.installDir` | Hard override for the install directory |
| `install.binDir` (Linux) | Target bin directory, default `~/.local/bin` |

Default Windows install directory: `C:\dev-tool\GitCompact` (resolved via `devDir`).
Default Linux target: `~/.local/bin/git-compact`.

## Verification

Post-install the script runs `git-compact --version`, prints the resolved binary path,
and marks the run `[OK]`. Failures log an explicit file error with the exact path and reason.

## See also

- [Script 35 — Install GitMap](../35-install-gitmap/readme.md)
- [Generic install script behaviour](../00-generic-install-script-behavior/01-readme.md)
