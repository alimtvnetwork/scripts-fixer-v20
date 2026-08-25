import os
import shutil
import json

base_dir = "scripts/46-install-kubernetes"
new_scripts = [
    ("72-install-git-lfs", "Git LFS", "git-lfs", "install-git-lfs.sh"),
    ("73-install-gh", "GitHub CLI", "gh", "install-gh.sh"),
    ("74-install-python2", "Python 2", "python2", "install-python2.sh"),
    ("75-install-yarn", "Yarn", "yarn", "install-yarn.sh")
]

for folder, title, kw, sh_script in new_scripts:
    target = os.path.join("scripts", folder)
    if not os.path.exists(target):
        shutil.copytree(base_dir, target)
        
        # update run.ps1
        run_file = os.path.join(target, "run.ps1")
        with open(run_file, "w", encoding="utf-8") as f:
            f.write(f'''# Install {title}
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir = Join-Path (Split-Path -Parent $scriptDir) "shared"
. (Join-Path $sharedDir "logging.ps1")

Write-Host "Installing {title} via WSL Ubuntu..." -ForegroundColor Cyan
wsl -e bash scripts/os/ubuntu/{sh_script}
''')
        # update config.json
        cfg = os.path.join(target, "config.json")
        with open(cfg, "w", encoding="utf-8") as f:
            f.write(json.dumps({"id": folder[:2], "name": folder}, indent=4))
            
print("Created new script folders.")
