#!/bin/bash
# ==============================================================================
# scripts-fixer: Intelligent Archive Installer for Ubuntu / Linux
# Supported formats: .tar.gz, .tgz, .tar.xz, .tar.bz2, .tar.zst, .tar, .zip, .gz
# Sources: Local file path or remote HTTP / HTTPS URL
# ==============================================================================

set -eo pipefail

# ANSI color codes with fallback
PRIMARY='\033[1;32m'   # Bright LightGreen
SECONDARY='\033[1;36m' # Bright Cyan
ACCENT='\033[1;33m'    # Bright Yellow
MUTED='\033[0;37m'     # Bright Light Gray
ERROR='\033[1;31m'     # Bright Red
TEXT='\033[0m'         # Reset

map_color() {
    case "$1" in
        "Magenta") echo '\033[0;35m' ;;
        "Cyan") echo '\033[1;36m' ;;
        "Yellow") echo '\033[1;33m' ;;
        "Red") echo '\033[1;31m' ;;
        "Gray") echo '\033[0;37m' ;;
        "DarkGray") echo '\033[1;30m' ;;
        "LightBlue") echo '\033[1;34m' ;;
        "LightGreen") echo '\033[1;32m' ;;
        *) echo '' ;;
    esac
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

if [ -f "$ROOT_DIR/scripts/shared/theme.json" ]; then
    t_primary=$(grep -o '"primary": "[^"]*"' "$ROOT_DIR/scripts/shared/theme.json" | cut -d'"' -f4)
    t_secondary=$(grep -o '"secondary": "[^"]*"' "$ROOT_DIR/scripts/shared/theme.json" | cut -d'"' -f4)
    t_accent=$(grep -o '"accent": "[^"]*"' "$ROOT_DIR/scripts/shared/theme.json" | cut -d'"' -f4)
    t_muted=$(grep -o '"muted": "[^"]*"' "$ROOT_DIR/scripts/shared/theme.json" | cut -d'"' -f4)
    t_error=$(grep -o '"error": "[^"]*"' "$ROOT_DIR/scripts/shared/theme.json" | cut -d'"' -f4)

    [ -n "$t_primary" ] && val=$(map_color "$t_primary") && [ -n "$val" ] && PRIMARY=$val
    [ -n "$t_secondary" ] && val=$(map_color "$t_secondary") && [ -n "$val" ] && SECONDARY=$val
    [ -n "$t_accent" ] && val=$(map_color "$t_accent") && [ -n "$val" ] && ACCENT=$val
    [ -n "$t_muted" ] && val=$(map_color "$t_muted") && [ -n "$val" ] && MUTED=$val
    [ -n "$t_error" ] && val=$(map_color "$t_error") && [ -n "$val" ] && ERROR=$val
fi

show_help() {
    echo -e ""
    echo -e "  ${PRIMARY}Intelligent Archive Installer for Linux${TEXT}"
    echo -e "  ${MUTED}Supports: .tar.gz, .tgz, .tar.xz, .tar.bz2, .tar.zst, .tar, .zip, .gz${TEXT}"
    echo -e ""
    echo -e "  ${ACCENT}Usage:${TEXT}"
    echo -e "    ./run.sh install tar <path-or-url> [app-name]"
    echo -e "    ./run.sh install zip <path-or-url> [app-name]"
    echo -e "    ./run.sh install gz <path-or-url> [app-name]"
    echo -e "    ./run.sh install archive <path-or-url> [app-name]"
    echo -e "    ./run.sh install-tar <path-or-url> [app-name]"
    echo -e ""
    echo -e "  ${ACCENT}Examples:${TEXT}"
    echo -e "    ./run.sh install tar https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz"
    echo -e "    ./run.sh install zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    echo -e "    ./run.sh install tar ./ripgrep-14.1.0-x86_64-unknown-linux-musl.tar.gz"
    echo -e "    ./run.sh install tar ~/Downloads/Antigravity.tar.gz antigravity"
    echo -e ""
}

RAW_INPUT="$1"
CUSTOM_APP_NAME="$2"

if [ -z "$RAW_INPUT" ] || [[ "$RAW_INPUT" == "-h" ]] || [[ "$RAW_INPUT" == "--help" ]] || [[ "$RAW_INPUT" == "help" ]]; then
    show_help
    exit 0
