---
name: gitmap-mcp
description: >-
  GitMap native MCP server operations, JSON-RPC 2.0 tools catalog, fleet management, and AI agent toolchain integration.
---

# GitMap MCP Skill

> **Invocation:** `@[gitmap-mcp](directory;.cursor/skills/gitmap-mcp)`

The GitMap native MCP server (`cli/cmdmcp/`) exposes the GitMap CLI to AI
agents over JSON-RPC 2.0. This skill is the single place that describes how
to start it, what it offers, and how to extend it. It mirrors the server as
of task 316 (70 tools).

## 1. Serve-first rule (mandatory)

When operating inside an MCP-enabled IDE (Google Antigravity, Cursor, Claude
Desktop), start and interact with `gitmap mcp serve` FIRST — before ad-hoc
terminal commands. The server is the zero-disk, sub-millisecond path to the
workspace; raw terminal commands are the fallback, not the default.

- `gitmap mcp serve` — starts the server (HTTP on `127.0.0.1:8765`, automatic
  failover to 8766, 8767). If already running, it reports the active PID, port
  and endpoints and exits without pausing.
- `gitmap mcp serve --stdio` (or `-s`) — stdio JSON-RPC 2.0 for clients that
  spawn the server over a pipe (Claude Desktop, Cursor, Antigravity).
- `gitmap mcp serve --port <port>` — HTTP on an explicit port.
- `gitmap mcp status` — active port, running status, registered tools.
- `gitmap mcp stop` (alias `kill`) — terminates the server, cleans runtime state.
- `gitmap mcp tools` (alias `list`) — **the source of truth for the tool list
  and count.** Never hard-code a tool count in docs or prompts; counts rot.
  (70 tools as of task 316 — verify live with `gitmap mcp tools`.)
- `gitmap mcp install` — prints client configuration stanzas for Claude
  Desktop, Cursor, and Google Antigravity. It does NOT write client config.
- `gitmap mcp inject --agy` (aliases: `gitmap mcp add`, `gitmap agy mcp add`) —
  automatically discovers all Antigravity `mcp_config.json` configuration files
  across `~/.gemini/config/` and multi-instance paths
  (`.antigravity_tools/instances/*/home/.gemini/config/`), non-destructively
  injecting the GitMap stdio MCP server stanza with auto-start on IDE launch.
- `gitmap mcp inject --cursor` (alias `gitmap cursor mcp add`) —
  automatically discovers Cursor IDE `mcp.json` configuration files across
  `~/.cursor/mcp.json`, `%APPDATA%\Cursor\User\globalStorage\rooveterinaryinc.cursor-mcp\mcp_config.json`,
  and `.cursor/mcp.json`, non-destructively injecting the GitMap stdio MCP server stanza.
- `gitmap mcp inject --all` —
  discovers and injects the GitMap stdio MCP server configuration into BOTH
  Google Antigravity and Cursor IDE simultaneously.
- `gitmap nodes mcp add --cursor` / `gitmap nodes mcp add --agy` / `gitmap nodes mcp add --all`
  (aliases: `gitmap nodes-mcp-add`, `gitmap nodes-mcp`, `gitmap nodes agy mcp add`) —
  broadcasts and injects GitMap MCP server configuration into Cursor, Google Antigravity,
  or both IDEs across all connected remote SSH cluster fleet nodes.
- `gitmap spec next` / `gitmap spec latest` / `gitmap spec list` (MCP tool `gitmap_spec`) —
  CLI commands for specification sequence numbering and discovery. Whenever an AI
  needs to discover files or spec sequence numbers, it MUST execute `gitmap spec next`,
  `gitmap spec latest`, `gitmap spec list`, or `gitmap find`. TOTAL BAN on ad-hoc
  inline Python scripts (`python -c "import os; dirs = ..."`) or shell loops to
  inspect directories or calculate spec sequences.

### 1.1 In-Process Search Acceleration & Folder Skip Invariant

