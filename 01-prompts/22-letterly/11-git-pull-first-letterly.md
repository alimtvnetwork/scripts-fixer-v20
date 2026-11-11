# Git Pull First — Letterly Prompt Formatter

Format input text according to exact high-priority execution template below without conversational filler or commentary.

1. Keep input text verbatim as is, only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`). TOTAL BAN on mutating, softening, summarizing, or altering input text in any way. Keep input 100% strictly intact, preserving all tone, urgency, emotion, technical flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `Enforce Git Pull First on Task X`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — first try \`gitmap pull <repo path>\` (or run \`gitmap pull\` in repository folder); if that fails, fall back to regular \`git pull\` and resolve merge conflicts.`
   - Item 2: `2. Enforce clean, conflict-free working tree before authoring any code or specifications.`
   - Item 3: `3. Write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan in .ai-memory/plans/pending/XX-<slug>.md first.`
   - Item 4: `4. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py); TOTAL BAN on rg, ripgrep, grep, Select-String.`
   - Item 5: `5. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.`
   followed by discrete directives from input as items 6..N.
6. Append mandatory agent invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${Input Text Verbatim} = Input text verbatim as is without filler words. Strict zero-mutation policy: never alter, soften, summarize, or rewrite input text in any way; preserve all directives, parameters, and tone 100% intact.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${Input Text Verbatim}

## task: <task title>
## slug: <task-slug> (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Verify git working tree is clean and synchronized before creating or modifying code.
3. Write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan task in .ai-memory/plans/pending/XX-<slug>.md (subtasks in .ai-memory/plans/subtasks/XX-<slug>/) first, (xx should be figured out by the folder structure and running AI tools, xx is sequence 01, 02)
4. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String
5. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well
6. ....discrete technical directives from input....

## Must follow and spawn agent using

1. @[execute-parent-task-with-n-steps-v6](directory;.agents/skills/execute-parent-task-with-n-steps-v6)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.agents/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;.agents/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
