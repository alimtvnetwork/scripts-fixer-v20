# Parent Task: Install LS Tree Expansion & Detailed Under-the-Hood Visualization

## Phase 1: Planning (10 Subtasks)
Decompose the implementation into 10 granular micro-specifications covering tree parsing in `list_installs.py`, profile resolution, color contrast, error recovery, and release management.

## Phase 2: Execution (10 Actions)
1. Enhance `scripts/shared/list_installs.py` to import `PROFILES` from `scripts/shared/profile_tree.py`.
2. For every logged entry in `installs` database:
   - Identify if the item is a profile (e.g. `profile ubuntu+small-dev`, `ubuntu-basic`, `ubuntu+dev`, etc.).
   - Expand with indented hierarchical tree lines (`├──`, `└──`) and descriptions.
   - For individual tools, display tool metadata and purpose.
3. Synchronize `version.json` and `scripts/version.json` to 1.15.0.
4. Update `.lovable/memory/release-architecture-map.md`.
5. Update `.lovable/temp-agents/12-install-ls-tree.md` to `STATUS: DONE`.
