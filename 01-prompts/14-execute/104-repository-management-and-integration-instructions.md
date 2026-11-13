# AI Execution Instruction — Plan 104: Repository Management and Multi-IDE Integration Instructions

> **Status:** ACTIVE  
> **Target Slug:** repository-management-and-integration-instructions  
> **Spec File:** `02-spec/21-app/104-repository-management-and-integration-instructions/01-architecture-spec.md`  
> **Master Plan:** `.ai-memory/plans/pending/104-repository-management-and-integration-instructions.md`  
> **Subtasks Directory:** `.ai-memory/plans/subtasks/104-repository-management-and-integration-instructions/`  
> **Target Version:** v6.681.0  

---

## 1. Top-Instruction Priority Mandate (Preamble Precedence)

Whatever directives, constraints, checklists, or instructions are given in this prompt are HIGHEST PRIORITY and NON-NEGOTIABLE.
All execution mechanics must follow:
- Tree Swarm Hierarchy ($A=2, H=2$)
- Coding Guidelines (functions $\le 15$ lines, positive booleans `is*`/`has*`, zero nested `if`s)
- Leaf Error Sovereignty (all leaf functions return `*apperror.AppError`, top-level handlers exit)
- Strict relative Git paths (no absolute filesystem paths)
- Exclusive GitMap search (`gitmap aum search`, `gitmap find`, `gitmap cat`)
- Mandatory semantic commit verbs (`gitmap cpr "v6.681.0 - multi-ide auto-registration cursor memory db and desktop popup auto-tick"`)

---

## 2. Ordered Work Streams & Deliverables

### Work Stream A: Antigravity Multi-Instance Discovery & Project Registration (RCA-1)
1. In `cli/workspacesync/`:
   - Implement `ResolveHostUserProfile` to recover base user profile when running inside an Antigravity instance (`.antigravity_tools`).
   - Implement `DiscoverAllAgyProjectDirs() []string` discovering `~/.gemini/config/projects/` and all `.antigravity_tools/instances/*/home/.gemini/config/projects/`.
   - Update `SyncAntigravity` to iterate through all discovered instances and register `<uuid>.json`.
   - Add unit tests in `cli/workspacesync/agy_sync_multi_test.go`.

### Work Stream B: Cursor Workspace Registration & Memory Database Engine (RCA-2)
1. Create `cli/cursorpm/` mirroring `vscodepm` but targeting Cursor storage (`%APPDATA%\Cursor\User\projects.json` and extension storage).
2. Wire Cursor sync into `cli/workspacesync/workspacesync.go` so `SyncAll` outputs `[cur: ok]`.
3. Create `cli/cmdcursor/cursor_db.go`:
   - `gitmap cursor db export [path]` (extracting `state.vscdb` + `conversation-search.db` to `cursor_memory.db`)
   - `gitmap cursor db import <path> [--dry-run]`
   - `gitmap cursor db stats`
   - `gitmap cursor db query "<sql>"`
4. Add unit tests in `cli/cursorpm/cursorpm_test.go` and `cli/cmdcursor/cursor_db_test.go`.

### Work Stream C: GitHub Desktop Pop-Up Modal Auto-Resolution (RCA-3)
1. In `cli/desktop/desktop_autoconfirm.go`:
   - Implement `AutoConfirmDesktopModal(repoPath string)`.
   - On Windows: Run background non-blocking PowerShell script targeting GitHub Desktop window and invoking "Add repository" button or `{ENTER}`.
   - On Linux: Run background `xdotool`.
   - On macOS: Run background `osascript`.
2. In `cli/desktop/desktop.go:addOne`: Invoke `AutoConfirmDesktopModal` immediately following the CLI open verb.
3. Add unit tests in `cli/desktop/desktop_autoconfirm_test.go`.

### Work Stream D: Antigravity Terminal UI Table Polish (RCA-4)
1. In `cli/cmdagy/agy_summaries.go`:
   - Redesign table to fit within ~80 columns without wrapping lines.
   - Shorten conversation ID to 8 chars (`uuid[:8]`).
   - Add `--full` / `--wide` flag for displaying full 36-char UUID.
   - Render clean Tokyo Night border tokens.
2. In `cli/cmdagy/agy_wpr_render.go`: Clean up table borders and padding.
3. Add unit tests in `cli/cmdagy/agy_summaries_test.go`.

### Work Stream E: Catalogs, Help Documentation & Release
1. Update `src/data/commands.ts` with new Cursor database commands.
2. Add help docs in `cli/helpdoc/cursor-db.md`.
3. Create Antigravity skill `.agents/skills/cursor-memory-and-workspace/skill.md` with valid YAML frontmatter.
4. Validate with `python 03-ai-scripts/53-skill-frontmatter-validator.py`.
5. Run targeted tests, bump version to `v6.681.0`, build, swap binary, and release via `gitmap cpr`.
