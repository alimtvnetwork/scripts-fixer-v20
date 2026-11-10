# Execute Parent Task (V7 Time-Restricted & Autonomous Engine) — Cursor Prompt Formatter

Format input text according to exact high-priority execution template below without conversational filler or commentary. Directs the AI agent to follow unified V7 master execution per @[execute-parent-task-with-n-steps-v7](directory;.cursor/skills/execute-parent-task-with-n-steps-v7) (Option 1: Time-Restricted; Option 2: Unrestricted) and bot integration.

1. Keep the verbatim as is, only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`) while strictly preserving everything as said parameters, flags, and file paths. TOTAL BAN on mutating, softening, summarizing, or making the input text "smart" or "better". All reprimands, emotional tone, anger, and urgency must be kept 100% intact.
2. Derive `<task title>` as task subject (e.g. `Time-Restricted Recommit and Bot Workflow`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; when authoring directories and plan files, format as XX-<task-slug> where XX is zero-padded sequence).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: include fixed items 1-9 (pull first, spec/plan enqueue with planning decoupled from execution under `02-spec/21-app/XX-<slug>/` and `.ai-memory/plans/pending/XX-<slug>.md`, GitMap search primacy, relative Git paths mandate, agent data entry, commit and push, task slug naming, V7 dual-option execution, and time-restricted recommits), followed by discrete technical directives from input as items 10..N.
6. Append mandatory agent invocation suffix pointing to directory-based V7 engine.
7. Output plain markdown only. Never wrap in fenced code blocks.
8. Relative Paths: Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute paths.

${Input Text Verbatim} = No change except for removal of filler words. Zero tone softening, zero omission of directives.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${Input Text Verbatim}

## task: <task title>
## slug: <task-slug> (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan task in .ai-memory/plans/pending/XX-<slug>.md (subtasks in .ai-memory/plans/subtasks/XX-<slug>/) first. (xx should be figured out by the folder structure and running AI tools, xx is sequence 01, 02)
3. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train; TOTAL BAN on rg, ripgrep, grep, git grep, Select-String; TOTAL BAN on ad-hoc Python/Node scripts like `python -c "..."`; use native GitMap commands for EOL normalization, DB querying, and JSONL reading).
4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative path, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
5. Use `gitmap` AI agents to enter data.
6. Task completion includes committing and pushing to Git (`gitmap push` / `gitmap cpf`).
7. Give every Task-NN in confirmed task breakdown a `Slug:` sub-item derived from root slug (`<root-slug> - Task NN`) so GitMap can create and verify subtasks under the root task.
8. Execute via V7 Master Engine per @[execute-parent-task-with-n-steps-v7](directory;.cursor/skills/execute-parent-task-with-n-steps-v7): Option 1 (Time-Restricted commits before 08:00 AM weekdays / anytime weekends via `--tz`, `--schedule`, `--auto-window`) or Option 2 (Unrestricted commits); configure bot identity via `gitmap autobot` when commanded.
9. Enforce time-restricted recommits per @[gitmap-time-restriction](directory;.cursor/skills/gitmap-time-restriction) using `gitmap` semantic commit verbs without polluting git history.
10. ....other steps and more steps sequentially from the input direction. Create more steps in between.

## Must follow and spawn agent using

1. @[execute-parent-task-with-n-steps-v7](directory;.cursor/skills/execute-parent-task-with-n-steps-v7)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.cursor/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;.cursor/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
