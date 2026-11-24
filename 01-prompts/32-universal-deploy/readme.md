# Universal Binary Deployment & Public Distribution (`32-universal-deploy`) — Index & Catalog

> [!IMPORTANT]
> **Category:** `32-universal-deploy`
> **Official GitHub Gist:** [https://gist.github.com/alimtvnetwork/029a817118a07a7ff270eb1d8b20a6eb](https://gist.github.com/alimtvnetwork/029a817118a07a7ff270eb1d8b20a6eb)
> **Architecture:** Dynamic Identity Discovery, 7z LZMA2 Multi-Volume Chunking, Cryptographic SHA-256 Hashing, Public Distribution Folder Anchoring, and Universal One-Liner Installers
> **Scope:** Cross-platform software distribution for ANY repository (GitMap, Antigravity Manager, CLI tools, desktop apps, microservices)

---

## 📖 Overview

The `32-universal-deploy` prompt category provides a battle-tested, autonomous protocol for packaging and distributing compiled binary applications to public infrastructure without credential friction or bot challenge failures.

### The Problem Solved (RCA-80 & RCA-81)
When creating new repositories via command-line tools or SSH push-to-create, GitLab defaults repository visibility to **Private**. When remote users or automated setup scripts fetch raw files (`/-/raw/main/...`) from a private repository without authentication tokens, GitLab returns `HTTP 302 Found` redirecting to the sign-in page. Cloudflare intercepts these unauthenticated programmatic requests with a managed JavaScript challenge (`Just a moment... Enable JavaScript and cookies to continue`), causing PowerShell `irm ... | iex` and bash `curl ... | sh` commands to immediately crash.

### The Universal Solution
Rather than relying on fragile manual repository settings or missing CLI flags:
1. **Dynamic CLI Identity Discovery:** The agent detects the active GitLab login via `glab auth status` or `ssh -T git@gitlab.com` and confirms with the user before proceeding (never hardcoding usernames).
2. **Dedicated Public Folder Anchoring:** Releases are organized into dedicated subfolders (`<dist-repo>/<project>/releases/v<version>/`) within a confirmed **PUBLIC** repository (e.g. `rup-gitlab/r-files`).
3. **Multi-Part 7z LZMA2 Slicing:** Binaries are split into 8MB (CLI) or 3MB (GUI) volumes, enabling parallel downloads via `aria2c` or `Invoke-WebRequest`.
4. **Cryptographic Integrity:** Every chunk is verified against its SHA-256 checksum recorded in `binary-info.json`.
5. **Universal One-Liners:** Generates unauthenticated one-liners (`irm https://gitlab.com/<user>/<repo>/-/raw/main/<project>/install.ps1 | iex`) that return verified **HTTP 200 OK**.

---

## 🗂️ Catalog of Prompts & Tools

| Artifact | Type | Path / Link | Description |
| :--- | :---: | :--- | :--- |
| **Universal Binary Deployment Prompt** | Prompt | [`01-universal-binary-deployment-prompt.md`](01-universal-binary-deployment-prompt.md) | Master autonomous execution prompt (v4.0.0) parameterized with variable repo `<REPO_NAME>` and explicit public visibility |
| **Single-File Standalone Edition** | Prompt | [`../35-universal-single-file-prompts/03-universal-binary-deployment-prompt.md`](../35-universal-single-file-prompts/03-universal-binary-deployment-prompt.md) | 100% sovereign single-file edition copy-pasteable anywhere with embedded Python deployment engine |
| **Official GitHub Gist** | Gist | [alimtvnetwork/029a817118a07a7ff270eb1d8b20a6eb](https://gist.github.com/alimtvnetwork/029a817118a07a7ff270eb1d8b20a6eb) | Published public Gist for easy sharing across teams, repositories, and instances |
| **Workflow Deployment Engine** | Script | `03-ai-scripts/55-deploy-workflow-engine.py` | Advanced automation script for multi-OS slicing, 10 GB rollover check, manifest synthesis, tag creation, and push |
| **Distribution Python Engine** | Script | `03-ai-scripts/54-deploy-folder-distribution.py` | Automated CLI script to chunk, hash, generate manifests/installers, and push to GitLab |
| **GitMap Native CLI Command** | Command | `gitmap deploy-folder` / `gitmap deploy-public` | Native GitMap CLI command implementing the universal folder deployment flow |
| **Root Cause Analysis (RCA-81)** | Spec | `02-spec/22-app-issues/81-gitlab-deploy-folder-distribution-rca.md` | Comprehensive 4-part root cause analysis of the GitLab private visibility & Cloudflare challenge bug |

---

## 🚀 Quick Start for AI Agents

To deploy any project binary from an existing workspace:

### Method 1: Using the Standalone Python Engine
```powershell
python 03-ai-scripts/54-deploy-folder-distribution.py `
  --project "myapp" `
  --binary-path "target/release/myapp.exe" `
  --deploy-repo "d:\work\deploy\r-files" `
  --folder "myapp" `
  --version "v1.0.0" `
  --volume-size "8m"
```

### Method 2: Using Native GitMap CLI
```powershell
gitmap deploy-folder `
  --project "gitmap" `
  --binary "d:\work\gitmap\gitmap.exe" `
  --dist-repo "d:\work\deploy\r-files" `
  --folder "gitmap" `
  --version "v6.693.0"
```

### Method 3: Using the Canonical Execution Prompt
Feed [`01-universal-binary-deployment-prompt.md`](01-universal-binary-deployment-prompt.md) (or the [GitHub Gist](https://gist.github.com/alimtvnetwork/029a817118a07a7ff270eb1d8b20a6eb)) directly to any AI agent. The agent will discover the active GitLab CLI login, request confirmation, package the application, verify HTTP 200 reachability, and deliver the live installation one-liners.

---

## 🧪 Verified Live Distribution Anchor (`r-files`)

The official public distribution anchor is hosted on GitLab:
- **Repository:** `https://gitlab.com/rup-gitlab/r-files`
- **Visibility:** Public (`HTTP 200 OK`)

### Live Installation One-Liners:
```powershell
# GitMap CLI
irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/gitmap/install.ps1 | iex

# Antigravity Manager (AGM)
irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/agm/install.ps1 | iex

# Universal Multi-Project Router
irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/install.ps1 | iex
```
