# Mobile CI/CD Fix Mode — Cursor Prompt Formatter

Combine output into exactly ONE continuous single-line paragraph with zero newlines and zero conversational filler.

1. Clean input text verbatim, stripping verbal fillers (`um`, `ah`, `uh`).
2. Derive `<task title>` as task subject (e.g. `CI/CD Pipeline Fix`). Derive `<task-slug>` as lowercase-hyphenated task title (e.g. `cicd-pipeline-fix`).
3. Extract discrete understandable tasks from input text as ordered list: `1. diagnose CI/CD via gitmap pe -t, 2. apply 4-part RCA fix, 3. verify locally, 4. atomic commit via gitmap cpr, 5. minor release`.
4. Prefix single line with slash commands: `[/goal](slashCommand;goal) [/learn](slashCommand;learn) from [gitmap](directory;.cursor/skills/gitmap) [/plan](slashCommand;plan) `.
5. Follow immediately with chained title header: `# <task title> - high priority instruction, non-negotiable task (task: <task title>, slug: <task-slug>): `.
6. Immediately follow colon with `${Input Text Verbatim}; `.
7. Follow with core actionable directives: `first try gitmap pull <repo-path> (fallback git pull) and resolve conflicts before starting; run gitmap pe -t to diagnose live CI/CD errors, fix all pipeline failures via 4-part RCA, track file touches and prevent write collisions using GitMap RC Heatmap (gitmap rc heatmap status / tree / live / sync); after learning and planning, immediately begin executing the plan without asking for confirmation; verify locally, commit atomically via gitmap cpr, and release minor update. `.
8. Append extracted task list: `discrete understandable tasks to execute: <extracted ordered tasks>`.
9. Conclude single line with: ` - strictly use relative git paths only; only add relative paths, never add absolute paths during work (this must be respected on release page and in release notes as well), must follow the skill 1. @[ci-cd-fix-gitmap-release](directory;.cursor/skills/ci-cd-fix-gitmap-release), 2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.cursor/skills/fix-with-rca)`.
10. Output exactly that single continuous paragraph with ZERO newlines and ZERO line breaks.

${Input Text Verbatim} = Cleaned input text without verbal filler words.

Output Format:
[/goal](slashCommand;goal) [/learn](slashCommand;learn) from [gitmap](directory;.cursor/skills/gitmap) [/plan](slashCommand;plan) # <task title> - high priority instruction, non-negotiable task (task: <task title>, slug: <task-slug>): ${Input Text Verbatim}; first try gitmap pull <repo-path> (fallback git pull) and resolve conflicts before starting; run gitmap pe -t to diagnose live CI/CD errors, fix all pipeline failures via 4-part RCA, track file touches and prevent write collisions using GitMap RC Heatmap (gitmap rc heatmap status / tree / live / sync); after learning and planning, immediately begin executing the plan without asking for confirmation; verify locally, commit atomically via gitmap cpr, and release minor update. discrete understandable tasks to execute: 1. diagnose CI/CD via gitmap pe -t, 2. apply 4-part RCA fix, 3. verify locally, 4. atomic commit via gitmap cpr, 5. minor release - strictly use relative git paths only; only add relative paths, never add absolute paths during work (this must be respected on release page and in release notes as well), must follow the skill 1. @[ci-cd-fix-gitmap-release](directory;.cursor/skills/ci-cd-fix-gitmap-release), 2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.cursor/skills/fix-with-rca)
