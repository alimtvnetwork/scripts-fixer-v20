# Muse Prompts (`27-muse-prompts`) — Index & Catalog

> [!IMPORTANT]
> **Category:** `27-muse-prompts`
> **Architecture:** Clean Two-Tier Onboarding & Task Execution Engine (V6 Engine)
> **Scope:** Unified Single Catalog, Strict Separation of Concerns (`general/` vs `private/`), Sequenced Execution (`01-` Onboarding, `02-` Task Execution), Private Repository Local CI/CD Verification, and GitMap Private Distribution.

---

## How to Run — Two-Tier Sequenced Workflow

Follow the exact two-tier sequence below. First run onboarding once per fresh Muse AI session, then drive every subsequent task with the execution prompt.

### 1. Sequence Map

```text
Fresh Muse AI Session
         │
         ▼
[Step 01: Onboarding]
   Paste 01-muse-master-prompt.md (9-step onboarding ritual & bootstrap)
         │
         ▼
[Step 02: Task Execution]
   Paste 02-muse-execute-task.md after each incoming task instruction
```

### 2. Which Variant to Choose

- **Private Variant (`private/`):** For MD ALIM UL KARIM (`alimtvnetwork`). Pre-filled with identity, named repository scope, GMT+8 display timezone, `go-email-reader` setup, Literally / Letterly title convention, and standing rules.
- **General Variant (`general/`):** For any other operator. All personal details are replaced with bracketed placeholders (`<your-github-org>`, `[your-guidelines-repo]`, `[your-primary-cli-repo]`) to fill in before first use.

---

## Step 01: The 9-Step Onboarding Ritual

Paste `01-muse-master-prompt.md` into a fresh Muse chat and execute the 9 steps in strict linear order with mandatory step-by-step reporting:

| Order | Step | What to Run / Verify | Dependency |
|---|---|---|---|
| 1 | Step 1 — 7-Zip Prerequisite, GitMap First & AGM Setup | Verify 7-Zip (`p7zip-full` / `7z`); on fresh nodes install GitMap FIRST via zero-credential GitLab script (`curl ... install.sh` / `irm ... install.ps1` with automated 7-Zip extraction); install Antigravity Manager (AGM / ADM) alongside; verify `gitmap version` and `agm version` | Internet / 7-Zip / Go installed |
| 2 | Step 2 — Dual Login (GitHub & GitLab), SSH Keygen & Hard Gate | `gh auth status` and `ssh -T git@gitlab.com` fast-path bypass; if not logged in, ask user for SSH key format/sequence (`<operator>-muse<sequence>-<tag>`), generate key via GitMap or ssh-keygen, share public key immediately before learning, guide user to add to BOTH GitHub and GitLab, wait for user confirmation (`[DONE]`), verify dual SSH connectivity and CLI (device flow if required); strict ban on Gmail and unapproved personal email | Step 1 |
| 3 | Step 3 — Clone Default Repositories & Establish Side Chats | Clone 13 default repos (`repo-cache`, `supabase-running-v2`, `lara-publishing-v1`, `lara-quick-public`, etc.) using `gitmap clone <url> <destination>`; seed 5 side chats + 3 vault repos; secondary repos require explicit approval | Step 2 |
| 4 | Step 4 — Pull All Repositories | Pull repos avoiding DB self-lock via plain `git pull --ff-only` per repo | Step 3 |
| 5 | Step 5 — Read Master Prompt, Custom Skills & Ingest Operating Contract | Read master prompt; learn GitMap skills directly from cloned codebase paths; ingest TURBO-01..05 & GUARD-01..09 | Step 4 |
| 6 | Step 6 — Memory Synchronization, Vault Training & Scripts | Run `gitmap llm train muse --days 7`; ingest DECISION TRACE and SINCE LAST READ; leverage `repo-cache/01-os-optimization/scripts/` for workstation hygiene | Step 5 |
| 7 | Step 7 — Connect Email Reader | Connect email CLI under standing SMTP pre-approval with password-only rule | Step 6 |
| 8 | Step 8 — Scan Everything into GitMap | Index workspace via `gitmap scan ~/workspace/repos` into `gitmap.db`; verify heatmap status | Step 7 |
| 9 | Step 9 — Final Status Report Block | Deliver completion report with exactly 9 structured items | Steps 1–8 |

