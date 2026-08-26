import os

plan_content = """# Goal
Add a detailed version footer to both `run.ps1` and `scripts/run.sh` that displays the Git URL, last SHA, release version (semantic), and last commit timing.

## Subtasks
1. Edit `run.ps1`: Update `Show-VersionFooter` to include commit timing.
2. Edit `scripts/run.sh`: Create a `show_footer` function and call it at the end of the script.
3. Validate output.

## Guidelines Checklist
- [x] Boolean conventions followed.
- [x] No garbage names.
- [x] Semantic updates.
"""

os.makedirs(".lovable/plans/pending", exist_ok=True)
os.makedirs(".lovable/plans/subtasks/06-cli-footer", exist_ok=True)

with open(".lovable/plans/pending/06-cli-footer.md", "w", encoding="utf-8") as f:
    f.write(plan_content)

for i in range(1, 4):
    with open(f".lovable/plans/subtasks/06-cli-footer/0{i}-task.md", "w", encoding="utf-8") as f:
        f.write(f"# Task {i}\nExecute task {i} from the plan.")

print("Plan created successfully in .lovable/plans/")
