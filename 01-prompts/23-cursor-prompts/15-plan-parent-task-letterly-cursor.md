# Plan Parent Task (N-Steps Blueprint) — Cursor Prompt Formatter

Format input text according to exact planning-only template below without conversational filler or commentary.

1. Keep input text verbatim as is, only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`). TOTAL BAN on mutating, softening, summarizing, or altering input text in any way. Keep input 100% strictly intact, preserving all tone, urgency, emotion, technical flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `Architect Cache Eviction Engine`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; when authoring directories and plan files, format as XX-<task-slug> where XX is zero-padded sequence).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — try \`gitmap pull <repo path>\` first (or \`gitmap pull\`); fallback to \`git pull\` and resolve merge conflicts so repository is clean and current.`
   - Item 2: `2. Write architectural spec under 02-spec/21-app/XX-<slug>/01-architecture-spec.md adhering to 02-spec/01-spec-authoring-guide/ (XX is zero-padded sequence).`
   - Item 3: `3. Enqueue master plan in .ai-memory/plans/pending/XX-<slug>.md and subtasks under .ai-memory/plans/subtasks/XX-<slug>/ with exactly 400 granular self-looping steps (Phase 1: 1–200 Planning & Spec, Phase 2: 201–400 Subtasks & Acceptance Criteria).`
   - Item 4: `4. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py); TOTAL BAN on rg, ripgrep, grep, Select-String.`
   - Item 5: `5. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute filesystem paths.`
   - Item 6: `6. STRICTLY PLANNING ONLY: Total ban on code modification, compilation, local builds, or test suite execution (NO-BUILD, NO-TEST, NO-CODE-CHANGES).`
   - Item 7: `7. Formulate multi-stage execution roadmap with binary acceptance criteria for every subtask.`
   followed by discrete architectural requirements from input as items 8..N.
6. Append mandatory planning skill invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${Input Text Verbatim} = Input text verbatim as is without filler words. Strict zero-mutation policy: never alter, soften, summarize, or rewrite input text in any way; preserve all directives, parameters, and tone 100% intact.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${Input Text Verbatim}

## task: <task title>
## slug: <task-slug>

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — try `gitmap pull <repo path>` first (or `gitmap pull`); fallback to `git pull` and resolve merge conflicts so repository is clean and current.
2. Write architectural spec under 02-spec/21-app/XX-<slug>/01-architecture-spec.md adhering to 02-spec/01-spec-authoring-guide/ (XX is zero-padded sequence).
3. Enqueue master plan in .ai-memory/plans/pending/XX-<slug>.md and subtasks under .ai-memory/plans/subtasks/XX-<slug>/ with exactly 400 granular self-looping steps (Phase 1: 1–200 Planning & Spec, Phase 2: 201–400 Subtasks & Acceptance Criteria).
4. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py); TOTAL BAN on rg, ripgrep, grep, Select-String.
5. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute filesystem paths.
6. STRICTLY PLANNING ONLY: Total ban on code modification, compilation, local builds, or test suite execution during this planning phase (NO-BUILD, NO-TEST, NO-CODE-CHANGES).
7. Define binary acceptance criteria and verification requirements for every subtask before closing the planning turn.

## Must follow and spawn agent using

1. @[plan-spec-steps-v2](directory;.cursor/skills/plan-spec-steps-v2)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.cursor/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;.cursor/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- Formulate master plan in exactly 400 granular self-looping steps (Phase 1: 1–200, Phase 2: 201–400) detailing an actionable AI roadmap.
- Keep all created specifications in `02-spec/21-app/XX-<slug>/` and plans in `.ai-memory/plans/pending/XX-<slug>.md` and `.ai-memory/plans/subtasks/XX-<slug>/` without starting immediate code execution.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `tree` / `live` / `sync`).
- Strictly use relative Git paths; never add absolute filesystem paths.
