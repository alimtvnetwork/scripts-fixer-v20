import os
import re

# 1. Create install-ssh.sh
ssh_sh_path = "scripts/os/ubuntu/install-ssh.sh"
ssh_sh_code = """#!/bin/bash
sudo apt-get install -y openssh-server

PORT=$1
if [ -z "$PORT" ]; then
    read -p "Enter custom SSH port (Default: 22): " PORT
fi
if [ -z "$PORT" ]; then
    PORT=22
fi

echo "Configuring SSH on Port $PORT..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

if grep -q "^#Port" /etc/ssh/sshd_config; then
    sudo sed -i "s/^#Port.*/Port $PORT/" /etc/ssh/sshd_config
elif grep -q "^Port" /etc/ssh/sshd_config; then
    sudo sed -i "s/^Port.*/Port $PORT/" /etc/ssh/sshd_config
else
    echo "Port $PORT" | sudo tee -a /etc/ssh/sshd_config
fi

sudo service ssh restart || sudo systemctl restart ssh
echo "SSH Installation and configuration complete."
"""
with open(ssh_sh_path, "w", encoding="utf-8", newline='\n') as f:
    f.write(ssh_sh_code)

# 2. Modify run.sh
run_sh_path = "scripts/run.sh"
with open(run_sh_path, "r", encoding="utf-8") as f:
    run_sh = f.read()

# Add to Core Tools help menu
new_core_tools = """    printf "    ${MUTED}%s${TEXT}  %-30s  %s\\n" "24" "vim" "Install vim text editor"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\\n" "25" "ssh" "Install SSH & configure port"
    printf "    ${MUTED}%s${TEXT}  %-30s  %s\\n" "26" "aria2c" "Install aria2c downloader\""""

run_sh = run_sh.replace('    printf "    ${MUTED}%s${TEXT}  %-30s  %s\\n" "24" "vim" "Install vim text editor"', new_core_tools)

# Add to case statement in install
new_install_case = """        elif [[ "$ARGS" == *"vim"* || "$ARGS" == *"24"* ]]; then
            bash scripts/os/ubuntu/dep-vim.sh
        elif [[ "$ARGS" == *"ssh"* || "$ARGS" == *"25"* ]]; then
            # Extract port if provided, e.g., './run.sh install ssh 2222'
            PORT=$(echo "$ARGS" | grep -oE '[0-9]+' | head -n 1)
            bash scripts/os/ubuntu/install-ssh.sh "$PORT"
        elif [[ "$ARGS" == *"aria2c"* || "$ARGS" == *"26"* ]]; then
            bash scripts/os/ubuntu/dep-aria2c.sh"""

run_sh = run_sh.replace('        elif [[ "$ARGS" == *"vim"* || "$ARGS" == *"24"* ]]; then\n            bash scripts/os/ubuntu/dep-vim.sh', new_install_case)

with open(run_sh_path, "w", encoding="utf-8", newline='\n') as f:
    f.write(run_sh)

import subprocess
subprocess.run(["git", "add", "."], check=True)
subprocess.run(["git", "commit", "-m", "feat: add ssh installer with port config and aria2c to ui menu"], check=True)
subprocess.run(["git", "push"], check=True)
print("Updated run.sh and added install-ssh.sh successfully!")
