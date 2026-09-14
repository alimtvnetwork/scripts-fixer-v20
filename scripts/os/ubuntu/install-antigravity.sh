#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
ACCENT='\033[1;33m'
MUTED='\033[0;37m'
ERROR='\033[1;31m'
TEXT='\033[0m'

IS_FORCE=false
for arg in "$@"; do
    if [ "$arg" = "--force" ] || [ "$arg" = "-f" ] || [ "$arg" = "force" ]; then
        IS_FORCE=true
        break
    fi
done
if [ "${FORCE:-0}" = "1" ] || [ "${IS_FORCE_INSTALL:-false}" = "true" ]; then
    IS_FORCE=true
fi

detect_arch() {
    local raw
    raw=$(uname -m)
    case "$raw" in
        x86_64|amd64) echo "x64" ;;
        aarch64|arm64) echo "arm64" ;;
        *) echo "x64" ;;
    esac
}

ensure_prereqs() {
    local pkgs=(curl tar libnss3 libgbm1 libasound2 libsecret-1-0)
    local missing=()
    for p in "${pkgs[@]}"; do
        if ! dpkg -s "$p" &>/dev/null && ! command -v "$p" &>/dev/null; then
            missing+=("$p")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "  ${MUTED}[step 1/5] Installing dependencies (${missing[*]})...${TEXT}"
        if [ "$(id -u)" -eq 0 ]; then
            apt-get update -qq && apt-get install -y -qq "${missing[@]}" 2>/dev/null || true
        elif command -v sudo &>/dev/null; then
            sudo apt-get update -qq && sudo apt-get install -y -qq "${missing[@]}" 2>/dev/null || true
        fi
    fi
}

fetch_ide_url() {
    local arch="$1"
    if [ "$arch" = "arm64" ] || [ "$arch" = "arm" ] || [ "$arch" = "aarch64" ]; then
        echo "https://storage.googleapis.com/antigravity-public/antigravity-hub/2.13.0-6362815968182272/linux-arm/Antigravity.tar.gz"
    else
        echo "https://storage.googleapis.com/antigravity-public/antigravity-hub/2.13.0-6362815968182272/linux-x64/Antigravity.tar.gz"
    fi
}

clean_existing_installation() {
    echo -e "  ${ACCENT}[FORCE] Wiping previous Antigravity installations for clean re-install...${TEXT}"
    rm -rf "$HOME/.local/share/antigravity" "$HOME/.local/share/antigravity-ide" "$HOME/.antigravity"
    rm -f "$HOME/.local/bin/antigravity" "$HOME/.local/bin/agy"

    if command -v sudo &>/dev/null; then
        sudo rm -f /usr/local/bin/antigravity /usr/local/bin/agy /usr/bin/antigravity /usr/bin/agy 2>/dev/null || true
    fi
}