---

## Step 02: Task Execution Engine (V6 Autonomous Engine)

For every task after onboarding, paste `02-muse-execute-task.md` after the task instructions:
1. **Confirmed Task Breakdown FIRST:** Turn 1 visible breakdown (`Task-01`, `Task-02`, ... each with `Understood: [YES]`).
2. **Immediate RUNNING Declaration:** Declare `RUNNING. ETA: <duration>.` (or `NOT RUNNING. Blocker: <one sentence>.`). Named violation: `LISTING-WITHOUT-STARTING`.
3. **5-Minute Status Pings:** Emit periodic status pings while work is active.
4. **Pull First in Target Repo:** Always `gitmap pull` (fallback `git pull`) before touching any file.
5. **Mandatory Multi-Agent Dispatch:** `invoke_subagent` (A = 3, H = 2, Capacity = 6 concurrent operations) in disjoint file boxes. Zero solo execution.
6. **Local Verification:** In private repositories, NEVER check remote CI/CD! Run local runner script (`03-ai-scripts/06-cicd-local-runner.py`). Check remote CI/CD only if verified public.
7. **Atomic GitMap Commit & Push:** Hyphen-separated commit format (`gitmap cpf "<module> - <summary>"` / `gitmap cbf` / `gitmap cpc`) with immediate push.

---

## Directory Index & Catalog

| Prompt File | Variant | Sequence | Scope & Role | Status |
| :--- | :--- | :--- | :--- | :--- |
| [`general/01-muse-master-prompt.md`](general/01-muse-master-prompt.md) | General | `01-` | Onboarding Master Prompt with bracketed placeholders for any operator. | **Active (Canonical)** |
| [`general/02-muse-execute-task.md`](general/02-muse-execute-task.md) | General | `02-` | Sequenced Task Execution Prompt for general operators driving V6 execution engine. | **Active (Canonical)** |
| [`private/01-muse-master-prompt.md`](private/01-muse-master-prompt.md) | Private | `01-` | Private Onboarding Master Prompt pre-filled for operator MD ALIM UL KARIM. | **Active (Canonical)** |
| [`private/02-muse-execute-task.md`](private/02-muse-execute-task.md) | Private | `02-` | Sequenced Task Execution Prompt pre-filled for operator MD ALIM UL KARIM. | **Active (Canonical)** |

---

## Directory Tree

```text
01-prompts/27-muse-prompts/
├── general/
│   ├── 01-muse-master-prompt.md    # Onboarding master prompt (bracketed placeholders)
│   └── 02-muse-execute-task.md     # Sequenced task execution prompt (general operator)
├── private/
│   ├── 01-muse-master-prompt.md    # Onboarding master prompt (pre-filled for operator)
│   └── 02-muse-execute-task.md     # Sequenced task execution prompt (private operator)
└── readme.md                       # Canonical index & catalog (single README)
```

---

## Core Architectural Invariants

### 1. Zero Date Noise ("Dates Are Noise")
All historical dates, changelog dates, and timestamp markers have been purged across all prompt files and catalogs. Version numbers represent semantic releases, not calendar days.

### 2. Private Repository CI/CD Invariant
In private repositories, **NEVER check remote CI/CD**! Remote CI/CD checks for private repositories are strictly prohibited. CI/CD verification must always be performed locally using the repository runner script:
```bash
python 03-ai-scripts/06-cicd-local-runner.py
```
Check remote CI/CD only if the repository is verified public and remote CI/CD is known to be operational.

### 3. GitMap Dual Installation Protocol
GitMap supports both public zero-credential deployment via GitLab raw distribution and private source builds:
- **Public GitLab Zero-Credential Installer:**
  ```bash
  # Linux / macOS (automated 7-Zip multi-volume extraction):
  curl -fsSL https://gitlab.com/rup-gitlab/deploy-gitmap/-/raw/main/install.sh | bash

  # Windows PowerShell:
  irm https://gitlab.com/rup-gitlab/deploy-gitmap/-/raw/main/install.ps1 | iex
  ```
