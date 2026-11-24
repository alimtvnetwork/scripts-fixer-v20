---
name: deploy-repository-and-antigravity-tools-instructions
description: >-
  Universal repository deployment and folder-based public distribution engine: scaffolds public distribution folders, splits binaries into 7-Zip LZMA2 multi-volume chunks, synthesizes binary-info.json manifests, generates aria2c-accelerated client installers, and automates deployment via Python script and native GitMap commands.
---

# [V6] Deploy Repository and Antigravity Tools Instructions — Public Distribution Engine (must follow)

```text
N = 400 (Total self-loop steps budget — editable top-header parameter, default: 400)
A = 3   (MANDATORY number of spawned autonomous subagents running concurrently via invoke_subagent, default: 3)
H = 2   (Operational hands per agent: dual-task batch capacity & parallel tool dispatch, default: 2)
C = 30  (Tool calls per worker before it must report, default: 30)

System Concurrency Capacity = A × H = 3 agents × 2 hands = 6 concurrent subtask operations
Tree Hierarchy = Lead Orchestrator (Root Node) -> Branch Coordinators (Subtask Owners) -> Leaf Workers & Dynamic Joining Assistants
PHASE_1_BUDGET = 100     (Steps 1 .. 100: Planning, Discovery Subagents, Up-Front Brain & Roadmap Creation, Lean Subtasks)
PHASE_2_BUDGET = 150     (Steps 101 .. 250: Folder Scaffolding, 7z Split Chunking, Hashes & binary-info.json Manifest)
PHASE_3_BUDGET = 150     (Steps 251 .. 400: Aria2c Installers, Public HTTP 200 Assertion, Python Engine & GitMap CLI Push)
WAVES = ceil(subtasks / (A x H))
```

> [!IMPORTANT]
> **Prompt Version:** 6.2.0
> **Runtime:** Google Antigravity 2.0 (IDE and CLI)
> **Canonical Prompt Specification:** [`01-prompts/14-execute/119-deploy-repository-and-antigravity-tools-instructions.md`](file;01-prompts/14-execute/119-deploy-repository-and-antigravity-tools-instructions.md)
> **Toolchain Discovery & Primacy:** [/learn](slashCommand;learn) from [gitmap](directory;.agents/skills/gitmap)
> **Invocation:** `@[deploy-repository-and-antigravity-tools-instructions](directory;.agents/skills/deploy-repository-and-antigravity-tools-instructions)`
>
> **Top-Instruction Priority Mandate (Above Precedence / Preamble Precedence):**
> Whatever directives, constraints, checklists, or user instructions are given ABOVE this prompt (including in the user preamble, header blocks, or incoming user request above) are HIGHEST PRIORITY and MUST BE FOLLOWED as strictly NON-NEGOTIABLE. They supersede and strictly override any conflicting general advice, default conventions, or lower-level guidelines below. The agent MUST inspect and follow the instructions above with absolute precedence.

[/goal](slashCommand;goal) Autonomously orchestrate and execute folder-based public binary distribution across ANY repository:
1. In Turn 1, showcase the 5 Mandatory Pillars and 6-part task verification schema in visible chat.
2. Ingest the target repository identity and binary outputs without hardcoding workspace paths.
3. Deploy into dedicated project folders inside the verified public distribution repository (`d:\work\deploy\r-files\<folder>/` or configured public deploy repo).
4. Enforce the **Public Visibility Invariant (RCA-80 & RCA-81)**: assert that unauthenticated HTTP requests return `HTTP 200 OK` and never redirect to Cloudflare login challenges.
5. Slice binary executables into multi-part 7-Zip LZMA2 volumes (`-v8m` for gitmap, `-v3m` for agm), compute SHA-256 digests, and synthesize `binary-info.json`.
6. Author high-speed client installers (`install.ps1`, `install.sh`) powered by `aria2c -x 16 -s 16` parallel downloading, checksum assertion, and atomic binary swapping (`.old`/`.bak`).
7. Provide the automated Python deployment engine (`03-ai-scripts/54-deploy-folder-distribution.py`) and compile native GitMap integration (`gitmap deploy-folder` / `gitmap deploy-public`).
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

## 2. Public Folder Distribution Architecture & Directory Contracts

```text
d:\work\deploy\r-files/
├── gitmap/                                       # GitMap CLI Public Distribution
│   ├── install.ps1                               # aria2c-accelerated PowerShell installer
│   ├── install.sh                                # POSIX Bash installer
│   ├── binary-info.json                          # Release manifest with chunk SHA-256 hashes
│   └── releases/
│       └── v6.693.0/
│           ├── gitmap-windows-amd64.7z.001       # 8 MB LZMA2 volume part 1
│           └── gitmap-windows-amd64.7z.002       # 8 MB LZMA2 volume part 2
├── agm/                                          # Antigravity Manager Public Distribution
│   ├── install.ps1                               # aria2c-accelerated PowerShell installer
│   ├── install.sh                                # POSIX Bash installer
│   ├── binary-info.json                          # Release manifest with chunk SHA-256 hashes
│   └── releases/
│       └── v4.329.0/
│           ├── antigravity-manager-windows-amd64.7z.001
│           └── antigravity-manager-windows-amd64.7z.002
├── install.ps1                                   # Universal root multi-project installer router
└── readme.md                                     # Public downloads catalog
```

---

## 3. GitMap CLI Command Reference for AI Agents

| Command | Purpose & Description |
| :--- | :--- |
| `gitmap pull` | Pre-flight synchronization; pulls upstream commits and handles merges |
| `gitmap deploy-folder [flags]` | Deploy binary into public repository folder via automated Python engine |
| `gitmap repo create <name> --gitlab` | Creates repository on GitLab via SSH push-to-create |
| `gitmap repo create <name> --github` | Creates repository on GitHub via SSH |
| `gitmap aum search "<pattern>"` | High-speed in-process AST and symbol search across codebases |
| `gitmap find "<glob>"` | Ultra-fast file locator respecting folder skip heuristics |
| `gitmap cat <relative-path>` | Inspect file contents with line numbers and syntax highlighting |
| `gitmap ps` | Inspect running background processes, PIDs, and memory footprint |
| `gitmap py <script.py>` | Run reusable Python automation scripts inside repository sandbox |
| `gitmap cpf "MODULE - summary"` | Conventional Feature commit (`Feature: MODULE - summary`) |
| `gitmap cbf "MODULE - summary"` | Conventional Bug fix commit (`Bug: MODULE - summary`) |
| `gitmap cpc "MODULE - summary"` | Conventional Chore commit (`Chore: MODULE - summary`) |
| `gitmap cpr "vX.Y.Z - summary"` | Conventional Release commit (`Release: vX.Y.Z - summary`) |
| `gitmap swap-binary --from <p> --kill` | Atomic replacement of active running binary with retry loops |

---

## 4. Universal Installation One-Liners

### GitMap CLI (`gitmap`):
```powershell
irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/gitmap/install.ps1 | iex
```

### Antigravity Manager (`agm`):
```powershell
irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/agm/install.ps1 | iex
```

### Universal Multi-Project Router:
```powershell
# Installs gitmap by default:
irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/install.ps1 | iex

# Installs agm:
irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/install.ps1 | iex -Project agm
```
