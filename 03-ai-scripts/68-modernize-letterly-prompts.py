#!/usr/bin/env python3
"""Modernizes Letterly and Cursor prompt formatters.

Enforces:
1. Directory-based skill references: `(directory;.agents/skills/...)` and `(directory;.cursor/skills/...)`.
2. Dual-item agent spawning section:
   1. Primary skill
   2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;...)
3. In Additional Instructions:
   - "After learning and planning, immediately begin executing the plan without asking for confirmation."
4. Standardizes V7 as prompt 14: `14-execute-parent-task-v7-letterly.md` (and removes duplicates).
5. Creates 3 new plan-only prompts (15, 16, 17) in both suites.
6. Synchronizes readme index tables.
"""

from __future__ import annotations

import os
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
LETTERLY_DIR = os.path.join(REPO_ROOT, "01-prompts", "22-letterly")
CURSOR_DIR = os.path.join(REPO_ROOT, "01-prompts", "23-cursor-prompts")


def update_letterly_01_mobile(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"01-mobile-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Mobile Mode{title_suffix}

Format input text according to exact mobile single-line template below without conversational filler or commentary.

1. Clean input text verbatim, stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`) while strictly preserving technical details, file paths, commands, and requirements.
2. Derive `<task title>` as task subject (e.g. `SEO Writing and Folder Structure Instructions`). Derive `<task-slug>` as lowercase-hyphenated task title (e.g. `seo-writing-and-folder-structure-instructions`).
3. Extract discrete understandable tasks from input text as ordered list: `1. [task-1], 2. [task-2], 3. [task-3]`.
4. Prefix single line with slash commands: `[/goal](slashCommand;goal) [/learn](slashCommand;learn) from [gitmap](directory;{prefix}/skills/gitmap) [/plan](slashCommand;plan) `.
5. Follow immediately with chained title header: `# <task title> - high priority instruction, non-negotiable task (task: <task title>, slug: <task-slug>): `.
6. Immediately follow colon with `${{Input Text Verbatim}}; `.
7. Follow with core actionable directives: `do gitmap pull <repo path> (fallback git pull) and resolve conflicts before starting; write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan in .ai-memory/plans/pending/XX-<slug>.md (subtasks in .ai-memory/plans/subtasks/XX-<slug>/) first (xx is sequence 01, 02); planning is strictly dedicated to architecture and decoupled from execution (no-build, no-test, no-code-changes); search codebase exclusively via GitMap; track file touches and prevent write collisions using GitMap RC Heatmap (gitmap rc heatmap status / tree / live / sync); strictly use relative git paths only; after learning and planning, immediately begin executing the plan without asking for confirmation; `.
8. Append extracted task list: `discrete understandable tasks to execute: <extracted ordered tasks>`.
9. Conclude single line with: ` - strictly use relative git paths only; only add relative paths, never add absolute paths during work (this must be respected on release page and in release notes as well); must follow the skill 1. @[execute-parent-task-with-n-steps-v6](directory;{prefix}/skills/execute-parent-task-with-n-steps-v6), 2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)`.
10. Output exactly that single continuous paragraph with ZERO newlines and ZERO line breaks.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:
[/goal](slashCommand;goal) [/learn](slashCommand;learn) from [gitmap](directory;{prefix}/skills/gitmap) [/plan](slashCommand;plan) # <task title> - high priority instruction, non-negotiable task (task: <task title>, slug: <task-slug>): ${{Input Text Verbatim}}; do gitmap pull <repo path> (fallback git pull) and resolve conflicts before starting; write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan in .ai-memory/plans/pending/XX-<slug>.md (subtasks in .ai-memory/plans/subtasks/XX-<slug>/) first (xx is sequence 01, 02); planning is strictly dedicated to architecture and decoupled from execution (no-build, no-test, no-code-changes); search codebase exclusively via GitMap; track file touches and prevent write collisions using GitMap RC Heatmap (gitmap rc heatmap status / tree / live / sync); strictly use relative git paths only; after learning and planning, immediately begin executing the plan without asking for confirmation; discrete understandable tasks to execute: 1. [task-1], 2. [task-2], 3. [task-3] - strictly use relative git paths only; only add relative paths, never add absolute paths during work (this must be respected on release page and in release notes as well); must follow the skill 1. @[execute-parent-task-with-n-steps-v6](directory;{prefix}/skills/execute-parent-task-with-n-steps-v6), 2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_letterly_02_desktop(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"02-desktop-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Desktop Mode{title_suffix}

Format input text according to exact output template below without conversational filler or commentary.

1. Clean input text verbatim, removing verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`) while strictly preserving technical details, requirements, file paths, commands, and directives.
2. Derive `<task title>` as task subject (e.g. `SEO Writing and Folder Structure Instructions`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; when authoring directories and plan files, format as XX-<task-slug> where XX is the zero-padded sequence of that folder, e.g. `## slug: 24-seo-writing-and-folder-structure-instructions`).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: include fixed items 1-7 (pull first, spec/plan enqueue in `02-spec/21-app/XX-<slug>/` and `.ai-memory/plans/pending/XX-<slug>.md` with planning decoupled from execution, GitMap search primacy, relative Git paths mandate, gitmap AI agent data entry, commit and push completion, and task slug naming), followed by discrete technical action items extracted from input text as items 8..N.
6. End with mandatory agent invocation suffix pointing to directory-based skill references.
7. Output plain markdown text only. Never wrap in fenced code blocks (no ```markdown or ``` fences).
8. Relative Paths: Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute paths.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

## task: <task title>
## slug: <task-slug>  (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan task in .ai-memory/plans/pending/XX-<slug>.md (subtasks in .ai-memory/plans/subtasks/XX-<slug>/) first, (xx should be figured out by the folder structure and running AI tools, xx is sequence 01, 02)
3. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String
4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well
5. Use `gitmap` AI agents to enter data
6. Task completion includes committing and pushing to Git
7. Give every Task-NN in the confirmed task breakdown a `Slug:` sub-item derived from the root slug (`<root-slug> - Task NN`, e.g. `Slug: SEO Writing and Folder Structure Instructions - Task 01`) so GitMap can create and verify subtasks under the root task
8. [extracted actionable technical directive from input]

## Must follow and spawn agent using

1. @[execute-parent-task-with-n-steps-v6](directory;{prefix}/skills/execute-parent-task-with-n-steps-v6)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_letterly_03_execute(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"03-execute-n-steps-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Execute N-Steps{title_suffix}

Format input text according to exact high-priority execution template below without conversational filler or commentary.

1. Keep the verbatim as is only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`) while strictly preserving everything as said parameters, flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `SEO Writing and Folder Structure Instructions`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; when authoring directories and plan files, format as XX-<task-slug> where XX is the zero-padded sequence of that folder, e.g. `## slug: 24-seo-writing-and-folder-structure-instructions`).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: include fixed items 1-5 (pull first, spec/plan enqueue in `02-spec/21-app/XX-<slug>/` and `.ai-memory/plans/pending/XX-<slug>.md` with planning decoupled from execution steps, GitMap search primacy, relative Git paths mandate, SQL repository pattern and enum-driven actions per @[sql-repository-pattern-and-enum-actions](directory;{prefix}/skills/sql-repository-pattern-and-enum-actions)), followed by discrete technical directives extracted from input text as items 6..N.
6. Append mandatory agent invocation suffix pointing to directory-based skill references.
7. Output plain markdown only. Never wrap in fenced code blocks (no ```markdown or ``` fences).
8. Relative Paths: Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute paths.

${{Input Text Verbatim}} = No change except for removal of filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

## task: <task title>
## slug: <task-slug> (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan task in .ai-memory/plans/pending/XX-<slug>.md (subtasks in .ai-memory/plans/subtasks/XX-<slug>/) first, (xx should be figured out by the folder structure and running AI tools, xx is sequence 01, 02)
3. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String
4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well
5. Enforce SQL repository pattern and enum-driven actions per @[sql-repository-pattern-and-enum-actions](directory;{prefix}/skills/sql-repository-pattern-and-enum-actions): all SQL isolated behind repository interfaces, operations dispatched by exhaustive enum switch with complete util methods (String, Parse, IsValid, All), and strongly-typed AppError envelopes.
6. ....other steps and more steps sequentially from the input direction. Create more steps in between.

## Must follow and spawn agent using

1. @[execute-parent-task-with-n-steps-v6](directory;{prefix}/skills/execute-parent-task-with-n-steps-v6)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_letterly_04_plan(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"04-plan-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Plan Mode{title_suffix}

Format input text according to exact planning template below without conversational filler or commentary.

1. Clean input text verbatim, stripping verbal fillers while strictly preserving architectural requirements, scope boundaries, and design constraints.
2. Derive `<task title>` as task subject (e.g. `SEO Writing and Folder Structure Instructions`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; when authoring directories and plan files, format as XX-<task-slug> where XX is the zero-padded sequence of that folder, e.g. `## slug: 24-seo-writing-and-folder-structure-instructions`).
5. Under `# Actionable Items Must Follow Non-Negotiable`, ensure:
   - Item 1: `1. Git pull BEFORE starting any work — first try \\`gitmap pull <repo path>\\` (or run \\`gitmap pull\\` in repository folder); if that fails, fall back to regular \\`git pull\\` and resolve any merge conflicts so the repository is completely up to date and clean before starting.`
   - Item 2: `2. Write plan and architectural spec first under 02-spec/21-app/XX-<slug>/ adhering to 02-spec/01-spec-authoring-guide/ (where XX is zero-padded folder sequence)`
   - Item 3: `3. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String`
   - Item 4: `4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well`
   - Item 5: `5. Write first step on task decomposition and bounded subtasks under .ai-memory/plans/subtasks/XX-<slug>/`
   - Item 6: `6. Enforce strict no-build and no-test rules throughout planning phase`
   followed by discrete architectural requirements from input as items 7..N.
6. Append mandatory planning skill invocation suffix.
7. Output plain markdown text only. Never wrap in fenced code blocks (no ```markdown or ``` fences).
8. Relative Paths: Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute paths.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

## task: <task title>
## slug: <task-slug> (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan task in .ai-memory/plans/pending/XX-<slug>.md (subtasks in .ai-memory/plans/subtasks/XX-<slug>/) first, (xx should be figured out by the folder structure and running AI tools, xx is sequence 01, 02)
3. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String
4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well
5. Write the first step on task decomposition and bounded subtasks under .ai-memory/plans/subtasks/XX-<slug>/
6. Enforce strict no-build and no-test rules throughout the planning phase
7. Define binary acceptance criteria for every subtask

## Must follow and spawn agent using

1. @[plan-spec-steps-v2](directory;{prefix}/skills/plan-spec-steps-v2)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- Keep all created specifications in `02-spec/21-app/XX-<slug>/` and plans in `.ai-memory/plans/pending/XX-<slug>.md` without starting immediate code execution.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_letterly_05_release(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"05-release-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Release Mode{title_suffix}

Format input text according to exact minor release template below without conversational filler or commentary.

1. Clean input text verbatim, stripping verbal fillers while strictly preserving version scope, changelog notes, and release constraints.
2. Derive `<task title>` as task subject (e.g. `Release v6.500.0 - Enhanced Telemetry`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — first try \\`gitmap pull <repo path>\\` (or run \\`gitmap pull\\` in repository folder); if that fails, fall back to regular \\`git pull\\` and resolve merge conflicts.`
   - Item 2: `2. Verify pipeline telemetry via \\`gitmap pe -t\\` or local CI runner until 100% green before cutting release.`
   - Item 3: `3. Execute minor version bump release ceremony via \\`python 03-ai-scripts/37-bump-version.py -t minor -s "<summary>"\\` (or \\`gitmap cpr "vX.Y.Z - summary"\\`).`
   - Item 4: `4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.`
   - Item 5: `5. Synchronize package.json, Cargo.toml, or version constants across all subprojects.`
   followed by discrete release directives from input as items 6..N.
6. Append mandatory release skill invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

## task: <task title>
## slug: <task-slug>

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Verify pipeline telemetry via `gitmap pe -t` or local runner until 100% green before cutting release.
3. Execute minor version bump release ceremony via `python 03-ai-scripts/37-bump-version.py -t minor -s "<summary>"` (or `gitmap cpr "vX.Y.Z - summary"`).
4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
5. Synchronize package.json, Cargo.toml, or version constants across all connected subprojects.
6. Push all release commits and tags upstream (`gitmap push --tags` / `git push --tags`).

## Must follow and spawn agent using

1. @[minor-bump](directory;{prefix}/skills/minor-bump)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_letterly_06_cicd(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"06-cicd-fix-release-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# CI/CD Fix & Release Mode{title_suffix}

Format input text according to exact CI/CD fix and minor release template below without conversational filler or commentary.

1. Clean input text verbatim, capturing failing workflow names, errors, and reproduction steps.
2. Derive `<task title>` as task subject (e.g. `CI/CD Pipeline Fix and Minor Release`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — first try \\`gitmap pull <repo path>\\` (or run \\`gitmap pull\\` in repository folder); if that fails, fall back to regular \\`git pull\\` and resolve merge conflicts.`
   - Item 2: `2. Query live CI/CD pipeline telemetry via \\`gitmap pe -t\\` to extract exact step failures and bounded stack traces.`
   - Item 3: `3. Formulate 4-part Root Cause Analysis (Symptom, Trigger, Root Cause, Mitigation) and apply surgical fixes.`
   - Item 4: `4. Verify fix locally using local pipeline runner (e.g. \\`python 03-ai-scripts/06-cicd-local-runner.py\\`).`
   - Item 5: `5. Execute minor version bump release ceremony via \\`python 03-ai-scripts/37-bump-version.py -t minor -s "<summary>"\\`.`
   - Item 6: `6. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.`
   followed by discrete directives from input as items 7..N.
6. Append mandatory CI/CD fix and release skill invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

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

1. @[ci-cd-fix-gitmap-release](directory;{prefix}/skills/ci-cd-fix-gitmap-release)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap live telemetry, pipeline self-healing, and toolchain caching.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_letterly_07_mobile_cicd(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"07-mobile-cicd-fix-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Mobile CI/CD Fix Mode{title_suffix}

Combine output into exactly ONE continuous single-line paragraph with zero newlines and zero conversational filler.

1. Clean input text verbatim, stripping verbal fillers (`um`, `ah`, `uh`).
2. Derive `<task title>` as task subject (e.g. `CI/CD Pipeline Fix`). Derive `<task-slug>` as lowercase-hyphenated task title (e.g. `cicd-pipeline-fix`).
3. Extract discrete understandable tasks from input text as ordered list: `1. diagnose CI/CD via gitmap pe -t, 2. apply 4-part RCA fix, 3. verify locally, 4. atomic commit via gitmap cpr, 5. minor release`.
4. Prefix single line with slash commands: `[/goal](slashCommand;goal) [/learn](slashCommand;learn) from [gitmap](directory;{prefix}/skills/gitmap) [/plan](slashCommand;plan) `.
5. Follow immediately with chained title header: `# <task title> - high priority instruction, non-negotiable task (task: <task title>, slug: <task-slug>): `.
6. Immediately follow colon with `${{Input Text Verbatim}}; `.
7. Follow with core actionable directives: `first try gitmap pull <repo-path> (fallback git pull) and resolve conflicts before starting; run gitmap pe -t to diagnose live CI/CD errors, fix all pipeline failures via 4-part RCA, track file touches and prevent write collisions using GitMap RC Heatmap (gitmap rc heatmap status / tree / live / sync); after learning and planning, immediately begin executing the plan without asking for confirmation; verify locally, commit atomically via gitmap cpr, and release minor update. `.
8. Append extracted task list: `discrete understandable tasks to execute: <extracted ordered tasks>`.
9. Conclude single line with: ` - strictly use relative git paths only; only add relative paths, never add absolute paths during work (this must be respected on release page and in release notes as well), must follow the skill 1. @[ci-cd-fix-gitmap-release](directory;{prefix}/skills/ci-cd-fix-gitmap-release), 2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)`.
10. Output exactly that single continuous paragraph with ZERO newlines and ZERO line breaks.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:
[/goal](slashCommand;goal) [/learn](slashCommand;learn) from [gitmap](directory;{prefix}/skills/gitmap) [/plan](slashCommand;plan) # <task title> - high priority instruction, non-negotiable task (task: <task title>, slug: <task-slug>): ${{Input Text Verbatim}}; first try gitmap pull <repo-path> (fallback git pull) and resolve conflicts before starting; run gitmap pe -t to diagnose live CI/CD errors, fix all pipeline failures via 4-part RCA, track file touches and prevent write collisions using GitMap RC Heatmap (gitmap rc heatmap status / tree / live / sync); after learning and planning, immediately begin executing the plan without asking for confirmation; verify locally, commit atomically via gitmap cpr, and release minor update. discrete understandable tasks to execute: 1. diagnose CI/CD via gitmap pe -t, 2. apply 4-part RCA fix, 3. verify locally, 4. atomic commit via gitmap cpr, 5. minor release - strictly use relative git paths only; only add relative paths, never add absolute paths during work (this must be respected on release page and in release notes as well), must follow the skill 1. @[ci-cd-fix-gitmap-release](directory;{prefix}/skills/ci-cd-fix-gitmap-release), 2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_letterly_08_run(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"08-run-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Run Mode{title_suffix}

Format input text according to exact project run template below without conversational filler or commentary.

1. Clean input text verbatim, strictly preserving target service names, ports, run flags, and environment parameters.
2. Derive `<task title>` as task subject (e.g. `Run Application Services`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — first try \\`gitmap pull <repo path>\\` (or run \\`gitmap pull\\` in repository folder); if that fails, fall back to regular \\`git pull\\` and resolve merge conflicts.`
   - Item 2: `2. Execute project runner via \\`./run.ps1\\` or \\`./run.sh\\` according to repository run configuration.`
   - Item 3: `3. If run fails due to missing dependencies, trigger local automated installer (\\`./local-install.ps1\\` or \\`./local-install.sh\\`) and auto-rerun upon completion.`
   - Item 4: `4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.`
   followed by discrete directives from input as items 5..N.
6. Append mandatory run skill invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

## task: <task title>
## slug: <task-slug>

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Execute project runner via `./run.ps1` or `./run.sh` according to repository run configuration.
3. If run fails due to missing dependencies, trigger local installer (`./local-install.ps1` or `./local-install.sh`) and auto-rerun runner upon successful installation.
4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
5. Verify services are live, healthy, and reporting HTTP 200 / listening on configured ports.

## Must follow and spawn agent using

1. @[run](directory;{prefix}/skills/run)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_letterly_09_verification(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"09-execute-with-verification-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Execute with Verification Mode{title_suffix}

Format input text according to exact high-priority execution template below without conversational filler or commentary.

1. Capture input text verbatim, stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`) while preserving technical directives, parameters, flags, and paths.
2. Derive `<task title>` as task subject (e.g. `Implement Feature X with Retrospective AI Verification`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; when authoring directories and plan files, format as XX-<task-slug> where XX is zero-padded sequence).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — first try \\`gitmap pull <repo path>\\` (or run \\`gitmap pull\\` in repository folder); if that fails, fall back to regular \\`git pull\\` and resolve merge conflicts.`
   - Item 2: `2. Write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan in .ai-memory/plans/pending/XX-<slug>.md (subtasks in .ai-memory/plans/subtasks/XX-<slug>/) first.`
   - Item 3: `3. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py); TOTAL BAN on rg, ripgrep, grep, Select-String.`
   - Item 4: `4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.`
   - Item 5: `5. Execute core task implementation in bounded micro-batches.`
   - Item 6: `6. At task completion, conduct comprehensive Retrospective AI Verification per @[ai-verification](directory;{prefix}/skills/ai-verification) checking acceptance criteria, coding guidelines, relative paths, and CI/CD status.`
   followed by discrete directives from input as items 7..N.
6. Append mandatory agent invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

## task: <task title>
## slug: <task-slug> (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan task in .ai-memory/plans/pending/XX-<slug>.md (subtasks in .ai-memory/plans/subtasks/XX-<slug>/) first, (xx should be figured out by the folder structure and running AI tools, xx is sequence 01, 02)
3. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String
4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well
5. Execute core task implementation in bounded 5–8 file micro-batches.
6. Conduct comprehensive Retrospective AI Verification per @[ai-verification](directory;{prefix}/skills/ai-verification) before declaring completion, validating acceptance criteria, coding standards, relative paths, and CI status.
7. Commit and push all changes upstream (`gitmap cpf` / `gitmap push`).

## Must follow and spawn agent using

1. @[execute-parent-task-with-n-steps-v6](directory;{prefix}/skills/execute-parent-task-with-n-steps-v6)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_letterly_10_release(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"10-execute-with-release-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Execute with Release Mode{title_suffix}

Format input text according to exact execution with minor release template below without conversational filler or commentary.

1. Capture input text verbatim, stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`) while preserving technical directives, parameters, flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `Implement Feature X with Minor Release`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — first try \\`gitmap pull <repo path>\\` (or run \\`gitmap pull\\` in repository folder); if that fails, fall back to regular \\`git pull\\` and resolve merge conflicts.`
   - Item 2: `2. Write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan in .ai-memory/plans/pending/XX-<slug>.md (subtasks in .ai-memory/plans/subtasks/XX-<slug>/) first.`
   - Item 3: `3. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py); TOTAL BAN on rg, ripgrep, grep, Select-String.`
   - Item 4: `4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.`
   - Item 5: `5. Execute core task implementation adhering strictly to coding guidelines.`
   - Item 6: `6. Verify pipeline telemetry via \\`gitmap pe -t\\` until 100% green.`
   - Item 7: `7. Execute minor version bump release ceremony via \\`python 03-ai-scripts/37-bump-version.py -t minor -s "<summary>"\\` (or \\`gitmap cpr "vX.Y.Z - summary"\\`).`
   followed by discrete directives from input as items 8..N.
6. Append mandatory agent invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

## task: <task title>
## slug: <task-slug> (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan task in .ai-memory/plans/pending/XX-<slug>.md (subtasks in .ai-memory/plans/subtasks/XX-<slug>/) first, (xx should be figured out by the folder structure and running AI tools, xx is sequence 01, 02)
3. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String
4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well
5. Execute core task implementation adhering strictly to coding guidelines.
6. Verify pipeline telemetry via `gitmap pe -t` until 100% green before cutting release.
7. Execute minor version bump release ceremony via `python 03-ai-scripts/37-bump-version.py -t minor -s "<summary>"` (or `gitmap cpr "vX.Y.Z - summary"`).
8. Push all release commits and tags upstream (`gitmap push --tags` / `git push --tags`).

## Must follow and spawn agent using

1. @[execute-parent-task-with-n-steps-v6](directory;{prefix}/skills/execute-parent-task-with-n-steps-v6)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_letterly_11_pull(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"11-git-pull-first-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Git Pull First{title_suffix}

Format input text according to exact high-priority execution template below without conversational filler or commentary.

1. Capture input text verbatim, stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`) while preserving technical directives, parameters, flags, and file paths.
2. Derive `<task title>` as task subject (e.g. `Enforce Git Pull First on Task X`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — first try \\`gitmap pull <repo path>\\` (or run \\`gitmap pull\\` in repository folder); if that fails, fall back to regular \\`git pull\\` and resolve merge conflicts.`
   - Item 2: `2. Enforce clean, conflict-free working tree before authoring any code or specifications.`
   - Item 3: `3. Write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan in .ai-memory/plans/pending/XX-<slug>.md first.`
   - Item 4: `4. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py); TOTAL BAN on rg, ripgrep, grep, Select-String.`
   - Item 5: `5. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.`
   followed by discrete directives from input as items 6..N.
6. Append mandatory agent invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

## task: <task title>
## slug: <task-slug> (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Verify git working tree is clean and synchronized before creating or modifying code.
3. Write spec under 02-spec/21-app/XX-<slug>/ and enqueue plan task in .ai-memory/plans/pending/XX-<slug>.md (subtasks in .ai-memory/plans/subtasks/XX-<slug>/) first, (xx should be figured out by the folder structure and running AI tools, xx is sequence 01, 02)
4. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String
5. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well
6. ....discrete technical directives from input....

## Must follow and spawn agent using

1. @[execute-parent-task-with-n-steps-v6](directory;{prefix}/skills/execute-parent-task-with-n-steps-v6)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_letterly_14_v7(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    target_fname = f"14-execute-parent-task-v7-letterly{suffix}"
    target_fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, target_fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Execute Parent Task (V7 Time-Restricted & Autonomous Engine){title_suffix}

Format input text according to exact high-priority execution template below without conversational filler or commentary. Directs the AI agent to follow unified V7 master execution per @[execute-parent-task-with-n-steps-v7](directory;{prefix}/skills/execute-parent-task-with-n-steps-v7) (Option 1: Time-Restricted; Option 2: Unrestricted) and bot integration.

1. Keep the verbatim as is, only stripping verbal fillers (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`) while strictly preserving everything as said parameters, flags, and file paths. TOTAL BAN on mutating, softening, summarizing, or making the input text "smart" or "better". All reprimands, emotional tone, anger, and urgency must be kept 100% intact.
2. Derive `<task title>` as task subject (e.g. `Time-Restricted Recommit and Bot Workflow`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; when authoring directories and plan files, format as XX-<task-slug> where XX is zero-padded sequence).
5. Construct `# Actionable Items Must Follow Non-Negotiable`: include fixed items 1-9 (pull first, spec/plan enqueue with planning decoupled from execution under `02-spec/21-app/XX-<slug>/` and `.ai-memory/plans/pending/XX-<slug>.md`, GitMap search primacy, relative Git paths mandate, agent data entry, commit and push, task slug naming, V7 dual-option execution, and time-restricted recommits), followed by discrete technical directives from input as items 10..N.
6. Append mandatory agent invocation suffix pointing to directory-based V7 engine.
7. Output plain markdown only. Never wrap in fenced code blocks.
8. Relative Paths: Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute paths.

${{Input Text Verbatim}} = No change except for removal of filler words. Zero tone softening, zero omission of directives.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

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
8. Execute via V7 Master Engine per @[execute-parent-task-with-n-steps-v7](directory;{prefix}/skills/execute-parent-task-with-n-steps-v7): Option 1 (Time-Restricted commits before 08:00 AM weekdays / anytime weekends via `--tz`, `--schedule`, `--auto-window`) or Option 2 (Unrestricted commits); configure bot identity via `gitmap autobot` when commanded.
9. Enforce time-restricted recommits per @[gitmap-time-restriction](directory;{prefix}/skills/gitmap-time-restriction) using `gitmap` semantic commit verbs without polluting git history.
10. ....other steps and more steps sequentially from the input direction. Create more steps in between.

## Must follow and spawn agent using

1. @[execute-parent-task-with-n-steps-v7](directory;{prefix}/skills/execute-parent-task-with-n-steps-v7)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(target_fpath, "w", encoding="utf-8") as f:
        f.write(content)

    # Clean up obsolete files
    obsolete = [
        f"14-execute-recommit-time-restricted-letterly{suffix}",
        f"15-execute-n-steps-v7-letterly{suffix}",
        f"15-execute-parent-task-v7-letterly{suffix}",
    ]
    base_dir = CURSOR_DIR if is_cursor else LETTERLY_DIR
    for obs in obsolete:
        p = os.path.join(base_dir, obs)
        if os.path.exists(p) and p != target_fpath:
            os.remove(p)


def create_letterly_15_plan_parent_task(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"15-plan-parent-task-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Plan Parent Task (N-Steps Blueprint){title_suffix}

Format input text according to exact planning-only template below without conversational filler or commentary.

1. Clean input text verbatim, stripping verbal fillers while strictly preserving architectural requirements, scope boundaries, and design constraints.
2. Derive `<task title>` as task subject (e.g. `Architect Cache Eviction Engine`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; when authoring directories and plan files, format as XX-<task-slug> where XX is zero-padded sequence).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — first try \\`gitmap pull <repo path>\\` (or run \\`gitmap pull\\` in repository folder); if that fails, fall back to regular \\`git pull\\` and resolve merge conflicts.`
   - Item 2: `2. Write comprehensive architectural specification under 02-spec/21-app/XX-<slug>/01-architecture-spec.md adhering strictly to 02-spec/01-spec-authoring-guide/.`
   - Item 3: `3. Enqueue master plan under .ai-memory/plans/pending/XX-<slug>.md and granular subtasks under .ai-memory/plans/subtasks/XX-<slug>/01-subtask-<name>.md.`
   - Item 4: `4. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py); TOTAL BAN on rg, ripgrep, grep, Select-String.`
   - Item 5: `5. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.`
   - Item 6: `6. STRICTLY PLANNING ONLY: Total ban on code execution, compilation, builds, or test suite execution during this planning phase (NO-BUILD, NO-TEST, NO-CODE-CHANGES).`
   - Item 7: `7. Formulate multi-stage execution roadmap with binary acceptance criteria for every subtask.`
   followed by discrete architectural requirements from input as items 8..N.
6. Append mandatory planning skill invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

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

1. @[plan-spec-steps-v2](directory;{prefix}/skills/plan-spec-steps-v2)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- Keep all created specifications in `02-spec/21-app/XX-<slug>/` and plans in `.ai-memory/plans/pending/XX-<slug>.md` and `.ai-memory/plans/subtasks/XX-<slug>/` without starting immediate code execution.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def create_letterly_16_plan_groups(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"16-plan-steps-by-groups-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Plan Steps by Groups (Modular Layer Blueprint){title_suffix}

Format input text according to exact grouped planning template below without conversational filler or commentary.

1. Clean input text verbatim, stripping verbal fillers while strictly preserving technical requirements and architectural layer boundaries.
2. Derive `<task title>` as task subject (e.g. `Grouped Architecture Plan for Service Mesh`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; formatted as XX-<task-slug> for directories and plan files).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — first try \\`gitmap pull <repo path>\\` (or run \\`gitmap pull\\` in repository folder); if that fails, fall back to regular \\`git pull\\` and resolve merge conflicts.`
   - Item 2: `2. Write architectural spec under 02-spec/21-app/XX-<slug>/ decomposing work into discrete layer groups (Data/Schema, Core Logic, CLI/API, UI, Verification).`
   - Item 3: `3. Enqueue master plan under .ai-memory/plans/pending/XX-<slug>.md and grouped subtasks under .ai-memory/plans/subtasks/XX-<slug>/ (e.g. 01-group-data.md, 02-group-logic.md).`
   - Item 4: `4. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py); TOTAL BAN on rg, ripgrep, grep, Select-String.`
   - Item 5: `5. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.`
   - Item 6: `6. STRICTLY PLANNING ONLY: Total ban on code modification, compilation, local builds, or test suite execution (NO-BUILD, NO-TEST).`
   followed by discrete architectural directives from input as items 7..N.
6. Append mandatory grouped planning skill invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

## task: <task title>
## slug: <task-slug> (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Write grouped architectural specification under 02-spec/21-app/XX-<slug>/ decomposing the project into discrete, cohesive architectural layers.
3. Enqueue master plan in .ai-memory/plans/pending/XX-<slug>.md and grouped subtask checklists under .ai-memory/plans/subtasks/XX-<slug>/ (e.g. 01-group-data.md, 02-group-core.md, 03-group-wiring.md).
4. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String.
5. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
6. STRICTLY PLANNING ONLY: Total ban on code modification, compilation, local builds, or test suite execution during this planning phase (NO-BUILD, NO-TEST, NO-CODE-CHANGES).
7. Define explicit interface contracts and binary acceptance criteria between layer groups.

## Must follow and spawn agent using

1. @[plan-steps-by-groups](directory;{prefix}/skills/plan-steps-by-groups)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- Keep all created specifications in `02-spec/21-app/XX-<slug>/` and plans in `.ai-memory/plans/pending/XX-<slug>.md` and `.ai-memory/plans/subtasks/XX-<slug>/` without starting immediate code execution.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def create_letterly_17_plan_audit(is_cursor: bool) -> None:
    prefix = ".cursor" if is_cursor else ".agents"
    suffix = "-cursor.md" if is_cursor else ".md"
    fname = f"17-plan-coding-guideline-audit-letterly{suffix}"
    fpath = os.path.join(CURSOR_DIR if is_cursor else LETTERLY_DIR, fname)
    title_suffix = " — Cursor Prompt Formatter" if is_cursor else " — Letterly Prompt Formatter"

    content = f"""# Plan Coding Guideline Audit (Quality & Spec Scorecard){title_suffix}

Format input text according to exact guideline audit planning template below without conversational filler or commentary.

1. Clean input text verbatim, stripping verbal fillers while strictly preserving target module paths, guideline rule families, and audit scopes.
2. Derive `<task title>` as task subject (e.g. `Plan Coding Guideline Audit for CLI Modules`). Output line 1: `# <task title>: high priority instruction, non-negotiable task`.
3. Output `${{Input Text Verbatim}}` directly beneath title.
4. Output task name and slug subheaders:
   - `## task: <task title>`
   - `## slug: <task-slug>` (lowercase-hyphenated; formatted as XX-<task-slug> for directories and plan files).
5. Construct `# Actionable Items Must Follow Non-Negotiable`:
   - Item 1: `1. Git pull BEFORE starting any work — first try \\`gitmap pull <repo path>\\` (or run \\`gitmap pull\\` in repository folder); if that fails, fall back to regular \\`git pull\\` and resolve merge conflicts.`
   - Item 2: `2. Scan target codebase against 02-spec/02-coding-guidelines/ and 02-spec/03-error-manage/ to catalog violations (error sovereignty, positive booleans, 8-15 line functions, Result wrappers, PascalCase tables).`
   - Item 3: `3. Author audit specification and scorecard under 02-spec/25-app-spec-audit/XX-<slug>-audit.md.`
   - Item 4: `4. Enqueue remediation master plan in .ai-memory/plans/pending/XX-<slug>.md and bounded subtasks in .ai-memory/plans/subtasks/XX-<slug>/ (5–8 files per subtask).`
   - Item 5: `5. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py); TOTAL BAN on rg, ripgrep, grep, Select-String.`
   - Item 6: `6. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.`
   - Item 7: `7. STRICTLY PLANNING ONLY: Total ban on code modification, compilation, local builds, or test suite execution (NO-BUILD, NO-TEST).`
   followed by discrete audit requirements from input as items 8..N.
6. Append mandatory audit planning skill invocation suffix.
7. Output plain markdown only. Never wrap in fenced code blocks.

${{Input Text Verbatim}} = Cleaned input text without verbal filler words.

Output Format:

# <task title>: high priority instruction, non-negotiable task

${{Input Text Verbatim}}

## task: <task title>
## slug: <task-slug> (should not contain `xx-` here. )

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Scan target codebase against 02-spec/02-coding-guidelines/ to catalog all coding standard violations across error sovereignty, positive booleans, function line limits, and split DB encapsulation.
3. Author comprehensive audit scorecard and remediation matrix under 02-spec/25-app-spec-audit/XX-<slug>-audit.md.
4. Enqueue remediation master plan in .ai-memory/plans/pending/XX-<slug>.md and bounded 5–8 file micro-batch subtasks under .ai-memory/plans/subtasks/XX-<slug>/.
5. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String.
6. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
7. STRICTLY PLANNING ONLY: Total ban on code modification, compilation, local builds, or test suite execution during this planning phase (NO-BUILD, NO-TEST, NO-CODE-CHANGES).

## Must follow and spawn agent using

1. @[plan-coding-guideline-audit](directory;{prefix}/skills/plan-coding-guideline-audit)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;{prefix}/skills/fix-with-rca)

## Additional Instructions

- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) from @[gitmap](directory;{prefix}/skills/gitmap) skill to leverage GitMap high-speed search, toolchain discovery, and caching.
- Keep all created specifications in `02-spec/25-app-spec-audit/` and plans in `.ai-memory/plans/pending/XX-<slug>.md` and `.ai-memory/plans/subtasks/XX-<slug>/` without starting immediate code execution.
- Track in-flight file touches and prevent write collisions using GitMap RC Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`).
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_readme_letterly() -> None:
    fpath = os.path.join(LETTERLY_DIR, "readme.md")
    content = """# Letterly Prompt Formatters (`22-letterly`)

This collection contains deterministic prompt transformation templates designed to ingest raw voice-dictated user transcripts from Letterly (mobile and desktop) and format them into rigorous, non-negotiable agent prompts.

## Directory Index

| # | Prompt File | Target Mode | Description | Canonical Successor Skill |
| :---: | :--- | :--- | :--- | :--- |
| **01** | [`01-mobile-letterly.md`](01-mobile-letterly.md) | Mobile Single-Line | Compact one-liner without line breaks starting with `# High Priority Instruction:` | `execute-parent-task-with-n-steps-v6` |
| **02** | [`02-desktop-letterly.md`](02-desktop-letterly.md) | Desktop Structured | Formats voice dictation into high-priority instructions, action items, and V6 suffix | `execute-parent-task-with-n-steps-v6` |
| **03** | [`03-execute-n-steps-letterly.md`](03-execute-n-steps-letterly.md) | Execute N-Steps | Verbatim input capture with discrete action items and V6 execution engine | `execute-parent-task-with-n-steps-v6` |
| **04** | [`04-plan-letterly.md`](04-plan-letterly.md) | Planning Spec | Formats raw input into architectural planning directives with no-build rules | `plan-spec-steps-v2` |
| **05** | [`05-release-letterly.md`](05-release-letterly.md) | Minor Release (Letter U) | Formats input into minor release update ceremony directives | `minor-bump` |
| **06** | [`06-cicd-fix-release-letterly.md`](06-cicd-fix-release-letterly.md) | CI/CD Fix & Release | Formats input into `gitmap pe -t` telemetry diagnosis, 4-part RCA, and minor release | `ci-cd-fix-gitmap-release` |
| **07** | [`07-mobile-cicd-fix-letterly.md`](07-mobile-cicd-fix-letterly.md) | Mobile CI/CD Fix | One-liner mobile prompt diagnosing via `gitmap pe -t` and triggering release | `ci-cd-fix-gitmap-release` |
| **08** | [`08-run-letterly.md`](08-run-letterly.md) | Run Script | Formats input into run instructions via `./run.ps1` / `./run.sh` with auto dependency install | `run` |
| **09** | [`09-execute-with-verification-letterly.md`](09-execute-with-verification-letterly.md) | Execute + Retrospective Audit | Formats input into execute N-steps with mandatory retrospective AI verification at task end | `execute-parent-task-with-n-steps-v6` / `ai-verification` |
| **10** | [`10-execute-with-release-letterly.md`](10-execute-with-release-letterly.md) | Execute + Minor Release | Formats input into execute N-steps followed directly by green CI verification and minor release | `execute-parent-task-with-n-steps-v6` / `minor-bump` |
| **11** | [`11-git-pull-first-letterly.md`](11-git-pull-first-letterly.md) | Git Pull First | Formats input into pull-first execution directives ensuring gitmap pull runs before any work | `execute-parent-task-with-n-steps-v6` |
| **12** | [`12-muse-long-update-letterly.md`](12-muse-long-update-letterly.md) | Muse Long Update | Formats input into Muse long-running overnight execution with gitmap update first, rate-limited gitmap pa / repo pull, autopilot ambiguity logging, pragmatic commits, and conditional CI release | `execute-parent-task-with-n-steps-v6` |
| **13** | [`13-muse-sleepy-letterly.md`](13-muse-sleepy-letterly.md) | Muse Sleepy Mode | Formats input into "I am sleepy" autopilot execution with repo pull first, closest-choice ambiguity resolution, morning review log, no-build/no-test default, and pragmatic commits | `execute-parent-task-with-n-steps-v6` |
| **14** | [`14-execute-parent-task-v7-letterly.md`](14-execute-parent-task-v7-letterly.md) | Execute Parent Task (V7 Engine) | Formats voice dictation with V7 master autonomous execution engine (Option 1: Time-Restricted commits before 08:00 AM weekdays; Option 2: Unrestricted), autobot identity, and dual-window quotas | `execute-parent-task-with-n-steps-v7` |
| **15** | [`15-plan-parent-task-letterly.md`](15-plan-parent-task-letterly.md) | Plan Parent Task (N-Steps Blueprint) | Formats input into architectural planning specification and pending backlog task without immediate code execution | `plan-spec-steps-v2` |
| **16** | [`16-plan-steps-by-groups-letterly.md`](16-plan-steps-by-groups-letterly.md) | Plan Steps by Groups | Formats input into modular layer-by-layer architectural blueprint (Data, Core, API, UI, Verification) with zero code execution | `plan-steps-by-groups` |
| **17** | [`17-plan-coding-guideline-audit-letterly.md`](17-plan-coding-guideline-audit-letterly.md) | Plan Coding Guideline Audit | Formats input into coding standard compliance audit, scorecard, and remediation micro-batch backlog | `plan-coding-guideline-audit` |

### Cursor Prompt Suite (`23-cursor-prompts/`)

For Cursor environments requiring `.cursor/skills/` resolution, see [`../23-cursor-prompts/readme.md`](../23-cursor-prompts/readme.md) which houses the dedicated Cursor prompt suite (`01-mobile-letterly-cursor.md` through `17-plan-coding-guideline-audit-letterly-cursor.md`).

## Core Invariants

1. **Zero Conversational Filler:** Never output "Certainly! Here is your output:".
2. **Lossless Verbatim Capture:** Never drop specific technical flags, file paths, or commands from input.
3. **Mandatory Canonical Skill Triggers:** Every formatted prompt must conclude with its designated canonical skill trigger: `[<skill-name>](directory;.agents/skills/<skill-name>)`.
4. **Dual-Item Agent Invocation:** All execution formatters enforce dual-item agent spawning:
   - Primary task execution engine (`execute-parent-task-with-n-steps-v6` or `v7`).
   - Grounded bug remediation trigger: `If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.agents/skills/fix-with-rca)`.
5. **Immediate Execution Without Confirmation:** Under `## Additional Instructions`, all execution formatters strictly enforce:
   `- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.`
6. **Standard Letterly Suffix:** All prompt files in this directory strictly carry the `-letterly.md` file suffix.
7. **Strict Relative Git Paths Only:** Only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
8. **Decoupled Execution Engine:** Letterly prompts remain generic and decoupled from internal engine step budgeting; lifecycle execution parameters and concurrency are encapsulated directly within the invoked skills.
9. **Heatmap Telemetry & Write Collision Mandate:** All Letterly formatters embed the GitMap Heatmap one-liner (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`) to track in-flight file touches, prevent write collisions across parallel agent swarms ($A = 3$, Capacity = 6), and transparently report 3-tier database locations.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def update_readme_cursor() -> None:
    fpath = os.path.join(CURSOR_DIR, "readme.md")
    content = """# Cursor Prompt Formatters (`23-cursor-prompts`)

This collection contains deterministic prompt transformation templates specifically adapted for Cursor IDE environments, resolving skill dependencies directly against `.cursor/skills/`.

## Directory Index

| # | Prompt File | Target Mode | Description | Canonical Successor Skill |
| :---: | :--- | :--- | :--- | :--- |
| **01** | [`01-mobile-letterly-cursor.md`](01-mobile-letterly-cursor.md) | Mobile Single-Line | Compact one-liner without line breaks starting with `# High Priority Instruction:` | `execute-parent-task-with-n-steps-v6` |
| **02** | [`02-desktop-letterly-cursor.md`](02-desktop-letterly-cursor.md) | Desktop Structured | Formats voice dictation into high-priority instructions, action items, and V6 suffix | `execute-parent-task-with-n-steps-v6` |
| **03** | [`03-execute-n-steps-letterly-cursor.md`](03-execute-n-steps-letterly-cursor.md) | Execute N-Steps | Verbatim input capture with discrete action items and V6 execution engine | `execute-parent-task-with-n-steps-v6` |
| **04** | [`04-plan-letterly-cursor.md`](04-plan-letterly-cursor.md) | Planning Spec | Formats raw input into architectural planning directives with no-build rules | `plan-spec-steps-v2` |
| **05** | [`05-release-letterly-cursor.md`](05-release-letterly-cursor.md) | Minor Release (Letter U) | Formats input into minor release update ceremony directives | `minor-bump` |
| **06** | [`06-cicd-fix-release-letterly-cursor.md`](06-cicd-fix-release-letterly-cursor.md) | CI/CD Fix & Release | Formats input into `gitmap pe -t` telemetry diagnosis, 4-part RCA, and minor release | `ci-cd-fix-gitmap-release` |
| **07** | [`07-mobile-cicd-fix-letterly-cursor.md`](07-mobile-cicd-fix-letterly-cursor.md) | Mobile CI/CD Fix | One-liner mobile prompt diagnosing via `gitmap pe -t` and triggering release | `ci-cd-fix-gitmap-release` |
| **08** | [`08-run-letterly-cursor.md`](08-run-letterly-cursor.md) | Run Script | Formats input into run instructions via `./run.ps1` / `./run.sh` with auto dependency install | `run` |
| **09** | [`09-execute-with-verification-letterly-cursor.md`](09-execute-with-verification-letterly-cursor.md) | Execute + Retrospective Audit | Formats input into execute N-steps with mandatory retrospective AI verification at task end | `execute-parent-task-with-n-steps-v6` / `ai-verification` |
| **10** | [`10-execute-with-release-letterly-cursor.md`](10-execute-with-release-letterly-cursor.md) | Execute + Minor Release | Formats input into execute N-steps followed directly by green CI verification and minor release | `execute-parent-task-with-n-steps-v6` / `minor-bump` |
| **11** | [`11-git-pull-first-letterly-cursor.md`](11-git-pull-first-letterly-cursor.md) | Git Pull First | Formats input into pull-first execution directives ensuring gitmap pull runs before any work | `execute-parent-task-with-n-steps-v6` |
| **12** | [`12-muse-long-update-letterly-cursor.md`](12-muse-long-update-letterly-cursor.md) | Muse Long Update | Formats input into Muse long-running overnight execution with gitmap update first, rate-limited gitmap pa / repo pull, autopilot ambiguity logging, pragmatic commits, and conditional CI release | `execute-parent-task-with-n-steps-v6` |
| **13** | [`13-muse-sleepy-letterly-cursor.md`](13-muse-sleepy-letterly-cursor.md) | Muse Sleepy Mode | Formats input into "I am sleepy" autopilot execution with repo pull first, closest-choice ambiguity resolution, morning review log, no-build/no-test default, and pragmatic commits | `execute-parent-task-with-n-steps-v6` |
| **14** | [`14-execute-parent-task-v7-letterly-cursor.md`](14-execute-parent-task-v7-letterly-cursor.md) | Execute Parent Task (V7 Engine) | Formats voice dictation with V7 master autonomous execution engine (Option 1: Time-Restricted commits before 08:00 AM weekdays; Option 2: Unrestricted), autobot identity, and dual-window quotas | `execute-parent-task-with-n-steps-v7` |
| **15** | [`15-plan-parent-task-letterly-cursor.md`](15-plan-parent-task-letterly-cursor.md) | Plan Parent Task (N-Steps Blueprint) | Formats input into architectural planning specification and pending backlog task without immediate code execution | `plan-spec-steps-v2` |
| **16** | [`16-plan-steps-by-groups-letterly-cursor.md`](16-plan-steps-by-groups-letterly-cursor.md) | Plan Steps by Groups | Formats input into modular layer-by-layer architectural blueprint (Data, Core, API, UI, Verification) with zero code execution | `plan-steps-by-groups` |
| **17** | [`17-plan-coding-guideline-audit-letterly-cursor.md`](17-plan-coding-guideline-audit-letterly-cursor.md) | Plan Coding Guideline Audit | Formats input into coding standard compliance audit, scorecard, and remediation micro-batch backlog | `plan-coding-guideline-audit` |

## Core Invariants

1. **Zero Conversational Filler:** Never output "Certainly! Here is your output:".
2. **Lossless Verbatim Capture:** Never drop specific technical flags, file paths, or commands from input.
3. **Mandatory Canonical Skill Triggers:** Every formatted prompt must conclude with its designated canonical skill trigger: `[<skill-name>](directory;.cursor/skills/<skill-name>)`.
4. **Dual-Item Agent Invocation:** All execution formatters enforce dual-item agent spawning:
   - Primary task execution engine (`execute-parent-task-with-n-steps-v6` or `v7`).
   - Grounded bug remediation trigger: `If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.cursor/skills/fix-with-rca)`.
5. **Immediate Execution Without Confirmation:** Under `## Additional Instructions`, all execution formatters strictly enforce:
   `- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.`
6. **Standard Cursor Suffix:** All prompt files in this directory strictly carry the `-letterly-cursor.md` file suffix.
7. **Strict Relative Git Paths Only:** Only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
8. **Decoupled Execution Engine:** Prompts remain generic and decoupled from internal engine step budgeting; lifecycle execution parameters and concurrency are encapsulated directly within the invoked skills.
9. **Heatmap Telemetry & Write Collision Mandate:** All formatters embed the GitMap Heatmap one-liner (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`) to track in-flight file touches, prevent write collisions across parallel agent swarms ($A = 3$, Capacity = 6), and transparently report 3-tier database locations.
"""
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)


def main() -> int:
    for is_cursor in (False, True):
        update_letterly_01_mobile(is_cursor)
        update_letterly_02_desktop(is_cursor)
        update_letterly_03_execute(is_cursor)
        update_letterly_04_plan(is_cursor)
        update_letterly_05_release(is_cursor)
        update_letterly_06_cicd(is_cursor)
        update_letterly_07_mobile_cicd(is_cursor)
        update_letterly_08_run(is_cursor)
        update_letterly_09_verification(is_cursor)
        update_letterly_10_release(is_cursor)
        update_letterly_11_pull(is_cursor)
        update_letterly_14_v7(is_cursor)
        create_letterly_15_plan_parent_task(is_cursor)
        create_letterly_16_plan_groups(is_cursor)
        create_letterly_17_plan_audit(is_cursor)

    update_readme_letterly()
    update_readme_cursor()
    print("Successfully modernized Letterly and Cursor prompts (01 through 17).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
