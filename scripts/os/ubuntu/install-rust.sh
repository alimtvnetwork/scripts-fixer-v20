#!/bin/bash
if command -v rustc >/dev/null 2>&1 || [ -x "$HOME/.cargo/bin/rustc" ]; then
    echo "Rust is already installed: $(rustc --version 2>/dev/null || "$HOME/.cargo/bin/rustc" --version)"
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    exit 0
fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi
export PATH="$HOME/.cargo/bin:$PATH"
