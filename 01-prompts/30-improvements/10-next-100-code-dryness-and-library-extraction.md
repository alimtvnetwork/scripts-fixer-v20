# Next 100 Code Dryness Improvements

## slug: next-100-code-dryness-improvements

```text
N = 400 (Total self-loop steps budget — editable top-header parameter, default: 400)
A = 3   (MANDATORY number of spawned autonomous subagents running concurrently via invoke_subagent, default: 3)
H = 2   (Operational hands per agent: dual-task batch capacity & parallel tool dispatch, default: 2)
C = 30  (Tool calls per worker before it must report, default: 30)

System Concurrency Capacity = A × H = 3 agents × 2 hands = 6 concurrent subtask operations
Tree Hierarchy = Lead Orchestrator (Root Node) -> Branch Coordinators (Subtask Owners) -> Leaf Workers & Dynamic Joining Assistants
PHASE_1_BUDGET = 100     (Steps 1 .. 100: Planning, GitMap Codebase Scanning, Discovery Subagents, Up-Front Brain & Roadmap Creation)
PHASE_2_BUDGET = 150     (Steps 101 .. 250: 10-Field Specification Card Authoring, Micro-Batching Waves, Master Catalog Assembly, Pending Plan Enqueueing)
PHASE_3_BUDGET = 150     (Steps 251 .. 400: Retrospective Quality Verification, Relative Path Hygiene, Dynamic Join Saturation, Atomic Push)
WAVES = ceil(subtasks / (A x H))
```

> [!IMPORTANT]
> Prompt Version: 1.0.0
> Runtime: Google Antigravity 2.0 (IDE and CLI)
> Invoke: /next-100-code-dryness-improvements <codebase-or-path>
>
> **Trigger Keywords & Aliases:**
> `next-100-code-dryness-improvements`, `next-100-code-dryness`, `code-dryness-100`, `next-dryness-improvements`, `dryness-improvements`
>
> **Top-Instruction Priority Mandate (Above Precedence / Preamble Precedence):**
> Whatever directives, constraints, checklists, or user instructions are given ABOVE this prompt are HIGHEST PRIORITY and MUST BE FOLLOWED as strictly NON-NEGOTIABLE.

[/goal](slashCommand;goal) Autonomously scan, audit, discover, and document exactly 100 high-impact, grounded code dryness (DRY), anti-duplication, and structural hygiene improvements across the target codebase: partition the discovery across 10 canonical Code Dryness Rule Families (10 improvements per family = 100 total), format each improvement into an exhaustive 10-field specification card, compile a Master Catalog Summary Table, enqueue all 100 improvements as actionable, execution-ready pending plans into `.ai-memory/plans/pending/XX-<slug>.md` with modular subtasks in `.ai-memory/plans/subtasks/XX-<slug>/`, and configure the pipeline so each successive execution seamlessly generates the next 100 improvements.

[/learn](slashCommand;learn) Enforce the Top-Instruction Priority Mandate: all discoveries, analysis, and fix proposals must strictly ground themselves in repository coding guidelines (`02-spec/02-coding-guidelines/`) and error management standards (`02-spec/03-error-manage/`). Every single improvement proposal must eliminate duplicate logic, extract shared single-responsibility helpers, flatten nested if statements, eradicate magic strings and numbers, centralize enums with `Type` suffixes, and route all fallible operations through AppError or the error store.

[/plan](slashCommand;plan) Execute thorough step-by-step planning before execution:
1. Scan codebase for duplicate logic across functions, handlers, and UI components using `gitmap aum search`.
2. Categorize candidates across the 10 Code Dryness Rule Families.
3. Author detailed 10-field specification cards with exact line ranges, caller blast radius, and drop-in refactored code.
4. Enqueue structured micro-batches in `.ai-memory/plans/pending/` with subtasks in `.ai-memory/plans/subtasks/`.

---

## The 10 Code Dryness Rule Families (10 Items Each = 100 Total)

1. **Family 01: Function Logic Duplication & Utility Extraction**
   - Identify identical or near-identical business logic repeated across multiple functions or files.
   - Extract pure, reusable helpers into domain utilities (e.g. `src/utils/`, `src-tauri/src/modules/`).
   - Cap function lengths to 8–15 lines with a single, clear responsibility.

