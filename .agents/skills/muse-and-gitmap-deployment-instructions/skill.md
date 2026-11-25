---
name: muse-and-gitmap-deployment-instructions
description: >-
  Autonomously orchestrate Muse onboarding, GitLab unauthenticated deployment, GitMap universal binary deployment, GitMap EA automated conflict resolution and commit/push, dynamic prompt serving via gitmap prompts/pa, and repo-cache CML 1:1 chat seed alignment.
---

# Muse and GitMap Deployment Instructions

Use this skill when tasked with configuring, onboarding, or deploying Muse autonomous agents, managing GitLab public distribution scripts, executing automated conflict resolution via `gitmap ea`, serving prompt templates dynamically via `gitmap prompts` / `gitmap pa`, or aligning CML (Chat Memory Log) 1:1 chat seeds in `repo-cache/08-muse-ai/`.

## 1. Core Architecture & Deployment Invariants

### 1.1 GitLab High-Speed Deployment Engine
For unauthenticated public distribution of binaries (e.g. GitMap, Antigravity Manager), leverage GitLab raw script deployment:
```bash
# GitMap Installation
curl -fsSL https://gitlab.com/rup-gitlab/deploy-gitmap/-/raw/main/install.sh | bash
irm https://gitlab.com/rup-gitlab/deploy-gitmap/-/raw/main/install.ps1 | iex

# Antigravity Manager Installation
curl -fsSL https://gitlab.com/rup-gitlab/deploy-antigravity-manager/-/raw/main/install.sh | bash
irm https://gitlab.com/rup-gitlab/deploy-antigravity-manager/-/raw/main/install.ps1 | iex
```

#### What It Does:
- **Zero-Credential Public Distribution:** Produces unauthenticated, high-speed universal one-liner installers (`irm ... | iex` / `curl ... | bash`) returning verified `HTTP 200 OK`.
- **Dynamic Variable Repo Naming (`<REPO_NAME>`):** Supports parameterized repository creation and subfolder isolation (`<REPO_NAME>/<project>/releases/v<version>/<os-arch>/`).
- **Explicit Public Visibility Invariant (RCA-80 / RCA-81):** Guarantees `--public`, `"visibility": "public"`, and `"enforce_auth_checks_on_uploads": false`.
- **10 GB Rollover Protection:** Monitors repository size and triggers clean rollover (e.g. `<REPO_NAME>-2`) when approaching 9.5 GB without breaking historical URLs.
- **Multi-OS 7z LZMA2 Slicing & Verification:** Slices binaries into small chunks (`-v8m` for CLI, `-v5m` for GUI) with SHA-256 cryptographic verification via `binary-info.json`.
- **Automated Locked-Binary Replacement:** Installers rename active executables to `.old` with retry loops before replacing.
- **NO-CLONE Deploy Invariant:** Strictly forbids `git clone` on distribution repositories. All interactions use `glab api` or direct raw HTTP downloads to prevent disk exhaustion and untrusted script execution.

### 1.2 GitMap Universal Binary Deployment Gist
- **Authoritative Gist:** `https://gist.github.com/alimtvnetwork/029a817118a07a7ff270eb1d8b20a6eb`
- **Canonical Local Path:** `01-prompts/32-universal-deploy/01-universal-binary-deployment-prompt.md`
- Inspect this canonical spec for complete cross-platform binary deployment patterns, installer generation, and release packaging.

---

## 2. GitMap `ea` Command & Conflict Resolution

Whenever an agent finishes a task or encounters git divergence/merge conflicts:
```bash
# Execute autonomous conflict resolution, staging, atomic commit, and upstream push
gitmap ea
# Aliases:
gitmap execute-all
gitmap resolve-commit-push
```

### Execution Pipeline:
1. **Immutable Backup Snapshot:** Stashes current state into the GitMap backup vault.
2. **Divergence & Conflict Detection:** Proactively inspects tracking remotes and upstream changes.
3. **Autonomous AI Conflict Resolution:** Resolves collision files cleanly across known code patterns without data loss.
4. **Git Staging:** Stages all modified files.
5. **Atomic Commit Formatting:** Executes conventional commit via `gitmap cpf "<module> - <summary>"`.
6. **Remote Push:** Pushes to upstream tracking remote.

---

## 3. Dynamic Prompt Serving & Prompt Assist

### 3.1 Dual-Store Discovery (`gitmap prompts ls`)
GitMap dynamically indexes prompt templates from two sources:
1. Local user configuration directory: `~/.gemini/config/prompts/*.md`.
2. Canonical repository directory: `01-prompts/**/*.md` across all 35 subcategories (288+ templates).

```bash
# List all 288+ indexed prompts in a styled Tokyo Night table
gitmap prompts ls

# View prompt contents
gitmap prompts show <slug>
```

### 3.2 Context Resolution (`gitmap pa`)
When detailed context or companion files are needed:
```bash
# View prompt with companion referenced markdown links, specs, and scripts
gitmap pa <slug>
# Equivalent to:
gitmap prompt show <slug> --context
```

---

## 4. CML (Chat Memory Log) 1:1 Chat Seeds in `repo-cache/08-muse-ai/`

- All chat seed files live in `repo-cache/08-muse-ai/chat-seeds/<name>.md`.
- Each file provides a 1:1 context reconstruction for a specific repository:
  - `gitmap-v28-repo.md`: GitMap CLI engine (`v6.704.0`).
  - `agm.md`: Antigravity Manager (`v5.76.4`).
  - `cat-my-v12-repo.md`: Industrial vision system (`v4.129.15`).
  - `macro-ahk-v55-repo.md`: Browser automation extension (`v6.102.75`).
  - `wp-exam.md`: WordPress assessment platform (`v0.4.86`).
  - `movie-cli.md`: Media automation engine (`v2.343.88`).
  - `scripts-fixer.md`: Workstation setup fixtures (`v1.62.68`).
  - `repo-cache.md`: OS optimization suite and session cache repository.

### Rebuilding Context in Fresh Chats:
Run the first prompt specified in `08-muse-ai/chat-seeds/<name>.md` to immediately restore context, verify git state, and report active version numbers.