- **In-Process Acceleration:** In MCP mode, `gitmap_aum_search` executes directly
  in-memory via Go goroutines with cached lazy regex, completely bypassing
  process spawning overhead and responding in $< 10$ms.
- **Search Folder Skips (`gitmap aum skip <folder> [reason]`):** Excludes noisy
  compiled build artifacts (`dist`, `.output`, `.next`, `.turbo`, `build`,
  `out`) and vendor outputs. Skips persist in SQLite Split-DB
  (`repodb/SearchFolderSkip`).
- **User Unskip Invariant (`gitmap aum unskip <folder>`):** When unskipped by a
  developer or agent, `IsUserUnskipped = 1` is permanently recorded in repodb.
  Automated detection heuristics are strictly prohibited from ever re-skipping
  that directory.
- **Audit Skips (`gitmap aum skips`):** Lists all active automatic and
  user-unskipped search exclusion entries.

## 2. Transport and protocol

- Transports: stdio JSON-RPC 2.0 (`serve --stdio`) and HTTP JSON-RPC on
  loopback `127.0.0.1:8765` → `8767` (first free port). No SSE despite the
  banner; HTTP is request/response only (no streaming).
- Protocol version `2024-11-05`. Methods: `initialize`, `tools/list`,
  `tools/call`, `prompts/list`, `prompts/get`, `resources/list`,
  `resources/read`, `ping`.
- No auth, no TLS; the loopback-only bind is the only boundary. **There is no
  per-call rights check** in `DispatchToolCall` (`CapMcp` is only displayed by
  status). Never present the MCP server as access-controlled.
- Tool behaviour follows the **serving binary's version**: most handlers
  re-invoke the serving binary (`runGitmapSubprocess`, `os.Executable()`), so
  new tools only behave correctly after a rebuild + deploy of that binary.
  Read-only `agy` tools call `cmdagy` in-process and are exempt.
- Prompts/skills resolve CWD-relative — start the server inside the repo tree.
- All tool inputs are coerced to strings. No pagination on `tools/list` /
  `prompts/list`.
- `clone` / `pe` need `gh` auth. Do not add tools that bypass auth.

## 3. Tool inventory by group (70 tools)

Every tool description embeds 2–6 copy-paste-ready JSON argument examples —
that is where the AI examples live. `gitmap_help` (`index` / `search` /
`cheatsheet` / `workflows` / `help`) is the in-server learning surface:
`cheatsheet` renders ready-to-run JSON for any tool; `workflows` holds the
curated multi-tool chains (§6).

- **Search** — `gitmap_aum_search`, `gitmap_find`, `gitmap_cat`, `gitmap_lf`,
  `gitmap_log`, `gitmap_prompts`
- **Skills** — `gitmap_skills`, `gitmap_train`
- **Fleet** — `gitmap_nodes`, `gitmap_deploy`, `gitmap_delegate`,
  `gitmap_cluster`, `gitmap_screenshot`, `gitmap_rights_status`,
  `gitmap_scan`, `gitmap_ls`
- **Agents** — `gitmap_heatmap`, `gitmap_agent`, `gitmap_dev_team`
- **Diagnostics** — `gitmap_pipeline`, `gitmap_pipeline_errors`,
  `gitmap_lines`, `gitmap_doctor`, `gitmap_plans`
- **Management** — `gitmap_status`, `gitmap_pull`, `gitmap_user`, `gitmap_agy`,
  `gitmap_agy_instances`, `gitmap_agy_running_prompts`,
  `gitmap_agy_running_projects`, `gitmap_agy_prompt_counts`,
  `gitmap_agy_fast_forward`, `gitmap_agy_backup`, `gitmap_agy_restore`,
  `gitmap_templates`
- **Database** — `gitmap_db`, `gitmap_db_rest`
- **Repo** — `gitmap_repo`, `gitmap_cg`, `gitmap_install`, `gitmap_commit`,
  `gitmap_release`, `gitmap_spec`, `gitmap_history`, `gitmap_stats`