2. **Family 02: Magic String Eradication & Enum Centralization**
   - Scan for raw string comparisons, string literals, and magic numbers scattered in code.
   - Consolidate into strongly-typed enums (`PascalCase` naming, `Type` suffixes in Go/Rust/TS).
   - Author helper methods (`as_str()`, `parse()`, `is_valid()`) and eliminate hardcoded string matches.

3. **Family 03: Nested Conditionals & Guard Clause Inversion**
   - Flatten deeply nested `if` / `else if` / `else` branches using early return guard clauses.
   - Enforce zero nested `if` statements (max nesting depth: 1).
   - Decompose multi-clause boolean expressions into named boolean variables with positive prefixes (`is`, `has`).

4. **Family 04: UI Component Logic Duplication & Custom Hook Extraction**
   - Identify repeated React UI patterns (pill capsules, action buttons, modals, dropdown positioning).
   - Extract repetitive state management (polling, outside-click detection, window listeners) into custom React hooks (`use...`).
   - Centralize layout styling tokens and eliminate copy-pasted Tailwind utility strings.

5. **Family 05: Monadic Error Envelope Unification & Swallowed Error Elimination**
   - Enforce the **No Silent Errors** house rule: every fallible operation must route failures to AppError or the error store.
   - Eradicate bare `catch {}`, `.catch(() => {})`, `let _ = <fallible>`, or `.ok()` without logging.
   - For best-effort operations, require `crate::error::record_ignored` plus an explicit `// Justification:` comment.

6. **Family 06: Parallel Data Structures & Single Source of Truth**
   - Identify synchronized parallel arrays, duplicate state stores, or redundant caches tracking the same underlying entity.
   - Unify into a single normalized data structure or reactive store.
   - Eliminate out-of-sync risks and stale cache invalidation bugs.

7. **Family 07: Parameter Struct Consolidation & Signature Slimming**
   - Scan functions taking more than 3 parameters or receiving long positional arguments.
   - Group related arguments into dedicated parameter options structs (`Options`, `Config`, `Params`).
   - Use variadic or spread patterns (`...args`, `&[T]`) instead of artificial slice wrapping.

8. **Family 08: Database Query & Repository Pattern Centralization**
   - Extract raw SQLite queries, inline SQL strings, and repetitive migrations behind repository interfaces.
   - Standardize table naming (`PascalCase`), column naming (`camelCase`), and positive boolean flags (`is_active`, `has_synced`).
   - Consolidate query builders and enforce WAL mode consistency across split databases.

9. **Family 09: Pure Function Construction & Immutability Guarantees**
   - Eliminate in-place mutations of shared objects across conditional branches.
   - Enforce copy-on-write semantics and pure constructor returns.
   - Avoid mutable references (`mut`) outside tight iteration loops.

10. **Family 10: Polyglot Standard Library & Framework Helper Adoption**
    - Audit ad-hoc reimplementations of standard library features (string padding, trimming, cloning, JSON extraction).
    - Replace custom reinvented wheels with idiomatic standard helpers or existing workspace packages.
    - Guarantee zero regression through automated verification contracts.

---

## 10-Field Specification Card Schema

Every improvement card must contain:
1. `Id`: `DRY-XX`
2. `Title`: Concise description of the duplication / structural hygiene violation.
3. `Rule Family`: One of Families 01–10.
4. `Target Files`: Strictly repository-relative paths with exact line numbers (`file:///...#Lxx-Lyy`).
5. `Violation Pattern`: Grounded code snippet demonstrating the duplicate logic or hygiene issue.
6. `Refactored Solution`: Copy-paste ready drop-in replacement with extracted shared helper or centralized enum.
7. `Caller Blast Radius`: List of all callers identified via `gitmap aum search` requiring updates.
8. `Lines of Code Saved`: Estimated code reduction and complexity reduction.
9. `Verification Contract`: Concrete CLI command, unit test, or verification script validating the fix.
10. `Subtask Reference`: Relative path to the generated subtask in `.ai-memory/plans/subtasks/`.
