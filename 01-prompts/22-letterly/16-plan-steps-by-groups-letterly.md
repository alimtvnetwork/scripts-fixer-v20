# Plan Steps by Groups (Modular Layer Blueprint) — Letterly Prompt Formatter

Format input text according to exact grouped planning template below without conversational filler or commentary.

1. Keep input text verbatim as is, only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`). TOTAL BAN on mutating, softening, summarizing, or altering input text in any way. Keep input 100% strictly intact, preserving all tone, urgency, emotion, technical flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `Grouped Architecture Plan for Service Mesh`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; formatted as XX-<task-slug> for directories and plan files).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: include fixed items 1-7 (pull first, grouped architectural spec, master plan and grouped subtask checklists, GitMap search primacy, relative Git paths, NO-BUILD/NO-TEST planning rules, and interface contracts with binary acceptance criteria), followed by discrete architectural directives from input as items 8..N.
6. Append mandatory grouped planning skill invocation suffix.
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
2. Write grouped architectural specification under `02-spec/21-app/XX-<slug>/` decomposing the project into discrete, cohesive architectural layers.
3. Enqueue master plan in `.ai-memory/plans/pending/XX-<slug>.md` and grouped subtask checklists under `.ai-memory/plans/subtasks/XX-<slug>/` (e.g. `01-group-data.md`, `02-group-core.md`, `03-group-wiring.md`) totaling exactly 400 granular self-looping steps (Phase 1: 1–200, Phase 2: 201–400).
4. Search codebase exclusively via GitMap (`gitmap aum search`, `gitmap find`, `gitmap cat`, `gitmap ps`, `gitmap py`, `gitmap llm train`); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String.
5. Strictly use relative Git paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
6. STRICTLY PLANNING ONLY: Total ban on code modification, compilation, local builds, or test suite execution during this planning phase (NO-BUILD, NO-TEST, NO-CODE-CHANGES).
7. Define explicit interface contracts and binary acceptance criteria between layer groups.
8. ....other steps and more steps sequentially from the input direction.

## Must follow and spawn agent using (Non-Negotiable)

1. @[plan-steps-by-groups](directory;.agents/skills/plan-steps-by-groups)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.agents/skills/fix-with-rca)
3. @[coding-guidelines](directory;.agents/skills/coding-guidelines)
4. @[error-management](directory;.agents/skills/error-management)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- Formulate grouped master plan in exactly 400 granular self-looping steps (Phase 1: 1–200, Phase 2: 201–400) detailing an actionable AI roadmap.
- [/learn](slashCommand;learn) from @[gitmap](directory;.agents/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- All modular group planning protocols and layer decomposition rules are offboarded to @[plan-steps-by-groups](directory;.agents/skills/plan-steps-by-groups).
- Keep all created specifications in `02-spec/21-app/XX-<slug>/` and plans in `.ai-memory/plans/pending/XX-<slug>.md` and `.ai-memory/plans/subtasks/XX-<slug>/` without starting immediate code execution.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