fi

# Step 0: Strict Linux check
if [ "$(uname -s)" != "Linux" ]; then
    echo -e "  ${ERROR}[FAIL ] This installer is designed for Linux / Ubuntu systems only.${TEXT}"
    echo -e "  ${MUTED}Detected operating system: $(uname -s)${TEXT}"
    echo -e "  ${ACCENT}For Windows, please use run.ps1 or run inside WSL2.${TEXT}"
    exit 1
fi

# Trap cleanup
TMP_WORK_DIR=""
STAGE_DIR=""

cleanup() {
    if [ -n "$TMP_WORK_DIR" ] && [ -d "$TMP_WORK_DIR" ]; then
        rm -rf "$TMP_WORK_DIR" 2>/dev/null || true
    fi
    if [ -n "$STAGE_DIR" ] && [ -d "$STAGE_DIR" ]; then
        rm -rf "$STAGE_DIR" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

echo -e "\n  ${SECONDARY}[  ..  ] Intelligent Archive Installer (Ubuntu/Linux)${TEXT}"

# Step 1: Dependencies verification
echo -e "  ${MUTED}[step 1/10] Verifying environment & archive utilities...${TEXT}"
MISSING_TOOLS=()
for tool in tar gzip bzip2 xz unzip file; do
    if ! command -v "$tool" &>/dev/null; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo -e "  ${MUTED}  -> Installing missing utilities: ${MISSING_TOOLS[*]}...${TEXT}"
    if [ "$(id -u)" -eq 0 ]; then
        apt-get update -qq && apt-get install -y -qq "${MISSING_TOOLS[@]}" xz-utils 2>/dev/null || true
    elif command -v sudo &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y -qq "${MISSING_TOOLS[@]}" xz-utils 2>/dev/null || true
    else
        echo -e "  ${ERROR}[WARN ] Missing required tools: ${MISSING_TOOLS[*]}. Proceeding with available tools.${TEXT}"
    fi
fi

# Step 2: Source resolution
echo -e "  ${MUTED}[step 2/10] Resolving source target...${TEXT}"
ARCHIVE_PATH=""
ORIGINAL_FILENAME=""

if [[ "$RAW_INPUT" =~ ^https?:// ]] || [[ "$RAW_INPUT" =~ ^ftp:// ]]; then
    TMP_WORK_DIR=$(mktemp -d /tmp/archive-install-XXXXXX)
    # Extract filename from URL (stripping query string and fragment)
    URL_CLEAN="${RAW_INPUT%%\?*}"
    URL_CLEAN="${URL_CLEAN%%\#*}"
    URL_BASENAME="$(basename "$URL_CLEAN")"
    if [ -z "$URL_BASENAME" ] || [[ "$URL_BASENAME" == "/" ]]; then
        URL_BASENAME="download.archive"
    fi
    ORIGINAL_FILENAME="$URL_BASENAME"
    ARCHIVE_PATH="$TMP_WORK_DIR/$URL_BASENAME"

    echo -e "  ${MUTED}  -> Downloading from: ${SECONDARY}$RAW_INPUT${TEXT}"
    if command -v curl &>/dev/null; then
        curl -fSL --progress-bar "$RAW_INPUT" -o "$ARCHIVE_PATH"
    elif command -v wget &>/dev/null; then
        wget -q --show-progress "$RAW_INPUT" -O "$ARCHIVE_PATH"
    else
        echo -e "  ${ERROR}[FAIL ] Neither curl nor wget is installed.${TEXT}"
        exit 1
    fi

    if [ ! -f "$ARCHIVE_PATH" ] || [ ! -s "$ARCHIVE_PATH" ]; then
        echo -e "  ${ERROR}[FAIL ] Download failed or received empty payload.${TEXT}"
        exit 1
    fi

    DOWNLOAD_SIZE=$(stat -c%s "$ARCHIVE_PATH" 2>/dev/null || echo 0)
    if [ "$DOWNLOAD_SIZE" -lt 100 ]; then
        echo -e "  ${ERROR}[FAIL ] Downloaded file is too small ($DOWNLOAD_SIZE bytes). Likely an HTTP error page.${TEXT}"
        exit 1
    fi
else
    # Local file path
    EXPANDED_PATH="${RAW_INPUT/#\~/$HOME}"
    if [ ! -e "$EXPANDED_PATH" ]; then
        echo -e "  ${ERROR}[FAIL ] File not found: $RAW_INPUT${TEXT}"
        exit 1
    fi
    ARCHIVE_PATH="$(readlink -f "$EXPANDED_PATH" 2>/dev/null || realpath "$EXPANDED_PATH" 2>/dev/null || echo "$EXPANDED_PATH")"
    ORIGINAL_FILENAME="$(basename "$ARCHIVE_PATH")"
    if [ ! -r "$ARCHIVE_PATH" ]; then
        echo -e "  ${ERROR}[FAIL ] File is not readable: $ARCHIVE_PATH${TEXT}"
        exit 1
    fi
fi

# Step 3: Format detection
echo -e "  ${MUTED}[step 3/10] Detecting archive format & compression...${TEXT}"

detect_format() {
    local file="$1"
    local mime=""
    if command -v file &>/dev/null; then
        mime=$(file -b --mime-type "$file" 2>/dev/null || true)
    fi
    local fname="${ORIGINAL_FILENAME,,}" # lowercase

    if [[ "$mime" =~ gzip ]] || [[ "$fname" =~ \.(tar\.gz|tgz)$ ]]; then
        # Check if tarball or single gz
        if tar -ztf "$file" &>/dev/null; then
            echo "tar.gz"
        elif gzip -t "$file" &>/dev/null; then
            echo "gz-single"
        else
            echo "tar.gz"
        fi
    elif [[ "$mime" =~ (x-xz|xz) ]] || [[ "$fname" =~ \.(tar\.xz|txz)$ ]]; then
        echo "tar.xz"
    elif [[ "$mime" =~ (x-bzip2|bzip2) ]] || [[ "$fname" =~ \.(tar\.bz2|tbz2)$ ]]; then
        echo "tar.bz2"
    elif [[ "$mime" =~ (x-tar|tar) ]] || [[ "$fname" =~ \.tar$ ]]; then
        echo "tar"
    elif [[ "$mime" =~ zip ]] || [[ "$fname" =~ \.zip$ ]]; then
        echo "zip"
    elif [[ "$mime" =~ (zstd|x-zstd) ]] || [[ "$fname" =~ \.(tar\.zst|tzst)$ ]]; then
        echo "tar.zst"
    elif gzip -t "$file" &>/dev/null; then
        echo "gz-single"
    else
        echo "unknown"
    fi
}

FORMAT=$(detect_format "$ARCHIVE_PATH")
if [[ "$FORMAT" == "unknown" ]]; then
    # Final fallback attempt using file output
    file_info=$(file -b "$ARCHIVE_PATH" 2>/dev/null || true)
    if [[ "$file_info" =~ gzip ]]; then
        FORMAT="tar.gz"
    elif [[ "$file_info" =~ Zip ]]; then
        FORMAT="zip"
    elif [[ "$file_info" =~ XZ ]]; then
        FORMAT="tar.xz"
    elif [[ "$file_info" =~ bzip2 ]]; then
        FORMAT="tar.bz2"
    elif [[ "$file_info" =~ POSIX\ tar ]]; then
        FORMAT="tar"
    else
        echo -e "  ${ERROR}[FAIL ] Unrecognized archive format: $ORIGINAL_FILENAME${TEXT}"
        echo -e "  ${MUTED}File magic: $file_info${TEXT}"
        exit 1
    fi
fi
echo -e "  ${MUTED}  -> Format identified: ${PRIMARY}$FORMAT${TEXT} (${ORIGINAL_FILENAME})"

# Step 4: Derive application name
echo -e "  ${MUTED}[step 4/10] Deriving application name...${TEXT}"
derive_app_name() {
    if [ -n "$CUSTOM_APP_NAME" ]; then
        echo "$CUSTOM_APP_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9_-]+/-/g' | sed -E 's/^-+|-+$//g'
        return
    fi

    local name="$ORIGINAL_FILENAME"
    # 1. Strip extensions
    name=$(echo "$name" | sed -E 's/\.(tar\.gz|tar\.xz|tar\.bz2|tar\.zst|tgz|txz|tbz2|zip|gz)$//I')
    # 2. Strip linux platform tags
    name=$(echo "$name" | sed -E 's/[-_]linux[-_](x64|amd64|arm64|aarch64|x86_64|i386|all)//I')
    # 3. Strip arch suffixes
    name=$(echo "$name" | sed -E 's/[-_](x86_64|amd64|arm64|aarch64|i386|x64|linux-x64|linux-arm64)//I')
    # 4. Strip platform triples
    name=$(echo "$name" | sed -E 's/[-_](unknown-linux-musl|unknown-linux-gnu|pc-windows|darwin)//I')
    # 5. Strip version strings (e.g. -1.2.3, _v2.0, -2.13.0-6362815968182272)
    name=$(echo "$name" | sed -E 's/[-_]v?[0-9]+(\.[0-9]+)*([-_][0-9a-zA-Z]+)?//I')
    # 6. Strip build tags
    name=$(echo "$name" | sed -E 's/[-_](latest|stable|beta|release|dist|bin|cli|standalone)//I')
    # 7. Sanitize
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9_-]+/-/g' | sed -E 's/^-+|-+$//g')
    
    if [ -z "$name" ]; then
        name="installed-app"
    fi
    echo "$name"
}

APP_NAME=$(derive_app_name)
echo -e "  ${MUTED}  -> Target application name: ${PRIMARY}$APP_NAME${TEXT}"

# Step 5: Isolated staging extraction
echo -e "  ${MUTED}[step 5/10] Extracting archive into isolated staging area...${TEXT}"
STAGE_DIR=$(mktemp -d /tmp/archive-stage-XXXXXX)

case "$FORMAT" in
    "tar.gz")
        tar -xzf "$ARCHIVE_PATH" -C "$STAGE_DIR"
        ;;
    "tar.xz")
        tar -xJf "$ARCHIVE_PATH" -C "$STAGE_DIR" || tar -xf "$ARCHIVE_PATH" -C "$STAGE_DIR"
        ;;
    "tar.bz2")
        tar -xjf "$ARCHIVE_PATH" -C "$STAGE_DIR"
        ;;
    "tar")
        tar -xf "$ARCHIVE_PATH" -C "$STAGE_DIR"
        ;;
    "tar.zst")
        tar --zstd -xf "$ARCHIVE_PATH" -C "$STAGE_DIR" || tar -xf "$ARCHIVE_PATH" -C "$STAGE_DIR"
        ;;
    "zip")
        if command -v unzip &>/dev/null; then
            unzip -q -o "$ARCHIVE_PATH" -d "$STAGE_DIR"
        else
            python3 -m zipfile -e "$ARCHIVE_PATH" "$STAGE_DIR"
        fi
        ;;
    "gz-single")
        mkdir -p "$STAGE_DIR"
        gzip -dc "$ARCHIVE_PATH" > "$STAGE_DIR/$APP_NAME"
        chmod +x "$STAGE_DIR/$APP_NAME"
        ;;
    *)
        echo -e "  ${ERROR}[FAIL ] Cannot extract unsupported format: $FORMAT${TEXT}"
        exit 1
        ;;
