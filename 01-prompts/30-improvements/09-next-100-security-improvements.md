# High Priority Instruction
# Next 100 Security Improvements

## slug: next-100-security-improvements

```text
N = 400 (Total self-loop steps budget — editable top-header parameter, default: 400)
A = 3   (MANDATORY number of spawned autonomous subagents running concurrently via invoke_subagent, default: 3)
H = 2   (Operational hands per agent: dual-task batch capacity & parallel tool dispatch, default: 2)
C = 30  (Tool calls per worker before it must report, default: 30)

System Concurrency Capacity = A × H = 3 agents × 2 hands = 6 concurrent subtask operations
Tree Hierarchy = Lead Orchestrator (Root Node) -> Branch Coordinators (Subtask Owners) -> Leaf Workers & Dynamic Joining Assistants
PHASE_1_BUDGET = 100     (Steps 1 .. 100: Planning, 10-Cluster Security Diagnostic Survey, Discovery Subagents, Up-Front Brain & Threat Model)
PHASE_2_BUDGET = 150     (Steps 101 .. 250: 8-Field Security Specification Card Synthesis across 10 Clusters, 5-8 File Micro-Batches, Master Plan & Subtask Generation)
PHASE_3_BUDGET = 150     (Steps 251 .. 400: Retrospective Quality Verification, Zero Secrets Leak Gate, Relative Path Hygiene, Review Docket Assembly, Atomic Push Gate)
WAVES = ceil(subtasks / (A x H))
```

> [!IMPORTANT]
> **Prompt Version:** 1.0.0  
> **Runtime:** Google Antigravity 2.0 (IDE and CLI) & Cursor IDE  
> **Invoke:** `/next-100-security-improvements <project-or-module>`  
>
> **Trigger Keywords & Aliases:**  
> `next-100-security-improvements`, `next-100-security`, `security-improvements`, `next-security`, `100-security`, `security-flywheel`, `audit-100-security`  
>
> **Companion Antigravity Skill:** [`next-100-security-improvements`](directory;.agents/skills/next-100-security-improvements)  
>
> **Top-Instruction Priority Mandate (Above Precedence / Preamble Precedence):**  
> Whatever directives, constraints, checklists, or user instructions are given ABOVE this prompt (including in the user preamble, header blocks, or incoming user request above) are HIGHEST PRIORITY and MUST BE FOLLOWED as strictly NON-NEGOTIABLE. They supersede and strictly override any conflicting general advice, default conventions, or lower-level guidelines below. The agent MUST inspect and follow the instructions above with absolute precedence.

[/goal](slashCommand;goal) Autonomously conduct an exhaustive, 10-cluster security diagnostic audit across the target repository and ecosystem, inspect IPC boundaries, credential vaults, REST endpoints, database queries, and filesystem interactions, and synthesize exactly 100 concrete, defense-in-depth security improvements and threat mitigations structured into 10 thematic security clusters. Enforce the 8-Field Security Specification Schema with mathematical precision, prove backward compatibility and zero operational regression for every mitigation, enqueue all 100 security improvements into `.ai-memory/plans/pending/XX-next-100-security-improvements.md` with modular subtasks in `.ai-memory/plans/subtasks/XX-next-100-security-improvements/`, and present an executive security docket to the lead architect with strict no-build and no-test rules.

[/learn](slashCommand;learn) Enforce the STRICT REVIEW-FIRST & ZERO IMMEDIATE CODE EXECUTION MANDATE: security vulnerabilities, hardening ideas, and architectural mitigations discovered and articulated under this prompt MUST NOT be executed, modified into source code, compiled, or tested during the discovery run. The purpose of this workflow is comprehensive threat modeling, architectural attack surface mapping, and actionable backlog enqueueing. Every single security item must provide grounded codebase anchors, concrete vulnerability vectors, defense-in-depth remediation code, blast radius boundaries, and verifiable security criteria with zero placeholders (`[N]`, `TODO`, `TBD`).

[/plan](slashCommand;plan) Execute thorough step-by-step threat modeling and attack surface mapping in the target repository before synthesizing improvements. Ensure all architectural boundaries, privilege rings, and plan enqueuing deliverables are clearly structured in the roadmap ledger and subtask plans before dispatching worker waves.

---

### 🚨 MANDATORY SUBAGENT SPAWNING GATE (A = 3, H = 2, CAPACITY = 6 — TREE SWARM & DYNAMIC JOIN)

- **ACTUAL TOOL CALL REQUIRED:** You must ACTUALLY CALL the `invoke_subagent` tool via your tool-calling API. Do NOT just print the text `"Dispatched Worker..."` and stop. If you only print text, the subagents will not spawn and the task will fail! You must execute the `invoke_subagent` JSON tool payload.
- **TREE-STRUCTURED SWARM HIERARCHY:** Organize execution as an operational tree:
  1. **Root Orchestrator (Lead Agent):** Owns the unified Brain roadmap, cluster partitioning, master threat model assembly, and final GitMap commit. Never executes file discoveries solo.
  2. **Branch Coordinators (Cluster Subtask Owners):** Own designated domain clusters (Worker 01 owns Clusters 01, 02, 05; Worker 02 owns Clusters 03, 04, 06, 08; Worker 03 owns Clusters 07, 09, 10, and Enqueueing Alignment) and manage synthesis waves.
  3. **Leaf Workers & Dynamic Joining Assistants:** Assist branch coordinators with GitMap AST/symbol searches, attack vector tracing, contract validation, and security card authoring.
