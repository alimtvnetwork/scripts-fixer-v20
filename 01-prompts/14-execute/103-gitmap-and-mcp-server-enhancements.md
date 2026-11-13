# AI Execution Instruction — Plan 103: GitMap and MCP Server Enhancements

> **Status:** ACTIVE  
> **Target Slug:** gitmap-and-mcp-server-enhancements  
> **Spec File:** `02-spec/21-app/103-gitmap-and-mcp-server-enhancements/01-architecture-spec.md`  
> **Master Plan:** `.ai-memory/plans/pending/103-gitmap-and-mcp-server-enhancements.md`  

---

## 1. Top-Instruction Priority Mandate (Preamble Precedence)

Whatever directives, constraints, checklists, or instructions are given in this prompt are HIGHEST PRIORITY and NON-NEGOTIABLE.
All execution mechanics must follow:
- Tree Swarm Hierarchy ($A=2, H=2$)
- Coding Guidelines (functions $\le 15$ lines, positive booleans, zero nested `if`s)
- Leaf Error Sovereignty (all leaf functions return `*apperror.AppError`, top-level handlers exit)
- Strict relative Git paths (no absolute filesystem paths)
- Exclusive GitMap search (`gitmap aum search`, `gitmap find`, `gitmap cat`)

---

## 2. Ordered Work Streams & Deliverables

### Work Stream A: Error Display Compactness & Exit 101 RCA
1. Update `cli/strutil/strutil.go` to ensure all bracketed error prefixes (`[CODE:TYPE]`) are stripped cleanly from error messages.
2. In `cli/cmderrors/errors_render.go`, format table rows compactly without square brackets.
3. In `cli/cliexit/` and subprocess runners, intercept exit status 101, classify as `E_RUST_PANIC`, and attach captured stderr and actionable root cause context.

### Work Stream B: AGY Database Subcommand & On-The-Fly Prompting
1. Register `db` alias under `gitmap agy` in `cli/cmdagy/agy_cmd.go`.
2. Implement `gitmap agy db [limit]` and `gitmap agy db query "<sql>"` with read-only SQL validation.
3. Register `on-the-fly` (aliases: `otf`, `ask`) under `gitmap agy`.
4. Implement `gitmap agy on-the-fly "<prompt>"` invoking `agy.exe -p "<prompt>" --output-format text --dangerously-skip-permissions` against default instance without project context.

### Work Stream C: Mermaid ER Database Visualizer & Schema Sync
1. Implement `gitmap mermaid db <path-or-alias> [--out <file>]` introspecting SQLite tables, columns, and foreign keys into Mermaid `erDiagram`.
2. Implement `gitmap sync-db mermaid <file> [--db <path>] [--dry-run]` parsing `.mermaid` / `.marmaid` files and applying `CREATE TABLE IF NOT EXISTS` DDL statements.

### Work Stream D: Native MCP Server Tools & Command Catalog
1. Add MCP tools: `gitmap_make_private`, `gitmap_make_public`, `gitmap_agy_db`, `gitmap_agy_on_the_fly`, `gitmap_mermaid_db`, `gitmap_sync_db_mermaid`.
2. Register terminal help in `cli/helpdoc/` (`agy-db.md`, `agy-on-the-fly.md`, `mermaid-db.md`, `sync-db-mermaid.md`).
3. Register command catalog entries in `src/data/commands.ts`.
4. Compile binary, perform atomic swap to PATH, and verify on current machine.
