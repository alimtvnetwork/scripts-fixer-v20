#!/bin/bash
set -e

CARGO_BIN="$HOME/.cargo/bin"

if command -v rustc >/dev/null 2>&1 || [ -x "$CARGO_BIN/rustc" ]; then
    echo "Rust is already installed: $(rustc --version 2>/dev/null || "$CARGO_BIN/rustc" --version)"
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    "$CARGO_BIN/rustup" component add rustfmt clippy rust-analyzer 2>/dev/null || true
    exit 0
fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

export PATH="$CARGO_BIN:$PATH"
"$CARGO_BIN/rustup" component add rustfmt clippy rust-analyzer 2>/dev/null || true

# System-wide path export for profile sessions
if [ -d "/etc/profile.d" ] && [ -w "/etc/profile.d" ]; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' > /etc/profile.d/cargo.sh
fi