- **3-STAGE MANDATORY DISPATCH:** You must invoke `A = 3` agents (`invoke_subagent`) at EVERY stage of the workflow:
  1. **Planning & Discovery Step (A = 3 `research` subagents):** Spawn 3 read-only discovery subagents (`TypeName: "research"`) to execute the attack surface survey using GitMap high-speed commands.
  2. **Security Card Authoring Step (A = 3 `self` authoring subagents):** Spawn 3 authoring subagents (`TypeName: "self"`) to author modular, disjoint 8-field security specification cards and cluster subtask files.
  3. **Verification & Enqueueing Step (A = 3 `self` worker subagents):** Spawn 3 worker subagents (`TypeName: "self"`) to validate relative path hygiene, verify zero placeholders, compile pending subtasks, and register the Master Plan in `.ai-memory/plans/pending/`.
- **DYNAMIC AGENT JOIN & IMMEDIATE RESPAWN (NO IDLE WORKERS):** Worker capacity `A` must remain pinned at 3 active agents (System Concurrency Capacity = 6) throughout execution. As soon as ANY single worker completes, the lead immediately spawns a replacement worker for the next pending cluster batch, or commands the worker to dynamically join an active subtask in collaborative assistance mode to keep concurrency at exactly 3 active subagents (100% duty cycle).
- **SOLO EXECUTION IS AN AUTO-REJECT FAILURE:** The lead orchestrator is **STRICTLY FORBIDDEN** from performing all codebase surveying, security card authoring, or plan enqueueing solo without calling the `invoke_subagent` tool.

---

## 10 Core Security Clusters

Every run of this workflow discovers, models, and specifies 10 concrete security improvements across each of the following 10 thematic clusters (10 clusters × 10 improvements = exactly 100 improvements):

### Cluster 01: Credential Vaulting & Secret Hygiene
- Zero plaintext API tokens, session cookies, or bot secrets committed in Git repositories.
- SQLite credential database encryption with master key derivation and OS keychain integration.
- Telegram bot token and Supabase API key isolation inside encrypted tables (`vault.db`).
- Process environment variable sanitization, avoiding leaking secrets to child processes or logs.
- Pre-commit scanning hooks preventing accidental credential leakage.

### Cluster 02: Tauri v2 IPC Command & Event Sandboxing
- Granular capability-based command permission policies (`src-tauri/capabilities/`).
- IPC argument validation and strict deserialization schemas preventing arbitrary type coercion.
- Origin validation on Tauri event listeners and Tauri log bridges.
- Window management command restriction (`close_window`, `toggle_maximize_window`) preventing malicious UI freeze.
- Webview context isolation ensuring untrusted HTML/JS cannot invoke system IPC.

### Cluster 03: Subprocess Execution & Windows Job Breakaway Hardening
- Enforcing `spawn_with_job_breakaway_fallback` to prevent Windows Job Object privilege escalation or freeze.
- Strict argument sanitization and escaping for shell dispatchers (`cmd.exe`, `powershell.exe`).
- Banning direct `.cmd` or `.bat` batch file invocation in `Command::new(...)`.
- Validating binary paths against known trusted application directories, preventing PATH interception.
- Caller process PID verification (`detect_caller_instance_id()`) preventing termination of developer IDE sessions.

### Cluster 04: Local HTTP/REST & WebSocket Endpoint Security
- Strict bind address enforcement: `127.0.0.1` loopback only (never `0.0.0.0` without explicit flag).
- Origin and Host header verification on port 19527 and port 8045 Axum servers.
- CSRF protection on mutation endpoints (`/api/db/table/:name/row`, `/api/proxy/switch`).
- CORS preflight restrictions banning wildcard `*` origins on sensitive management APIs.
- Request rate limiting and body size limits preventing local Denial of Service (DoS).

### Cluster 05: SQLite Split-DB & SQL Injection Defense
- Strict enforcement of parameterized queries (`rusqlite::params!`) across all database operations.
- Dynamic table name sanitization in REST DB visualizer (`^[a-zA-Z0-9_]+$`).
- Transaction isolation and rollback invariants during profile cloning and database exports.
- Secure WAL deletion and zero leftover temporary database files on application shutdown.
- Split-DB file permission hardening (`errors.db`, `repo_prompts.db`, `transcripts.db`).

### Cluster 06: File System Path Traversal & Workspace Isolation
- Canonicalizing workspace paths before file operations, rejecting directory traversal sequences (`..`).
- Symlink resolution guards preventing escapes outside designated workspace boundaries.
- Atomic file write patterns (write to `.tmp`, flush, rename) preventing partial state corruption.
- Safe temporary directory isolation (`tmp/agm-<pid>/`) with deterministic cleanup routines.
- Workspace storage partition between independent IDE instances and Chrome user data directories.

