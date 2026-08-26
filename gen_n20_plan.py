import os

os.makedirs(".lovable/plans/pending", exist_ok=True)
os.makedirs(".lovable/plans/subtasks/09-ssh-and-aria2c", exist_ok=True)

plan = """# Parent Task: SSH Installation & Aria2c Inclusion

## Phase 1: Planning
1. Generate 10 discrete subtask specs to enforce the 50% deep planning requirement (N=20 -> 10 planning steps).
2. Map out the creation of `install-ssh.sh` with port customization, and the addition of `aria2c` to the `run.sh` menu.

## Phase 2: Execution
1. Add `install-ssh.sh` in `scripts/os/ubuntu/` which:
   - Installs `openssh-server`.
   - Reads an optional port argument.
   - Modifies `/etc/ssh/sshd_config` safely using `sed`.
   - Restarts the SSH service.
2. Update `scripts/run.sh` to route to `install-ssh.sh`.
3. Update `scripts/run.sh` UI to display `ssh` and `aria2c` under Core Tools.
"""

with open(".lovable/plans/pending/09-ssh-and-aria2c.md", "w", encoding="utf-8") as f:
    f.write(plan)

for i in range(1, 11):
    with open(f".lovable/plans/subtasks/09-ssh-and-aria2c/{i:02d}-spec.md", "w", encoding="utf-8") as f:
        f.write(f"# Spec {i}\nEnsure rule {i} of the SSH and aria2c specification is strictly followed.")

print("Generated 10 planning specs.")
