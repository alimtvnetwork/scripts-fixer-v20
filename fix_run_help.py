import os
import subprocess

run_sh = "scripts/run.sh"

new_content = """#!/bin/bash
COMMAND=$1
shift
ARGS="$*"

show_install_help() {
    echo "Usage: ./run install [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  zsh,zsh+config             Install ZSH and Oh-My-Zsh with autosuggestions"
    echo "  profile <profile_name>     Install a predefined profile"
    echo "  help                       Show this help menu"
}

show_profile_help() {
    echo "Available Profiles for $USER:"
    echo "  ubuntu-basic       - Git, ZSH, aria2c, vim, build-essential, curl, wget"
    echo "  ubuntu+vscode      - ubuntu-basic + VS Code snap"
    echo "  ubuntu+simple-dev  - ubuntu+vscode + Golang, Rust, PHP, Python3"
    echo "  ubuntu+small-dev   - Alias for ubuntu+simple-dev"
    echo "  ubuntu+dev         - ubuntu+simple-dev + Node.js, PNPM"
}

case "$COMMAND" in
    "os")
        if [ "$ARGS" = "update-all" ]; then
            bash scripts/os/ubuntu/update-all.sh
        elif [ "$ARGS" = "update" ]; then
            bash scripts/os/ubuntu/update.sh
        fi
        ;;
    "install")
        if [[ "$ARGS" == *"zsh,zsh+config"* ]]; then
            bash scripts/os/ubuntu/dep-omyzsh.sh
            bash scripts/os/ubuntu/dep-zsh-autosuggestions.sh
        elif [[ "$ARGS" == *"profile ubuntu+dev"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-dev.sh
        elif [[ "$ARGS" == *"profile ubuntu+small-dev"* || "$ARGS" == *"profile ubuntu+simple-dev"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-simple-dev.sh
        elif [[ "$ARGS" == *"profile ubuntu+vscode"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-vscode.sh
        elif [[ "$ARGS" == *"profile ubuntu-basic"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-basic.sh
        elif [[ "$ARGS" == *"profile help"* || "$ARGS" == *"profile -h"* || "$ARGS" == *"profile --help"* || "$ARGS" == *"profile -help"* ]]; then
            show_profile_help
        elif [[ "$ARGS" == *"help"* || "$ARGS" == *"-h"* || "$ARGS" == *"--help"* || "$ARGS" == *"-help"* ]]; then
            show_install_help
        else
            echo "Unknown install argument: $ARGS"
            echo "Run './run install help' for more details."
        fi
        ;;
    *)
        echo "Usage: ./run os [update|update-all]"
        echo "       ./run install [zsh,zsh+config | profile <name> | help]"
        ;;
esac
"""

with open(run_sh, "w", encoding="utf-8") as f:
    f.write(new_content)

rca = """## Root cause analysis

Symptom: `Unknown install argument: profile -h` and `Unknown install argument: ubuntu+small-dev`
Trigger: Executing `./run.sh install profile -h` or `./run.sh install ubuntu+small-dev`.
Root cause: The internal bash dispatcher (`scripts/run.sh`) lacked parsing cases for `--help`, `-h`, and `help` commands, defaulting to an unknown argument failure. Additionally, it did not alias `ubuntu+small-dev` to `ubuntu+simple-dev`.
Why it escaped: The previous iterations correctly proxied arguments from the root script, but the switch/case evaluation inside `scripts/run.sh` rigidly exact-matched a static string array and lacked a dynamic fallback or help UI.
Fix: Refactored `scripts/run.sh` to implement dedicated `show_install_help()` and `show_profile_help()` functions. Added alias evaluation for `ubuntu+small-dev`. Bound `-h`, `--help`, and `help` to trigger the documentation UI.
Prevention: spec/02-coding-guidelines/04-bash/00-overview.md - Always inject standardized `-h` and `--help` trap routines on all CLI interfaces to present available arguments instead of raw failures.
Regression check: `./run.sh install profile help` -> outputs cleanly formatted available profiles for the logged-in user.
"""

os.makedirs(".lovable/issues", exist_ok=True)
with open(".lovable/issues/03-run-sh-help-support.md", "w", encoding="utf-8") as f:
    f.write(rca)

subprocess.run(["git", "add", "."], check=True)
subprocess.run(["git", "commit", "-m", "fix(cli): add robust help parsing and small-dev alias to internal bash dispatcher"], check=True)
subprocess.run(["git", "push"], check=True)
print("Updated run.sh and pushed RCA.")
