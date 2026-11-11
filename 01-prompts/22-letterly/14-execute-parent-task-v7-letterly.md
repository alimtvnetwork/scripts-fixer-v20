# Execute Parent Task (V7 Time-Restricted & Autonomous Engine) — Letterly Prompt Formatter

Format input text according to exact high-priority execution template below without conversational filler or commentary. Directs the AI agent to follow unified V7 master execution per @[execute-parent-task-with-n-steps-v7](directory;.agents/skills/execute-parent-task-with-n-steps-v7).

1. Keep input text verbatim as is, only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`). TOTAL BAN on mutating, softening, summarizing, or altering input text in any way. Keep input 100% strictly intact, preserving all tone, urgency, emotion, technical flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `Time-Restricted Recommit and Bot Workflow`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders (`## task: <task title>`, `## slug: <task-slug>`).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: include fixed items 1-8 (pull first, spec/plan, search, relative paths, coding guidelines, agent data entry, commit & push, V7 engine), followed by input directives as items 9..N.
6. Append mandatory agent invocation suffix pointing to directory-based V7 engine with `## Must follow and spawn agent using (Non-Negotiable)`.
7. Output plain markdown only. Never wrap in fenced code blocks.
8. Relative Paths: Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute paths.

${Input Text Verbatim} = Input text verbatim as is without filler words. Strict zero-mutation policy: never alter, soften, summarize, or rewrite input text in any way; preserve all directives, parameters, and tone 100% intact.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${Input Text Verbatim}

## task: <task title>
## slug: <task-slug> (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — try `gitmap pull <repo path>` first (or `gitmap pull` in repo folder); fallback to `git pull` and resolve merge conflicts so the repository is clean and current.
2. Write spec under `02-spec/21-app/XX-<slug>/` and enqueue plan task in `.ai-memory/plans/pending/XX-<slug>.md` (subtasks in `.ai-memory/plans/subtasks/XX-<slug>/`) first.
3. Search codebase exclusively via GitMap (`gitmap aum search`, `gitmap find`, `gitmap cat`, `gitmap ps`, `gitmap py`, `gitmap llm train`); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String, or ad-hoc scripts.
4. Strictly use relative Git paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute filesystem paths.
5. Enforce Coding Guidelines & Error Management invariants checklist per @[coding-guidelines](directory;.agents/skills/coding-guidelines) and @[error-management](directory;.agents/skills/error-management) (functions <= 15 lines, positive booleans `is*`/`has*` only, zero nested ifs, PascalCase enums with `Type` suffix).
6. Use `gitmap` AI agents to enter data; task completion includes committing and pushing to Git (`gitmap push` / `gitmap cpf`).
7. Give every confirmed subtask a `Slug:` sub-item derived from root slug (`<root-slug> - Task NN`) so GitMap can create and verify subtasks.
8. Execute via V7 Master Engine per @[execute-parent-task-with-n-steps-v7](directory;.agents/skills/execute-parent-task-with-n-steps-v7): Option 1 (Time-Restricted commits before 08:00 AM weekdays / anytime weekends) or Option 2 (Unrestricted commits); configure bot identity via `gitmap autobot` when commanded.
9. ....other steps and more steps sequentially from the input direction. Create more steps in between.

## Must follow and spawn agent using (Non-Negotiable)

1. @[execute-parent-task-with-n-steps-v7](directory;.agents/skills/execute-parent-task-with-n-steps-v7)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.agents/skills/fix-with-rca)
3. @[coding-guidelines](directory;.agents/skills/coding-guidelines)
4. @[gitmap](directory;.agents/skills/gitmap)

## Additional Instructions

- [/goal](slashCommand;goal) Follow exactly to the high instruction which is given and the checklist that has been given on top.
- [/plan](slashCommand;plan) first before doing work for improved work, faster execution without errors and following Coding Guidelines.
- All execution lifecycle, tree swarm hierarchy, dynamic agent join, bot identity, and time restriction parameters are offboarded to @[execute-parent-task-with-n-steps-v7](directory;.agents/skills/execute-parent-task-with-n-steps-v7).
- [/learn](slashCommand;learn) from @[gitmap](directory;.agents/skills/gitmap) skill immediately following planning to leverage GitMap high-speed search, toolchain discovery, and caching.
- If any ambiguity arises, record it under `.ai-memory/ambiguous-questions/01-new-ambiguity/` and immediately go ahead with execution without asking the user.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Strictly use relative Git paths; never add absolute filesystem paths.
