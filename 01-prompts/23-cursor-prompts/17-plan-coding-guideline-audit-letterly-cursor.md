# Plan Coding Guideline Audit (Quality & Spec Scorecard) — Letterly Prompt Formatter

Format input text according to exact guideline audit planning template below without conversational filler or commentary.

1. Keep input text verbatim as is, only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`). TOTAL BAN on mutating, softening, summarizing, or altering input text in any way. Keep input 100% strictly intact, preserving all tone, urgency, emotion, technical flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `Plan Coding Guideline Audit for CLI Modules`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; formatted as XX-<task-slug> for directories and plan files).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: include fixed items 1-7 (pull first, scan codebase against 02-spec/02-coding-guidelines/, author audit scorecard under 02-spec/25-app-spec-audit/, enqueue remediation plan with 5-8 file micro-batches, GitMap search primacy, relative Git paths, and NO-BUILD/NO-TEST planning rules), followed by input directives as items 8..N.
6. Append mandatory audit planning skill invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.
8. Relative Paths: Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute paths.

${Input Text Verbatim} = Input text verbatim as is without filler words. Strict zero-mutation policy: never alter, soften, summarize, or rewrite input text in any way; preserve all directives, parameters, and tone 100% intact.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${Input Text Verbatim}

## task: <task title>
## slug: <task-slug>

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Scan target codebase against `02-spec/02-coding-guidelines/` to catalog all coding standard violations across error sovereignty, positive booleans, function line limits, and split DB encapsulation.
3. Author comprehensive audit scorecard and remediation matrix under `02-spec/25-app-spec-audit/XX-<slug>-audit.md`.
4. Enqueue remediation master plan in `.ai-memory/plans/pending/XX-<slug>.md` and bounded 5–8 file micro-batch subtasks under `.ai-memory/plans/subtasks/XX-<slug>/`.
5. Search codebase exclusively via GitMap (`gitmap aum search`, `gitmap find`, `gitmap cat`, `gitmap ps`, `gitmap py`, `gitmap llm train`); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String.
6. Strictly use relative Git paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
7. STRICTLY PLANNING ONLY: Total ban on code modification, compilation, local builds, or test suite execution during this planning phase (NO-BUILD, NO-TEST, NO-CODE-CHANGES).
8. ....other steps and more steps sequentially from the input direction.

## Must follow and spawn agent using (Non-Negotiable)

1. @[plan-coding-guideline-audit](directory;.cursor/skills/plan-coding-guideline-audit)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.cursor/skills/fix-with-rca)
3. @[coding-guidelines](directory;.cursor/skills/coding-guidelines)
4. @[error-management](directory;.cursor/skills/error-management)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;.cursor/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- All compliance audit matrices, scorecards, and remediation micro-batches are offboarded to @[plan-coding-guideline-audit](directory;.cursor/skills/plan-coding-guideline-audit).
- Keep all created specifications in `02-spec/25-app-spec-audit/` and plans in `.ai-memory/plans/pending/XX-<slug>.md` and `.ai-memory/plans/subtasks/XX-<slug>/` without starting immediate code execution.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
