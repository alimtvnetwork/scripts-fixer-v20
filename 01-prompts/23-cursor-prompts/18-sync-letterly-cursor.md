# Sync Mode (GitMap Fleet Synchronizer) — Letterly Prompt Formatter

Format input text according to exact multi-repository fleet synchronization template below without conversational filler or commentary.

1. Keep input text verbatim as is, only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`). TOTAL BAN on mutating, softening, summarizing, or altering input text in any way. Keep input 100% strictly intact, preserving all tone, urgency, emotion, technical flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `Synchronize Canonical Prompts, Skills and Guidelines across Fleet`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: include fixed items 1-8 (pull first via `gitmap pa`, fleet status inspection via `gitmap cg status --all`, native 3-way sync via `gitmap cg sync --all --yes` with TOTAL BAN on Python sync scripts, conflict management via `gitmap cg conflicts` and `gitmap cg resolve`, maintaining compact `version.json` and dedicated `coding-guideline.json`, atomic commits via `gitmap cpc`, upstream pushing, and relative Git paths mandate), followed by discrete sync directives from input as items 9..N.
6. Append mandatory sync skill invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.
8. Relative Paths: Only add relative paths (`01-prompts/...`, `.cursor/skills/...`, `coding-guideline.json`); never add absolute paths.

${Input Text Verbatim} = Input text verbatim as is without filler words. Strict zero-mutation policy: never alter, soften, summarize, or rewrite input text in any way; preserve all directives, parameters, and tone 100% intact.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${Input Text Verbatim}

## task: <task title>
## slug: <task-slug>

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work across all fleet targets — run `gitmap pa` (or `gitmap pull <target>`) and ensure clean working trees before proceeding.
2. Inspect coding guidelines installation status and versions across discovered repositories via `gitmap cg status --all`.
3. Execute native 3-way synchronization across all fleet repositories via `gitmap cg sync --all --yes` (or domain-specific `gitmap cg prompt sync --all --yes`, `gitmap cg skill sync --all --yes`); TOTAL BAN on executing ad-hoc Python sync scripts.
4. If sync conflicts arise, inspect them via `gitmap cg conflicts` and execute resolution via `gitmap cg resolve --strategy merged` (or `gitmap cg resolve --auto-clean`).
5. Ensure `coding-guideline.json` is updated with current coding guidelines version and sync telemetry, while keeping `version.json` simple, lightweight, and compact (< 2 KB).
6. Atomically stage and commit changes in each updated repository via GitMap semantic commit verbs: `gitmap cpc "sync - <summary>"`.
7. Push all synchronized commits and tags upstream via `gitmap push` (or `gitmap push --tags`).
8. Strictly use relative Git paths (01-prompts/..., .cursor/skills/..., coding-guideline.json); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
9. ....other sync steps sequentially from the input direction.

## Must follow and spawn agent using (Non-Negotiable)

1. @[gitmap-fleet-sync](directory;.cursor/skills/gitmap-fleet-sync)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.cursor/skills/fix-with-rca)
3. @[coding-guidelines](directory;.cursor/skills/coding-guidelines)
4. @[gitmap](directory;.cursor/skills/gitmap)

## Additional Instructions

- [/goal](slashCommand;goal) Follow exactly to the high instruction which is given and the checklist that has been given on top.
- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;.cursor/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- All multi-repository 3-way synchronization, Merkle hash calculations, conflict resolutions, and fleet operations are offboarded to @[gitmap-fleet-sync](directory;.cursor/skills/gitmap-fleet-sync).
- After learning and planning, immediately begin executing the synchronization without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
