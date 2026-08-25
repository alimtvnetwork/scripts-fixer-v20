#!/bin/bash
COMMAND=$1
shift
ARGS="$*"

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
        elif [[ "$ARGS" == *"profile ubuntu+simple-dev"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-simple-dev.sh
        elif [[ "$ARGS" == *"profile ubuntu+vscode"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-vscode.sh
        elif [[ "$ARGS" == *"profile ubuntu-basic"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-basic.sh
        else
            echo "Unknown install argument: $ARGS"
        fi
        ;;
    *)
        echo "Usage: ./run os [update|update-all]"
        echo "       ./run install [zsh,zsh+config | profile ubuntu+dev]"
        ;;
esac
