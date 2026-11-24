---
name: gitmap-deployment-and-execution-instructions
description: >-
  Universal repository deployment and execution engine: scaffolds public GitLab deployment repositories, splits binaries into 7-Zip LZMA2 multi-volume chunks, attaches to confidential issues, synthesizes aria2c high-speed installers, and orchestrates direct deploy or release minor bump workflows with universal one-liners across any fleet repository.
---

# [V6] GitMap Deployment and Execution Instructions — Universal Workflow (must follow)

```text
N = 400 (Total self-loop steps budget — editable top-header parameter, default: 400)
A = 3   (MANDATORY number of spawned autonomous subagents running concurrently via invoke_subagent, default: 3)
H = 2   (Operational hands per agent: dual-task batch capacity & parallel tool dispatch, default: 2)
C = 30  (Tool calls per worker before it must report, default: 30)

System Concurrency Capacity = A × H = 3 agents × 2 hands = 6 concurrent subtask operations
Tree Hierarchy = Lead Orchestrator (Root Node) -> Branch Coordinators (Subtask Owners) -> Leaf Workers & Dynamic Joining Assistants
PHASE_1_BUDGET = 100     (Steps 1 .. 100: Planning, Discovery Subagents, Up-Front Brain & Roadmap Creation, Lean Subtasks)
PHASE_2_BUDGET = 150     (Steps 101 .. 250: Deployment Scaffolding, 7z Split Chunking, Hashes & binary-info.json Manifest)
PHASE_3_BUDGET = 150     (Steps 251 .. 400: Aria2c Installers, Public Visibility Gate, Dual-Trigger Release, Atomic Push)
WAVES = ceil(subtasks / (A x H))
```

> [!IMPORTANT]
> **Prompt Version:** 6.1.0
> **Runtime:** Google Antigravity 2.0 (IDE and CLI)
> **Canonical Prompt Specification:** [`01-prompts/14-execute/118-gitmap-deployment-and-execution-instructions.md`](file;01-prompts/14-execute/118-gitmap-deployment-and-execution-instructions.md)
> **Toolchain Discovery & Primacy:** [/learn](slashCommand;learn) from [gitmap](directory;.agents/skills/gitmap)
> **Invocation:** `@[gitmap-deployment-and-execution-instructions](directory;.agents/skills/gitmap-deployment-and-execution-instructions)`
>
> **Top-Instruction Priority Mandate (Above Precedence / Preamble Precedence):**
> Whatever directives, constraints, checklists, or user instructions are given ABOVE this prompt (including in the user preamble, header blocks, or incoming user request above) are HIGHEST PRIORITY and MUST BE FOLLOWED as strictly NON-NEGOTIABLE. They supersede and strictly override any conflicting general advice, default conventions, or lower-level guidelines below. The agent MUST inspect and follow the instructions above with absolute precedence.

[/goal](slashCommand;goal) Autonomously orchestrate and execute binary deployment, public repository management, confidential issue multi-part archiving, and universal installation across ANY repository:
1. In Turn 1, showcase the 5 Mandatory Pillars and 6-part task verification schema in visible chat.
2. Ingest the target repository identity and binary outputs without hardcoding workspace paths.
3. Scaffold the public GitLab deployment repository at `<work_dir>/deploy/<repo_name>/` using GitMap commands (`gitmap repo create deploy-<repo_name> --gitlab`).
4. Enforce the **Public Visibility Invariant (RCA-80)** so unauthenticated raw installer fetches (`irm ... | iex` / `curl ... | bash`) return `HTTP 200 OK` and never redirect to Cloudflare login challenges.
5. Slice binary executables into multi-part 7-Zip LZMA2 archives (`.7z.001`, `.7z.002`, ...), compute SHA-256 hashes, and bind them to GitLab confidential issues and `binary-info.json`.
6. Author high-speed client installers (`install.ps1`, `install.sh`) powered by `aria2c` multi-connection downloading (`-x 16 -s 16 -j 4`), integrity validation, and `.old`/`.bak` atomic swapping.
7. Support dual execution triggers: standalone `deploy` and SemVer `release minor bump` (`gitmap cpr`).
8. Output copy-pasteable universal installation summaries and finish with one atomic GitMap commit (`gitmap cpf "<module> - <summary>"` / `gitmap cpr "vX.Y.Z - <summary>"`).

[/learn](slashCommand;learn) Enforce the Top-Instruction Priority Mandate: whatever directives, custom requirements, checklists, or user instructions are provided ABOVE this prompt outrank everything below. Turn 1 MUST showcase the given task list in visible chat before any background execution. Each rule is stated once and cited by ID. Progress lives in the ledger and in `.ai-memory/plans/`, never only in chat.

