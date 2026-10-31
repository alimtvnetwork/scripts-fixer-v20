#!/usr/bin/env bash
# scripts-linux/16-install-php/run.sh
# PHP CLI + FPM installer (Debian/Ubuntu, plus macOS via Homebrew).
#
# Default PHP is pinned to 8.5.12 exactly. The distro default ("latest")
# is NOT the default any more: on Ubuntu 24.04 plain apt installs 8.3,
# which must never be reported as the 8.5.12 install. Pinned 8.5.12 on
# Debian/Ubuntu comes from the ondrej/php PPA, with the exact apt build
# resolved at install time from apt-cache madison (never a bare
# php8.5-cli install, which would float to whatever 8.5.x the PPA ships).
# macOS has no patch pin: Homebrew php@8.5 gives latest 8.5.x, and the
# script says so instead of claiming 8.5.12.
#
# Verbs:    install (default) | check | repair | uninstall
# Flags:    --interactive | -i    Prompt for the PHP version before install
#                                 (e.g. "PHP version (8.5.12|8.5|8.1|8.2|8.3|latest) [8.5.12]: ")
#           --php <ver>           Pin PHP version: 8.5.12 (default) | 8.5 | 8.1 | 8.2 | 8.3 | latest
#           -h | --help           Show help and exit
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export SCRIPT_ID="16"

. "$ROOT/_shared/logger.sh"
. "$ROOT/_shared/pkg-detect.sh"
. "$ROOT/_shared/file-error.sh"
. "$ROOT/_shared/interactive.sh"
. "$ROOT/_shared/install-paths.sh"

CONFIG="$SCRIPT_DIR/config.json"
[ -f "$CONFIG" ] || { log_file_error "$CONFIG" "config.json missing for 16-install-php"; exit 1; }

INSTALLED_MARK="$ROOT/.installed/16.ok"
VERIFY_CMD='php --version'

# ---- arg parsing -----------------------------------------------------------
PHP_VERSION="${PHP_VERSION:-8.5.12}"
INTERACTIVE=0
VERB=""
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<HELP
scripts-linux/run.sh 16 [verb] [flags]
  Verbs:  install | check | repair | uninstall   (default: install)
  Flags:
    --interactive, -i      Prompt for PHP version before install
    --php <ver>            Pin PHP version (8.5.12|8.5|8.1|8.2|8.3|latest, default: 8.5.12)
    -h, --help             Show this help
HELP
            exit 0 ;;
        -i|--interactive)  INTERACTIVE=1; shift ;;
        --php)             PHP_VERSION="${2:-}"; shift 2 ;;
        --php=*)           PHP_VERSION="${1#--php=}"; shift ;;
        install|check|repair|uninstall) VERB="$1"; shift ;;
        *) log_err "[16] Unknown arg: $1"; exit 2 ;;
    esac
done
VERB="${VERB:-install}"

# ---- interactive prompt (only for install/repair, only if requested) -------
if [ "$INTERACTIVE" = "1" ] && { [ "$VERB" = "install" ] || [ "$VERB" = "repair" ]; }; then
    log_info "[16] --interactive: collecting PHP version"
    PHP_VERSION="$(prompt_with_default 'PHP version (8.5.12|8.5|8.1|8.2|8.3|latest)' "$PHP_VERSION" validate_php_version)"
    log_info "[16] -> PHP version='$PHP_VERSION'"
fi

# Validate even when not interactive (catches bad --php values).
if ! validate_php_version "$PHP_VERSION"; then
    log_err "[16] Invalid PHP version '$PHP_VERSION' (expected: 8.5.12|8.5|8.1|8.2|8.3|latest)"
    exit 2
fi

# ---- resolve apt package set from chosen version ---------------------------
# "8.5" is an alias for the pinned patch: it must resolve to 8.5.12, not
# to whatever 8.5.x a package manager happens to ship today.
TARGET_PHP_VERSION="$PHP_VERSION"
if [ "$PHP_VERSION" = "8.5" ]; then TARGET_PHP_VERSION="8.5.12"; fi
IS_PINNED_8512=0
if [ "$TARGET_PHP_VERSION" = "8.5.12" ]; then IS_PINNED_8512=1; fi
if [ "$PHP_VERSION" = "latest" ]; then
    APT_PKG="php-cli php-fpm"
