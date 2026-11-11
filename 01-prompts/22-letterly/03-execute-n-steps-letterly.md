# Execute N-Steps — Letterly Prompt Formatter

Format input text according to exact high-priority execution template below without conversational filler or commentary.

1. Keep input text verbatim as is, only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`). TOTAL BAN on mutating, softening, summarizing, or altering input text in any way. Keep input 100% strictly intact, preserving all tone, urgency, emotion, technical flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `SEO Writing and Folder Structure Instructions`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders (`## task: <task title>`, `## slug: <task-slug>`).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: fixed items 1-8 (pull first, spec, 100-step roadmap, ambiguity log, instruction generator, GitMap search, relative paths, coding guidelines, and SQL repository pattern), then input directives as items 9..N.
6. Append mandatory agent invocation suffix under `## Must follow and spawn agent using (Non-Negotiable)`.
7. Output plain markdown only. Never wrap in fenced code blocks.
8. Relative Paths: Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute paths.

${Input Text Verbatim} = Input text verbatim as is without filler words. Strict zero-mutation policy: never alter, soften, summarize, or rewrite input text in any way; preserve all directives, parameters, and tone 100% intact.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${Input Text Verbatim}

## task: <task title>
## slug: <task-slug>

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — try `gitmap pull <repo path>` first (or `gitmap pull` in repo folder); fallback to `git pull` and resolve merge conflicts so repository is clean and current.
2. Write spec under `02-spec/21-app/XX-<slug>/01-architecture-spec.md` and enqueue plan task in `.ai-memory/plans/pending/XX-<slug>.md` (subtasks in `.ai-memory/plans/subtasks/XX-<slug>/`) first (XX is zero-padded sequence).
3. Formulate master plan in 100 granular self-looping steps detailing an actionable AI roadmap. Record any ambiguities to `.ai-memory/ambiguous-questions/01-new-ambiguity/XX-<slug>-ambiguity.md` and proceed autonomously without asking user.
4. At the end of planning, generate complete AI instructions using @[execute-ai-instruction-writer](directory;.agents/skills/execute-ai-instruction-writer).
5. Search codebase exclusively via GitMap (`gitmap aum search`, `gitmap find`, `gitmap cat`, `gitmap ps`, `gitmap py`, `gitmap llm train`); TOTAL BAN on rg, ripgrep, grep, Select-String.
6. Strictly use relative Git paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute filesystem paths.
7. Enforce Coding Guidelines & Error Management invariants per @[coding-guidelines](directory;.agents/skills/coding-guidelines) and @[error-management](directory;.agents/skills/error-management) (functions <= 15 lines, no magic strings, zero nested ifs, positive booleans `is*`/`has*` only).
8. Enforce SQL repository pattern and enum-driven actions per @[sql-repository-pattern-and-enum-actions](directory;.agents/skills/sql-repository-pattern-and-enum-actions): all SQL isolated behind repository interfaces, operations dispatched by exhaustive enum switch, and strongly-typed AppError envelopes.
9. ....other steps and more steps sequentially from the input direction. Create more steps in between.

## Must follow and spawn agent using (Non-Negotiable)

1. @[execute-parent-task-with-n-steps-v6](directory;.agents/skills/execute-parent-task-with-n-steps-v6)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.agents/skills/fix-with-rca)
3. @[coding-guidelines](directory;.agents/skills/coding-guidelines)
4. @[error-management](directory;.agents/skills/error-management)
5. @[execute-ai-instruction-writer](directory;.agents/skills/execute-ai-instruction-writer)

## Additional Instructions

- [/learn](slashCommand;learn) from @[gitmap](directory;.agents/skills/gitmap) skill for high-speed search and caching.
- [/plan](slashCommand;plan) first before doing work for improved execution without errors following Coding Guidelines.
- Formulate master plan in 100 granular self-looping steps detailing an actionable AI roadmap.
- At end of planning, generate complete AI instructions using @[execute-ai-instruction-writer](directory;.agents/skills/execute-ai-instruction-writer) so AI execution follows through accurately.
- Ambiguity Protocol: Record any ambiguity to `.ai-memory/ambiguous-questions/01-new-ambiguity/XX-<slug>-ambiguity.md`; proceed autonomously without asking user.
- All execution mechanics, tree swarm hierarchy, dynamic agent join, and SQLite task management are offboarded to @[execute-parent-task-with-n-steps-v6](directory;.agents/skills/execute-parent-task-with-n-steps-v6).
- After learning and planning, immediately begin executing the plan without asking for confirmation.
- Track in-flight touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `tree` / `live` / `sync`).
- Strictly use relative Git paths; never add absolute filesystem paths.