[/plan](slashCommand;plan) Execute thorough step-by-step planning in the repository before execution for improved work or less friction, faster work and more pure and effective work. Ensure all deliverables, architecture boundaries, and requirements are clearly defined in the audit ledger and subtask plans before dispatching worker waves.

---

## 1. Multi-Agent Tree Swarm Hierarchy & Concurrency (A = 3, H = 2, Capacity = 6)

- **Root Orchestrator (Lead Agent):** Owns the unified Brain roadmap, audit ledger, and final GitMap commit. Never executes file edits solo.
- **Branch Coordinators (Subtask Primary Owners):** Own designated disjoint file boundaries (`Owned Files`) and execute modifications.
- **Leaf Workers & Dynamic Joining Assistants:** Assist primary owners with parallel reading, symbol caller discovery, memory generation, and companion lint verification.
- **3-Stage Dispatch:**
  1. Planning Step: Spawn 3 `research` subagents to explore dependencies, build outputs, and remote states.
  2. Spec Step: Spawn 3 `self` authoring subagents to author modular, disjoint spec files and subtasks.
  3. Execution Step: Spawn 3 `self` worker subagents to execute code modifications in strictly disjoint file boxes.
- **Immediate Dynamic Respawn:** Concurrency remains pinned at 3 active subagents (6 operational hands). As soon as ANY single worker completes, the lead immediately spawns a replacement worker for the next pending subtask.

---

## 2. Turn 1 Mandatory Understood Showcase & Task Verification Schema

In the VERY FIRST response turn upon receiving this prompt, you MUST output a comprehensive understanding block directly in visible chat before any background tool execution:

```markdown
### 🧠 Deep Comprehension & Understood Mandate

#### Pillar 1: Strategic Intent & Systems Reasoning
- [Articulate overarching architectural goal: universal repository deployment, public GitLab repo governance, split 7z archives in confidential issues, and aria2c-accelerated installation.]

#### Pillar 2: Explicit Scope Boundaries (In-Scope vs. Excluded / Deferred)
- **In-Scope:** [Scaffolding deploy/<repo>, 7z split volumes, binary-info.json manifest, install.ps1, install.sh, dual deploy/release triggers, and universal one-liners.]
- **Excluded / Deferred:** [Banned test running, banned compiler checks, untouched legacy deployment paths.]

#### Pillar 3: Non-Negotiable Constraints & Negative Guardrails Ingestion
- [Explicit recitation of active constraints: raw search ban (no rg/ripgrep/Select-String), worker git ban (no git in subagents), zero builds/tests during routine loops, strict relative Git paths, lowercase naming, public deployment repo invariant (RCA-80), GitMap hyphen-separated commit verbs without colons.]

#### Pillar 4: Blast Radius & Dependency Topology
- [Map impacted files: deploy/<repo>/, scripts/, version.json, release notes, and install scripts with risk containment.]

#### Pillar 5: Multi-Agent Concurrency Topology
- [Detail swarm structure: A = 3, H = 2, Capacity = 6, disjoint file assignments, and immediate dynamic join.]
```

Followed by the Confirmed Task Breakdown:
```markdown
### 📋 Confirmed Task Breakdown & Requirement Ingestion

1. **Task-01: [Task Title]**
   - **State:** `[PENDING]`
   - **Understood / AI Comprehension:** `[YES]` — [Concise sentence proving deep understanding of intent and constraints]
   - **Azure AI / Model Runtime Context:** `[N/A — Local CLI/GitMap]`
   - **Actionable Scope:** [Precise implementation scope]
   - **Target Files / Area:** `[relative/path/to/module]`
```

---

## 3. GitMap Command Primacy & CLI Reference

All repository discovery, searching, and Git governance MUST use GitMap CLI tools. TOTAL BAN on raw `rg`, `ripgrep`, `grep`, `Select-String`, or raw `git commit`.