esac

# Step 6: Layout inspection & atomic transfer
echo -e "  ${MUTED}[step 6/10] Inspecting structure & transferring to target directory...${TEXT}"
APP_SOURCE_ROOT="$STAGE_DIR"

# Check if there is only 1 top-level subdirectory inside the archive
ENTRY_COUNT=$(find "$STAGE_DIR" -mindepth 1 -maxdepth 1 | wc -l)
if [ "$ENTRY_COUNT" -eq 1 ]; then
    SINGLE_ENTRY=$(find "$STAGE_DIR" -mindepth 1 -maxdepth 1)
    if [ -d "$SINGLE_ENTRY" ]; then
        echo -e "  ${MUTED}  -> Detected nested root folder: $(basename "$SINGLE_ENTRY") (normalizing layout)${TEXT}"
        APP_SOURCE_ROOT="$SINGLE_ENTRY"
    fi
fi

TARGET_DIR="$HOME/.local/share/$APP_NAME"
mkdir -p "$HOME/.local/share"
if [ -d "$TARGET_DIR" ]; then
    echo -e "  ${MUTED}  -> Replacing previous installation at: $TARGET_DIR${TEXT}"
    rm -rf "$TARGET_DIR"
fi
mkdir -p "$TARGET_DIR"
cp -a "$APP_SOURCE_ROOT/." "$TARGET_DIR/"

