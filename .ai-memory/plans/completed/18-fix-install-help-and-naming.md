# Plan 18: Fix Install Help & Antigravity Naming

## Objective
1. Fix "Antigravity CLI" to "Antigravity".
2. Fix `install`, `install ls`, and `install list` to show the main help block which lists all profiles and commands.

## Constraints
- Must not rename standard commands.
- Must ensure help menus are shown.

## Execution
- Create subtask 01 to replace string "Antigravity CLI" with "Antigravity" across codebase.
- Create subtask 02 to update `run.sh` and `run.ps1` to display `Show-RootHelp` / `show_main_help` for empty arguments or `ls`/`list` arguments.