- **Execution** — `gitmap_ps`, `gitmap_py`, `gitmap_node`, `gitmap_cargo`,
  `gitmap_run`, `gitmap_build`
- **SSH** — `gitmap_ssh`
- **Auth** — `gitmap_login`, `gitmap_change_user`, `gitmap_create_user`
- **Extended repo** — `gitmap_clone`, `gitmap_reclone`, `gitmap_create_repo`,
  `gitmap_cfr`, `gitmap_pr`, `gitmap_resolve`
- **Socket / conflicts** — `gitmap_socket_status`, `gitmap_conflicts_list`,
  `gitmap_conflicts_inspect`, `gitmap_conflicts_resolve`
- **OS** — `gitmap_os`, `gitmap_os_cache`
- **Meta-help** — `gitmap_help`
- **Agy prompts** — `gitmap_agy_prompts`

### 3.1 Primary Tool Groups with Expanded Examples

#### Search Group
- `gitmap_aum_search`: High-speed in-memory token and regex search via AUM index.
  - `{"query": "RunHeatmap"}` — fast token search across workspace
  - `{"query": "RunHeatmap", "path": "cli/cmd"}` — directory-scoped symbol search
  - `{"query": "func Test.*", "path": "cli/cmdmcp/*_test.go"}` — regex search across test files
  - `{"query": "type Tool struct\\n\\tName"}` — multiline structural token search
  - `{"query": "func \\(s \\*Server\\)"}` — escaped regex pattern matching
- `gitmap_find`: Glob pattern and filename locator across repositories.
  - `{"pattern": "*.tsx"}` — find all TypeScript JSX files
  - `{"pattern": "*.go", "path": "cli/cmdmcp"}` — find Go files in specific subfolder
  - `{"pattern": "Button.tsx", "path": "src/components"}` — pinpoint exact component path
  - `{"pattern": "*test*", "path": "cli", "ext": "go"}` — search by pattern and extension filter
- `gitmap_cat`: Streaming file viewer with bounded line range support.
  - `{"path": "go.mod"}` — read entire small file
  - `{"path": "cli/cmd/root.go", "range": "1-40"}` — read bounded range to preserve context window
  - `{"path": "02-spec/21-app/05-antigravity-manager-and-mcp.md", "range": "100-150"}` — read spec section
- `gitmap_lf`: LF newline hygiene enforcement across repository files.
  - `{"path": "."}` — scan and normalize line endings across entire workspace
  - `{"path": "cli/cmdmcp"}` — enforce LF on specific directory
- `gitmap_log`: Commit log, git history, and pickaxe diff search.
  - `{"query": "fix(ui)"}` — search commit message headers
  - `{"query": "gitmap_nodes", "diff": "true"}` — pickaxe (-S) search for commits introducing/removing symbol
  - `{"query": "auth", "limit": "5"}` — return 5 most recent commits matching query
- `gitmap_prompts`: Canonical prompt catalog search and retrieval from `01-prompts/`.
  - `{"action": "categories"}` — list all prompt categories
  - `{"category": "14-execute"}` — list prompts in category
  - `{"name": "02-execute-parent-task-with-n-steps-v6"}` — retrieve full prompt markdown
  - `{"action": "search", "query": "Tree Swarm"}` — full-text prompt search

#### Fleet Group
- `gitmap_nodes`: Cluster fleet health, status, and infrastructure coordination.
  - `{"subcommand": "ls", "filter": "online"}` — list online cluster nodes
  - `{"subcommand": "status"}` — view overall cluster health and node status
  - `{"subcommand": "ping", "target": "u1"}` — ping specific node
  - `{"subcommand": "resources"}` — inspect CPU, RAM, and disk utilization across nodes
  - `{"subcommand": "tasks", "flags": "--heavy-only"}` — inspect active heavy tasks on fleet
  - `{"subcommand": "bootstrap", "target": "u1"}` — bootstrap new node with dependencies
