# Plan 25: Run Install Help, Profile Tree Inspection & Antigravity Installer Parity (Completed)

> **Main Task Inception**: User requested:
> 1. `./run install`, `./run install help`, and `./run` must properly display full help with all available install options, profiles, and examples.
> 2. Every `run` execution must execute `git pull` first before doing anything else.
> 3. `./run install profile <name> --tree` (and `./run profile <name> --tree`) must display the profile hierarchy tree.
> 4. Fix Antigravity IDE and CLI installer (`install-antigravity.sh` and related scripts) incorporating verified logic from `01-installer`.
>
> **Execution Status**: Complete (Consolidated from subtasks 01-04 across 1 continuous loop).

## Summary of Completed Subtasks

### Subtask 01: Git Pull and Run Entrypoints
- Placed initial repository refresh (`git pull`) at the very top of `scripts/run.sh` right after parameter initialization.
- Every command invocation now fetches remote repository updates first before checking verbs or rendering help screens.
- Safe fallback handles offline/unreachable network without blocking execution.

### Subtask 02: Install Help and Profiles List
- Unified `show_install_help()` with `show_main_help()` so `./run`, `./run install`, and `./run install help` all output the full-fidelity help display.
- Displays full list of profiles (Ubuntu-specific and generic OS-agnostic: basic, simple-dev, small-dev, dev, dev+ai, ai-tools, antigravity).
- Lists combo shortcuts, all categorized scripts, and concrete usage examples including tree inspection syntax.

### Subtask 03: Profile Tree Inspection CLI
- Intercepted `--tree`, `-t`, and `tree` flags in both `case "install")` and `case "profile")` in `scripts/run.sh`.
- Added definition for `ubuntu+dev+ai` in `scripts/shared/profile_tree.py`.
- Added cross-platform alias mapping for `basic`, `dev`, `small-dev`, `simple-dev`, `dev+ai`, `ai-tools`, `antigravity`, `antigravity-suite`.
- Added robust loop-based prefix/suffix stripping in `resolve_profile` to handle complex invocations like `install profile dev --tree` cleanly.

### Subtask 04: Antigravity Installer Parity
- Upgraded `scripts/os/ubuntu/install-antigravity.sh` with logic from `D:\work\antigravity-installer\01-installer\agy-install.sh`:
  - Staging directory extraction handles varying archive root structures.
  - Case-insensitive binary discovery checks both `Antigravity` (capital A) and `antigravity`.
  - Sets executable permissions (`chmod +x`), configures `chrome-sandbox` permissions (4755/executable), and creates CLI symlinks for `antigravity` and `agy`.
  - Verification validates executable presence and returns non-zero on failure.
- Updated `scripts/69-install-antigravity/run.ps1`:
  - Added unique GUID-based temp file naming (`agy_${uniqueId}_...`) to avoid parallel file locking collisions in `$env:TEMP`.
  - Added dedicated read-only `check` handler for automated smoke checks.
  - Added `ProgramFiles` detection candidate for system-level Antigravity installations.

## Verification
- `./run`: Verified `git pull` triggers and comprehensive help renders.
- `./run install`: Verified full help with profiles table and script list renders.
- `./run install help`: Verified full help renders.
- `./run install profile dev --tree`: Verified hierarchy tree breakdown outputs cleanly.
- `./run profile dev --tree`: Verified hierarchy tree breakdown outputs cleanly.
- `./run install profile ubuntu+small-dev --tree`: Verified hierarchy tree breakdown outputs cleanly.
- `node tools/smoke-check.mjs --id 69`: Verified 100% PASS with exit code 0.
- `node tools/validate-json-configs.mjs`: Verified 100% pass across 424 JSON files.
