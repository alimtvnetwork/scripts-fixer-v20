## Root cause analysis

Symptom: `Permission denied` on dpkg frontend lock and `npm: command not found` alongside idempotency failures for ZSH.
Trigger: Executing `./run.sh install profile ubuntu+dev`.
Root cause: The previous script missed prepending `sudo` to nodesource's `bash -` setup script, causing the Nodesource APT repo setup to fail without root, which subsequently broke the NPM installation. Furthermore, `sudo` was missed on `apt-get update`, and the zsh-autosuggestions directory idempotency check evaluated before `sudo git clone`, but `git clone` lacked `sudo` if the directory required elevated writes.
Why it escaped: The previous bulk replace used literal string matching (`apt-get install` instead of `apt-get`) which left `apt-get update` exposed. The Nodesource curl pipe was identified in RCA but omitted from the actual python execution payload.
Fix: Applied comprehensive regex replacements `(?<!sudo )apt-get ` across all scripts to ensure 100% coverage of package managers. Prepended `sudo` to the Nodesource `bash -` pipe. Forced `sudo git clone` for zsh plugins to bypass permission hurdles.
Prevention: spec/02-coding-guidelines/04-bash/00-overview.md - Always use AST or strict Regex boundaries when bulk-refactoring command permissions, never literal substrings.
Regression check: `./run.sh install profile ubuntu+dev` -> Node LTS successfully acquires APT locks via sudo, npm becomes available, and profiles finish clean.
