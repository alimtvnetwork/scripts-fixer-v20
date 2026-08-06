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

*Mandatory spec header — see [spec/00-spec-writing-guide](../00-spec-writing-guide/readme.md).*

</div>

---

## Overview

Implementation folder for **Script 71 — Install git-compact**. The full design contract lives in the spec.

## Quick start

```powershell
# From repo root
.\run.ps1 -I 71 install
.\run.ps1 -I 71 -- -Help
```

### Upstream one-liners (git-compact)

```powershell
# Windows
irm https://raw.githubusercontent.com/alimtvnetwork/git-compact/main/install.ps1 | iex
```

```bash
# UNIX (macOS / Linux)
curl -fsSL https://raw.githubusercontent.com/alimtvnetwork/git-compact/main/install.sh | sh
```

Pin a different ref (branch / tag / commit) with `-Tag` / `--tag`:

```powershell
.\run.ps1 -I 71 -Tag v1.2.0
```

## Layout

| File | Purpose |
|------|---------|
| `run.ps1` | Entry point dispatched by the root `run.ps1`. |
| `config.json` | External config (URLs, install dir, toggles). |
| `log-messages.json` | All user-facing messages and the help block. |
| `helpers/git-compact.ps1` | Install / verify / uninstall helper functions. |

## See also

- [Full spec](../../spec/71-install-git-compact/readme.md)
- [Script 35 — Install GitMap](../35-install-gitmap/readme.md)
