## Root cause analysis

Symptom: `Unknown install argument: profile -h` and `Unknown install argument: ubuntu+small-dev`
Trigger: Executing `./run.sh install profile -h` or `./run.sh install ubuntu+small-dev`.
Root cause: The internal bash dispatcher (`scripts/run.sh`) lacked parsing cases for `--help`, `-h`, and `help` commands, defaulting to an unknown argument failure. Additionally, it did not alias `ubuntu+small-dev` to `ubuntu+simple-dev`.
Why it escaped: The previous iterations correctly proxied arguments from the root script, but the switch/case evaluation inside `scripts/run.sh` rigidly exact-matched a static string array and lacked a dynamic fallback or help UI.
Fix: Refactored `scripts/run.sh` to implement dedicated `show_install_help()` and `show_profile_help()` functions. Added alias evaluation for `ubuntu+small-dev`. Bound `-h`, `--help`, and `help` to trigger the documentation UI.
Prevention: spec/02-coding-guidelines/04-bash/00-overview.md - Always inject standardized `-h` and `--help` trap routines on all CLI interfaces to present available arguments instead of raw failures.
Regression check: `./run.sh install profile help` -> outputs cleanly formatted available profiles for the logged-in user.
