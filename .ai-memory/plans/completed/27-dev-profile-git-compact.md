# Plan & Implementation Record: Git-compact in Dev Profile

> **Version:** 1.0.0  
> **Date:** 2026-09-14  
> **Status:** Completed

## 1. Goal
Incorporate `git-compact` (Script 71 repository compactor and pruner CLI) into the developer profile stacks across the project:
- `ubuntu+simple-dev`
- `ubuntu+dev`
- `ubuntu+dev+ai`
- Windows profile recipes (`scripts/profile/config.json`)

## 2. Implementation
1. **Ubuntu Installer Helper (`scripts/os/ubuntu/install-git-compact.sh`)**:
   - Follows strict boolean guidelines (`is_git_compact_installed`, `is_force`).
   - Micro-functions (<= 8-15 lines).
   - Delegates to `scripts-linux/71-install-git-compact/run.sh` or falls back to upstream release script.
   - Configures and verifies PATH (`~/.local/bin`) and runs version assertion.
2. **Profile Script (`scripts/os/ubuntu/profile-ubuntu-simple-dev.sh`)**:
   - Calls `bash scripts/os/ubuntu/install-git-compact.sh` alongside GitHub Desktop.
3. **Profile Tree (`scripts/shared/profile_tree.py`)**:
   - Updated descriptions, hierarchy trees, and step breakdown for `ubuntu+simple-dev`, `ubuntu+dev`, and `ubuntu+dev+ai`.
4. **Linux Root Runner (`scripts/run.sh`)**:
   - Added script 71 to Available Scripts table.
   - Added `profile git-compact` handling.
   - Added standalone `git-compact` / `gitcompact` / `71` install dispatch.
5. **Cross-Platform / Windows (`scripts/profile/config.json`, `scripts/shared/install-keywords.json`)**:
   - Added Script 71 step to `"git-compact"` profile recipe.
   - Added `"git-compact"` and `"gitcompact"` keywords mapped to Script 71.

## 3. Verification
- `python scripts/shared/profile_tree.py ubuntu+dev`: verified git-compact in tree and steps.
- `python scripts/shared/profile_tree.py ubuntu+simple-dev`: verified git-compact in tree and steps.
- `bash -n` syntax check passed on all modified/new bash scripts.
- JSON syntax validation passed on `scripts/profile/config.json` and `scripts/shared/install-keywords.json`.
- Strict LF line endings verified.
