#!/usr/bin/env bash
# scripts-linux/77-install-laravel-ubuntu/components/composer.sh
# Installs Composer 2 with official SHA-384 signature verification.
set -u

component_composer_verify() {
    command -v composer >/dev/null 2>&1 || return 1
    composer --version >/dev/null 2>&1 || return 1
    return 0
}

component_composer_install() {
    log_info "[77][composer] starting Composer 2 installation with SHA-384 verification"

    if component_composer_verify; then
        local current_ver
        current_ver="$(composer --version 2>/dev/null | head -1)"
        log_ok "[77][composer] composer already installed ($current_ver) -- skipping"
        mkdir -p "$ROOT/.installed" && touch "$ROOT/.installed/77-composer.ok"
        return 0
    fi

    if ! command -v php >/dev/null 2>&1; then
        log_err "[77][composer] 'php' binary not found on PATH -- install php component first"
        return 1
    fi

    local setup_path="/tmp/composer-setup.php"
    local sig_url="https://composer.github.io/installer.sig"
    local setup_url="https://getcomposer.org/installer"
    local target_bin="/usr/local/bin/composer"

    log_info "[77][composer] fetching official installer signature from $sig_url"
    local expected_sig
    expected_sig="$(curl -fsSL "$sig_url" 2>/dev/null | tr -d '[:space:]')"
    if [ -z "$expected_sig" ]; then
        log_file_error "$sig_url" "failed to download expected Composer installer signature from $sig_url"
        return 1
    fi

    log_info "[77][composer] downloading composer installer from $setup_url"
    if ! php -r "copy('$setup_url', '$setup_path');" 2>/dev/null; then
        log_file_error "$setup_path" "failed to download composer installer from $setup_url"
        return 1
    fi

    if [ ! -f "$setup_path" ]; then
        log_file_error "$setup_path" "composer installer setup file does not exist after download"
        return 1
    fi

    local actual_sig
    actual_sig="$(php -r "echo hash_file('sha384', '$setup_path');" 2>/dev/null || echo "")"
    if [ "$expected_sig" != "$actual_sig" ]; then
        log_file_error "$setup_path" "SHA-384 checksum mismatch (expected='$expected_sig', actual='$actual_sig') -- corrupted or tampered installer"
        rm -f "$setup_path" 2>/dev/null || true
        return 1
    fi
    log_ok "[77][composer] SHA-384 signature verified: $actual_sig"

    log_info "[77][composer] installing Composer to $target_bin"
    if ! sudo php "$setup_path" --install-dir=/usr/local/bin --filename=composer --quiet; then
        log_file_error "$target_bin" "composer-setup.php failed to install binary into /usr/local/bin"
        rm -f "$setup_path" 2>/dev/null || true
        return 1
    fi
    rm -f "$setup_path" 2>/dev/null || true

    sudo chmod +x "$target_bin" 2>/dev/null || true

    if ! component_composer_verify; then
        log_err "[77][composer] verify failed after installation"
        return 1
    fi

    local installed_ver
    installed_ver="$(composer --version 2>/dev/null | head -1)"
    log_ok "[77][composer] installed successfully ($installed_ver)"
    mkdir -p "$ROOT/.installed" && touch "$ROOT/.installed/77-composer.ok"
    return 0
}

component_composer_uninstall() {
    local target_bin="/usr/local/bin/composer"
    log_info "[77][composer] removing Composer binary ($target_bin)"
    if [ -f "$target_bin" ]; then
        if ! sudo rm -f "$target_bin"; then
            log_file_error "$target_bin" "failed to remove composer binary"
            return 1
        fi
        log_ok "[77][composer] removed $target_bin"
    else
        log_info "[77][composer] $target_bin not present (already removed)"
    fi
    rm -f "$ROOT/.installed/77-composer.ok" 2>/dev/null || true
    return 0
}
