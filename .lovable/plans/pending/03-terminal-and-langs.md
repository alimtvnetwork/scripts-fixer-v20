# Plan: Terminal Utilities & Language Version Managers

## Overview
This plan covers the installation and configuration of modern terminal utilities and language version managers across Windows and Ubuntu.

**Targeted Utilities:**
- Modern Terminal Utilities: `jq`, `yq`, `Zellij`
- Language Version Managers: `fnm` (Node.js), `uv` (Python), `rustup` (Rust)

## Custom Rules & Constraints
1. **Idempotency:** Installation scripts must check if the tool is already installed before attempting installation.
2. **Modular Functions:** Each utility and language manager should have its own separate installation function.
3. **Environment Isolation:** Do not pollute the global environment. Add tools to the local user profile and update `$PATH` correctly for Windows (`$PROFILE`) and Ubuntu (`~/.bashrc` / `~/.zshrc`).
4. **Error Handling:** Ensure scripts exit gracefully with meaningful error messages if an installation fails.
5. **No Interactive Prompts:** Use unattended/silent flags (e.g., `-y`) to prevent scripts from blocking.

## Subtasks
- [.lovable/plans/subtasks/03-terminal-and-langs/01-windows-tasks.md](.lovable/plans/subtasks/03-terminal-and-langs/01-windows-tasks.md)
- [.lovable/plans/subtasks/03-terminal-and-langs/02-ubuntu-tasks.md](.lovable/plans/subtasks/03-terminal-and-langs/02-ubuntu-tasks.md)