- `gitmap_deploy`: Multi-node deployment across binaries, config, keys, and IDE presets.
  - `{"action": "binary", "target": "u1"}` — deploy compiled binary to target node
  - `{"action": "keys", "target": "all"}` — synchronize SSH public keys across fleet
  - `{"action": "ide", "target": "u1"}` — deploy Antigravity IDE themes and plugins
  - `{"action": "config", "target": "all"}` — deploy configuration topology
  - `{"action": "repo", "target": "u1", "source": "gitmap"}` — synchronize git repository
- `gitmap_delegate`: Execute shell commands remotely on cluster fleet nodes over SSH.
  - `{"node": "u1", "command": "uname -a && uptime"}` — run remote inspection command
  - `{"node": "u1", "command": "gitmap status"}` — check workspace status on remote node
  - `{"broadcast": "true", "command": "gitmap version"}` — broadcast command across all nodes
  - `{"node": "w1", "command": "git status -s", "cluster": "true"}` — run through cluster coordinator
- `gitmap_cluster`: Multi-node cluster orchestration and coordinator operations.
  - `{"subcommand": "status"}` — inspect cluster orchestration status
  - `{"subcommand": "nodes"}` — list cluster member nodes
  - `{"subcommand": "exec", "node": "u1", "command": "git status"}` — coordinate remote command
  - `{"subcommand": "ping"}` — verify cluster interconnectivity
- `gitmap_screenshot`: Local and remote screen capture.
  - `{}` — capture local primary display
  - `{"node": "u1", "output": "u1.png"}` — capture remote node screen to local PNG
- `gitmap_rights_status`: Administrative rights and security matrix.
  - `{}` — check administrative rights matrix and permissions
- `gitmap_scan`: Register Git repositories into the fleet registry.
  - `{}` — scan and register Git repositories under current directory
  - `{"dir": "~/workspace/repos"}` — scan explicit target directory
  - `{"dir": ".", "json": "true"}` — return discovered repos in JSON format
- `gitmap_ls`: Fleet registry repository inspector.
  - `{}` — list registered repos with branch and clean/dirty state
  - `{"filter": "go"}` — filter repos by language or slug substring
  - `{"json": "true"}` — structured JSON listing

#### Diagnostics Group
- `gitmap_pipeline`: CI/CD pipeline telemetry, error logs, and traces.
  - `{"action": "errors"}` — show failing CI/CD jobs and error headers
  - `{"action": "trace"}` — stream live pipeline execution trace (`pe -t`)
  - `{"action": "ai"}` — run automated pipeline self-healing diagnosis
  - `{"action": "all", "flags": "--json"}` — inspect all jobs across pipeline in JSON
- `gitmap_pipeline_errors`: Extract CI/CD pipeline error logs and 4-part RCA.
  - `{}` — extract 4-part RCA for active workspace
  - `{"repo": "gitmap"}` — extract 4-part RCA for specific repository slug
- `gitmap_lines`: File size, function limit, and 300-line ceiling scanner.
  - `{}` — audit workspace files against 300-line ceiling (exempts markdown & JSON)
  - `{"max": "100"}` — check for files exceeding 100-line threshold
  - `{"max": "300", "path": "cli/cmdmcp"}` — scope line audit to specific directory
  - `{"json": "true"}` — output violations as structured JSON
- `gitmap_doctor`: System diagnostic health check.
  - `{}` — run full system diagnostic across binaries, database, and network
- `gitmap_plans`: Memory roadmap and pending plans inspector in `.ai-memory/plans/`.
  - `{}` — inspect memory roadmap and list all active/pending plans
  - `{"status": "pending"}` — list only pending uncompleted plans
  - `{"status": "active"}` — inspect currently in-progress plan

#### Management Group
- `gitmap_status`: Multi-repo and active workspace status.
  - `{}` — summarize status of active repository (branch, dirty state, ahead/behind)
  - `{"dirty": "true"}` — filter to show only dirty repositories in workspace
