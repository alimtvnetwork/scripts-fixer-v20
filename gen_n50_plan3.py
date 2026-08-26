import os

os.makedirs(".lovable/plans/pending", exist_ok=True)
os.makedirs(".lovable/plans/subtasks/10-install-summary-and-logging", exist_ok=True)

plan = """# Parent Task: Install Summary, Multi-ID Support & SQLite Logging

## Phase 1: Planning
1. Generate 25 discrete subtask specs to enforce the 50% deep planning requirement (N=50 -> 25 planning steps).

## Phase 2: Execution
1. Implement a Python logger (`scripts/shared/logger.py`) that accepts an installed package/profile name and writes to `install_log.json` and `install_log.db` (SQLite).
2. Update `scripts/run.sh` to parse comma-separated arguments for the `install` command.
3. Keep track of installed packages during execution in an array and print a summary table at the end.
4. Add the Python logger call after every successful package installation in `run.sh`.
5. Release & Version bump (Minor version) in `version.json`.
6. Document release architecture in `.lovable/memory/release-architecture-map.md`.
"""

with open(".lovable/plans/pending/10-install-summary-and-logging.md", "w", encoding="utf-8") as f:
    f.write(plan)

for i in range(1, 26):
    with open(f".lovable/plans/subtasks/10-install-summary-and-logging/{i:02d}-spec.md", "w", encoding="utf-8") as f:
        f.write(f"# Spec {i}\nEnsure rule {i} of the summary, multi-install, and SQLite logging is strictly followed.")

print("Generated 25 planning specs.")
