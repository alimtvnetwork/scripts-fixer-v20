#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
ACCENT='\033[1;33m'
MUTED='\033[0;37m'
ERROR='\033[1;31m'
TEXT='\033[0m'

IS_FORCE=false
IS_DOWNLOAD_MUST=false

for arg in "$@"; do
    if [ "$arg" = "-h" ] || [ "$arg" = "--help" ] || [ "$arg" = "help" ]; then
        echo -e ""
        echo -e "  ${PRIMARY}Google Antigravity IDE & CLI Companion Installer${TEXT}"
        echo -e ""
        echo -e "  ${ACCENT}Usage:${TEXT}"
        echo -e "    ./run.sh install agy"
        echo -e "    ./run.sh install antigravity"
        echo -e ""
        echo -e "  ${ACCENT}Options & Flags:${TEXT}"
        echo -e "    --force, -f          Force re-installation (clean reinstall, reusing cached downloads)"
        echo -e "    --download-must      Force fresh re-download of archive even if cached locally"
        echo -e ""
        exit 0
    fi

    if [ "$arg" = "--force" ] || [ "$arg" = "-f" ] || [ "$arg" = "force" ]; then
        IS_FORCE=true
    fi

    if [ "$arg" = "--download-must" ] || [ "$arg" = "--redownload" ] || [ "$arg" = "--force-download" ] || [ "$arg" = "-fd" ]; then
        IS_DOWNLOAD_MUST=true
    fi
done

if [ "${FORCE:-0}" = "1" ] || [ "${IS_FORCE_INSTALL:-false}" = "true" ] || [ "${IS_FORCE:-false}" = "true" ]; then
    IS_FORCE=true
fi

if [ "${DOWNLOAD_MUST:-0}" = "1" ] || [ "${IS_DOWNLOAD_MUST:-false}" = "true" ]; then
    IS_DOWNLOAD_MUST=true
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
    if [ "$IS_DOWNLOAD_MUST" = "true" ]; then
        echo -e "  ${ACCENT}[DOWNLOAD-MUST] Purging cached downloads to force fresh download...${TEXT}"
        rm -f "/tmp/scripts-fixer-downloads/Antigravity.tar.gz" "/tmp/Antigravity.tar.gz"
    fi

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

get_antigravity_fallback_icon_base64() {
cat <<'EOF'
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
8Xg8E4D/H85JYd9OjgAWAAAAAElFTkSuQmCC
EOF
}

ensure_hicolor_index_theme() {
    local target_dir="$1"
    local index_file="$target_dir/index.theme"
    if [ ! -f "$index_file" ]; then
        local tmp_theme
        tmp_theme=$(mktemp /tmp/hicolor-index-XXXXXX 2>/dev/null || echo "/tmp/hicolor-index-$$")
        cat <<'EOF' > "$tmp_theme"
[Icon Theme]
Name=Hicolor
Comment=Fallback icon theme
Hidden=true
Directories=16x16/apps,24x24/apps,32x32/apps,48x48/apps,64x64/apps,128x128/apps,256x256/apps,512x512/apps

[16x16/apps]
Size=16
Type=Threshold

[24x24/apps]
Size=24
Type=Threshold

[32x32/apps]
Size=32
Type=Threshold

[48x48/apps]
Size=48
Type=Threshold

[64x64/apps]
Size=64
Type=Threshold

[128x128/apps]
Size=128
Type=Threshold

[256x256/apps]
Size=256
Type=Threshold

[512x512/apps]
Size=512
Type=Threshold
EOF
        if [ -w "$target_dir" ]; then
            cp -f "$tmp_theme" "$index_file" 2>/dev/null || true
        elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
            sudo cp -f "$tmp_theme" "$index_file" 2>/dev/null || true
        fi
        rm -f "$tmp_theme" 2>/dev/null || true
    fi
}

deploy_single_icon_res() {
    local src="$1"
    local dest="$2"
    local size="$3"

    local dest_dir
    dest_dir=$(dirname "$dest")
    if [ -w "$dest_dir" ] || [ ! -d "$dest_dir" ]; then
        mkdir -p "$dest_dir" 2>/dev/null || true
    fi
    if [ ! -d "$dest_dir" ] && command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
        sudo mkdir -p "$dest_dir" 2>/dev/null || true
    fi

    local resized=false
    if command -v convert &>/dev/null; then
        convert "$src" -resize "${size}x${size}" "$dest" 2>/dev/null && resized=true
    elif command -v ffmpeg &>/dev/null; then
        ffmpeg -y -i "$src" -vf "scale=${size}:${size}" "$dest" &>/dev/null && resized=true
    elif command -v python3 &>/dev/null; then
        python3 -c "from PIL import Image; Image.open('$src').resize(($size, $size)).save('$dest')" &>/dev/null && resized=true
    fi

    if [ "$resized" = "false" ]; then
        if [ -w "$dest_dir" ]; then
            cp -f "$src" "$dest" 2>/dev/null || true
        elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
            sudo cp -f "$src" "$dest" 2>/dev/null || true
        fi
    fi
}

