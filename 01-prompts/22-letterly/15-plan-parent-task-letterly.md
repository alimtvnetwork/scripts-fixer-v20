# Plan Parent Task (N-Steps Blueprint) — Letterly Prompt Formatter

Format input text according to exact planning-only template below without conversational filler or commentary.

1. Keep input text verbatim as is, only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`). TOTAL BAN on mutating, softening, summarizing, or altering input text in any way. Keep input 100% strictly intact, preserving all tone, urgency, emotion, technical flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `Architect Cache Eviction Engine`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders (`## task: <task title>`, `## slug: <task-slug>`).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: fixed items 1-10 (pull first, spec, master plan with 400 steps, ambiguity log, instruction generator, GitMap search, relative paths, NO-BUILD/NO-TEST, coding guidelines, acceptance criteria), then input directives as items 11..N.
6. Append mandatory planning skill invocation suffix under `## Must follow and spawn agent using (Non-Negotiable)`.
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
2. Write architectural spec under `02-spec/21-app/XX-<slug>/01-architecture-spec.md` adhering to `02-spec/01-spec-authoring-guide/` (XX is zero-padded sequence).
3. Enqueue master plan in `.ai-memory/plans/pending/XX-<slug>.md` and subtasks under `.ai-memory/plans/subtasks/XX-<slug>/` with exactly 400 granular self-looping steps (Phase 1: 1–200 Planning & Spec, Phase 2: 201–400 Subtasks & Acceptance Criteria).
4. Record any ambiguity to `.ai-memory/ambiguous-questions/01-new-ambiguity/XX-<slug>-ambiguity.md` and proceed autonomously without asking user.
5. At the end of planning, generate complete AI instructions using @[execute-ai-instruction-writer](directory;.agents/skills/execute-ai-instruction-writer).
6. Search codebase exclusively via GitMap (`gitmap aum search`, `gitmap find`, `gitmap cat`, `gitmap ps`, `gitmap py`); TOTAL BAN on rg, ripgrep, grep, Select-String.
7. Strictly use relative Git paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute filesystem paths.
8. STRICTLY PLANNING ONLY: Total ban on code modification, compilation, local builds, or test suite execution (NO-BUILD, NO-TEST, NO-CODE-CHANGES).
9. Enforce Coding Guidelines & Error Management invariants per @[coding-guidelines](directory;.agents/skills/coding-guidelines) and @[error-management](directory;.agents/skills/error-management).
10. Define binary acceptance criteria and verification requirements for every subtask before closing the turn.
11. ....other steps and more steps sequentially from the input direction. Create more steps in between.

## Must follow and spawn agent using (Non-Negotiable)

1. @[plan-spec-steps-v2](directory;.agents/skills/plan-spec-steps-v2)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.agents/skills/fix-with-rca)
3. @[coding-guidelines](directory;.agents/skills/coding-guidelines)
4. @[error-management](directory;.agents/skills/error-management)
5. @[execute-ai-instruction-writer](directory;.agents/skills/execute-ai-instruction-writer)

## Additional Instructions

- [/learn](slashCommand;learn) from @[gitmap](directory;.agents/skills/gitmap) skill for high-speed search and caching.
- [/plan](slashCommand;plan) first before doing work for improved execution without errors following Coding Guidelines.
- Formulate master plan in exactly 400 granular self-looping steps (Phase 1: 1–200, Phase 2: 201–400) detailing an actionable AI roadmap.
- At end of planning, generate complete AI instructions using @[execute-ai-instruction-writer](directory;.agents/skills/execute-ai-instruction-writer) so AI execution follows through accurately.
- Ambiguity Protocol: Record any ambiguity to `.ai-memory/ambiguous-questions/01-new-ambiguity/XX-<slug>-ambiguity.md`; proceed autonomously without asking user.
- All planning protocols, concurrency rules (A=2, H=2), and no-build/no-test constraints are offboarded to @[plan-spec-steps-v2](directory;.agents/skills/plan-spec-steps-v2).
- Keep created specifications in `02-spec/21-app/XX-<slug>/` and plans in `.ai-memory/plans/pending/XX-<slug>.md` without starting code execution.
- Track in-flight touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `tree` / `live` / `sync`).
- Strictly use relative Git paths; never add absolute filesystem paths.
