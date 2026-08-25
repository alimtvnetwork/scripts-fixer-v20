import os

gitignore_path = '.gitignore'
entries = [
    ".lovable/temp/",
    ".lovable/temp-scripts/",
    ".lovable/temp-agents/"
]

content = ""
if os.path.exists(gitignore_path):
    with open(gitignore_path, "r", encoding="utf-8") as f:
        content = f.read()

added = False
for entry in entries:
    if entry not in content:
        content += f"\n{entry}\n"
        added = True

if added:
    with open(gitignore_path, "w", encoding="utf-8") as f:
        f.write(content.strip() + "\n")
    print("Updated .gitignore")
else:
    print(".gitignore already configured")

# Create folders
os.makedirs(".lovable/temp", exist_ok=True)
os.makedirs(".lovable/temp-scripts", exist_ok=True)
os.makedirs(".lovable/temp-agents", exist_ok=True)
os.makedirs(".lovable/plans/completed", exist_ok=True)
