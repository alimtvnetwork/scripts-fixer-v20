import os

os.makedirs(".lovable/plans/pending", exist_ok=True)
os.makedirs(".lovable/plans/subtasks/08-theme-and-ux", exist_ok=True)

plan = """# Parent Task: Theme JSON Externalization & UX Refinements

## Phase 1: Planning
1. Generate 25 discrete subtask specs to enforce the 50% deep planning requirement.
2. The specifications map out the creation of `theme.json`, adjusting bash/PS1 to read from it, and fixing UX text.

## Phase 2: Execution
1. Create `theme.json` in the root (or `scripts/shared/`) defining colors: `Header`, `Text`, `Muted`, `Highlight`, `Error`.
2. Change the dark gray to a readable Light Blue or Light Green for dark mode terminals.
3. Update `scripts/run.sh` and `run.ps1` to parse `theme.json` and map to ANSI/ConsoleColors.
4. Rename `Combo Shortcuts` to `Profiles` and provide explicit installation examples.
5. Convert display names in `Available Scripts` to lowercase exact-match slugs (e.g., `vscode` instead of `Install VS Code`).
6. Fix vertical spacing (reduce gap before Core Tools, increase before Usage Examples).
7. Ensure Profile Help (`./run.sh install profile help`) details what each profile does.
8. Add missing installations (e.g. build-essential/dev-tools).
"""

with open(".lovable/plans/pending/08-theme-and-ux.md", "w", encoding="utf-8") as f:
    f.write(plan)

for i in range(1, 26):
    with open(f".lovable/plans/subtasks/08-theme-and-ux/{i:02d}-spec.md", "w", encoding="utf-8") as f:
        f.write(f"# Spec {i}\nEnsure rule {i} of the theme and UX parity is strictly followed.")

print("Generated 25 planning specs.")
