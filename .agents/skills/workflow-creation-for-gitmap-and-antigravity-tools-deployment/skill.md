---
name: workflow-creation-for-gitmap-and-antigravity-tools-deployment
description: >-
  Workflow creation for GitMap and Antigravity Tools/Manager deployment: coordinates multi-OS binary compilation, 10 GB repository rollover guards, dedicated GitLab repository distribution (deploy-gitmap, deploy-antigravity-manager) with public r-files fallback mirror, multi-volume 7z slicing, and auto-update routing.
---

# Workflow Creation for GitMap and Antigravity Tools Deployment

Autonomously orchestrates the deployment and updating lifecycle for **GitMap** and **Antigravity Manager (AGM) / Antigravity Tools**, enforcing dedicated repository isolation, 10 GB capacity limits, multi-OS split slicing, and resilient update routing.

## Operational Pillars

1. **Dedicated Repositories with Public Mirror Fallback:**
   - GitMap: `rup-gitlab/deploy-gitmap`
   - Antigravity Manager: `rup-gitlab/deploy-antigravity-manager`
   - Shared Public Mirror: `rup-gitlab/r-files`
2. **Update Routing Configuration:**
   - Both applications configure their update checkers (`cmdupdate/selfupdate.go` for GitMap, `installagmanager.go` / `install-gitlab.ps1` for AGM) to query their dedicated repository's `binary-info.json` first.
   - If an unauthenticated fetch redirects to `users/sign_in` or returns HTML (RCA-80 / RCA-81 private visibility challenge), the update client automatically falls back to `rup-gitlab/r-files`.
3. **10 GB Repository Rollover Guard:**
   - Tracks deployment repository footprint.
   - Enforces automated warnings and rollover provisioning (`<project>-deploy-2`) upon reaching 9.5 GB.
4. **Multi-OS Slicing & Laravel-Style Hierarchy:**
   - Stores assets under `releases/v<version>/<os-arch>/`.
   - Slices binaries using 7-Zip LZMA2 ultra compression:
     - GitMap (CLI): 8 MB volumes (`-v8m`).
     - Antigravity Manager (GUI): 5 MB volumes (`-v5m`).
   - Generates SHA-256 integrity digests for all chunks.
5. **Smart Client Installers:**
   - Generates PowerShell (`install.ps1`) and Bash (`install.sh`) scripts.
   - Incorporates `aria2c -x 16 -s 16` multi-connection downloading, SHA-256 verification, and `.old` locked executable replacement.

## Quick Invocations

```powershell
# Deploy GitMap via dedicated workflow engine
python 03-ai-scripts/55-deploy-workflow-engine.py --project gitmap --binary-path /path/to/gitmap.exe --deploy-repo d:\work\deploy\gitmap --version v6.693.0 --volume-size 8m --root-mode

# Deploy Antigravity Manager via dedicated workflow engine
python 03-ai-scripts/55-deploy-workflow-engine.py --project antigravity-manager --binary-path /path/to/agm.exe --deploy-repo d:\work\deploy\antigravity-manager --version v5.50.0 --volume-size 5m --root-mode
```