- `gitmap_pull`: Workspace and fleet repository synchronization.
  - `{}` — pull updates for the current repository only (mandatory pre-flight command)
  - `{"path": "cli"}` — pull specific subdirectory or repository path
  - `{"action": "pull-all"}` — explicitly pull all repositories across workspace
- `gitmap_user`: User identities, git author credentials, and developer switches.
  - `{"action": "whoami"}` — display current Git user and developer persona
  - `{"action": "ls"}` — list available developer personas (`work`, `personal`, `bot`)
  - `{"action": "change-user", "name": "bot"}` — switch active persona to autobot
- `gitmap_agy`: Antigravity cache cleaner and developer profile sync.
  - `{}` — clean temporary caches and synchronize profile
- `gitmap_agy_instances`: Multi-instance discovery.
  - `{}` — count running Antigravity instances and list hosted projects
  - `{"running_only": "true"}` — list only instances currently executing prompts
- `gitmap_agy_running_prompts`: Running and queued prompts inspector.
  - `{}` — list active and queued prompts across all IDE instances
  - `{"limit": "5"}` — bounded prompt list
- `gitmap_agy_running_projects`: Projects hosting active or queued prompts.
  - `{}` — list projects hosting active or queued prompts
- `gitmap_agy_prompt_counts`: Prompt counts per project.
  - `{}` — per-project breakdown of running, queued, and total prompts
- `gitmap_agy_fast_forward`: Fast-forward account switch.
  - `{"dry_run": "true"}` — simulate fast-forward account switch
- `gitmap_agy_backup`: Prompt state backup.
  - `{}` — back up active prompt turn states to SQLite Split-DB
- `gitmap_agy_restore`: Prompt state restoration.
  - `{}` — restore latest prompt turn backup
- `gitmap_templates`: Configuration template scaffolding.
  - `{"action": "list", "kind": "ignore", "lang": "go"}` — list available template snippets
  - `{"action": "show", "kind": "ignore", "lang": "go"}` — preview template contents
  - `{"action": "apply", "lang": "go", "dry_run": "true"}` — dry-run template scaffolding

#### Repo Group
- `gitmap_repo`: Repository lifecycle operations.
  - `{"action": "create", "name": "my-service"}` — create local or remote repository
  - `{"action": "clone", "url": "https://github.com/org/repo.git"}` — clone repository
  - `{"action": "cfr", "url": "https://github.com/org/repo.git"}` — clone, branch, and prepare fix
- `gitmap_cg`: Coding guidelines enforcement and prompt sync.
  - `{"action": "sync"}` — synchronize coding guidelines and AI prompts
  - `{"action": "install"}` — install guidelines to current workspace
- `gitmap_install`: Package, runtime, and toolchain installer.
  - `{"tools": "node,python,go"}` — install runtime toolchains
  - `{"tools": "cargo"}` — install Rust cargo toolchain
- `gitmap_commit`: Semantic commit execution.
  - `{"verb": "cpf", "message": "MODULE - add cluster health monitor"}` — Feature commit and push
  - `{"verb": "cbf", "message": "MODULE - fix memory leak in worker"}` — Bug fix commit and push
  - `{"verb": "cfr", "message": "MODULE - reduce function lines"}` — Refactor commit and push
  - `{"verb": "cpc", "message": "MODULE - chore clean dependencies"}` — Chore commit and push
  - `{"verb": "cp", "message": "wip: save state"}` — Flat WIP commit and push
- `gitmap_release`: Semantic release ceremonies and version tags.
  - `{"action": "cpr", "version": "vX.Y.Z", "summary": "hardened flexible path parsing"}` — execute release
