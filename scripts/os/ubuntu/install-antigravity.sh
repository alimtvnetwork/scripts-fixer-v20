#!/bin/bash
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
ACCENT='\033[1;33m'
MUTED='\033[0;37m'
ERROR='\033[1;31m'
TEXT='\033[0m'

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
    local missing=()
    for cmd in curl tar; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "  ${MUTED}[step 1/5] Installing dependencies (${missing[*]})...${TEXT}"
        if [ -w "/var/lib/dpkg" ] || [ "$(id -u)" -eq 0 ]; then
            apt-get update -y && apt-get install -y "${missing[@]}"
        elif command -v sudo &>/dev/null; then
            sudo apt-get update -y && sudo apt-get install -y "${missing[@]}"
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

fetch_ide_fallback_url() {
    local api="https://antigravity-ide-auto-updater-974169037036.us-central1.run.app/api/update/linux-x64/stable/latest"
    local url=""
    if command -v jq &>/dev/null; then
        url=$(curl -s "$api" 2>/dev/null | jq -r '.url // empty' 2>/dev/null || true)
    fi
    if [ -z "$url" ] || [ "$url" = "null" ]; then
        url=$(curl -s "$api" 2>/dev/null | grep -o '"url": *"[^"]*"' | head -n 1 | cut -d '"' -f 4 || true)
    fi
    if [ -z "$url" ] || [ "$url" = "null" ]; then
        url="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.5.5-4923483625488384/linux-x64/Antigravity%20IDE.tar.gz"
    fi
    echo "${url// /%20}"
}

check_reference_installer() {
    local candidates=(
        "/mnt/d/work/antigravity-installer/01-installer/agy-install.sh"
        "D:/work/antigravity-installer/01-installer/agy-install.sh"
        "/d/work/antigravity-installer/01-installer/agy-install.sh"
    )

    for ref in "${candidates[@]}"; do
        if [ -f "$ref" ]; then
            echo -e "  ${MUTED}Executing reference installer from $ref...${TEXT}"
            bash "$ref" && return 0
        fi
    done

    return 1
}

