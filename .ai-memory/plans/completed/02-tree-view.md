# Subtask 2: Profile Tree View & Examples

## Actions
- Update `run.ps1`: 
  - Document `.\run.ps1 profile tree <name>` and `.\run.ps1 profile <name> --dry-run` in the help output.
  - Add explicit examples on how to install profiles and view their trees.
  - Verify and implement the logic for `profile tree <name>` to print the full tree of the install before installing (e.g., wrap `profile_tree.py` or native implementation).
- Update `run.sh`:
  - Ensure `./run.sh profile tree <name>` works and delegates to `python3 scripts/shared/profile_tree.py tree <name>`.
  - Update `./run.sh help` to include explicit examples for installing profiles and viewing trees.
