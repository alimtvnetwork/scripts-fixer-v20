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
    local pkgs=(curl tar aria2 libnss3 libgbm1 libasound2 libsecret-1-0)
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
        return
    fi

    echo "https://storage.googleapis.com/antigravity-public/antigravity-hub/2.13.0-6362815968182272/linux-x64/Antigravity.tar.gz"
}

clean_existing_installation() {
    echo -e "  ${ACCENT}[FORCE] Wiping previous Antigravity installations for clean re-install...${TEXT}"
    rm -rf "$HOME/.local/share/antigravity" "$HOME/.local/share/antigravity-ide" "$HOME/.antigravity"
    rm -f "$HOME/.local/bin/antigravity" "$HOME/.local/bin/agy" "$HOME/.local/bin/antigravity-ide"
    rm -f "/tmp/scripts-fixer-downloads/Antigravity.tar.gz" "/tmp/Antigravity.tar.gz"

    rm -f "$HOME/.local/share/applications/antigravity.desktop" \
          "$HOME/.local/share/applications/antigravity-ide.desktop" \
          "$HOME/.local/share/applications/Google Antigravity.desktop" \
          "$HOME/Desktop/antigravity.desktop" \
          "$HOME/Desktop/antigravity-ide.desktop"

    if command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
        sudo rm -f /usr/share/applications/antigravity.desktop \
                   /usr/share/applications/antigravity-ide.desktop 2>/dev/null || true
    fi

    if command -v sudo &>/dev/null; then
        sudo rm -f /usr/local/bin/antigravity /usr/local/bin/agy /usr/local/bin/antigravity-ide \
                   /usr/bin/antigravity /usr/bin/agy /usr/bin/antigravity-ide 2>/dev/null || true
    fi
}

find_cached_download() {
    local candidates=(
        "/tmp/scripts-fixer-downloads/Antigravity.tar.gz"
        "/tmp/Antigravity.tar.gz"
        "$HOME/Downloads/Antigravity.tar.gz"
    )

    for c in "${candidates[@]}"; do
        if [ -f "$c" ] && [ -s "$c" ]; then
            local sz
            sz=$(stat -c%s "$c" 2>/dev/null || echo 0)

            if [ "$sz" -gt 50000000 ] && gzip -t "$c" &>/dev/null; then
                echo "$c"
                return 0
            fi
        fi
    done

    return 1
}

download_with_aria2c() {
    local url="$1"
    local dest="$2"
    local dest_dir
    dest_dir=$(dirname "$dest")
    mkdir -p "$dest_dir"
    local dest_name
    dest_name=$(basename "$dest")
    rm -f "$dest" "${dest}.aria2" 2>/dev/null || true

    if command -v aria2c &>/dev/null; then
        echo -e "  ${MUTED}[step 2/5] Downloading Google Antigravity via aria2c (16 parallel connections)...${TEXT}"
        aria2c -x 16 -s 16 -j 4 -k 1M --file-allocation=none --continue=true \
               --summary-interval=2 -d "$dest_dir" -o "$dest_name" "$url" && return 0
        echo -e "  ${MUTED}  -> aria2c failed, falling back to curl...${TEXT}"
    fi

    echo -e "  ${MUTED}[step 2/5] Downloading Google Antigravity via curl...${TEXT}"
    curl -fL --retry 2 --connect-timeout 30 "$url" -o "$dest"
}

