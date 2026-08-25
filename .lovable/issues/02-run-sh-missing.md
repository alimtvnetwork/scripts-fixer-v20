## Root cause analysis

Symptom: `bash: ./run.sh: No such file or directory` and `chmod: cannot access './run.sh'`
Trigger: Attempting to execute `./run.sh` (and `.\run.sh`) in the root directory to trigger the profile installation.
Root cause: The root directory contained a `setup.sh` and `run.ps1`, but lacked a `run.sh` wrapper. The previous fix added an extensionless `run` proxy, but user workflows defaulted to `run.sh`.
Why it escaped: The specification created `scripts/run.sh` as the internal dispatcher, but failed to provide the explicit `run.sh` proxy in the root to match `run.ps1` symmetrically.
Fix: Added an executable `run.sh` script to the root directory that safely proxies to `scripts/run.sh "$@"`.
Prevention: spec/02-coding-guidelines/04-bash/00-overview.md - Always provide symmetric `.sh` wrappers in the root directory alongside `.ps1` equivalents to prevent friction in cross-platform developer workflows.
Regression check: `./run.sh install profile` -> successfully delegates to the internal bash dispatcher instead of returning file not found.
