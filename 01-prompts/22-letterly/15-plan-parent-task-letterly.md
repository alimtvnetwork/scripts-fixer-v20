# Plan Parent Task (N-Steps Blueprint) — Letterly Prompt Formatter

Format input text according to exact planning-only template below without conversational filler or commentary.

1. Clean input text verbatim, stripping verbal fillers while strictly preserving architectural requirements, scope boundaries, and design constraints.
2. Derive `<task title>` as task subject (e.g. `Architect Cache Eviction Engine`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders (`## task: <task title>`, `## slug: <task-slug>`).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: include fixed items 1-8 (pull first via gitmap, architectural spec, master plan enqueue with 100-step roadmap and ambiguity logging, GitMap search primacy, relative Git paths, NO-BUILD/NO-TEST planning rules, coding guidelines, and acceptance criteria), followed by input directives as items 9..N.
6. Append mandatory planning skill invocation suffix with `## Must follow and spawn agent using (Non-Negotiable)`.
7. Output plain markdown only. Never wrap in fenced code blocks.
8. Relative Paths: Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute paths.

${Input Text Verbatim} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${Input Text Verbatim}

## task: <task title>
## slug: <task-slug> (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve merge conflicts so the repository is clean and current.
2. Write comprehensive architectural specification under `02-spec/21-app/XX-<slug>/01-architecture-spec.md` adhering strictly to `02-spec/01-spec-authoring-guide/`.
3. Enqueue master plan task in `.ai-memory/plans/pending/XX-<slug>.md` and subtasks under `.ai-memory/plans/subtasks/XX-<slug>/` with 100 granular self-looping steps. Record any ambiguity to `.ai-memory/ambiguous-questions/01-new-ambiguity/XX-<slug>-ambiguity.md` and proceed autonomously without asking user.
4. Search codebase exclusively via GitMap (`gitmap aum search`, `gitmap find`, `gitmap cat`, `gitmap ps`, `gitmap py`, `gitmap llm train`); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String.
5. Strictly use relative Git paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute filesystem paths.
6. STRICTLY PLANNING ONLY: Total ban on code modification, compilation, local builds, or test suite execution during this planning phase (NO-BUILD, NO-TEST, NO-CODE-CHANGES).
7. Enforce Coding Guidelines & Error Management invariants checklist per @[coding-guidelines](directory;.agents/skills/coding-guidelines) and @[error-management](directory;.agents/skills/error-management) (functions <= 15 lines, positive booleans `is*`/`has*` only, zero nested ifs, clean vertical spacing).
8. Define binary acceptance criteria and verification requirements for every subtask before closing the planning turn.
9. ....other steps and more steps sequentially from the input direction. Create more steps in between.

## Must follow and spawn agent using (Non-Negotiable)

1. @[plan-spec-steps-v2](directory;.agents/skills/plan-spec-steps-v2)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.agents/skills/fix-with-rca)
3. @[coding-guidelines](directory;.agents/skills/coding-guidelines)
4. @[error-management](directory;.agents/skills/error-management)

## Additional Instructions

- [/learn](slashCommand;learn) from @[gitmap](directory;.agents/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- [/plan](slashCommand;plan) first before doing work for improved work, faster execution for AI and coding without errors and following Coding Guidelines.
- All planning protocols, concurrency rules (A=2, H=2), spec modularization, and no-build/no-test constraints are offboarded to @[plan-spec-steps-v2](directory;.agents/skills/plan-spec-steps-v2).
- If any ambiguity arises, record it under `.ai-memory/ambiguous-questions/01-new-ambiguity/XX-<slug>-ambiguity.md` and immediately go ahead with planning without asking the user.
- Keep all created specifications in `02-spec/21-app/XX-<slug>/` and plans in `.ai-memory/plans/pending/XX-<slug>.md` without starting immediate code execution.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
