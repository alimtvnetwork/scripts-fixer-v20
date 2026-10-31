#!/bin/bash
# scripts/os/ubuntu/install-php.sh
# Standalone Ubuntu PHP installer (used by scripts/run.sh for script 16).
# Installs PHP 8.5.12 exactly from the ondrej/php PPA. Plain apt "php"
# on Ubuntu 24.04 is 8.3 and must never be reported as the 8.5.12 install,
# and an already-installed PHP of any other version is not "already done":
# this script installs 8.5.12 alongside it and points `php` at 8.5.
# It never falls back to an unpinned install: if the PPA offers no 8.5.12
# build, it fails loudly instead of installing something else.
set -u
TARGET="8.5.12"
KEY_NEW="B8DC7E53946656EFBCE4C1DD71DAEAAB4AD4CAB6"
KEY_OLD="14AA40EC0831756756D7F66C4F4EA0AAE5267A6C"
KEYRING="/etc/apt/keyrings/ondrej-php.gpg"
SOURCE="/etc/apt/sources.list.d/ondrej-php.list"

php_version_now() { php -r 'echo PHP_VERSION;' 2>/dev/null || echo ''; }

if [ "$(php_version_now)" = "$TARGET" ]; then
    echo "PHP $TARGET is already installed: $(php -v | head -n 1)"
    exit 0
fi

# Add the ondrej/php PPA directly (not add-apt-repository: that wrapper
# rewrites the distro ubuntu.sources file, which is unwritable on some
# images). The keyring must be world-readable: apt verifies as _apt.
if [ ! -s "$SOURCE" ] || [ ! -s "$KEYRING" ]; then
    if ! command -v curl >/dev/null 2>&1 || ! command -v gpg >/dev/null 2>&1; then
        echo "ERROR: curl and gpg are required to add the ondrej/php PPA" >&2
        exit 1
    fi
    tmp_new="$(mktemp)"; tmp_old="$(mktemp)"
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${KEY_NEW}" | gpg --yes --dearmor -o "$tmp_new" 2>/dev/null || { echo "ERROR: failed to fetch ondrej/php key $KEY_NEW" >&2; exit 1; }
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${KEY_OLD}" | gpg --yes --dearmor -o "$tmp_old" 2>/dev/null || { echo "ERROR: failed to fetch ondrej/php key $KEY_OLD" >&2; exit 1; }
    gpg --show-keys "$tmp_new" 2>/dev/null | grep -q "$KEY_NEW" || { echo "ERROR: fetched key does not match $KEY_NEW" >&2; exit 1; }
    gpg --show-keys "$tmp_old" 2>/dev/null | grep -q "$KEY_OLD" || { echo "ERROR: fetched key does not match $KEY_OLD" >&2; exit 1; }
    sudo mkdir -p /etc/apt/keyrings
    sudo sh -c "cat '$tmp_new' '$tmp_old' > '$KEYRING'"
    sudo chmod 644 "$KEYRING"
    rm -f "$tmp_new" "$tmp_old"
    codename="$(. /etc/os-release 2>/dev/null && echo "${VERSION_CODENAME:-}")"
    [ -n "$codename" ] || { echo "ERROR: cannot determine Ubuntu codename" >&2; exit 1; }
    printf 'deb [signed-by=%s] https://ppa.launchpadcontent.net/ondrej/php/ubuntu %s main\n' "$KEYRING" "$codename" | sudo tee "$SOURCE" >/dev/null
    sudo chmod 644 "$SOURCE"
else
    sudo chmod 644 "$KEYRING" "$SOURCE" 2>/dev/null || true
fi

sudo apt-get update -y || true

pinned_version() {
    apt-cache madison "$1" 2>/dev/null | awk -F'|' '{ gsub(/ /, "", $2); if ($2 ~ /^8\.5\.12(-|\+|$)/) { print $2; exit } }'
}

cli_ver="$(pinned_version php8.5-cli)"
fpm_ver="$(pinned_version php8.5-fpm)"
if [ -z "$cli_ver" ] || [ -z "$fpm_ver" ]; then
    echo "ERROR: ondrej/php PPA does not offer a PHP 8.5.12 build on this distro -- refusing to install an unpinned version" >&2
    exit 1
fi

echo "Installing pinned PHP 8.5.12: php8.5-cli=$cli_ver php8.5-fpm=$fpm_ver"
if ! sudo apt-get install -y "php8.5-cli=$cli_ver" "php8.5-fpm=$fpm_ver"; then
    echo "Initial apt install failed, refreshing package index and retrying with --fix-missing..."
    sudo apt-get update -y
    sudo apt-get install -y --fix-missing "php8.5-cli=$cli_ver" "php8.5-fpm=$fpm_ver" || { echo "ERROR: apt install failed" >&2; exit 1; }
fi

if command -v php8.5 >/dev/null 2>&1 && [ "$(php_version_now)" != "$TARGET" ]; then
    sudo update-alternatives --set php /usr/bin/php8.5 2>/dev/null || true
fi

if [ "$(php_version_now)" = "$TARGET" ]; then
    echo "PHP installed: $(php -v | head -n 1)"
    exit 0
fi
echo "ERROR: installed PHP is '$(php_version_now)', not $TARGET" >&2
exit 1
