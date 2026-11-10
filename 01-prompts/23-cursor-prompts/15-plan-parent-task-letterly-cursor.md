# Plan Parent Task (N-Steps Blueprint) — Cursor Prompt Formatter

Format input text according to exact planning-only template below without conversational filler or commentary.

1. Clean input text verbatim, stripping verbal fillers while strictly preserving architectural requirements, scope boundaries, and design constraints.
2. Derive `<task title>` as task subject (e.g. `Architect Cache Eviction Engine`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; when authoring directories and plan files, format as XX-<task-slug> where XX is zero-padded sequence).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — first try \`gitmap pull <repo path>\` (or run \`gitmap pull\` in repository folder); if that fails, fall back to regular \`git pull\` and resolve merge conflicts.`
   - Item 2: `2. Write comprehensive architectural specification under 02-spec/21-app/XX-<slug>/01-architecture-spec.md adhering strictly to 02-spec/01-spec-authoring-guide/.`
   - Item 3: `3. Enqueue master plan under .ai-memory/plans/pending/XX-<slug>.md and granular subtasks under .ai-memory/plans/subtasks/XX-<slug>/01-subtask-<name>.md.`
   - Item 4: `4. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py); TOTAL BAN on rg, ripgrep, grep, Select-String.`
   - Item 5: `5. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.`
   - Item 6: `6. STRICTLY PLANNING ONLY: Total ban on code execution, compilation, builds, or test suite execution during this planning phase (NO-BUILD, NO-TEST, NO-CODE-CHANGES).`
   - Item 7: `7. Formulate multi-stage execution roadmap with binary acceptance criteria for every subtask.`
   followed by discrete architectural requirements from input as items 8..N.
6. Append mandatory planning skill invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${Input Text Verbatim} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${Input Text Verbatim}

## task: <task title>
## slug: <task-slug> (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Write comprehensive architectural specification under 02-spec/21-app/XX-<slug>/01-architecture-spec.md adhering strictly to 02-spec/01-spec-authoring-guide/.
3. Enqueue master plan task in .ai-memory/plans/pending/XX-<slug>.md and granular subtask checklists under .ai-memory/plans/subtasks/XX-<slug>/ (where XX is zero-padded sequence).
4. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String.
5. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
6. STRICTLY PLANNING ONLY: Total ban on code modification, compilation, local builds, or test suite execution during this planning phase (NO-BUILD, NO-TEST, NO-CODE-CHANGES).
7. Define binary acceptance criteria and verification requirements for every subtask before closing the planning turn.

## Must follow and spawn agent using

1. @[plan-spec-steps-v2](directory;.cursor/skills/plan-spec-steps-v2)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.cursor/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;.cursor/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- Keep all created specifications in `02-spec/21-app/XX-<slug>/` and plans in `.ai-memory/plans/pending/XX-<slug>.md` and `.ai-memory/plans/subtasks/XX-<slug>/` without starting immediate code execution.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
