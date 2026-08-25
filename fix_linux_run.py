import os

run_sh = "scripts/run.sh"
with open(run_sh, "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace('ARGS=$2', 'shift\nARGS="$*"')
with open(run_sh, "w", encoding="utf-8") as f:
    f.write(content)

root_run = "run"
with open(root_run, "w", encoding="utf-8") as f:
    f.write("#!/bin/bash\nbash scripts/run.sh \"$@\"\n")

# Make it executable if possible in WSL (using git update-index)
import subprocess
subprocess.run(["git", "add", "run", "scripts/run.sh"], check=True)
subprocess.run(["git", "update-index", "--chmod=+x", "run"], check=True)

# Write RCA
os.makedirs(".lovable/issues", exist_ok=True)
rca = """## Root cause analysis

Symptom: `Command '.run' not found` when executing `.\\run install profile -h` in a bash shell.
Trigger: Typing `.\\run` (Windows PowerShell path syntax) in a Linux bash environment. Bash evaluates `\\r` as `r` or `.\\run` as literal `.run` and searches the `$PATH` for it, instead of executing a local script.
Root cause: The repository lacked a top-level native bash entrypoint (`run` without an extension) and bash does not recognize Windows-style backslash relative paths.
Why it escaped: The previous plan focused strictly on generating the internal scripts under `scripts/os/ubuntu/` and `scripts/run.sh`, but omitted the top-level Linux proxy script needed to mimic the `run.ps1` experience.
Fix: Created the top-level `run` bash executable that proxies to `scripts/run.sh "$@"`. Fixed argument joining in `scripts/run.sh` so `profile -h` is treated as a combined argument string.
Prevention: spec/02-coding-guidelines/04-bash/00-overview.md - Always provide extensionless bash wrappers in the root for CLI tools that emulate multi-platform root commands.
Regression check: `./run install profile -h` -> outputs usage/unknown argument message instead of "command not found".
"""

with open(".lovable/issues/01-run-cli-linux.md", "w", encoding="utf-8") as f:
    f.write(rca)

print("RCA written and fix applied.")