install_ide_fallback() {
    local arch="$1"
    local ide_url
    ide_url=$(fetch_ide_url "$arch")
    local ide_dir="$HOME/.local/share/antigravity"
    local tmp_archive
    tmp_archive=$(mktemp /tmp/antigravity-XXXXXX.tar.gz)
    local staging
    staging=$(mktemp -d /tmp/antigravity-extract-XXXXXX)

    mkdir -p "$ide_dir"
    echo -e "  ${MUTED}[step 2/5] Downloading Google Antigravity ($arch)...${TEXT}"
    curl -fL --retry 2 --connect-timeout 30 "$ide_url" -o "$tmp_archive"
    tar -xzf "$tmp_archive" -C "$staging"
    rm -f "$tmp_archive"

    local root="$staging"
    if [ -d "$staging/Antigravity-x64" ]; then
        root="$staging/Antigravity-x64"
    fi

    cp -a "$root"/* "$ide_dir/" 2>/dev/null || cp -a "$root"/. "$ide_dir/" 2>/dev/null || true
    rm -rf "$staging"
}

create_runtime_wrapper() {
    local ide_dir="$HOME/.local/share/antigravity"
    local exec_bin="$ide_dir/antigravity"
    [ -f "$exec_bin" ] || exec_bin="$ide_dir/Antigravity"
    [ -f "$exec_bin" ] || return 0

    chmod +x "$exec_bin"
    if [ -f "$ide_dir/chrome-sandbox" ]; then
        chmod 4755 "$ide_dir/chrome-sandbox" 2>/dev/null || chmod +x "$ide_dir/chrome-sandbox" 2>/dev/null || true
    fi

    local wrapper="$ide_dir/antigravity-runner.sh"
    cat <<'EOF' > "$wrapper"
#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LD_LIBRARY_PATH="$DIR:$DIR/lib:${LD_LIBRARY_PATH:-}"
EXEC="$DIR/antigravity"
[ -f "$EXEC" ] || EXEC="$DIR/Antigravity"

if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
    exec "$EXEC" --no-sandbox "$@"
else
    exec "$EXEC" "$@"
fi
EOF
    chmod +x "$wrapper"

    # Link wrapper to PATH
    mkdir -p "$HOME/.local/bin"
    ln -sf "$wrapper" "$HOME/.local/bin/antigravity"
    ln -sf "$wrapper" "$HOME/.local/bin/agy"

    if [ -w "/usr/local/bin" ]; then
        ln -sf "$wrapper" "/usr/local/bin/antigravity" 2>/dev/null || true
        ln -sf "$wrapper" "/usr/local/bin/agy" 2>/dev/null || true
    elif command -v sudo &>/dev/null; then
        sudo ln -sf "$wrapper" "/usr/local/bin/antigravity" 2>/dev/null || true
        sudo ln -sf "$wrapper" "/usr/local/bin/agy" 2>/dev/null || true
        sudo ln -sf "$wrapper" "/usr/bin/antigravity" 2>/dev/null || true
        sudo ln -sf "$wrapper" "/usr/bin/agy" 2>/dev/null || true
    fi
}

configure_shell_profiles() {
    local line='export PATH="$HOME/.local/bin:$HOME/.antigravity/bin:$HOME/.local/share/antigravity:$PATH"'
    for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        if [ -f "$rc" ]; then
            if ! grep -q ".local/bin" "$rc" 2>/dev/null; then
                echo "$line" >> "$rc"
                echo -e "  ${MUTED}  -> Added Antigravity PATH to $rc${TEXT}"
            fi
        fi
    done
}

create_desktop_launcher() {
    local ide_dir="$HOME/.local/share/antigravity"
    local app_dir="$HOME/.local/share/applications"
    local desktop_path="$app_dir/antigravity.desktop"
    local exec_cmd="$ide_dir/antigravity-runner.sh"
    [ -f "$exec_cmd" ] || exec_cmd="$ide_dir/antigravity"

    local icon_path
    icon_path=$(find "$ide_dir" -maxdepth 4 -type f \( -name "antigravity.png" -o -name "code.png" -o -name "icon.png" \) 2>/dev/null | head -n 1 || true)
    [ -z "$icon_path" ] && icon_path="antigravity"

    mkdir -p "$app_dir"
    cat <<EOF > "$desktop_path"
[Desktop Entry]
Name=Google Antigravity
Comment=Google Antigravity IDE & AI Coding Assistant
GenericName=Text Editor
Exec="$exec_cmd" %F
Icon=$icon_path
Type=Application
StartupNotify=true
StartupWMClass=Antigravity
Categories=Development;IDE;TextEditor;
MimeType=text/plain;inode/directory;
Terminal=false
EOF
    chmod +x "$desktop_path"

    if [ -w "/usr/share/applications" ]; then
        cp -f "$desktop_path" "/usr/share/applications/antigravity.desktop" 2>/dev/null || true
    elif command -v sudo &>/dev/null; then
        sudo cp -f "$desktop_path" "/usr/share/applications/antigravity.desktop" 2>/dev/null || true
    fi

    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$app_dir" 2>/dev/null || true
    fi
}

verify_antigravity() {
    export PATH="$HOME/.local/bin:$HOME/.antigravity/bin:/usr/local/bin:/usr/bin:$PATH"
    local bin_path=""

    for b in \
        "/usr/local/bin/antigravity" \
        "$HOME/.local/bin/antigravity" \
        "/usr/bin/antigravity" \
        "/usr/local/bin/agy" \
        "$HOME/.local/bin/agy" \
        "/usr/bin/agy" \
        "$HOME/.local/share/antigravity/antigravity-runner.sh" \
        "$HOME/.local/share/antigravity/antigravity" \
        "$HOME/.local/share/antigravity/Antigravity"; do
        if [ -f "$b" ] && [ -x "$b" ]; then
            bin_path="$b"
            break
        fi
    done

    if [ -z "$bin_path" ]; then
        echo -e "  ${ERROR}[FAIL] Antigravity binary not found or not executable.${TEXT}"
        return 1
    fi

    echo -e "  ${PRIMARY}[  OK  ] Antigravity verified at $bin_path${TEXT}"
    return 0
}

main() {
    echo -e "\n  ${SECONDARY}[  ..  ] Installing Google Antigravity IDE & CLI...${TEXT}"

    if [ "$IS_FORCE" = "true" ]; then
        clean_existing_installation
    elif command -v antigravity &>/dev/null && [ -x "$HOME/.local/share/antigravity/antigravity" ]; then
        echo -e "  ${PRIMARY}[  OK  ] Google Antigravity is already installed (use --force to reinstall).${TEXT}"
        return 0
    fi

    ensure_prereqs

    local arch
    arch=$(detect_arch)
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local archive_installer="$script_dir/install-archive.sh"

    if [ -f "$archive_installer" ]; then
        local ide_url
        ide_url=$(fetch_ide_url "$arch")
        bash "$archive_installer" "$ide_url" "antigravity"
    else
        install_ide_fallback "$arch"
        create_runtime_wrapper
        configure_shell_profiles
        echo -e "  ${MUTED}[step 4/5] Setting up desktop application launcher...${TEXT}"
        create_desktop_launcher
        echo -e "  ${MUTED}[step 5/5] Verifying Antigravity installation...${TEXT}"

        if ! verify_antigravity; then
            echo -e "  ${ERROR}[FAIL ] Antigravity installation verification failed.${TEXT}"
            exit 1
        fi
    fi

    echo -e "\n  ${PRIMARY}[DONE ] Google Antigravity IDE & CLI setup complete.${TEXT}"
    echo -e "  ${MUTED}  Usage: antigravity \"your task\" or agy \"your task\"${TEXT}"
    echo -e "  ${MUTED}  Docs : https://antigravity.dev/docs${TEXT}\n"
}

main "$@"
