# CI/CD Fix & Release Mode — Letterly Prompt Formatter

Format input text according to exact CI/CD fix and minor release template below without conversational filler or commentary.

1. Clean input text verbatim, capturing failing workflow names, errors, and reproduction steps.
2. Derive `<task title>` as task subject (e.g. `CI/CD Pipeline Fix and Minor Release`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${Input Text Verbatim}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — first try \`gitmap pull <repo path>\` (or run \`gitmap pull\` in repository folder); if that fails, fall back to regular \`git pull\` and resolve merge conflicts.`
   - Item 2: `2. Query live CI/CD pipeline telemetry via \`gitmap pe -t\` to extract exact step failures and bounded stack traces.`
   - Item 3: `3. Formulate 4-part Root Cause Analysis (Symptom, Trigger, Root Cause, Mitigation) and apply surgical fixes.`
   - Item 4: `4. Verify fix locally using local pipeline runner (e.g. \`python 03-ai-scripts/06-cicd-local-runner.py\`).`
   - Item 5: `5. Execute minor version bump release ceremony via \`python 03-ai-scripts/37-bump-version.py -t minor -s "<summary>"\`.`
   - Item 6: `6. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.`
   followed by discrete directives from input as items 7..N.
6. Append mandatory CI/CD fix and release skill invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${Input Text Verbatim} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${Input Text Verbatim}

## task: <task title>
## slug: <task-slug>

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Query live CI/CD pipeline telemetry via `gitmap pe -t` to extract exact step failures and bounded stack traces.
3. Formulate 4-part Root Cause Analysis (Symptom, Trigger, Root Cause, Mitigation) and apply surgical fixes.
4. Verify fix locally using local pipeline runner script (e.g. `python 03-ai-scripts/06-cicd-local-runner.py`).
5. Execute minor version bump release ceremony via `python 03-ai-scripts/37-bump-version.py -t minor -s "<summary>"` upon green pipeline.
6. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
7. Push all commits and release tags upstream (`gitmap push --tags` / `git push --tags`).

## Must follow and spawn agent using

1. @[ci-cd-fix-gitmap-release](directory;.agents/skills/ci-cd-fix-gitmap-release)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.agents/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;.agents/skills/gitmap) skill to leverage GitMap live telemetry, pipeline self-healing, and toolchain caching.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
