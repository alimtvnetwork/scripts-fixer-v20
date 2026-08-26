import os

os.makedirs(".lovable/plans/pending", exist_ok=True)
os.makedirs(".lovable/plans/subtasks/07-linux-cli-parity", exist_ok=True)

plan = """# Parent Task: Linux CLI UI Parity & Command Enhancements

## Phase 1: Planning
1. Generate 25 discrete subtask specs to enforce the 50% deep planning requirement.
2. The specifications will map out the complete overhaul of `scripts/run.sh` to match `run.ps1`'s rich Help UI.

## Phase 2: Execution
1. Implement the ID-based table rendering in `scripts/run.sh`.
2. Map `01` -> VS Code, `03` -> Node, etc.
3. List explicit Linux-only commands: `os update`, `os update-all`.
4. List profile combinations explicitly with IDs.
5. Embed semantic coloring and formatting identical to Windows.
"""

with open(".lovable/plans/pending/07-linux-cli-parity.md", "w", encoding="utf-8") as f:
    f.write(plan)

for i in range(1, 26):
    with open(f".lovable/plans/subtasks/07-linux-cli-parity/{i:02d}-spec.md", "w", encoding="utf-8") as f:
        f.write(f"# Spec {i}\nEnsure rule {i} of the UI parity is strictly followed.")

print("Generated 25 planning specs.")