install_ide() {
    local arch="$1"
    local ide_dir="$HOME/.local/share/antigravity"
    local ide_legacy_dir="$HOME/.local/share/antigravity-ide"

    if check_reference_installer; then
        return 0
    fi

    local ide_url
    ide_url=$(fetch_ide_url "$arch")
    local tmp_archive
    tmp_archive=$(mktemp /tmp/antigravity-XXXXXX.tar.gz)
    local staging
    staging=$(mktemp -d /tmp/antigravity-extract-XXXXXX)

    mkdir -p "$ide_dir"
    echo -e "  ${MUTED}[step 2/5] Downloading Google Antigravity ($arch)...${TEXT}"
    local is_downloaded=false

    if curl -fL --retry 2 --connect-timeout 30 "$ide_url" -o "$tmp_archive" 2>/dev/null; then
        is_downloaded=true
    else
        echo -e "  ${ACCENT}[WARN] Primary download failed; attempting fallback URL...${TEXT}"
        local fallback_url
        fallback_url=$(fetch_ide_fallback_url)

        if curl -fL --retry 2 --connect-timeout 30 "$fallback_url" -o "$tmp_archive" 2>/dev/null; then
            is_downloaded=true
        fi
    fi

    if [ "$is_downloaded" != "true" ] || [ ! -s "$tmp_archive" ]; then
        echo -e "  ${ERROR}[FAIL] Failed to download Antigravity archive.${TEXT}"
        rm -rf "$tmp_archive" "$staging"

        return 1
    fi

    echo -e "  ${MUTED}          Extracting into $ide_dir...${TEXT}"

    if ! tar -xzf "$tmp_archive" -C "$staging" 2>/dev/null; then
        echo -e "  ${ERROR}[FAIL] Failed to extract Antigravity archive.${TEXT}"
        rm -rf "$tmp_archive" "$staging"

        return 1
    fi

    rm -f "$tmp_archive"

    local root="$staging"
    local entries
    entries=$(find "$staging" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')

    if [ "$entries" = "1" ] && [ -d "$(find "$staging" -mindepth 1 -maxdepth 1)" ]; then
        root=$(find "$staging" -mindepth 1 -maxdepth 1)
    fi

    cp -a "$root"/* "$ide_dir/" 2>/dev/null || cp -a "$root"/. "$ide_dir/" 2>/dev/null || true
    rm -rf "$staging"

    local bin=""

    for cand in "$ide_dir/Antigravity" "$ide_dir/antigravity" "$ide_dir/bin/Antigravity" "$ide_dir/bin/antigravity"; do
        if [ -f "$cand" ]; then
            bin="$cand"
            break
        fi
    done

    if [ -z "$bin" ]; then
        bin=$(find "$ide_dir" -maxdepth 2 -type f -perm -u+x ! -name '*.so*' ! -name '*.sh' 2>/dev/null | head -n 1 || true)
    fi

    if [ -n "$bin" ]; then
        chmod +x "$bin"

        if [ "$bin" != "$ide_dir/antigravity" ] && [ ! -e "$ide_dir/antigravity" ]; then
            ln -sf "$bin" "$ide_dir/antigravity" 2>/dev/null || true
        fi
    fi

    if [ -f "$ide_dir/chrome-sandbox" ]; then
        chmod 4755 "$ide_dir/chrome-sandbox" 2>/dev/null || chmod +x "$ide_dir/chrome-sandbox" 2>/dev/null || true
    fi

    if [ ! -d "$ide_legacy_dir" ] && [ -d "$ide_dir" ]; then
        ln -sfn "$ide_dir" "$ide_legacy_dir" 2>/dev/null || true
    fi
}

fetch_cli_url() {
    local arch="$1"
    local asset="agy_cli_linux_${arch}.tar.gz"
    local api="https://api.github.com/repos/google-antigravity/antigravity-cli/releases/latest"
    local url=""
    url=$(curl -s "$api" 2>/dev/null | grep "browser_download_url.*${asset}" | cut -d '"' -f 4 || true)

    if [ -z "$url" ]; then
        url="https://github.com/google-antigravity/antigravity-cli/releases/latest/download/${asset}"
    fi

    echo "$url"
}

extract_cli_bin() {
    local tmp_dir="$1"
    local target="$HOME/.antigravity/bin/antigravity"

    if [ -f "$tmp_dir/antigravity" ]; then
        mv "$tmp_dir/antigravity" "$target"
    elif [ -f "$tmp_dir/agy" ]; then
        mv "$tmp_dir/agy" "$target"
    else
        local found
        found=$(find "$tmp_dir" -maxdepth 2 -type f -perm -111 ! -name "*.tar.gz" ! -name "*.zip" 2>/dev/null | head -n 1 || true)
        [ -n "$found" ] && mv "$found" "$target"
    fi
}

fallback_cli_from_ide() {
    local cli_bin="$HOME/.antigravity/bin/antigravity"
    local ide_dir="$HOME/.local/share/antigravity"
    mkdir -p "$HOME/.antigravity/bin"

    if [ ! -f "$cli_bin" ]; then
        local cand_ide=""

        for cand in "$ide_dir/bin/antigravity" "$ide_dir/bin/Antigravity" "$ide_dir/Antigravity" "$ide_dir/antigravity" "$HOME/.local/share/antigravity-ide/Antigravity" "$HOME/.local/share/antigravity-ide/antigravity"; do
            if [ -f "$cand" ]; then
                cand_ide="$cand"
                break
            fi
        done

        if [ -n "$cand_ide" ]; then
            ln -sf "$cand_ide" "$cli_bin"
        fi
    fi

    if [ -f "$cli_bin" ] || [ -L "$cli_bin" ]; then
        chmod +x "$cli_bin" 2>/dev/null || true
        ln -sf "$cli_bin" "$HOME/.antigravity/bin/agy" 2>/dev/null || true
    fi
}

install_cli() {
    local arch="$1"
    local cli_dir="$HOME/.antigravity/bin"
    mkdir -p "$cli_dir"
    local asset="agy_cli_linux_${arch}.tar.gz"
    local dl_url
    dl_url=$(fetch_cli_url "$arch")
    local tmp_dir
    tmp_dir=$(mktemp -d /tmp/antigravity-cli-XXXXXX)

    echo -e "  ${MUTED}[step 3/5] Downloading Antigravity CLI companion (${asset})...${TEXT}"

    if curl -fL "$dl_url" -o "$tmp_dir/$asset" 2>/dev/null; then
        tar -xzf "$tmp_dir/$asset" -C "$tmp_dir" 2>/dev/null || true
        extract_cli_bin "$tmp_dir"
    fi

    rm -rf "$tmp_dir"
    fallback_cli_from_ide
}

resolve_primary_bin() {
    for b in \
        "$HOME/.local/share/antigravity/Antigravity" \
        "$HOME/.local/share/antigravity/antigravity" \
        "$HOME/.local/share/antigravity/bin/Antigravity" \
        "$HOME/.local/share/antigravity/bin/antigravity" \
        "$HOME/.local/share/antigravity-ide/Antigravity" \
        "$HOME/.local/share/antigravity-ide/antigravity" \
        "$HOME/.antigravity/bin/antigravity" \
        "$HOME/.antigravity/bin/agy"; do
        if [ -x "$b" ] || [ -f "$b" ]; then
            echo "$b"

            return
        fi
    done

    echo "$HOME/.local/share/antigravity/Antigravity"
}

link_system_binaries() {
    local target="$1"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.antigravity/bin"
    ln -sf "$target" "$HOME/.local/bin/antigravity"
    ln -sf "$target" "$HOME/.local/bin/agy"
    ln -sf "$target" "$HOME/.antigravity/bin/antigravity"
    ln -sf "$target" "$HOME/.antigravity/bin/agy"
    if [ -w "/usr/local/bin" ]; then
        ln -sf "$target" "/usr/local/bin/antigravity" 2>/dev/null || true
        ln -sf "$target" "/usr/local/bin/agy" 2>/dev/null || true
    elif command -v sudo &>/dev/null; then
        sudo ln -sf "$target" "/usr/local/bin/antigravity" 2>/dev/null || true
        sudo ln -sf "$target" "/usr/local/bin/agy" 2>/dev/null || true
    fi
}

configure_shell_profiles() {
    local line='export PATH="$HOME/.local/bin:$HOME/.antigravity/bin:$HOME/.local/share/antigravity:$HOME/.local/share/antigravity-ide/bin:$PATH"'
    for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        if [ -f "$rc" ]; then
            if ! grep -q ".antigravity/bin" "$rc" 2>/dev/null && ! grep -q "antigravity" "$rc" 2>/dev/null; then
                echo "$line" >> "$rc"
                echo -e "  ${MUTED}  -> Added Antigravity PATH to $rc${TEXT}"
            fi
        fi
    done
}

resolve_ide_exec() {
    local app=""

    for cand in \
        "$HOME/.local/share/antigravity/Antigravity" \
        "$HOME/.local/share/antigravity/antigravity" \
        "$HOME/.local/share/antigravity-ide/Antigravity" \
        "$HOME/.local/share/antigravity-ide/antigravity" \
        "$HOME/.local/bin/antigravity" \
        "$HOME/.antigravity/bin/antigravity"; do
        if [ -f "$cand" ]; then
            chmod +x "$cand" 2>/dev/null || true
            app="$cand"
            break
        fi
    done

    if [ -n "$app" ]; then
        echo "$app"
    else
        echo "$HOME/.local/share/antigravity/antigravity"
    fi
}

resolve_ide_icon() {
    local ide_dir="$HOME/.local/share/antigravity"
    local icon
    icon=$(find "$ide_dir" -maxdepth 4 -type f \( -name "antigravity.png" -o -name "code.png" -o -name "icon.png" \) 2>/dev/null | head -n 1 || true)

    if [ -z "$icon" ]; then
        icon=$(find "$HOME/.local/share/antigravity-ide" -maxdepth 4 -type f \( -name "antigravity.png" -o -name "code.png" -o -name "icon.png" \) 2>/dev/null | head -n 1 || true)
    fi

    if [ -n "$icon" ]; then
        echo "$icon"
    else
        echo "antigravity"
    fi
}

install_system_desktop() {
    local src="$1"

    if [ -w "/usr/share/applications" ]; then
        cp -f "$src" "/usr/share/applications/antigravity.desktop" 2>/dev/null || true
    elif command -v sudo &>/dev/null; then
        sudo cp -f "$src" "/usr/share/applications/antigravity.desktop" 2>/dev/null || true
    fi
}

install_user_desktop() {
    local src="$1"

    if [ -d "$HOME/Desktop" ]; then
        cp -f "$src" "$HOME/Desktop/antigravity.desktop"
        chmod +x "$HOME/Desktop/antigravity.desktop"

        if command -v gio &>/dev/null; then
            gio set "$HOME/Desktop/antigravity.desktop" metadata::trusted true 2>/dev/null || true
        fi
    fi
}

refresh_desktop_database() {
    local app_dir="$1"

    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$app_dir" 2>/dev/null || true

        if [ -w "/usr/share/applications" ]; then
            update-desktop-database "/usr/share/applications" 2>/dev/null || true
        elif command -v sudo &>/dev/null; then
            sudo update-desktop-database "/usr/share/applications" 2>/dev/null || true
        fi
    fi
}

create_desktop_launcher() {
    local exec_cmd="$1" icon_path="$2"
    local app_dir="$HOME/.local/share/applications"
    local desktop_path="$app_dir/antigravity.desktop"
    mkdir -p "$app_dir"
    printf "[Desktop Entry]\nName=Google Antigravity\nComment=Google Antigravity IDE & AI Coding Assistant\nGenericName=Text Editor\nExec=%s %%F\nIcon=%s\nType=Application\nStartupNotify=true\nStartupWMClass=Antigravity\nCategories=Development;IDE;TextEditor;\nMimeType=text/plain;inode/directory;\nTerminal=false\n" "$exec_cmd" "$icon_path" > "$desktop_path"
    chmod +x "$desktop_path"
    install_system_desktop "$desktop_path"
    install_user_desktop "$desktop_path"
    refresh_desktop_database "$app_dir"
}

verify_antigravity() {
    export PATH="$HOME/.local/bin:$HOME/.antigravity/bin:$HOME/.local/share/antigravity:$HOME/.local/share/antigravity-ide/bin:$HOME/.local/share/antigravity-ide:$PATH"
    local bin_path=""

    for b in \
        "$HOME/.local/share/antigravity/Antigravity" \
        "$HOME/.local/share/antigravity/antigravity" \
        "$HOME/.local/bin/antigravity" \
        "$HOME/.local/bin/agy" \
        "/usr/local/bin/antigravity" \
        "/usr/local/bin/agy" \
        "$HOME/.antigravity/bin/antigravity" \
        "$HOME/.antigravity/bin/agy" \
        "$HOME/.local/share/antigravity-ide/Antigravity" \
        "$HOME/.local/share/antigravity-ide/antigravity"; do
        if [ -f "$b" ] && [ -x "$b" ]; then
            bin_path="$b"
            break
        fi
    done

    if [ -z "$bin_path" ]; then
        echo -e "  ${ERROR}[FAIL] Antigravity binary not found or not executable.${TEXT}"

        return 1
    fi

    local out=""

    if out=$("$bin_path" --version 2>/dev/null) || out=$("$bin_path" -v 2>/dev/null) || out=$("$bin_path" -h 2>/dev/null) || \
       out=$(antigravity --version 2>/dev/null) || out=$(agy --version 2>/dev/null); then
        echo -e "  ${PRIMARY}[  OK  ] Antigravity verified: ${out:-operational} ($bin_path)${TEXT}"

        return 0
    fi

    if [ -x "$bin_path" ]; then
        echo -e "  ${PRIMARY}[  OK  ] Antigravity verified at $bin_path${TEXT}"

        return 0
    fi

    echo -e "  ${ERROR}[FAIL] Antigravity binary ($bin_path) execution test failed.${TEXT}"

    return 1
}

main() {
    echo -e "\n  ${SECONDARY}[  ..  ] Installing Google Antigravity IDE & CLI...${TEXT}"
    ensure_prereqs
    local arch
    arch=$(detect_arch)
    install_ide "$arch"
    install_cli "$arch"
    local primary_bin
    primary_bin=$(resolve_primary_bin)
    link_system_binaries "$primary_bin"
    configure_shell_profiles
    echo -e "  ${MUTED}[step 4/5] Setting up desktop application launcher...${TEXT}"
    local ide_exec ide_icon
    ide_exec=$(resolve_ide_exec)
    ide_icon=$(resolve_ide_icon)
    create_desktop_launcher "$ide_exec" "$ide_icon"
    echo -e "  ${MUTED}[step 5/5] Verifying Antigravity installation...${TEXT}"
    if ! verify_antigravity; then
        echo -e "  ${ERROR}[FAIL ] Antigravity installation verification failed.${TEXT}"
        exit 1
    fi
    echo -e "\n  ${PRIMARY}[DONE ] Google Antigravity IDE & CLI setup complete.${TEXT}"
    echo -e "  ${MUTED}  Usage: antigravity \"your task\" or agy \"your task\"${TEXT}"
    echo -e "  ${MUTED}  Docs : https://antigravity.dev/docs${TEXT}\n"
}

main "$@"
