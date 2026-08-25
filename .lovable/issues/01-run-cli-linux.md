## Root cause analysis

Symptom: `Command '.run' not found` when executing `.\run install profile -h` in a bash shell.
Trigger: Typing `.\run` (Windows PowerShell path syntax) in a Linux bash environment. Bash evaluates `\r` as `r` or `.\run` as literal `.run` and searches the `$PATH` for it, instead of executing a local script.
Root cause: The repository lacked a top-level native bash entrypoint (`run` without an extension) and bash does not recognize Windows-style backslash relative paths.
Why it escaped: The previous plan focused strictly on generating the internal scripts under `scripts/os/ubuntu/` and `scripts/run.sh`, but omitted the top-level Linux proxy script needed to mimic the `run.ps1` experience.
Fix: Created the top-level `run` bash executable that proxies to `scripts/run.sh "$@"`. Fixed argument joining in `scripts/run.sh` so `profile -h` is treated as a combined argument string.
Prevention: spec/02-coding-guidelines/04-bash/00-overview.md - Always provide extensionless bash wrappers in the root for CLI tools that emulate multi-platform root commands.
Regression check: `./run install profile -h` -> outputs usage/unknown argument message instead of "command not found".