elif [ "$IS_PINNED_8512" = "1" ]; then
    APT_PKG="php8.5-cli php8.5-fpm"
else
    APT_PKG="php${PHP_VERSION}-cli php${PHP_VERSION}-fpm"
fi

verify_installed() { bash -c "$VERIFY_CMD" >/dev/null 2>&1; }

php_current_version() { php -r 'echo PHP_VERSION;' 2>/dev/null || echo ''; }

# True only when the installed php matches what was requested. Any php
# present is NOT enough: 8.3 installed must never satisfy an 8.5.12 request.
php_matches_requested() {
    local cur
    cur="$(php_current_version)"
    if [ -z "$cur" ]; then return 1; fi
    case "$TARGET_PHP_VERSION" in
        latest) return 0 ;;
        *.*.*) [ "$cur" = "$TARGET_PHP_VERSION" ] ;;
        *.*) case "$cur" in "$TARGET_PHP_VERSION".*) return 0 ;; *) return 1 ;; esac ;;
        *) return 1 ;;
    esac
}

# Ondrej PPA signing keys (Launchpad PPA for Ondrej Sury, current + legacy).
# Both are required: the PPA InRelease carries signatures from both keys.
ONDREJ_KEY_NEW="B8DC7E53946656EFBCE4C1DD71DAEAAB4AD4CAB6"
ONDREJ_KEY_OLD="14AA40EC0831756756D7F66C4F4EA0AAE5267A6C"
ONDREJ_KEYRING="/etc/apt/keyrings/ondrej-php.gpg"
ONDREJ_SOURCE="/etc/apt/sources.list.d/ondrej-php.list"

# Add the ondrej/php PPA without add-apt-repository: that wrapper rewrites
# the distro ubuntu.sources file, which is unwritable on some images, and
# it leaves a broken empty source behind when it fails. Writing a dedicated
# .list + signed-by keyring avoids both problems. The keyring MUST be
# world-readable: apt verifies signatures as the unprivileged _apt user,
# and a 0600/0660 keyring fails with NO_PUBKEY even when the keys are in it.
ensure_ondrej_php() {
    local sudo_cmd=""
    if ! is_root; then sudo_cmd="sudo"; fi
    if [ -s "$ONDREJ_SOURCE" ] && [ -s "$ONDREJ_KEYRING" ]; then
        $sudo_cmd chmod 644 "$ONDREJ_KEYRING" "$ONDREJ_SOURCE" 2>/dev/null || true
        return 0
    fi
    if ! command -v curl >/dev/null 2>&1 || ! command -v gpg >/dev/null 2>&1; then
        log_file_error "$ONDREJ_KEYRING" "curl and gpg are required to add the ondrej/php PPA"
        return 1
    fi
    local tmp_new tmp_old codename
    tmp_new="$(mktemp)"; tmp_old="$(mktemp)"
    if ! curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${ONDREJ_KEY_NEW}" | gpg --yes --dearmor -o "$tmp_new" 2>/dev/null; then
        log_file_error "$ONDREJ_KEYRING" "failed to fetch ondrej/php signing key ${ONDREJ_KEY_NEW}"
        rm -f "$tmp_new" "$tmp_old"; return 1
    fi
    if ! curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${ONDREJ_KEY_OLD}" | gpg --yes --dearmor -o "$tmp_old" 2>/dev/null; then
        log_file_error "$ONDREJ_KEYRING" "failed to fetch ondrej/php signing key ${ONDREJ_KEY_OLD}"
        rm -f "$tmp_new" "$tmp_old"; return 1
    fi
    # Verify both fingerprints before trusting either key.
    if ! gpg --show-keys "$tmp_new" 2>/dev/null | grep -q "$ONDREJ_KEY_NEW"; then
        log_file_error "$ONDREJ_KEYRING" "fetched ondrej/php key does not match fingerprint ${ONDREJ_KEY_NEW}"
        rm -f "$tmp_new" "$tmp_old"; return 1
    fi
    if ! gpg --show-keys "$tmp_old" 2>/dev/null | grep -q "$ONDREJ_KEY_OLD"; then
        log_file_error "$ONDREJ_KEYRING" "fetched ondrej/php key does not match fingerprint ${ONDREJ_KEY_OLD}"
        rm -f "$tmp_new" "$tmp_old"; return 1
    fi
    $sudo_cmd mkdir -p /etc/apt/keyrings
    $sudo_cmd sh -c "cat '$tmp_new' '$tmp_old' > '$ONDREJ_KEYRING'"
    $sudo_cmd chmod 644 "$ONDREJ_KEYRING"
    rm -f "$tmp_new" "$tmp_old"
    codename="$(. /etc/os-release 2>/dev/null && echo "${VERSION_CODENAME:-}")"
    if [ -z "$codename" ]; then
        log_file_error "$ONDREJ_SOURCE" "cannot determine Ubuntu codename from /etc/os-release"
        return 1
    fi
    printf 'deb [signed-by=%s] https://ppa.launchpadcontent.net/ondrej/php/ubuntu %s main\n' "$ONDREJ_KEYRING" "$codename" | $sudo_cmd tee "$ONDREJ_SOURCE" >/dev/null
    $sudo_cmd chmod 644 "$ONDREJ_SOURCE"
    return 0
}

