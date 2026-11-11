# Execute with Release Mode — Letterly Prompt Formatter

Format input text according to exact execution with minor release template below without conversational filler or commentary.

1. Keep input text verbatim as is, only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`). TOTAL BAN on mutating, softening, summarizing, or altering input text in any way. Keep input 100% strictly intact, preserving all tone, urgency, emotion, technical flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `Implement Feature X with Minor Release`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: include fixed items 1-8 (pull first, spec/plan enqueue, GitMap search primacy, relative Git paths, task implementation per coding guidelines, pipeline verification via `gitmap pe -t`, minor release ceremony, and push commits/tags), followed by input directives as items 9..N.
6. Append mandatory agent invocation suffix.
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
2. Write spec under `02-spec/21-app/XX-<slug>/` and enqueue plan task in `.ai-memory/plans/pending/XX-<slug>.md` (subtasks in `.ai-memory/plans/subtasks/XX-<slug>/`) first (xx is folder sequence 01, 02).
3. Search codebase exclusively via GitMap (`gitmap aum search`, `gitmap find`, `gitmap cat`, `gitmap ps`, `gitmap py`, `gitmap llm train`); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String.
4. Strictly use relative Git paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
5. Execute core task implementation adhering strictly to coding guidelines.
6. Verify pipeline telemetry via `gitmap pe -t` until 100% green before cutting release.
7. Execute minor version bump release ceremony via `python 03-ai-scripts/37-bump-version.py -t minor -s "<summary>"` (or `gitmap cpr "vX.Y.Z - summary"`).
8. Push all release commits and tags upstream (`gitmap push --tags` / `git push --tags`).
9. ....other steps and more steps sequentially from the input direction.

## Must follow and spawn agent using (Non-Negotiable)

1. @[execute-parent-task-with-n-steps-v6](directory;.cursor/skills/execute-parent-task-with-n-steps-v6)
2. @[release](directory;.cursor/skills/release)
3. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.cursor/skills/fix-with-rca)
4. @[coding-guidelines](directory;.cursor/skills/coding-guidelines)

## Additional Instructions

- [/goal](slashCommand;goal) Follow exactly to the high instruction which is given and the checklist that has been given on top.
- [/learn](slashCommand;learn) from @[gitmap](directory;.cursor/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- All release ceremonies and version bump standards are offboarded to @[release](directory;.cursor/skills/release).
- All execution mechanics and task management are offboarded to @[execute-parent-task-with-n-steps-v6](directory;.cursor/skills/execute-parent-task-with-n-steps-v6).
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
