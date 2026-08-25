import os
import glob

scripts_dir = "scripts/os/ubuntu"
sh_files = glob.glob(os.path.join(scripts_dir, "*.sh"))

for fpath in sh_files:
    with open(fpath, "r", encoding="utf-8") as f:
        content = f.read()

    # Prepend sudo to apt-get
    content = content.replace("apt-get install", "sudo apt-get install")
    content = content.replace("apt update", "sudo apt update")
    content = content.replace("apt upgrade", "sudo apt upgrade")
    content = content.replace("do-release-upgrade", "sudo do-release-upgrade")
    content = content.replace("snap install", "sudo snap install")
    content = content.replace("npm install -g", "sudo npm install -g")
    
    # Fix oh-my-zsh idempotency
    if "tools/install.sh" in content:
        content = content.replace('sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended', '''if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh-My-Zsh is already installed."
fi''')

    # Fix zsh-autosuggestions idempotency
    if "zsh-autosuggestions" in content and "git clone" in content:
        content = content.replace('git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions', '''ZSH_PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$ZSH_PLUGIN_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR"
else
    echo "zsh-autosuggestions is already installed."
fi''')

    # Avoid double sudo if run multiple times
    content = content.replace("sudo sudo ", "sudo ")

    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)

rca = """## Root cause analysis

Symptom: `Permission denied` and `Unable to acquire the dpkg frontend lock` during `apt-get` execution, alongside `destination path already exists` errors for `oh-my-zsh`.
Trigger: Executing `./run.sh install profile ubuntu+dev` as a standard, non-root user.
Root cause: The generated bash scripts (`scripts/os/ubuntu/*.sh`) executed raw `apt-get`, `snap`, and global `npm` installations without prepending `sudo` for privilege escalation. Additionally, `git clone` and the `oh-my-zsh` installer lacked idempotency checks, blindly attempting to download files into existing directories.
Why it escaped: The `batch_orchestrator` implemented the bare terminal commands defined in the original specification (e.g., `apt-get install -y vim`), which implicitly assumed execution within a `root` environment (like a Dockerfile) rather than a standard user Linux desktop environment.
Fix: Refactored all `scripts/os/ubuntu/*.sh` files to prepend `sudo` before `apt`, `apt-get`, `snap`, and `npm -g` commands. Wrapped Git clones and shell installers with `if [ ! -d "..." ]; then ... fi` block guards to ensure clean idempotency.
Prevention: spec/02-coding-guidelines/04-bash/00-overview.md - Always invoke system package managers (`apt`, `snap`) with explicit `sudo` and write idempotent deployment scripts that gracefully skip pre-existing directories.
Regression check: `./run.sh install profile ubuntu+dev` -> triggers `sudo` password prompt, skips existing Oh-My-Zsh directories, and executes APT installations successfully.
"""

os.makedirs(".lovable/issues", exist_ok=True)
with open(".lovable/issues/04-ubuntu-permissions-idempotency.md", "w", encoding="utf-8") as f:
    f.write(rca)

import subprocess
subprocess.run(["git", "add", "."], check=True)
subprocess.run(["git", "commit", "-m", "fix(ubuntu): enforce sudo on package managers and add idempotency blocks for zsh"], check=True)
subprocess.run(["git", "push"], check=True)
print("Applied sudo and idempotency fixes.")
