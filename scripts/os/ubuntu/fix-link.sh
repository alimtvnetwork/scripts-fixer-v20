#!/bin/bash
# Fix Link: Creates a global symlink in ~/.local/bin for a given executable script
# Or repairs a Git text-file symlink back into a real symlink.

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
ACCENT='\033[1;33m'
ERROR='\033[1;31m'
MUTED='\033[0;90m'
TEXT='\033[0m'

TARGET_PATH="$1"

if [ -z "$TARGET_PATH" ]; then
    echo -e "${ERROR}✖ Error: Missing target path.${TEXT}"
    echo -e "Usage: ./run.sh os fix-link <path_to_executable_or_broken_link>"
    exit 1
fi

if [ ! -e "$TARGET_PATH" ]; then
    echo -e "${ERROR}✖ Error: File or directory not found at '$TARGET_PATH'${TEXT}"
    exit 1
fi

# Feature 1: Fix Git plain-text symlinks (where core.symlinks=false checked out a text file)
if [ -f "$TARGET_PATH" ] && [ ! -L "$TARGET_PATH" ] && [ $(wc -l < "$TARGET_PATH") -le 2 ]; then
    # Could be a plain text symlink
    POTENTIAL_TARGET=$(cat "$TARGET_PATH" | tr -d '\r\n')
    # If the text inside the file points to a valid relative or absolute path, it's likely a broken git symlink
    DIR_NAME=$(dirname "$TARGET_PATH")
    if [ -e "$DIR_NAME/$POTENTIAL_TARGET" ] || [ -e "$POTENTIAL_TARGET" ]; then
        echo -e "${ACCENT}ℹ Detected broken Git plain-text symlink. Converting to real symlink...${TEXT}"
        rm -f "$TARGET_PATH"
        ln -s "$POTENTIAL_TARGET" "$TARGET_PATH"
        echo -e "${PRIMARY}✔ Successfully restored symlink: $TARGET_PATH -> $POTENTIAL_TARGET${TEXT}"
        exit 0
    fi
fi

# Feature 2: Make the script globally accessible in ~/.local/bin
ABS_PATH=$(readlink -f "$TARGET_PATH")

if [ -d "$ABS_PATH" ]; then
    echo -e "${ERROR}✖ Error: Target is a directory, not an executable file.${TEXT}"
    exit 1
fi

echo -e "${ACCENT}ℹ Setting up global command link for '$ABS_PATH'...${TEXT}"

if [ ! -x "$ABS_PATH" ]; then
    echo -e "${MUTED}  Making file executable...${TEXT}"
    chmod +x "$ABS_PATH"
fi

BASENAME=$(basename "$ABS_PATH")
COMMAND_NAME="${BASENAME%.*}"

DEST_DIR="$HOME/.local/bin"
DEST_LINK="$DEST_DIR/$COMMAND_NAME"

mkdir -p "$DEST_DIR"

if [ -L "$DEST_LINK" ]; then
    echo -e "${MUTED}  Removing existing symlink at '$DEST_LINK'...${TEXT}"
    rm "$DEST_LINK"
elif [ -e "$DEST_LINK" ]; then
    echo -e "${ERROR}✖ Error: A regular file already exists at '$DEST_LINK'. Cannot create symlink.${TEXT}"
    exit 1
fi

ln -s "$ABS_PATH" "$DEST_LINK"

# Ensure ~/.local/bin is in PATH in bashrc/zshrc
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ]; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$rc"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
            echo -e "${MUTED}  Added $HOME/.local/bin to $rc${TEXT}"
        fi
    fi
done

echo -e "${PRIMARY}✔ Successfully linked '$ABS_PATH' to '$DEST_LINK'${TEXT}"
echo -e "${MUTED}You can now run '${SECONDARY}$COMMAND_NAME${MUTED}' globally from your terminal.${TEXT}"