| Task / Operation | Mandatory GitMap Command | Description / Purpose |
| :--- | :--- | :--- |
| **Pre-Flight Pull** | `gitmap pull [repo]` | Synchronize local branch with upstream tracking branch |
| **Repo Creation (GitLab)** | `gitmap repo create <slug> --gitlab` | Initialize and bind repository to GitLab via SSH |
| **Repo Creation (GitHub)** | `gitmap repo create <slug> --github` | Initialize and bind repository to GitHub via SSH |
| **Codebase Search** | `gitmap aum search "<pattern>" [path]` | In-process high-speed AST/symbol search engine |
| **File Locating** | `gitmap find "<glob>" [path]` | Ultra-fast file finder respecting folder skip rules |
| **File Inspection** | `gitmap cat <relative-path>` | Print file contents with syntax highlighting |
| **Process Inspection** | `gitmap ps` | View active processes, PIDs, and memory usage |
| **Python Script Execution**| `gitmap py <script.py> [args]` | Run Python AI scripts within repository sandbox |
| **Feature Commit** | `gitmap cpf "MODULE - summary"` | Conventional Feature commit: `Feature: MODULE - summary` |
| **Bug Fix Commit** | `gitmap cbf "MODULE - summary"` | Conventional Bug commit: `Bug: MODULE - summary` |
| **Refactor Commit** | `gitmap cfr "MODULE - summary"` | Conventional Refactor commit: `Refactor: MODULE - summary` |
| **Chore Commit** | `gitmap cpc "MODULE - summary"` | Conventional Chore commit: `Chore: MODULE - summary` |
| **Release Commit** | `gitmap cpr "vX.Y.Z - summary"` | Conventional Release commit: `Release: vX.Y.Z - summary` |
| **Binary Swap** | `gitmap swap-binary --from <p> --kill` | Atomic replacement of active running binary |

---

## 4. Universal Deployment Architecture Specifications

### 4.1 Deployment Workspace Layout
Every repository `<work_dir>/<repo_name>` deploys to `<work_dir>/deploy/<repo_name>/`:
```text
<work_dir>/
├── <repo_name>/                        # Source repository
│   ├── version.json                    # Canonical SemVer source of truth
│   ├── scripts/
│   │   ├── deploy-gitlab.ps1           # Windows deployment script
│   │   └── deploy-gitlab.sh            # POSIX deployment script
│   └── ...
└── deploy/
    └── <repo_name>/                    # Public GitLab deployment repository
        ├── .git/                       # Remote: gitlab.com/<namespace>/deploy-<repo_name>.git
        ├── .gitignore                  # Excludes *.exe, *.7z*, .staging/, releases/
        ├── binary-info.json            # Release manifest with chunk hashes & URLs
        ├── install.ps1                 # Windows aria2c installer with PATH registration
        ├── install.sh                  # POSIX installer with shell profile integration
        └── readme.md                   # Installation documentation and one-liners
```

### 4.2 Mandatory Public Visibility Invariant (RCA-80 Prevention)
The deployment repository `deploy-<repo_name>` MUST have **Public** visibility in GitLab:
1. When creating via SSH push-to-create or API, immediately verify visibility.
2. In GitLab Web UI: `Settings -> General -> Visibility, project features, permissions -> Project visibility: Public`.
3. Verify unauthenticated raw access:
   ```bash
   curl -I https://gitlab.com/<namespace>/deploy-<repo_name>/-/raw/main/install.ps1
   ```
   Must return `HTTP 200 OK` (`text/plain`). If `HTTP 302` redirecting to `/users/sign_in`, the repository is Private and must be changed to Public immediately.

### 4.3 Multi-Part 7-Zip LZMA2 Chunking & Hashes
1. Resolve target executable from `bin/`, `target/release/`, or system PATH.
2. Slice into split volumes via 7-Zip:
   ```powershell
   & 7z a -t7z -m0=lzma2 -mx=9 "-v$ChunkSize" "$stagingDir\$project-$platform-$arch.7z" "$targetBinary"
   ```
   - CLI tools: `-v8m` (8MB chunks).
   - GUI / Tauri apps: `-v3m` or `-v5m` (3–5MB chunks).
3. Compute cryptographic SHA-256 integrity hash for each volume file (`.7z.001`, `.7z.002`, ...).
4. Upload split chunks to GitLab project attachments / confidential issues.
5. Construct and write `binary-info.json`:
   ```json
   {
     "$schema": "https://json-schema.org/draft/2020-12/schema",
     "project": "<project>",
     "version": "<version>",
     "releaseDate": "2026-11-17T10:00:00Z",
     "binaryName": "<binaryName>",
     "executableWindows": "<binaryName>.exe",
     "executableLinux": "<binaryName>",
     "archiveFormat": "7z",
     "isConfidential": true,
     "issueId": 1,
     "issueUrl": "https://gitlab.com/<namespace>/deploy-<project>/-/issues/1",
     "totalSizeBytes": 32904192,
     "totalArchiveSizeBytes": 15482910,
     "chunks": [
       {
         "part": 1,
         "fileName": "<project>-windows-amd64.7z.001",
         "sizeBytes": 8388608,
         "sha256": "<hash>",
         "downloadUrl": "https://gitlab.com/<namespace>/deploy-<project>/-/raw/main/releases/v<version>/<fileName>"
       }
     ],
     "installers": {
       "oneLinerWindows": "irm https://gitlab.com/<namespace>/deploy-<project>/-/raw/main/install.ps1 | iex",
       "oneLinerLinux": "curl -fsSL https://gitlab.com/<namespace>/deploy-<project>/-/raw/main/install.sh | bash"
     }
   }
   ```

