# Execute N Steps

Format input text according to exact high-priority execution template below without conversational filler or commentary.

1. Keep input text verbatim as is, only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`). TOTAL BAN on mutating, softening, summarizing, or altering input text in any way. Keep input 100% strictly intact, preserving all tone, urgency, emotion, technical flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `SEO Writing and Folder Structure Instructions`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders (`## task: <task title>`, `## slug: <task-slug>`).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: include fixed items 1-7 (pull first, spec/plan enqueue with 100-step roadmap and ambiguity logging without asking user, GitMap search primacy, relative Git paths mandate, coding guidelines & error management invariants, and SQL repository pattern), followed by discrete technical directives from input text as items 8..N.
6. Append mandatory agent invocation suffix pointing to directory-based skill references: execute-parent-task-with-n-steps-v6, fix-with-rca, coding-guidelines, and error-management.
7. Output plain markdown only. Never wrap in fenced code blocks.
8. Relative Paths: Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute paths.

${Input Text Verbatim} = Input text verbatim as is without filler words. Strict zero-mutation policy: never alter, soften, summarize, or rewrite input text in any way; preserve all directives, parameters, and tone 100% intact.

Output:

# <task title>: high priority instruction, non-negotiable task

${Input Text Verbatim}

## task: <task title>
## slug: <task-slug>

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Write spec under `02-spec/21-app/XX-<slug>/` and enqueue plan task in `.ai-memory/plans/pending/XX-<slug>.md` (subtasks in `.ai-memory/plans/subtasks/XX-<slug>/`) first.
3. Formulate master plan in 100 granular self-looping steps detailing an actionable AI checklist and execution roadmap. Any question or ambiguity MUST be written to `.ai-memory/ambiguous-questions/01-new-ambiguity/XX-<slug>-ambiguity.md`. Do NOT ask the user — proceed autonomously and go ahead unless the user explicitly commanded "Ask me the question".
4. Search codebase exclusively via GitMap (`gitmap aum search`, `gitmap find`, `gitmap cat`, `gitmap ps`, `gitmap py`, `gitmap llm train`); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String.
5. Strictly use relative Git paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
6. Enforce Coding Guidelines & Error Management invariants checklist per @[coding-guidelines](directory;.agents/skills/coding-guidelines) and @[error-management](directory;.agents/skills/error-management) (functions <= 15 lines, no magic strings/literals, zero nested ifs, positive booleans `is*`/`has*` only, clean vertical spacing).
7. Enforce SQL repository pattern and enum-driven actions per @[sql-repository-pattern-and-enum-actions](directory;.agents/skills/sql-repository-pattern-and-enum-actions): all SQL isolated behind repository interfaces, operations dispatched by exhaustive enum switch with complete util methods (String, Parse, IsValid, All), and strongly-typed AppError envelopes.
8. ....other steps and more steps sequentially from the input direction. Create more steps in between.

## Must follow and spawn agent using (Non-Negotiable)

1. @[execute-parent-task-with-n-steps-v6](directory;.agents/skills/execute-parent-task-with-n-steps-v6)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.agents/skills/fix-with-rca)
3. @[coding-guidelines](directory;.agents/skills/coding-guidelines)
4. @[error-management](directory;.agents/skills/error-management)

## Additional Instructions

- [/learn](slashCommand;learn) from @[gitmap](directory;.agents/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- All execution mechanics, tree swarm hierarchy, dynamic agent join, and SQLite task management are offboarded to @[execute-parent-task-with-n-steps-v6](directory;.agents/skills/execute-parent-task-with-n-steps-v6).
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