# Step 7: Binary discovery & permissions
echo -e "  ${MUTED}[step 7/10] Discovering executables & configuring permissions...${TEXT}"
MAIN_BIN=""

# Candidate 1: $TARGET_DIR/bin/$APP_NAME
if [ -f "$TARGET_DIR/bin/$APP_NAME" ]; then
    MAIN_BIN="$TARGET_DIR/bin/$APP_NAME"
# Candidate 2: $TARGET_DIR/$APP_NAME
elif [ -f "$TARGET_DIR/$APP_NAME" ]; then
    MAIN_BIN="$TARGET_DIR/$APP_NAME"
# Candidate 3: In bin directory matching app name without punctuation
elif [ -d "$TARGET_DIR/bin" ]; then
    FOUND_IN_BIN=$(find "$TARGET_DIR/bin" -maxdepth 1 -type f -iname "*$APP_NAME*" | head -n 1)
    if [ -n "$FOUND_IN_BIN" ]; then
        MAIN_BIN="$FOUND_IN_BIN"
    else
        # Any file in bin/
        FIRST_BIN=$(find "$TARGET_DIR/bin" -maxdepth 1 -type f | head -n 1)
        if [ -n "$FIRST_BIN" ]; then
            MAIN_BIN="$FIRST_BIN"
        fi
    fi