- `gitmap_spec`: Concurrency-safe spec sequence numbers and spec discovery (CLI equivalents: `gitmap spec next`, `gitmap spec latest`, `gitmap spec list`).
  - `{"action": "next"}` — atomically claim next spec sequence number
  - `{"action": "latest"}` — inspect latest spec sequence directory and integer in `02-spec/21-app/`
  - `{"action": "list", "area": "21-app"}` — list specifications under `02-spec/21-app/`
  - `{"action": "show", "number": "437"}` — read spec by sequence number
  - `{"action": "show", "path": "02-spec/21-app/05-antigravity-manager-and-mcp.md"}` — read spec by relative path
- `gitmap_history`: Read-only repo and CLI history.
  - `{"action": "commits", "limit": "5"}` — read recent git commits (hash, date, author, message)
  - `{"action": "commands", "limit": "20", "json": "true"}` — read local GitMap CLI execution history
- `gitmap_stats`: Read-only usage statistics and churn.
  - `{"action": "usage"}` — aggregated CLI command metrics (runs, success/fail rate, duration)
  - `{"action": "commits", "limit": "5"}` — per-commit file churn via `git log --stat`

### 3.2 Extended Repo & Conflicts Tools

- `gitmap_pr` (extended repo): Local PR replay engine (not GitHub PRs). `list` audits recorded PRs in SQLite; `replay` replays commits and merges with `--no-ff`; `clean` prunes merged branches.
  - `{"action": "list"}`
  - `{"action": "replay", "left": "./upstream-repo", "right": "./mainline-repo", "dry_run": "true"}`
- `gitmap_resolve` (extended repo): Live working-tree merge conflicts on disk.
  - `{"action": "list"}` — check for conflicted files on disk
  - `{"action": "show", "file": "cli/cmd/root.go"}` — inspect file conflict markers
  - `{"action": "resolve", "strategy": "theirs"}` — resolve using incoming changes
  - `{"action": "abort"}` — safely abort in-progress merge/rebase
- `gitmap_os` & `gitmap_os_cache` (OS): Host metrics and 3-tier cache governance.
  - `{"action": "info"}`
  - `{"action": "stats"}`
  - `{"action": "clear", "tier": "l3", "dry_run": "true"}`
- `gitmap_help` (meta-help): Interactive tool discoverability and workflows.
  - `{"action": "index"}`
  - `{"action": "search", "query": "pipeline"}`
  - `{"action": "cheatsheet", "tool": "gitmap_os"}`
  - `{"action": "workflows"}`
- `gitmap_agy_prompts` (AGM prompts): Prompt DAG tree and turn inspection.
  - `{"action": "tree"}`
  - `{"action": "turn", "turn": "51"}`
  - `{"action": "rerun", "count": "4"}`
  - `{"action": "next", "step_code": "28 CODE"}`

## 4. AI Best Practices for Tool Utilization

To achieve maximum reliability, velocity, and correctness when operating as an autonomous AI agent with the GitMap MCP server, adhere strictly to these five operational principles:

### 4.1 Search Scoping Invariant
Always specify `"path": "."` or a targeted subfolder (e.g. `"path": "cli/cmdmcp"`, `"path": "src"`) when searching for specific file extensions or symbols so `gitmap_find` and `gitmap_aum_search` execute against the target directory without ambiguity.
- **Do:** `gitmap_find {"pattern": "*.go", "path": "cli/cmdmcp"}`
- **Do:** `gitmap_aum_search {"query": "createTool", "path": "cli/cmdmcp"}`
- **Avoid:** Unscoped searches across massive root directories when the relevant subsystem is already known.

### 4.2 Single-Repo Pull Rule
Always call `gitmap_pull {}` before editing code in the active workspace.
- **Routine Single-Repo Work:** Routine tasks must always execute `gitmap_pull {}` (current repository only).
- **Fleet-Wide Pull Restriction:** Never call `pull-all` (`{"action": "pull-all"}`) during routine single-repo work. Pulling all repositories across the workspace takes significant time, risks network timeouts, and can introduce external merge conflicts from unrelated repositories into the current active task context. Multi-repo `pull-all` is reserved for explicit fleet maintenance workflows.