### Cluster 07: Prompt Sanitization, Context Scrubbing & Injection Defense
- Regex-based agent-client prompt sanitization stripping adversarial system override patterns.
- Transcript inspection privacy: filtering sensitive auth tokens, passwords, and PII from JSONL logs.
- Request header sanitization: stripping risky headers before forwarding through protocol adapters.
- Multi-protocol divergence adaptation: preventing prompt truncation or token smuggling in gateway adapters.
- Sanitizing file paths and terminal outputs before embedding in prompt attachment cards.

### Cluster 08: Multi-Instance Profile Isolation & Data Leakage Prevention
- Partitioned storage: isolated `workspaceStorage`, `Local State`, and `IndexedDB` per profile.
- Preventing cross-profile cookie or OAuth session sharing during instance switching.
- Auto-switcher daemon safety: verifying instance health before terminating old instance.
- Transient test sandbox governance: ensuring `test-create` profiles are completely erased with zero remnants.
- Lockfile concurrency safety preventing concurrent write collisions on shared instance metadata.

### Cluster 09: Telemetry, Crash Logs & PII Anonymization
- Redacting user filesystem paths, usernames, and hostnames in anonymous crash telemetry.
- Error database (`errors.db`) sanitization: stripping query parameters and auth headers from logged traces.
- Telegram remote notification privacy: ensuring notification payloads never expose full API keys or auth tokens.
- Bounded transcript logging: preventing disk space exhaustion from infinite conversation loops.
- Local log rotation and configurable retention policies with automatic purging.

### Cluster 10: Supply Chain, Crate Auditing & Dependency Integrity
- Automated `cargo audit` and `npm audit` vulnerability scanning in CI/CD pipelines.
- Pinning trusted crate and npm package versions with verifiable checksum locks (`Cargo.lock`, `package-lock.json`).
- Sandboxing external CLI plugins and subagent execution permissions.
- Verifiable binary build pipeline: deterministic builds, signed executables, and SHA-256 manifest validation.
- Regular deprecation audits pruning abandoned dependencies and legacy polyfills.

---

## 8-Part Structured Specification Schema

Every single improvement across the 10 Security Clusters MUST strictly adhere to the following 8-part schema:

```markdown
### SEC-IMP-NNN: [Descriptive Title of Security Improvement]

1. **Identifier & Cluster:**
   - **ID:** `SEC-IMP-NNN`
   - **Cluster:** [Cluster 01 .. Cluster 10]
   - **Target Boundaries:** [Relative file paths or packages targeted, e.g. `src-tauri/src/modules/http_api/`, `src/services/`]

2. **Threat Model & Vulnerability Analysis:**
   - **Threat Vector:** [Exact attack scenario, exploitation path, or security weakness]
   - **Severity / Impact:** [Critical | High | Medium | Low] — [Confidentiality / Integrity / Availability impact]

3. **Grounded Codebase Anchor:**
   - **Anchor Location:** [Relative path with exact lines or symbol, e.g. `src-tauri/src/modules/http_api/mod.rs#L45-L60`]
   - **Current Implementation State:** [Concise description of existing vulnerable or non-hardened code]

4. **Defense-in-Depth Remediation Blueprint:**
   - **Architectural Mitigation:** [Step-by-step description of the defense-in-depth security fix]
   - **Concrete Code Snippet:**
     ```rust
     // Example hardening implementation
     ```

5. **Interface Contracts & Type Safety:**
   - **Error Handling:** [Explicit `AppError` variant routing; zero silent unwraps or bare `catch {}`]
   - **Data Validation:** [Input constraints, regex patterns, sanitization bounds]

6. **Regression Safety & Backward Compatibility Matrix:**
   - **Zero Harm Proof:** [Why applying this mitigation will not break existing valid user workflows or CLI commands]
   - **Fallback Mechanism:** [Graceful degradation if the security restriction intercepts an edge case]

7. **Caller Blast Radius & Impacted Subsystems:**
   - **Upstream Triggers:** [GUI, CLI, Telegram, or automated background services triggering this path]
   - **Downstream Callers:** [Components, databases, or network connections consuming the hardened output]

8. **Binary Acceptance & Verification Criteria:**
   - [ ] Criterion 1: Concrete, binary-verifiable mitigation rule (e.g. "Port 19527 rejects any request where Host header does not equal 127.0.0.1 or localhost").
   - [ ] Criterion 2: Automated test or CLI verification command.
   - [ ] Criterion 3: Zero regression on normal developer operations.
```

---

## Phase 3: Plan Enqueueing & Review Handoff

Upon completing the discovery and specification synthesis:
1. Compile the master plan into `.ai-memory/plans/pending/XX-next-100-security-improvements.md`.
2. Generate 10 modular cluster subtasks in `.ai-memory/plans/subtasks/XX-next-100-security-improvements/01-cluster-01.md` through `10-cluster-10.md`.
3. Present an executive security review docket to the architect summarizing top critical risks and recommended remediation phases.
4. Stage and commit changes using GitMap hyphen-separated atomic commit.