fi

# Candidate 4: In root directory matching app name (case-insensitive)
if [ -z "$MAIN_BIN" ]; then
    ROOT_MATCH=$(find "$TARGET_DIR" -maxdepth 1 -type f -iname "*$APP_NAME*" | head -n 1)
    if [ -n "$ROOT_MATCH" ]; then
        MAIN_BIN="$ROOT_MATCH"
    fi
fi

# Candidate 5: ELF executable in target directory
if [ -z "$MAIN_BIN" ] && command -v file &>/dev/null; then
    ELF_BIN=$(find "$TARGET_DIR" -maxdepth 2 -type f -exec file {} + 2>/dev/null | grep -E 'ELF.*executable' | awk -F: '{print $1}' | head -n 1 || true)
    if [ -n "$ELF_BIN" ]; then
        MAIN_BIN="$ELF_BIN"
    fi
fi

# Candidate 6: Any executable script (e.g. bash or python script)
if [ -z "$MAIN_BIN" ]; then
    SCRIPT_BIN=$(find "$TARGET_DIR" -maxdepth 2 -type f -exec grep -l '^#!/' {} + 2>/dev/null | head -n 1 || true)
    if [ -n "$SCRIPT_BIN" ]; then
        MAIN_BIN="$SCRIPT_BIN"
    fi
fi

if [ -z "$MAIN_BIN" ]; then
    echo -e "  ${ERROR}[FAIL ] Could not locate primary executable in archive contents.${TEXT}"
    echo -e "  ${MUTED}Contents extracted into: $TARGET_DIR${TEXT}"
    exit 1
fi