### 4.3 Bounded File Inspection Chaining
Always chain `gitmap_find` -> `gitmap_cat` with bounded line ranges (`{"range": "1-50"}`).
- **Pattern:** First pinpoint the exact file path with `gitmap_find {"pattern": "tools_catalog*.go", "path": "cli/cmdmcp"}`.
- **Inspection:** Then inspect the target section using `gitmap_cat {"path": "cli/cmdmcp/tools_catalog.go", "range": "1-50"}`.
- **Safety:** Never cat entire large files without line bounds. Bounded reading protects the agent's context window, preserves token budget, and improves comprehension precision.

### 4.4 Diagnostic Extraction & Roadmaps
When encountering CI/CD failures or planning next steps:
- **Error Diagnostics:** Immediately call `gitmap_pipeline_errors {}` to extract the structured 4-part Root Cause Analysis (What failed, Where, Why, Fix direction). Pair with `gitmap_pipeline {"action": "trace"}` to inspect live pipeline execution without manual polling.
- **Roadmap Inspection:** Call `gitmap_plans {}` (or `gitmap_plans {"status": "pending"}`) to inspect verified memory roadmaps, pending milestones, and subtasks before initiating new architectural work.

### 4.5 Zero-Hit Search Recovery
If a search query in `gitmap_aum_search` or `gitmap_find` returns 0 hits:
1. **Inspect Smart Suggestions:** GitMap search returns intelligent fallback guidance. Review the suggested alternative terms or nearest path matches.
2. **Audit Folder Skips:** Check `gitmap aum skips` to verify whether the target directory was automatically skipped as a build/vendor artifact.
3. **Broaden Path Scope:** If searching a narrow subpath, expand the scope up one level or set `"path": "."`.
4. **Loosen Match Criteria:** If regex or case-sensitive search failed, fall back to a simpler token substring before concluding the symbol does not exist.

## 5. Add-a-command pattern (all in `cli/cmdmcp/`)

Five steps, no exceptions, in this order:

1. `createXTool()` factory in `tools_catalog_<group>.go` — description +
   input schema + 2–6 JSON examples embedded in the description.
2. Registration in `get<Group>Tools()`, wired into `GetToolsCatalog` in
   `tools_catalog.go`.
3. `case` in `tools_dispatch_<group>.go` — handler; prefer re-invoking the
   serving binary via `runGitmapSubprocess` for CLI-parity tools, in-process
   `cmdagy` only for read-only agy tools.
4. `is<Group>Tool()` predicate in `tools_dispatch.go`.
5. Test in `mcp_test.go` / `mcp_enhancements_test.go` (tool listed, callable,
   examples valid; a handler test per new tool, not just a catalog-count
   test).

Constraints on new code:

- **300-line file cap** (spec 243.4, CI file-size gate): any `.go` file changed
  in a commit must stay at or under 300 lines — no grandfathering for touched
  files. `tools_dispatch.go` was split for exactly this reason: group dispatch
  switches live in their `tools_dispatch_<group>.go` files
  (`tools_dispatch_fleet.go`, `tools_dispatch_diagnostics.go`,
  `tools_dispatch_mgmt.go`, ...); the central dispatcher keeps only routing,
  predicates, arg parsing, and the subprocess runner. Split by concern before
  a file crosses the cap; never grow an already-oversized file.
- **Test seam**: handlers re-invoke `os.Executable()`, which is the test
  binary under `go test`. Tests set the package-private
  `gitmapBinaryOverride` to a real gitmap binary (PATH, `bin/gitmap`, or
  `~/bin/gitmap`) and run from the repo root (`t.Chdir`). Never execute
  `spec next` in a test — it atomically claims (burns) a spec number.
- Any new tool that deletes, pushes, merges, or releases must say so in its
  description. Do not weaken the (absent) rights model; do not present the
  server as access-controlled.

## 6. Curated multi-tool workflows (also in `gitmap_help` → `workflows`)

An agent that has never seen gitmap can run either chain from these examples
alone. Each step names the exact tool + arguments + what a good result looks
like.