# Exact apt version string for a package at the pinned 8.5.12 build, or
# empty when the PPA does not offer it. Never guess the suffix: it varies
# by distro (e.g. 8.5.12-1+ubuntu24.04.1+deb.sury.org+1).
resolve_pinned_apt_version() {
    apt-cache madison "$1" 2>/dev/null | awk -F'|' '{ gsub(/ /, "", $2); if ($2 ~ /^8\.5\.12(-|\+|$)/) { print $2; exit } }'
}

verb_install_pinned_8512() {
    if ! ensure_ondrej_php; then return 1; fi
    log_info "[16] Installing pinned PHP 8.5.12 via ondrej/php PPA"
    sudo apt-get update -y >/dev/null 2>&1 || true
    local cli_ver fpm_ver
    cli_ver="$(resolve_pinned_apt_version php8.5-cli)"
    fpm_ver="$(resolve_pinned_apt_version php8.5-fpm)"
    if [ -z "$cli_ver" ] || [ -z "$fpm_ver" ]; then
        log_err "[16] ondrej/php PPA does not offer a PHP 8.5.12 build on this distro -- refusing to install an unpinned version"
        return 1
    fi
    log_info "[16] Installing via apt: php8.5-cli=$cli_ver php8.5-fpm=$fpm_ver"
    if ! sudo apt-get install -y "php8.5-cli=$cli_ver" "php8.5-fpm=$fpm_ver"; then
        log_warn "[16] Initial install failed, retrying with apt-get update and --fix-missing..."
        sudo apt-get update -y >/dev/null 2>&1 || true
        if ! sudo apt-get install -y --fix-missing "php8.5-cli=$cli_ver" "php8.5-fpm=$fpm_ver"; then
            log_err "[16] apt install failed"; return 1
        fi
    fi
    # Co-installed versions: make the generic `php` point at 8.5 when it does not already.
    if command -v php8.5 >/dev/null 2>&1 && [ "$(php_current_version)" != "8.5.12" ]; then
        sudo update-alternatives --set php /usr/bin/php8.5 2>/dev/null || true
    fi
    if [ "$(php_current_version)" = "8.5.12" ]; then
        log_ok "[16] Installed PHP 8.5.12"
        mkdir -p "$ROOT/.installed"; touch "$INSTALLED_MARK"
        return 0
    fi
    log_err "[16] Installed PHP is '$(php_current_version)', not 8.5.12 -- not marking installed"
    return 1
}