install_ide_fallback() {
    local archive_path="$1"
    local ide_dir="$HOME/.local/share/antigravity-ide"
    local staging
    staging=$(mktemp -d /tmp/antigravity-extract-XXXXXX)

    mkdir -p "$ide_dir"
    echo -e "  ${MUTED}[step 3/5] Extracting archive into $ide_dir...${TEXT}"
    tar -xzf "$archive_path" -C "$staging"

    local root="$staging"

    if [ -d "$staging/Antigravity-x64" ]; then
        root="$staging/Antigravity-x64"
    elif [ -d "$staging/antigravity" ]; then
        root="$staging/antigravity"
    fi

    cp -a "$root"/* "$ide_dir/" 2>/dev/null || cp -a "$root"/. "$ide_dir/" 2>/dev/null || true
    rm -rf "$staging"
    ln -sfn "$ide_dir" "$HOME/.local/share/antigravity" 2>/dev/null || true
}

create_runtime_wrapper() {
    local ide_dir="$HOME/.local/share/antigravity-ide"
    [ -d "$ide_dir" ] || ide_dir="$HOME/.local/share/antigravity"
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

export ELECTRON_OZONE_PLATFORM_HINT="auto"
export DONT_PROMPT_WSL_INSTALL=1

# Always pass --no-sandbox for tarball Electron builds on modern Linux (AppArmor userns restriction)
exec "$EXEC" --no-sandbox "$@"
EOF
    chmod +x "$wrapper"
    ln -sf "$wrapper" "$ide_dir/antigravity.run" 2>/dev/null || true
    ln -sf "$wrapper" "$ide_dir/antigravity-ide.run" 2>/dev/null || true

    mkdir -p "$HOME/.local/bin"
    ln -sf "$wrapper" "$HOME/.local/bin/antigravity"
    ln -sf "$wrapper" "$HOME/.local/bin/agy"
    ln -sf "$wrapper" "$HOME/.local/bin/antigravity-ide"

    if [ -w "/usr/local/bin" ]; then
        ln -sf "$wrapper" "/usr/local/bin/antigravity" 2>/dev/null || true
        ln -sf "$wrapper" "/usr/local/bin/agy" 2>/dev/null || true
        ln -sf "$wrapper" "/usr/local/bin/antigravity-ide" 2>/dev/null || true
    elif command -v sudo &>/dev/null; then
        sudo ln -sf "$wrapper" "/usr/local/bin/antigravity" 2>/dev/null || true
        sudo ln -sf "$wrapper" "/usr/local/bin/agy" 2>/dev/null || true
        sudo ln -sf "$wrapper" "/usr/local/bin/antigravity-ide" 2>/dev/null || true
        sudo ln -sf "$wrapper" "/usr/bin/antigravity" 2>/dev/null || true
        sudo ln -sf "$wrapper" "/usr/bin/agy" 2>/dev/null || true
        sudo ln -sf "$wrapper" "/usr/bin/antigravity-ide" 2>/dev/null || true
    fi
}

configure_shell_profiles() {
    local line='export PATH="$HOME/.local/bin:$HOME/.antigravity/bin:$HOME/.local/share/antigravity-ide:$HOME/.local/share/antigravity:$PATH"'

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
    local ide_dir="$HOME/.local/share/antigravity-ide"
    [ -d "$ide_dir" ] || ide_dir="$HOME/.local/share/antigravity"
    local app_dir="$HOME/.local/share/applications"
    local desktop_path="$app_dir/antigravity.desktop"
    local exec_cmd="$ide_dir/antigravity-runner.sh"
    [ -f "$exec_cmd" ] || exec_cmd="$ide_dir/antigravity.run"
    [ -f "$exec_cmd" ] || exec_cmd="$ide_dir/antigravity-ide.run"
    [ -f "$exec_cmd" ] || exec_cmd="$ide_dir/antigravity"

    # Purge old conflicting launchers
    rm -f "$app_dir/antigravity-ide.desktop" "$app_dir/Google Antigravity.desktop"
    rm -f "$HOME/Desktop/antigravity-ide.desktop"
    if [ -w "/usr/share/applications" ]; then
        rm -f "/usr/share/applications/antigravity-ide.desktop" 2>/dev/null || true
    elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
        sudo rm -f "/usr/share/applications/antigravity-ide.desktop" 2>/dev/null || true
    fi

    local icon_path
    icon_path=$(find "$ide_dir" -maxdepth 8 -type f \( -iname "*antigravity*.png" -o -iname "*code*.png" -o -iname "*icon*.png" -o -iname "*logo*.png" \) 2>/dev/null | head -n 1 || true)
    if [ -z "$icon_path" ]; then
        for sys_icon in \
            "$HOME/.local/share/icons/hicolor/512x512/apps/antigravity.png" \
            "$HOME/.local/share/icons/hicolor/256x256/apps/antigravity.png" \
            "/usr/share/pixmaps/antigravity.png" \
            "/usr/share/icons/hicolor/256x256/apps/antigravity.png"; do
            if [ -f "$sys_icon" ]; then
                icon_path="$sys_icon"
                break
            fi
        done
    fi

    if [ -n "$icon_path" ]; then
        mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
        mkdir -p "$HOME/.local/share/icons/hicolor/512x512/apps"
        mkdir -p "$HOME/.local/share/pixmaps"
        cp -f "$icon_path" "$HOME/.local/share/icons/hicolor/256x256/apps/antigravity.png" 2>/dev/null || true
        cp -f "$icon_path" "$HOME/.local/share/icons/hicolor/256x256/apps/antigravity-ide.png" 2>/dev/null || true
        cp -f "$icon_path" "$HOME/.local/share/pixmaps/antigravity.png" 2>/dev/null || true
        cp -f "$icon_path" "$HOME/.local/share/pixmaps/antigravity-ide.png" 2>/dev/null || true
        if [ -w "/usr/share/pixmaps" ]; then
            cp -f "$icon_path" "/usr/share/pixmaps/antigravity.png" 2>/dev/null || true
        elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
            sudo cp -f "$icon_path" "/usr/share/pixmaps/antigravity.png" 2>/dev/null || true
        fi
        icon_path="$HOME/.local/share/icons/hicolor/256x256/apps/antigravity.png"
    fi
    [ -z "$icon_path" ] && icon_path="antigravity"

    mkdir -p "$app_dir"
    cat <<EOF > "$desktop_path"
[Desktop Entry]
Version=1.0
Name=Google Antigravity
Comment=Google Antigravity IDE & AI Coding Assistant
GenericName=Text Editor
Exec=$exec_cmd %F
Icon=$icon_path
Type=Application
StartupNotify=true
StartupWMClass=Antigravity
Categories=Development;IDE;TextEditor;
MimeType=text/plain;inode/directory;
Terminal=false
EOF
    chmod +x "$desktop_path"
    ln -sf "$desktop_path" "$app_dir/antigravity-ide.desktop" 2>/dev/null || true

    if [ -w "/usr/share/applications" ]; then
        cp -f "$desktop_path" "/usr/share/applications/antigravity.desktop" 2>/dev/null || true
    elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
        sudo cp -f "$desktop_path" "/usr/share/applications/antigravity.desktop" 2>/dev/null || true
    fi

    if [ -d "$HOME/Desktop" ]; then
        cp -f "$desktop_path" "$HOME/Desktop/" 2>/dev/null || true
        chmod +x "$HOME/Desktop/$(basename "$desktop_path")" 2>/dev/null || true
        if command -v gio &>/dev/null; then
            gio set "$HOME/Desktop/$(basename "$desktop_path")" metadata::trusted true 2>/dev/null || true
        fi
    fi

    if command -v gtk-update-icon-cache &>/dev/null; then
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
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
        "$HOME/.local/share/antigravity-ide/antigravity.run" \
        "$HOME/.local/share/antigravity-ide/antigravity-runner.sh" \
        "$HOME/.local/share/antigravity-ide/antigravity" \
        "$HOME/.local/share/antigravity/antigravity.run" \
        "$HOME/.local/share/antigravity/antigravity" \
        "$HOME/.local/share/antigravity/Antigravity" \
        "$HOME/.antigravity/bin/antigravity"; do
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
    elif command -v antigravity &>/dev/null && [ -x "$HOME/.local/share/antigravity-ide/antigravity" ]; then
        echo -e "  ${PRIMARY}[  OK  ] Google Antigravity is already installed (use --force to reinstall).${TEXT}"
        return 0
    elif command -v antigravity &>/dev/null && [ -x "$HOME/.local/share/antigravity/antigravity" ]; then
        echo -e "  ${PRIMARY}[  OK  ] Google Antigravity is already installed (use --force to reinstall).${TEXT}"
        return 0
    fi

    ensure_prereqs

    local arch
    arch=$(detect_arch)
    local ide_url
    ide_url=$(fetch_ide_url "$arch")
    local target_archive=""

    if [ "$IS_FORCE" != "true" ]; then
        local cached
        if cached=$(find_cached_download); then
            echo -e "  ${PRIMARY}[  OK  ] Reusing cached Antigravity download from temp folder: ${SECONDARY}$cached${TEXT}"
            target_archive="$cached"
        fi
    fi

    if [ -z "$target_archive" ]; then
        local cache_dest="${TMPDIR:-/tmp}/scripts-fixer-downloads/Antigravity.tar.gz"
        download_with_aria2c "$ide_url" "$cache_dest"
        target_archive="$cache_dest"
    fi

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local archive_installer="$script_dir/install-archive.sh"

    if [ -f "$archive_installer" ]; then
        bash "$archive_installer" "$target_archive" "antigravity-ide"
    else
        install_ide_fallback "$target_archive"
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
