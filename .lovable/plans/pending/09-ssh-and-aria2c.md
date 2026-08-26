# Parent Task: SSH Installation & Aria2c Inclusion

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