deploy_antigravity_multi_resolution_icons() {
    local src_icon="$1"
    local resolutions=(16 24 32 48 64 128 256 512)
    local hicolor_dirs=("$HOME/.local/share/icons/hicolor")
    local pixmaps_dirs=("$HOME/.local/share/pixmaps")

    if [ -w "/usr/share/icons/hicolor" ] || (command -v sudo &>/dev/null && sudo -n true 2>/dev/null); then
        hicolor_dirs+=("/usr/share/icons/hicolor")
    fi
    if [ -w "/usr/share/pixmaps" ] || (command -v sudo &>/dev/null && sudo -n true 2>/dev/null); then
        pixmaps_dirs+=("/usr/share/pixmaps")
    fi

    for hdir in "${hicolor_dirs[@]}"; do
        if [ ! -d "$hdir" ]; then
            if [ -w "$(dirname "$hdir")" ]; then
                mkdir -p "$hdir" 2>/dev/null || true
            elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
                sudo mkdir -p "$hdir" 2>/dev/null || true
            fi
        fi
        ensure_hicolor_index_theme "$hdir"

        for res in "${resolutions[@]}"; do
            deploy_single_icon_res "$src_icon" "$hdir/${res}x${res}/apps/antigravity.png" "$res"
            deploy_single_icon_res "$src_icon" "$hdir/${res}x${res}/apps/antigravity-ide.png" "$res"
        done

        if command -v gtk-update-icon-cache &>/dev/null; then
            if [ -w "$hdir" ]; then
                gtk-update-icon-cache -f -t "$hdir" 2>/dev/null || true
            elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
                sudo gtk-update-icon-cache -f -t "$hdir" 2>/dev/null || true
            fi
        fi
    done

    for pdir in "${pixmaps_dirs[@]}"; do
        if [ ! -d "$pdir" ]; then
            if [ -w "$(dirname "$pdir")" ]; then
                mkdir -p "$pdir" 2>/dev/null || true
            elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
                sudo mkdir -p "$pdir" 2>/dev/null || true
            fi
        fi
        if [ -w "$pdir" ]; then
            cp -f "$src_icon" "$pdir/antigravity.png" 2>/dev/null || true
            cp -f "$src_icon" "$pdir/antigravity-ide.png" 2>/dev/null || true
        elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
            sudo cp -f "$src_icon" "$pdir/antigravity.png" 2>/dev/null || true
            sudo cp -f "$src_icon" "$pdir/antigravity-ide.png" 2>/dev/null || true
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

    if [ -z "$icon_path" ]; then
        local fallback_tmp="/tmp/antigravity-fallback-icon.png"
        get_antigravity_fallback_icon_base64 | base64 -d > "$fallback_tmp" 2>/dev/null || true
        if [ -f "$fallback_tmp" ] && [ -s "$fallback_tmp" ]; then
            icon_path="$fallback_tmp"
        fi
    fi

    if [ -n "$icon_path" ]; then
        deploy_antigravity_multi_resolution_icons "$icon_path"
    fi

    mkdir -p "$app_dir"
    cat <<EOF > "$desktop_path"
[Desktop Entry]
Version=1.0
Name=Google Antigravity
Comment=Google Antigravity IDE & AI Coding Assistant
GenericName=Text Editor
Exec=$exec_cmd %F
Icon=antigravity
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
        if [ -w "/usr/share/icons/hicolor" ]; then
            gtk-update-icon-cache -f -t "/usr/share/icons/hicolor" 2>/dev/null || true
        elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
            sudo gtk-update-icon-cache -f -t "/usr/share/icons/hicolor" 2>/dev/null || true
        fi
    fi
    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$app_dir" 2>/dev/null || true
        if [ -w "/usr/share/applications" ]; then
            update-desktop-database "/usr/share/applications" 2>/dev/null || true
        elif command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
            sudo update-desktop-database "/usr/share/applications" 2>/dev/null || true
        fi
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

    if [ "$IS_DOWNLOAD_MUST" != "true" ]; then
        local cached
        if cached=$(find_cached_download); then
            local cached_sz
            cached_sz=$(stat -c%s "$cached" 2>/dev/null || echo 0)
            echo -e "  ${PRIMARY}[  OK  ] Reusing valid download from temp folder: ${SECONDARY}$cached ($(( cached_sz / 1024 / 1024 )) MB)${TEXT}"
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

    local extra_flags=()
    [ "$IS_FORCE" = "true" ] && extra_flags+=("--force")
    [ "$IS_DOWNLOAD_MUST" = "true" ] && extra_flags+=("--download-must")

    if [ -f "$archive_installer" ]; then
        bash "$archive_installer" "$target_archive" "antigravity-ide" "${extra_flags[@]}"
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
