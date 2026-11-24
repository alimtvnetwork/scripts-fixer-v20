# AI Execution Directive: Generic Bug Recorder, REST/MCP Ingestion, Endpoint UI & GitLab/GitHub CLI Governance

> [!IMPORTANT]
> **Prompt Version:** 1.0.0
> **Target:** Any Autonomous AI Agent, Copilot, or CLI Developer Companion
> **Invocation:** Autonomous Multi-Agent Tree Swarm (`A = 3`, `H = 2`, `Capacity = 6`)
> **Top-Instruction Priority Mandate (Preamble Precedence):**
> Any directive, constraint, checklist, or instruction declared in the prompt preamble, header blocks, or incoming user request represents an absolute MUST FOLLOW mandate that takes highest priority and strictly overrides any conflicting general advice or lower-level conventions.

---

## 1. System Mission & Core Directives

You are an expert full-stack systems architect and autonomous AI engineer. Your objective is to implement a production-grade, generic bug recorder engine, universal REST/MCP ingestion pipeline, endpoint-based web dashboard, error management modernization, and cross-platform GitLab (`glab`) / GitHub (`gh`) CLI governance across the target codebase.

You MUST execute this task with zero hallucinations, strict coding guideline enforcement, positive booleans, single-return Result containers, and bounded micro-batching.

---

## 2. Non-Negotiable Implementation Checklists

### Checklist A: Generic Bug Recorder Engine & Schema
- [ ] Implement canonical 16-field defect record schema (`id`, `number`, `title`, `slug`, `repo`, `status`, `severity`, `reporter`, `environment`, `steps`, `screenshots`, `session_ref`, `error_code`, `rca_ref`, `transition_reason`, `is_offline`).
- [ ] Enforce per-repository monotonic bug numbers (`BUG-<slug>-<N>`).
- [ ] Enforce 7-state append-only lifecycle machine (`recorded` -> `triaged` -> `in-progress` -> `fixed` -> `verified` -> `closed`, with `reopened` transition target).
- [ ] Implement four-tier reproduction step enrichment:
  - Tier 1: Backend Function, File, Line, and Trigger command.
  - Tier 2: Dual-mode visual snapshot with animated red coordinate locator ring.
  - Tier 3: DOM element descriptor, normalized XPath, and component hierarchy.
  - Tier 4: Raw JSON payload with 1-click copy support.
- [ ] Implement SHA-256 screenshot deduplication and disk caching.
- [ ] Shield all recorder HUD elements with `data-recorder-hud="true"` to prevent self-recursive capture loops.

### Checklist B: Universal Ingestion REST & MCP Endpoints
- [ ] Implement `/api/bugs/list` supporting pagination, repo slug, and status filtering.
- [ ] Implement `/api/bugs/get` supporting retrieval by unique ID or slug with full hydration.
- [ ] Implement `/api/bugs/save` supporting atomic creation, updates, and status transitions.
- [ ] Implement `/api/bugs/event` supporting single-step extraction with 2–3 step blast radius context.
- [ ] Register `gitmap_bug_record` MCP tool in the tools catalog supporting `list`, `get`, `create`, `save`, and `event` actions.
- [ ] Enforce the Universal Response Envelope across all API endpoints: `{ isSuccess: boolean, count?: number, data?: any, errorMessage?: string }`.

### Checklist C: Endpoint-Based React Web Dashboard
- [ ] Create `/bugs` dashboard route with top KPI summary counters (Total, Open, In-Progress, Fixed, Closed).
- [ ] Implement multi-select filter bar (App Slug, Status, Severity) and real-time search input.
- [ ] Render interactive defect session table with status badges and severity pills.
- [ ] Create `/bugs/:id` detailed defect inspection view with left-hand event timeline and right-hand 4-tier inspector.
- [ ] Implement full-screen screenshot Lightbox; guarantee dismissing lightbox returns focus to the active event in the timeline table.
- [ ] Ensure vertical resize handle between timeline and inspector maintains constant width `w-1.5` without hover jumps.
- [ ] Implement 1-click export actions: V6 Letterly prompt, V7 Tree Swarm prompt, and forensic ZIP bundle.

### Checklist D: Error Management Modernization (`02-spec/03-error-manage/`)
- [ ] TOTAL BAN on raw magic strings in error codes (e.g. `"E2010"`) and categories.
- [ ] Standardize all error variants on strongly typed `errtype.Variation` integer enums.
- [ ] Enforce single-return monadic `Result[T]` containers (`result.Wrap[T]`), eliminating bare `(T, error)` tuples.
- [ ] Enforce positive boolean properties: `isSuccess`, `hasError`, `isFailed`, `hasData` (strictly ban `!response.success`).
- [ ] Author all error models with fluent builders: `.WithOp()`, `.WithVar()`, `.WithCause()`, `.WithStatus()`.
- [ ] Align polyglot codebases (Go, TypeScript, Rust, Python, PHP) to the unified error architecture.

### Checklist E: GitLab (`glab`) & GitHub (`gh`) CLI Governance
- [ ] Confirm issue creation capabilities across both `gh issue create` and `glab issue create`.
- [ ] Implement file and screenshot attachment upload support via `--attach <file_path>` across both CLIs.
- [ ] Implement native confidential issue creation in GitLab via `--confidential` / `-c`.
- [ ] Automatically detect remote repository type (GitHub vs GitLab) from git remote origin URL.
- [ ] Pass non-interactive flags (`--yes` for `glab`) to guarantee autonomous execution without terminal hangs.
- [ ] Expose unified CLI command: `gitmap issue create` delegating to `gh` or `glab`.

---

## 3. Strict Coding & Behavioral Guidelines

1. **Function Size Limit:** Every function MUST be <= 15 lines (8 lines preferred). Functions exceeding 15 lines must be decomposed.
2. **Zero Nested Ifs:** Flatten all conditional logic with early returns and guard clauses.
3. **Positive Booleans Only:** All boolean variables and return types MUST begin with `is` or `has` and express positive logic (`isSuccess`, `hasData`). Negative booleans (`isNotValid`) are strictly banned.
4. **SQL Repository Pattern:** All database queries MUST be encapsulated behind repository interfaces in dedicated packages. No raw inline SQL in handlers or UI components.
5. **No Per-File Commits:** Accumulate all changes across the turn and commit in a single atomic GitMap commit at the final step.