# macOS path (UNVERIFIED here: no macOS runner in this environment).
# Homebrew cannot pin a patch version, so this installs latest 8.5.x and
# says so explicitly; it never claims 8.5.12.
verb_install_macos() {
    log_info "[16] macOS: installing via Homebrew php@8.5 (latest 8.5.x; Homebrew cannot pin 8.5.12)"
    if ! command -v brew >/dev/null 2>&1; then
        log_err "[16] brew not available"; return 1
    fi
    if ! brew install php@8.5; then
        log_err "[16] brew install php@8.5 failed"; return 1
    fi
    case "$(php_current_version)" in
        8.5.*) ;;
        *) brew link --force --overwrite php@8.5 2>/dev/null || true ;;
    esac
    case "$(php_current_version)" in
        8.5.*)
            log_ok "[16] Installed PHP $(php_current_version) via Homebrew (latest 8.5.x, not pinned 8.5.12)"
            mkdir -p "$ROOT/.installed"; touch "$INSTALLED_MARK"
            return 0 ;;
        *)
            log_err "[16] Homebrew PHP is '$(php_current_version)', not 8.5.x -- not marking installed"
            return 1 ;;
    esac
}

verb_install() {
    write_install_paths \
      --tool   "PHP CLI + FPM ($TARGET_PHP_VERSION)" \
      --source "apt (Debian/Ubuntu) | ondrej/php PPA for pinned 8.5.12 | brew php@8.5 on macOS" \
      --temp   "/var/cache/apt/archives" \
      --target "/usr/bin/php + /usr/sbin/php-fpm*"
    log_info "[16] Starting PHP CLI + FPM installer (version=$TARGET_PHP_VERSION, pkgs=$APT_PKG)"
    if [ "$(uname -s)" = "Darwin" ]; then
        verb_install_macos; return $?
    fi
    if php_matches_requested; then
        log_ok "[16] Already installed (PHP $(php_current_version))"
        mkdir -p "$ROOT/.installed"; touch "$INSTALLED_MARK"
        return 0
    fi
    if [ "$IS_PINNED_8512" = "1" ]; then
        if ! is_debian_family || ! is_apt_available; then
            log_err "[16] apt not available"; return 1
        fi
        verb_install_pinned_8512; return $?
    fi
    if ! is_debian_family || ! is_apt_available; then
        log_err "[16] apt not available"; return 1
    fi
    log_info "[16] Installing via apt: $APT_PKG"
    sudo apt-get update -y >/dev/null 2>&1 || true
    if sudo apt-get install -y $APT_PKG; then
        if php_matches_requested; then
            log_ok "[16] Installed"
            mkdir -p "$ROOT/.installed"; touch "$INSTALLED_MARK"
            return 0
        fi
        log_err "[16] Installed PHP is '$(php_current_version)', not $TARGET_PHP_VERSION -- not marking installed"
        return 1
    fi
    log_warn "[16] Initial install failed, retrying with apt-get update and --fix-missing..."
    sudo apt-get update -y >/dev/null 2>&1 || true
    if sudo apt-get install -y --fix-missing $APT_PKG; then
        if php_matches_requested; then
            log_ok "[16] Installed"
            mkdir -p "$ROOT/.installed"; touch "$INSTALLED_MARK"
            return 0
        fi
        log_err "[16] Installed PHP is '$(php_current_version)', not $TARGET_PHP_VERSION -- not marking installed"
        return 1
    fi
    log_err "[16] apt install failed"; return 1
}
verb_check()     { if php_matches_requested; then log_ok "[16] Verify OK (PHP $(php_current_version))"; return 0; fi; log_warn "[16] Verify FAILED (wanted $TARGET_PHP_VERSION, have '$(php_current_version)')"; return 1; }
verb_repair()    { rm -f "$INSTALLED_MARK"; verb_install; }
verb_uninstall() {
    if [ "$(uname -s)" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
        brew uninstall php@8.5 2>/dev/null || true
    else
        sudo apt-get remove -y $APT_PKG
    fi
    rm -f "$INSTALLED_MARK"; log_ok "[16] Removed"
}

case "$VERB" in
    install)   verb_install ;;
    check)     verb_check ;;
    repair)    verb_repair ;;
    uninstall) verb_uninstall ;;
    *)         log_err "[16] Unknown verb: $VERB"; exit 2 ;;
esac
