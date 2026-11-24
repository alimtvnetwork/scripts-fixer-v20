---
name: deploy-repository-and-antigravity-tools-instructions
description: >-
  Universal repository deployment and folder-based public distribution engine: scaffolds public distribution folders, splits binaries into 7-Zip LZMA2 multi-volume chunks, synthesizes binary-info.json manifests, generates aria2c-accelerated client installers, and automates deployment via Python script and native GitMap commands.
---

# Deploy Repository and Antigravity Tools Instructions

Universal repository deployment engine and folder distribution framework designed for zero-touch distribution of Antigravity Manager, Antigravity Tools, GitMap, and fleet services.

## Overview

1. **Folder-Based Public Distribution Anchor (`r-files`):** Consolidates binary distribution into a confirmed public repository (`https://gitlab.com/rup-gitlab/r-files`) organized by project folders (`gitmap/`, `agm/`), avoiding private repo Cloudflare 302 redirects (RCA-80 & RCA-81).
2. **7-Zip LZMA2 Multi-Volume Chunking:** Slices compiled executables into configurable volume chunks (`-v8m` for gitmap, `-v3m` for agm) to ensure fast, resilient transfers.
3. **Automated Python Engine (`03-ai-scripts/54-deploy-folder-distribution.py`):** Automates the entire packaging, hashing, manifest generation, installer creation, and git commit/push workflow.
4. **Native GitMap Integration:** Exposes `gitmap deploy-folder` / `gitmap deploy-public` / `gitmap deploy-dist` for one-command deployment.
5. **Aria2c Client Installers:** Generates `install.ps1` and `install.sh` utilizing 16 parallel connections per chunk, cryptographic checksum assertion, and atomic binary swapping (`.old`/`.bak`).

## Commands & Usage

```powershell
# Deploy gitmap using Python automation engine
python 03-ai-scripts/54-deploy-folder-distribution.py --project gitmap --binary-path /path/to/gitmap.exe --deploy-repo d:\work\deploy\r-files --folder gitmap --version v6.693.0 --volume-size 8m

# Deploy AGM using Python automation engine
python 03-ai-scripts/54-deploy-folder-distribution.py --project agm --binary-path /path/to/agm.exe --deploy-repo d:\work\deploy\r-files --folder agm --version v4.329.0 --volume-size 3m

# Deploy via native GitMap CLI
gitmap deploy-folder --project gitmap --folder gitmap --binary-path /path/to/gitmap.exe
```

## Universal One-Liners

```powershell
# GitMap CLI
irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/gitmap/install.ps1 | iex

# Antigravity Manager
irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/agm/install.ps1 | iex

# Universal Router
irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/install.ps1 | iex
```