### 6.1 Morning sync: pull → spec → implement → commit → verify → release

1. `gitmap_scan {}` — registry rows for every repo, no scan errors.
2. `gitmap_pull {}` — active repository pulled and up-to-date with remote
   before modifying code. (Note: Fleet-wide multi-repo pull is an explicit
   maintenance action `{"action": "pull-all"}`; routine single-repo workflows
   must always use `gitmap_pull {}`).
3. `gitmap_spec {"action": "next"}` (or CLI `gitmap spec next`) — a bare number (e.g. 438); use it as the
   spec folder prefix `02-spec/21-app/<N>-<slug>/`. Ad-hoc Python directory traversal is strictly forbidden.
4. Implement: `gitmap_aum_search {"query": "<symbol>", "path": "<dir>"}` then
   `gitmap_cat {"path": "<file>", "range": "1-50"}`; spec + plan first, code second.
5. `gitmap_commit {"verb": "cpf", "message": "<N> <module> - <summary>"}` —
   commit + push both succeed (No Push = Not Done).
6. `gitmap_pipeline {"action": "trace"}` (`pe -t`) until green; cross-check
   the check-runs API on the exact commit SHA — never trust `pe` alone on a
   pre-fix binary.
7. `gitmap_release {"action": "cpr", "version": "vX.Y.Z", "summary": "<one line>"}` —
   only after step 6 is green for the exact tagged SHA, never while another
   release is in flight.

### 6.2 CI-red recovery: diagnose → fix → re-verify until green

1. `gitmap_pipeline {"action": "errors"}` — the failing job + first error
   lines (exit code, file, line).
2. `gitmap_pipeline_errors {}` — the 4-part RCA (what failed, where, why,
   fix direction).
3. `gitmap_log {"query": "<failing area>", "limit": "5"}` then
   `gitmap_aum_search {"query": "<symbol from the error>", "path": "<dir>"}` — the exact file +
   function to fix.
4. Fix locally, then check the blast radius: `gitmap_status {}` must show
   only the intended files dirty; `gitmap_lines {"max": "300", "path": "cli/cmdmcp"}`
   must show no new file-size violation.
5. `gitmap_commit {"verb": "cbf", "message": "<module> - fix <what>"}` — pushed.
6. `gitmap_pipeline {"action": "trace"}` — repeat steps 3–6 until green; a red
   run with an empty log means the run was cancelled by push churn — wait for
   a quiet window and re-run instead of changing code.

### 6.3 Other chains (in-server)

- Diagnostic & self-healing: `gitmap_status` → `gitmap_pipeline_errors` →
  `gitmap_doctor` → `gitmap_cfr`.
- Prompt lifecycle & watchdog: `gitmap_agy_prompts {"action": "running"}` →
  `{"action": "schedule-check"}` → `{"action": "queue-push"}`.
- OS & cache: `gitmap_os_cache {"action": "stats"}` →
  `{"action": "clear", "tier": "l3", "dry_run": "true"}`.
- Code search & implementation: `gitmap_aum_search {"query": "...", "path": "."}` →
  `gitmap_cat {"path": "...", "range": "1-50"}` → `gitmap_lf`.

## 7. Verification after changing the server

1. `go vet ./cmdmcp/...` and `go test ./cmdmcp/ -count=1` from `cli/`
   (`GOTMPDIR` set — this VM's `/tmp` is a 512MB tmpfs).
2. Rebuild + deploy so the serving binary matches source:
   `(cd cli && go build -o ../bin/gitmap .)` then
   `./local-install.sh --dir ~/bin --force`.
3. `gitmap --version` (expect the source version) and `gitmap mcp tools`
   (new tools listed).
4. Stdio smoke call: pipe a `tools/call` request for a read-only tool
   (e.g. `gitmap_spec` list) into `gitmap mcp serve --stdio` and confirm a
   real result comes back.
5. `gitmap mcp status` after deploy.
