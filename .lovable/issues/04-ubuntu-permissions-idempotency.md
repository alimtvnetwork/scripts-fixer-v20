## Root cause analysis

Symptom: `Permission denied` and `Unable to acquire the dpkg frontend lock` during `apt-get` execution, alongside `destination path already exists` errors for `oh-my-zsh`.
Trigger: Executing `./run.sh install profile ubuntu+dev` as a standard, non-root user.
Root cause: The generated bash scripts (`scripts/os/ubuntu/*.sh`) executed raw `apt-get`, `snap`, and global `npm` installations without prepending `sudo` for privilege escalation. Additionally, `git clone` and the `oh-my-zsh` installer lacked idempotency checks, blindly attempting to download files into existing directories.
Why it escaped: The `batch_orchestrator` implemented the bare terminal commands defined in the original specification (e.g., `apt-get install -y vim`), which implicitly assumed execution within a `root` environment (like a Dockerfile) rather than a standard user Linux desktop environment.
Fix: Refactored all `scripts/os/ubuntu/*.sh` files to prepend `sudo` before `apt`, `apt-get`, `snap`, and `npm -g` commands. Wrapped Git clones and shell installers with `if [ ! -d "..." ]; then ... fi` block guards to ensure clean idempotency.
Prevention: spec/02-coding-guidelines/04-bash/00-overview.md - Always invoke system package managers (`apt`, `snap`) with explicit `sudo` and write idempotent deployment scripts that gracefully skip pre-existing directories.
Regression check: `./run.sh install profile ubuntu+dev` -> triggers `sudo` password prompt, skips existing Oh-My-Zsh directories, and executes APT installations successfully.
