---
name: universal-binary-deployment
description: >-
  Universal cross-platform binary deployment workflow engine: provisions dedicated or shared GitLab repositories, enforces 10 GB rollover threshold, compresses binaries into 7z LZMA2 multi-volume chunks (8MB CLI / 5MB GUI), computes SHA-256 integrity digests, synthesizes binary-info.json manifests, generates aria2c-accelerated smart client installers, and automates multi-OS distribution.
---

# Universal Binary Deployment & Workflow Engine

Universal cross-platform binary deployment workflow engine and distribution framework designed for zero-touch, resilient distribution of software binaries (GitMap, Antigravity Manager, CLI tools, desktop applications).

## Architectural Foundations

1. **Dedicated Repositories & Public Distribution Anchor:**
   - **Dedicated Mode:** Each project maintains its own dedicated GitLab repository (e.g., `rup-gitlab/deploy-gitmap`, `rup-gitlab/deploy-antigravity-manager`).
   - **Public Anchor Mirror:** `rup-gitlab/r-files` maintains a multi-project directory layout (`gitmap/`, `agm/`, etc.) serving as an unauthenticated fallback mirror.
2. **GitLab Default Visibility & Resilient Fallback (RCA-80 & RCA-81):**
   - Repositories created via SSH push-to-create default to **Private**.
   - Unauthenticated raw fetches to private repos redirect (`HTTP 302`) to `users/sign_in` where Cloudflare intercepts with a bot-detection HTML page.
   - **Resilient Fallback Rule:** All client installers (`install.ps1`, `install.sh`) and self-updating routines query the dedicated deployment repository first. If the response redirects or returns HTML, they automatically and gracefully fall back to the public `r-files` mirror.
3. **10 GB Repository Rollover Guard:**
   - Repositories track cumulative size (`.git` + working tree + new chunks).
   - A hard threshold of 9.5 GB triggers an automated operator warning to initialize a rollover repository (e.g., `<project>-deploy-2`) without breaking historical releases.
4. **Laravel-Inspired Release Hierarchy:**
   - Binaries are stored under `releases/v<version>/<os-arch>/<project>-<os-arch>.7z.*`.
   - Backed by an authoritative `binary-info.json` manifest recording latest versions, chunks, and hashes.
5. **Multi-OS Split 7z LZMA2 Slicing:**
   - CLI tools: 8 MB chunks (`-v8m`).
   - GUI desktop applications: 5 MB chunks (`-v5m`).
   - Cryptographic SHA-256 digests computed for every volume.
6. **Smart Client Installers:**
   - Synthesizes `install.ps1` and `install.sh` supporting `-Version` overrides, `aria2c -x 16 -s 16` parallel downloads, SHA-256 integrity verification, `.old` locked executable replacement, and user PATH registration.

## Commands & Usage

```powershell
# Deploy GitMap to dedicated deployment repository
python 03-ai-scripts/55-deploy-workflow-engine.py \
  --project gitmap \
  --binary-path /path/to/gitmap.exe \
  --deploy-repo d:\work\deploy\gitmap \
  --version v6.693.0 \
  --volume-size 8m \
  --root-mode

# Deploy Antigravity Manager to dedicated deployment repository
python 03-ai-scripts/55-deploy-workflow-engine.py \
  --project antigravity-manager \
  --binary-path /path/to/agm.exe \
  --deploy-repo d:\work\deploy\antigravity-manager \
  --version v5.50.0 \
  --volume-size 5m \
  --root-mode

# Deploy to shared public mirror anchor (r-files)
python 03-ai-scripts/55-deploy-workflow-engine.py \
  --project gitmap \
  --binary-path /path/to/gitmap.exe \
  --deploy-repo d:\work\deploy\r-files \
  --folder gitmap \
  --version v6.693.0 \
  --volume-size 8m
```

## Universal One-Liners

```powershell
# GitMap CLI (Primary dedicated repo with automatic r-files fallback)
irm https://gitlab.com/rup-gitlab/deploy-gitmap/-/raw/main/install.ps1 | iex

# Antigravity Manager (Primary dedicated repo with automatic r-files fallback)
irm https://gitlab.com/rup-gitlab/deploy-antigravity-manager/-/raw/main/install.ps1 | iex

# Shared Public Anchor (r-files mirror)
irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/gitmap/install.ps1 | iex
irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/agm/install.ps1 | iex
```