chmod +x "$MAIN_BIN"
if [ -d "$TARGET_DIR/bin" ]; then
    chmod +x "$TARGET_DIR/bin"/* 2>/dev/null || true
fi

echo -e "  ${MUTED}  -> Primary executable: ${PRIMARY}$MAIN_BIN${TEXT}"

# Electron chrome-sandbox permission handling
if [ -f "$TARGET_DIR/chrome-sandbox" ]; then
    echo -e "  ${MUTED}  -> Configuring Electron chrome-sandbox permissions...${TEXT}"
    if [ "$(id -u)" -eq 0 ]; then
        chown root:root "$TARGET_DIR/chrome-sandbox" 2>/dev/null || true
        chmod 4755 "$TARGET_DIR/chrome-sandbox" 2>/dev/null || chmod +x "$TARGET_DIR/chrome-sandbox"
    elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
        sudo chown root:root "$TARGET_DIR/chrome-sandbox" 2>/dev/null || true
        sudo chmod 4755 "$TARGET_DIR/chrome-sandbox" 2>/dev/null || chmod +x "$TARGET_DIR/chrome-sandbox"
    else
        chmod +x "$TARGET_DIR/chrome-sandbox" 2>/dev/null || true
    fi
fi

# Library path wrapper if internal lib directory exists
BIN_EXEC_TARGET="$MAIN_BIN"
if [ -d "$TARGET_DIR/lib" ] && [ -f "$MAIN_BIN" ]; then
    WRAPPER_PATH="$TARGET_DIR/${APP_NAME}.run"
    cat <<EOF > "$WRAPPER_PATH"
#!/bin/bash
DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
export LD_LIBRARY_PATH="\$DIR/lib:\$LD_LIBRARY_PATH"
exec "\$DIR/$(basename "$MAIN_BIN")" "\$@"
EOF
    chmod +x "$WRAPPER_PATH"
    BIN_EXEC_TARGET="$WRAPPER_PATH"
fi

# Step 8: Symlink to user and system PATH
echo -e "  ${MUTED}[step 8/10] Linking binaries to system and user PATH...${TEXT}"
mkdir -p "$HOME/.local/bin"
USER_LINK="$HOME/.local/bin/$APP_NAME"
ln -sf "$BIN_EXEC_TARGET" "$USER_LINK"
echo -e "  ${MUTED}  -> User symlink created: ${SECONDARY}$USER_LINK${TEXT}"

# Also link real binary basename if different from APP_NAME
REAL_BASENAME="$(basename "$MAIN_BIN")"
if [ "$REAL_BASENAME" != "$APP_NAME" ] && [ "$REAL_BASENAME" != "${APP_NAME}.run" ]; then
    ln -sf "$BIN_EXEC_TARGET" "$HOME/.local/bin/$REAL_BASENAME"
fi

# System symlink if writable or sudo
SYS_LINK="/usr/local/bin/$APP_NAME"
if [ -w "/usr/local/bin" ]; then
    ln -sf "$BIN_EXEC_TARGET" "$SYS_LINK" 2>/dev/null || true
    echo -e "  ${MUTED}  -> System symlink created: ${SECONDARY}$SYS_LINK${TEXT}"
elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
    sudo ln -sf "$BIN_EXEC_TARGET" "$SYS_LINK" 2>/dev/null || true
    echo -e "  ${MUTED}  -> System symlink created (sudo): ${SECONDARY}$SYS_LINK${TEXT}"
fi

# Step 9: Desktop launcher & icons
echo -e "  ${MUTED}[step 9/10] Evaluating Desktop integration & UI launchers...${TEXT}"
IS_GUI=false
ICON_FILE=""

# Check for GUI traits
if [ -f "$TARGET_DIR/resources/app.asar" ] || [ -d "$TARGET_DIR/resources/app" ] || [ -f "$TARGET_DIR/chrome-sandbox" ]; then
    IS_GUI=true
fi
if find "$TARGET_DIR" -maxdepth 2 -name "*.desktop" 2>/dev/null | grep -q .; then
    IS_GUI=true
fi
if find "$TARGET_DIR" -maxdepth 2 -name "libQt*" -o -name "libgtk*" 2>/dev/null | grep -q .; then
    IS_GUI=true
fi

# Find icon
ICON_CANDIDATE=$(find "$TARGET_DIR" -maxdepth 3 \( -name "*.png" -o -name "*.svg" \) 2>/dev/null | grep -iE 'icon|logo|app' | head -n 1 || true)
if [ -z "$ICON_CANDIDATE" ]; then
    ICON_CANDIDATE=$(find "$TARGET_DIR" -maxdepth 3 \( -name "*.png" -o -name "*.svg" \) 2>/dev/null | head -n 1 || true)
fi

if [ -n "$ICON_CANDIDATE" ]; then
    mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
    ICON_DEST="$HOME/.local/share/icons/hicolor/256x256/apps/${APP_NAME}.png"
    cp -f "$ICON_CANDIDATE" "$ICON_DEST" 2>/dev/null || true
    ICON_FILE="$ICON_DEST"
fi

if [ "$IS_GUI" = true ]; then
    DESKTOP_DIR="$HOME/.local/share/applications"
    mkdir -p "$DESKTOP_DIR"
    DESKTOP_FILE="$DESKTOP_DIR/${APP_NAME}.desktop"

    FORMATTED_NAME=$(echo "$APP_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Type=Application
Name=$FORMATTED_NAME
Comment=$FORMATTED_NAME installed via scripts-fixer
Exec=$BIN_EXEC_TARGET %U
Icon=${ICON_FILE:-$APP_NAME}
Terminal=false
StartupNotify=true
StartupWMClass=$APP_NAME
Categories=Utility;Development;
EOF
    chmod +x "$DESKTOP_FILE"
    echo -e "  ${MUTED}  -> Desktop launcher created: ${SECONDARY}$DESKTOP_FILE${TEXT}"

    # If ~/Desktop exists, copy launcher
    if [ -d "$HOME/Desktop" ]; then
        cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
        chmod +x "$HOME/Desktop/$(basename "$DESKTOP_FILE")" 2>/dev/null || true
        if command -v gio &>/dev/null; then
            gio set "$HOME/Desktop/$(basename "$DESKTOP_FILE")" metadata::trusted true 2>/dev/null || true
        fi
    fi

    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
    fi
else
    echo -e "  ${MUTED}  -> CLI utility detected (no GUI desktop entry required)${TEXT}"
fi

# Step 10: PATH configuration & verification
echo -e "  ${MUTED}[step 10/10] Verifying installation & shell PATH...${TEXT}"

PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -f "$rc" ]; then
        if ! grep -q '\.local/bin' "$rc" 2>/dev/null; then
            echo "$PATH_LINE" >> "$rc"
            echo -e "  ${MUTED}  -> Injected ~/.local/bin to: $rc${TEXT}"
        fi
    fi
done
export PATH="$HOME/.local/bin:$PATH"

# Verification smoke test
if [ ! -f "$MAIN_BIN" ]; then
    echo -e "  ${ERROR}[FAIL ] Installation verification failed: binary missing.${TEXT}"
    exit 1
fi

if [ ! -x "$MAIN_BIN" ]; then
    echo -e "  ${ERROR}[FAIL ] Installation verification failed: binary not executable.${TEXT}"
    exit 1
fi

VERSION_OUT=""
if [ -x "$MAIN_BIN" ]; then
    # Test version output with 3 second timeout
    VERSION_OUT=$(timeout 3 "$BIN_EXEC_TARGET" --version 2>/dev/null || timeout 3 "$BIN_EXEC_TARGET" -v 2>/dev/null || timeout 3 "$BIN_EXEC_TARGET" -V 2>/dev/null || echo "")
    VERSION_OUT=$(echo "$VERSION_OUT" | head -n 1 | tr -d '\r\n')
fi

TOTAL_SIZE=$(du -sh "$TARGET_DIR" 2>/dev/null | awk '{print $1}' || echo "unknown")

echo -e "  ${PRIMARY}[  OK  ] Installation verified successfully.${TEXT}"
if [ -n "$VERSION_OUT" ]; then
    echo -e "  ${MUTED}  -> Version: ${SECONDARY}$VERSION_OUT${TEXT}"
fi

echo -e ""
echo -e "  ${ACCENT}==================================================${TEXT}"
echo -e "  ${PRIMARY}Archive Installation Complete:${TEXT}"
echo -e "    ${SECONDARY}✔${TEXT} Application  : ${PRIMARY}$APP_NAME${TEXT}"
echo -e "    ${SECONDARY}✔${TEXT} Location     : $TARGET_DIR ($TOTAL_SIZE)"
echo -e "    ${SECONDARY}✔${TEXT} Executable   : $MAIN_BIN"
echo -e "    ${SECONDARY}✔${TEXT} User Command : ~/.local/bin/$APP_NAME"
if [ -f "$SYS_LINK" ]; then
    echo -e "    ${SECONDARY}✔${TEXT} System Link  : $SYS_LINK"
fi
if [ "$IS_GUI" = true ] && [ -f "$DESKTOP_FILE" ]; then
    echo -e "    ${SECONDARY}✔${TEXT} Desktop Entry: $DESKTOP_FILE"
fi
echo -e "  ${ACCENT}==================================================${TEXT}"

# Log to install database if python is available
if [ -f "$ROOT_DIR/scripts/shared/logger.py" ]; then
    python3 "$ROOT_DIR/scripts/shared/logger.py" "archive:$APP_NAME" 2>/dev/null || true
fi

exit 0