- **Private Repository Source Build:**
  1. Establish GitHub authentication (`gh auth login` / SSH key).
  2. Ensure Golang is installed on the host machine (`go version`, Go 1.24+).
  3. Clone the private GitMap repository (`git clone git@github.com:alimtvnetwork/gitmap-v28.git ~/workspace/repos/gitmap-v28`).
  4. Build the executable binary from source (`cd cli && go build -o ~/.local/bin/gitmap .`).
  5. Self-deploy the binary to the machine:
     ```bash
     gitmap deploy-bin w2
     ```

### 4. Workstation Bootstrapping via `repo-cache/scripts/`
Muse leverages `repo-cache/01-os-optimization/scripts/` and `repo-cache/17-muse-automation-connect/scripts/` to clean OS caches, compact Antigravity chat SQLite WAL files, optimize memory, manage desktop apps, and restore fresh workstations via `master-workstation-restoration-instruction.md`.

### 5. Universal Public Prompt Gists
Authoritative public GitHub Gists for multi-domain prompt architecture:
- **Python Universal Prompt:** [`fd0953a5f2bfbbc91ae6e3666c5f7c37`](https://gist.github.com/alimtvnetwork/fd0953a5f2bfbbc91ae6e3666c5f7c37)
- **WordPress Universal Prompt:** [`11900295ef222d921bd646923fbcff3d`](https://gist.github.com/alimtvnetwork/11900295ef222d921bd646923fbcff3d)
- **Elementor Universal Prompt:** [`9ee32e9568d0afc4ee4c49c86bedb9e8`](https://gist.github.com/alimtvnetwork/9ee32e9568d0afc4ee4c49c86bedb9e8)
- **Common Foundation Prompt:** [`9fe8c6fb25ab0e409a22e9c2624915da`](https://gist.github.com/alimtvnetwork/9fe8c6fb25ab0e409a22e9c2624915da)
- **AI Memory Digest Prompt:** [`faa0881913e4029b36951828418f5316`](https://gist.github.com/alimtvnetwork/faa0881913e4029b36951828418f5316)

### 6. Muse Codebase Learning Invariant
Muse must learn GitMap commands, LLM training workflows, and skills directly from the cloned codebase paths:
- Custom skills: `~/workspace/repos/gitmap-v28/.agents/skills/gitmap/skill.md`
- LLM training: `gitmap llm train --help` and `gitmap llm train muse --days 7`
- Authoritative command behavior: `gitmap --help`

### 7. Deduplicated Architecture & Single Catalog
All duplicate loose prompts in the folder root (`01-muse-master-prompt.md`, `02-muse-generic.md`, `03-muse-standalone-master-prompt.md`, `04-muse-universal-master-prompt.md`, `05-muse-execute-in-a-step.md`) and subfolder readmes (`general/readme.md`, `private/readme.md`) have been removed. The directory houses exactly one authoritative root `readme.md` guiding the sequenced two-tier structure.

---

## Verified Lessons & Operational Guardrails

Every item below was observed in verified command output during live sessions:

1. **SSH login is not GitHub API access:** SSH covers git transport (clone, pull, push). It does not authenticate GitHub API calls. Establish API auth state first with `gitmap token list` and `gh auth status` before repository creation or API operations.
2. **Verify remotes before pushing:** Run `git ls-remote <remote> HEAD` before pushing. A `Repository not found` error means the remote does not exist.
3. **Binary `--help` is authoritative:** The installed binary's `--help` output is authoritative for command flags and behaviors.
4. **Positional destination form:** `gitmap clone <url> <destination>` is the verified working syntax.
5. **Build filesystem hygiene:** Set `TMPDIR` to a directory on the HOME disk for Go builds to prevent filling small temporary filesystems.
6. **Destructive command guards:** `gitmap rm` removes on-disk folders; always inspect `--help` and use `--dry-run` first.