### 4.4 High-Speed `aria2c` Client Installers
- **Windows (`install.ps1`):**
  - Auto-provisions portable `aria2c.exe` and `7z.exe` if missing.
  - Downloads chunks concurrently via `aria2c -x 16 -s 16 -j 4`.
  - Asserts 100% SHA-256 match against `binary-info.json`.
  - Extracts via `7z x -y <archive>.7z.001`.
  - Replaces active binary using atomic `.old`/`.bak` renaming (RCA-07.11).
  - Registers `%LOCALAPPDATA%\<cli-name>` in User PATH and broadcasts registry change.
  - Auto-starts GUI/daemon if applicable (unless `-NoLaunch` passed).
- **Linux / macOS (`install.sh`):**
  - Fetches chunks with `aria2c` or `curl`.
  - Asserts SHA-256 checksums via `sha256sum`.
  - Extracts and moves executable to `~/.local/bin/<cli-name>` (`chmod 755`).
  - Appends PATH to `.bashrc` / `.zshrc` via `apply_profile_snippet` (RCA-07.2).

---

## 5. Dual-Trigger Workflow: Direct Deploy vs. Release Minor Bump

The orchestrator inspects the user trigger:

### 5.1 Trigger A: Standalone Direct Deploy (`deploy`)
1. Pull source repository (`gitmap pull`).
2. Package current binary outputs into split 7z volumes.
3. Update `binary-info.json` in `<work_dir>/deploy/<repo_name>/`.
4. Commit and push deploy repository to GitLab.
5. Print universal installation summary.

### 5.2 Trigger B: Release Minor Bump (`release minor bump`)
1. Pull source repository (`gitmap pull`).
2. Read current SemVer from `version.json` and compute incremented minor (`vX.Y+1.0`).
3. Update `version.json` in source repository.
4. Generate release notes in `.ai-memory/release/release-notes-vX.Y.Z.md`.
5. Record modified files in test inventory via `33-test-inventory-generator.py`.
6. Commit source repository with GitMap release verb:
   ```bash
   gitmap cpr "vX.Y.Z - <summary>"
   ```
7. Push source repository upstream (`git push origin main`).
8. Execute Trigger A deployment workflow with the new version.

---

## 6. Universal Installation Summary Formatting

Upon deployment completion, the agent MUST output the following visual summary block:

```text
=================================================================
  GitLab Binary Deployment Completed Successfully!
=================================================================
  Project:       <project> v<version>
  Archive:       7z Multi-Volume (<count> splits)
  Total Size:    <rawBytes> bytes (compressed: <archiveBytes> bytes)
  Confidential:  true
  GitLab Remote: https://gitlab.com/<namespace>/deploy-<project>

  Installer One-Liner (Windows PowerShell):
    irm https://gitlab.com/<namespace>/deploy-<project>/-/raw/main/install.ps1 | iex

  Installer One-Liner (Linux & macOS Bash):
    curl -fsSL https://gitlab.com/<namespace>/deploy-<project>/-/raw/main/install.sh | bash
=================================================================
```

---

## 7. Master 100-Step Actionable Execution Roadmap

Follow the 100 granular self-looping steps documented in `.ai-memory/plans/pending/459-gitmap-deployment-and-execution-instructions.md` across all 5 phases:
- Steps 1–20: Pre-Flight Discovery & Telemetry Verification
- Steps 21–40: Architecture Specification & Subtask Formulation
- Steps 41–60: Deployment Scaffolding & Packaging Implementation
- Steps 61–80: High-Speed Client Installers & Bootstrap One-Liners
- Steps 81–100: Canonical Execution Prompt & Antigravity Skill Synthesis

---

## 8. Anti-Hallucination, Quality Gates & Atomic Commit Discipline

Before concluding, verify:
- [ ] No raw search tools used (`rg`, `ripgrep`, `grep`, `Select-String`).
- [ ] No per-file commits; single atomic commit at final step.
- [ ] No unit tests or builds run during routine loops.
- [ ] All file paths are strictly relative Git paths.
- [ ] Functions <= 15 lines; positive booleans (`is*`/`has*`) only.
- [ ] Frontmatter validated with `python 03-ai-scripts/53-skill-frontmatter-validator.py`.
- [ ] Files recorded in test inventory via `python 03-ai-scripts/33-test-inventory-generator.py --record <files...>`.
- [ ] Atomic commit and push: `gitmap cpf "deploy - gitmap deployment and execution instructions prompt and skill"`.
