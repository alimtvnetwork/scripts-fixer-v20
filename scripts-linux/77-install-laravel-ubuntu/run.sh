#!/usr/bin/env bash
# scripts-linux/77-install-laravel-ubuntu/run.sh
# Ubuntu Laravel installer (Nginx + PHP-FPM + Composer 2 + DB + Queue Worker + Cron).
#
# Verbs:
#   install               install full stack in order (PHP -> Composer -> DB -> Laravel -> Nginx -> Daemons -> Verify)
#   install prereqs       install ONLY prerequisites (PHP + extensions + Composer + DB)
#   install <component>   install one of: php | composer | database | laravel | nginx | daemon | postinstall
#   check                 verify every installed component
#   repair                wipe markers, re-run full install
#   uninstall             remove Laravel app + nginx vhost + daemon workers
#   show-credentials      print saved DB credentials + app URL
#   verify                run 4-gate post-install verification
#
# Flags:
#   --interactive | -i    prompt for configuration parameters
#   --path <path>         Laravel install directory (default: /var/www/laravel)
#   --docroot <path>      alias of --path
#   --app-name <name>     Laravel APP_NAME in .env (default: laravel-app)
#   --site-port <n>       nginx HTTP port (default: 80)
#   --server-name <name>  vhost server_name / domain (default: localhost)
#   --php <ver>           PHP version: 8.2 | 8.3 | latest (default: 8.3)
#   --db <engine>         database engine: mysql | mariadb | pgsql | sqlite (default: mysql)
#   --db-name <name>      database name (default: laravel)
#   --db-user <name>      database user (default: laravel_user)
#   --db-pass <pass>      database password (default: auto-generate)
#   --db-host <host>      database host (default: 127.0.0.1)
#   --db-port <port>      database port (default: 3306 or 5432)
#   --queue               enable systemd queue worker (default: enabled)
#   --cron                enable artisan crontab scheduler (default: enabled)
#   --migrate             run database migrations (default: enabled)
#   --apt-refresh <mode>  refresh APT index before installing packages:
#                           none | update | upgrade | dist-upgrade (default: none)
#   --apt-update          shortcut for --apt-refresh update
#   --apt-upgrade         shortcut for --apt-refresh upgrade
#   --show-credentials    print DB credentials block after installation
#   --json                machine-readable JSON output for show-credentials
#   -h | --help           show this help and exit
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export SCRIPT_ID="77"
export ROOT

. "$ROOT/_shared/logger.sh"
. "$ROOT/_shared/file-error.sh"
. "$ROOT/_shared/install-paths.sh"
. "$ROOT/_shared/pkg-detect.sh"
. "$SCRIPT_DIR/components/composer.sh"
. "$SCRIPT_DIR/components/php.sh"
. "$SCRIPT_DIR/components/database.sh"
. "$SCRIPT_DIR/components/laravel.sh"
. "$SCRIPT_DIR/components/nginx.sh"
. "$SCRIPT_DIR/components/daemon.sh"
. "$SCRIPT_DIR/components/postinstall-verify.sh"

CONFIG="$SCRIPT_DIR/config.json"
if [ ! -f "$CONFIG" ]; then
    log_file_error "$CONFIG" "config.json missing for 77-install-laravel-ubuntu"
    exit 1
fi

# ---- defaults ---------------------------------------------------------------
INTERACTIVE=0
VERB=""
SUBCOMPONENT=""

export LARAVEL_INSTALL_PATH="/var/www/laravel"
export LARAVEL_APP_NAME="laravel-app"
export LARAVEL_SITE_PORT="80"
export LARAVEL_SERVER_NAME="localhost"
export LARAVEL_PHP_VERSION="8.3"
export LARAVEL_DB_ENGINE="mysql"
export LARAVEL_DB_NAME="laravel"
export LARAVEL_DB_USER="laravel_user"
export LARAVEL_DB_PASS=""
export LARAVEL_DB_HOST="127.0.0.1"
export LARAVEL_DB_PORT="3306"
export LARAVEL_ENABLE_QUEUE="1"
export LARAVEL_ENABLE_SCHEDULER="1"
export LARAVEL_RUN_MIGRATIONS="1"
export LARAVEL_STORAGE_LINK="1"
export LARAVEL_APT_REFRESH=""
export LARAVEL_SHOW_CREDENTIALS="0"
SHOW_CREDS_JSON="0"

_show_help() {
    sed -n '2,/^set -u$/p' "$0" | sed 's/^# \{0,1\}//' | head -n -1
}

# ---- arg parse --------------------------------------------------------------
while [ $# -gt 0 ]; do
    case "$1" in
        install|check|repair|uninstall)
            VERB="$1"; shift
            case "${1:-}" in
                composer|php|database|db|laravel|nginx|daemon|postinstall|postinstall-verify|prereqs|prerequisites)
                    SUBCOMPONENT="$1"; shift ;;
            esac
            ;;
        verify)
            VERB="verify"; shift ;;
        show-credentials|show-creds|creds)
            VERB="show-credentials"; shift ;;
        -i|--interactive)  INTERACTIVE=1; shift ;;
        --path|--docroot)  LARAVEL_INSTALL_PATH="$2"; shift 2 ;;
        --path=*|--docroot=*) LARAVEL_INSTALL_PATH="${1#*=}"; shift ;;
        --app-name)        LARAVEL_APP_NAME="$2"; shift 2 ;;
        --app-name=*)      LARAVEL_APP_NAME="${1#--app-name=}"; shift ;;
        --site-port)       LARAVEL_SITE_PORT="$2"; shift 2 ;;
        --site-port=*)     LARAVEL_SITE_PORT="${1#--site-port=}"; shift ;;
        --server-name|--domain) LARAVEL_SERVER_NAME="$2"; shift 2 ;;
        --server-name=*|--domain=*) LARAVEL_SERVER_NAME="${1#*=}"; shift ;;
        --php)             LARAVEL_PHP_VERSION="$2"; shift 2 ;;
        --php=*)           LARAVEL_PHP_VERSION="${1#--php=}"; shift ;;
        --db)              LARAVEL_DB_ENGINE="$2"; shift 2 ;;
        --db=*)            LARAVEL_DB_ENGINE="${1#--db=}"; shift ;;
        --db-name)         LARAVEL_DB_NAME="$2"; shift 2 ;;
        --db-name=*)       LARAVEL_DB_NAME="${1#--db-name=}"; shift ;;
        --db-user)         LARAVEL_DB_USER="$2"; shift 2 ;;
        --db-user=*)       LARAVEL_DB_USER="${1#--db-user=}"; shift ;;
        --db-pass)         LARAVEL_DB_PASS="$2"; shift 2 ;;
        --db-pass=*)       LARAVEL_DB_PASS="${1#--db-pass=}"; shift ;;
        --db-host)         LARAVEL_DB_HOST="$2"; shift 2 ;;
        --db-host=*)       LARAVEL_DB_HOST="${1#--db-host=}"; shift ;;
        --db-port)         LARAVEL_DB_PORT="$2"; shift 2 ;;
        --db-port=*)       LARAVEL_DB_PORT="${1#--db-port=}"; shift ;;
        --queue)           LARAVEL_ENABLE_QUEUE="1"; shift ;;
        --queue=*)         LARAVEL_ENABLE_QUEUE="${1#--queue=}"; shift ;;
        --cron)            LARAVEL_ENABLE_SCHEDULER="1"; shift ;;
        --cron=*)          LARAVEL_ENABLE_SCHEDULER="${1#--cron=}"; shift ;;
        --migrate)         LARAVEL_RUN_MIGRATIONS="1"; shift ;;
        --migrate=*)       LARAVEL_RUN_MIGRATIONS="${1#--migrate=}"; shift ;;
        --apt-refresh)     LARAVEL_APT_REFRESH="$2"; shift 2 ;;
        --apt-refresh=*)   LARAVEL_APT_REFRESH="${1#--apt-refresh=}"; shift ;;
        --apt-update)      LARAVEL_APT_REFRESH="update"; shift ;;
        --apt-upgrade)     LARAVEL_APT_REFRESH="upgrade"; shift ;;
        --show-credentials) LARAVEL_SHOW_CREDENTIALS="1"; shift ;;
        --json)            SHOW_CREDS_JSON="1"; shift ;;
        -h|--help)         _show_help; exit 0 ;;
        *)
            log_warn "[77] Unknown arg: '$1' -- run with --help for usage"
            shift ;;
    esac
done

VERB="${VERB:-install}"

# ---- config.json resolution -------------------------------------------------
_resolve_config_defaults() {
    if command -v jq >/dev/null 2>&1 && [ -f "$CONFIG" ]; then
        if [ -z "$LARAVEL_APT_REFRESH" ]; then
            local r
            r=$(jq -r '.prereqs.apt_refresh_mode // empty' "$CONFIG" 2>/dev/null)
            [ -n "$r" ] && LARAVEL_APT_REFRESH="$r"
        fi
        if [ -z "$LARAVEL_PHP_VERSION" ]; then
            local pv
            pv=$(jq -r '.components.php.default_version // empty' "$CONFIG" 2>/dev/null)
            [ -n "$pv" ] && LARAVEL_PHP_VERSION="$pv"
        fi
        if [ -z "$LARAVEL_DB_ENGINE" ]; then
            local de
            de=$(jq -r '.components.database.default_engine // empty' "$CONFIG" 2>/dev/null)
            [ -n "$de" ] && LARAVEL_DB_ENGINE="$de"
        fi
    fi
    LARAVEL_APT_REFRESH="${LARAVEL_APT_REFRESH:-none}"
    LARAVEL_PHP_VERSION="${LARAVEL_PHP_VERSION:-8.3}"
    LARAVEL_DB_ENGINE="${LARAVEL_DB_ENGINE:-mysql}"
}
_resolve_config_defaults

# ---- interactive prompts ----------------------------------------------------
_prompt() {
    local label="$1" default="$2" reply=""
    if [ ! -t 0 ] && [ ! -e /dev/tty ]; then
        echo "$default"
        return
    fi
    printf '  %s [%s]: ' "$label" "$default" > /dev/tty
    if ! IFS= read -r reply < /dev/tty; then
        echo "$default"
        return
    fi
    [ -z "$reply" ] && reply="$default"
    echo "$reply"
}

_run_interactive() {
    log_info "[77] Interactive mode -- press Enter to accept the [default]"
    LARAVEL_INSTALL_PATH="$(_prompt 'Laravel install directory (absolute path)' "$LARAVEL_INSTALL_PATH")"
    LARAVEL_APP_NAME="$(_prompt     'Laravel App Name'                         "$LARAVEL_APP_NAME")"
    LARAVEL_SITE_PORT="$(_prompt    'nginx HTTP port'                          "$LARAVEL_SITE_PORT")"
    LARAVEL_SERVER_NAME="$(_prompt  'Server name / domain'                     "$LARAVEL_SERVER_NAME")"
    LARAVEL_PHP_VERSION="$(_prompt  'PHP version (8.2|8.3|latest)'             "$LARAVEL_PHP_VERSION")"
    LARAVEL_DB_ENGINE="$(_prompt    'DB engine (mysql|mariadb|pgsql|sqlite)'   "$LARAVEL_DB_ENGINE")"
    if [ "$LARAVEL_DB_ENGINE" != "sqlite" ]; then
        LARAVEL_DB_HOST="$(_prompt  'DB host'                                  "$LARAVEL_DB_HOST")"
        LARAVEL_DB_PORT="$(_prompt  'DB port'                                  "$LARAVEL_DB_PORT")"
        LARAVEL_DB_NAME="$(_prompt  'DB name'                                  "$LARAVEL_DB_NAME")"
        LARAVEL_DB_USER="$(_prompt  'DB user'                                  "$LARAVEL_DB_USER")"
        LARAVEL_DB_PASS="$(_prompt  'DB password (blank = auto-generate)'      "$LARAVEL_DB_PASS")"
    fi
    LARAVEL_ENABLE_QUEUE="$(_prompt     'Enable systemd queue worker? (1=yes, 0=no)' "$LARAVEL_ENABLE_QUEUE")"
    LARAVEL_ENABLE_SCHEDULER="$(_prompt 'Enable crontab scheduler? (1=yes, 0=no)'    "$LARAVEL_ENABLE_SCHEDULER")"
    LARAVEL_RUN_MIGRATIONS="$(_prompt   'Run migrations? (1=yes, 0=no)'              "$LARAVEL_RUN_MIGRATIONS")"

    export LARAVEL_INSTALL_PATH LARAVEL_APP_NAME LARAVEL_SITE_PORT LARAVEL_SERVER_NAME \
           LARAVEL_PHP_VERSION LARAVEL_DB_ENGINE LARAVEL_DB_HOST LARAVEL_DB_PORT \
           LARAVEL_DB_NAME LARAVEL_DB_USER LARAVEL_DB_PASS LARAVEL_ENABLE_QUEUE \
           LARAVEL_ENABLE_SCHEDULER LARAVEL_RUN_MIGRATIONS
}

if [ "$INTERACTIVE" = "1" ] && [ "$VERB" = "install" ]; then
    _run_interactive
fi

# ---- APT refresh helper ----------------------------------------------------
_run_apt_refresh() {
    case "$LARAVEL_APT_REFRESH" in
        ""|none) return 0 ;;
        update|upgrade|dist-upgrade) ;;
        *)
            log_warn "[77][apt] invalid mode '$LARAVEL_APT_REFRESH' -- defaulting to 'none'"
            return 0 ;;
    esac
    if ! command -v apt-get >/dev/null 2>&1; then
        return 0
    fi
    log_info "[77][apt] $LARAVEL_APT_REFRESH -- refreshing package index"
    sudo apt-get update -y >/dev/null 2>&1 || true
    if [ "$LARAVEL_APT_REFRESH" = "upgrade" ]; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends >/dev/null 2>&1 || true
    elif [ "$LARAVEL_APT_REFRESH" = "dist-upgrade" ]; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y --no-install-recommends >/dev/null 2>&1 || true
    fi
    return 0
}

# ---- verb dispatchers -------------------------------------------------------
_install_prerequisites() {
    log_info "[77][prereqs] === installing prerequisites ==="
    _run_apt_refresh
    component_php_install       || return 1
    component_composer_install  || return 1
    component_database_install  || return 1
    log_ok "[77][prereqs] === prerequisites complete ==="
    return 0
}

_install_one() {
    case "$1" in
        php)       component_php_install ;;
        composer)  component_composer_install ;;
        database|db) component_database_install ;;
        laravel)   component_laravel_install ;;
        nginx)     component_nginx_install ;;
        daemon)    component_daemon_install ;;
        postinstall|postinstall-verify) component_postinstall_verify ;;
        prereqs|prerequisites) _install_prerequisites ;;
        *)         log_err "[77] Unknown component: '$1'"; return 2 ;;
    esac
}

_install_all() {
    write_install_paths \
      --tool   "Laravel full stack (Nginx + PHP-FPM + Composer 2 + $LARAVEL_DB_ENGINE + Queue + Cron)" \
      --source "Ubuntu APT + Composer + official Laravel skeleton" \
      --temp   "/var/cache/apt/archives + /tmp/composer-setup.php" \
      --target "$LARAVEL_INSTALL_PATH (docroot: /public) + nginx vhost + daemons"

    log_info "[77] Starting Ubuntu Laravel installer (engine=$LARAVEL_DB_ENGINE php=$LARAVEL_PHP_VERSION path=$LARAVEL_INSTALL_PATH)"
    local rc=0
    _install_prerequisites     || rc=$?
    [ $rc -eq 0 ] && component_laravel_install || rc=$?
    [ $rc -eq 0 ] && component_nginx_install   || rc=$?
    [ $rc -eq 0 ] && component_daemon_install  || rc=$?
    if [ $rc -eq 0 ]; then
        if ! component_postinstall_verify; then
            log_warn "[77] post-install verification failed -- examine postinstall logs above"
            rc=1
        fi
    fi
    return $rc
}

_check_all() {
    local rc=0
    component_php_verify        && log_ok "[77][verify] PHP OK"       || { log_err "[77][verify] PHP FAILED";       rc=1; }
    component_composer_verify   && log_ok "[77][verify] Composer OK"  || { log_err "[77][verify] Composer FAILED";  rc=1; }
    component_database_verify   && log_ok "[77][verify] Database OK"  || { log_err "[77][verify] Database FAILED";  rc=1; }
    component_laravel_verify    && log_ok "[77][verify] Laravel OK"   || { log_err "[77][verify] Laravel FAILED";   rc=1; }
    component_nginx_verify      && log_ok "[77][verify] Nginx OK"     || { log_err "[77][verify] Nginx FAILED";     rc=1; }
    component_daemon_verify     && log_ok "[77][verify] Daemons OK"   || { log_err "[77][verify] Daemons FAILED";   rc=1; }
    component_postinstall_verify && log_ok "[77][verify] Postinstall 4-gate OK" || { log_err "[77][verify] Postinstall FAILED"; rc=1; }
    return $rc
}

_uninstall_all() {
    log_info "[77][uninstall] === uninstalling Laravel stack ==="
    local rc=0
    component_daemon_uninstall   || rc=$?
    component_nginx_uninstall    || rc=$?
    component_laravel_uninstall  || rc=$?
    component_database_uninstall || rc=$?
    component_composer_uninstall || rc=$?
    log_info "[77][uninstall] PHP packages are preserved by default."
    log_info "[77] To remove PHP packages explicitly, run: $0 uninstall php"
    if [ "$rc" -eq 0 ]; then
        log_ok "[77][uninstall] === uninstall complete ==="
    else
        log_warn "[77][uninstall] uninstall finished with errors (rc=$rc)"
    fi
    return $rc
}

# ---- main execution ---------------------------------------------------------
rc=0
case "$VERB" in
    install)
        if [ -n "$SUBCOMPONENT" ]; then
            _install_one "$SUBCOMPONENT" || rc=$?
        else
            _install_all || rc=$?
        fi
        if [ $rc -eq 0 ]; then
            echo ""
            log_info "[77] === Laravel Installation Summary ==="
            log_info "[77]   App Name    : $LARAVEL_APP_NAME"
            log_info "[77]   Site URL    : http://${LARAVEL_SERVER_NAME}:${LARAVEL_SITE_PORT}/"
            log_info "[77]   Install Dir : $LARAVEL_INSTALL_PATH"
            log_info "[77]   Doc Root    : $LARAVEL_INSTALL_PATH/public"
            log_info "[77]   DB Engine   : $LARAVEL_DB_ENGINE"
            log_info "[77]   Credentials : $ROOT/.installed/77-laravel-credentials.json"
            log_info "[77]   Queue Unit  : /etc/systemd/system/laravel-queue.service"
            log_info "[77]   Scheduler   : /etc/cron.d/laravel-scheduler"
            if [ "${LARAVEL_SHOW_CREDENTIALS:-0}" = "1" ]; then
                component_laravel_show_credentials || true
            else
                log_info "[77]   (run '$0 show-credentials' to view credentials)"
            fi
        fi
        ;;
    check)
        _check_all || rc=$?
        ;;
    verify)
        component_postinstall_verify || rc=$?
        ;;
    show-credentials)
        if [ "$SHOW_CREDS_JSON" = "1" ]; then
            component_laravel_show_credentials --json || rc=$?
        else
            component_laravel_show_credentials || rc=$?
        fi
        ;;
    repair)
        rm -f "$ROOT/.installed/77-"*.ok 2>/dev/null || true
        _install_all || rc=$?
        ;;
    uninstall)
        if [ -n "$SUBCOMPONENT" ]; then
            case "$SUBCOMPONENT" in
                php)         component_php_uninstall ;;
                composer)    component_composer_uninstall ;;
                database|db) component_database_uninstall ;;
                laravel)     component_laravel_uninstall ;;
                nginx)       component_nginx_uninstall ;;
                daemon)      component_daemon_uninstall ;;
                *)           log_err "[77] Unknown uninstall component: '$SUBCOMPONENT'"; rc=2 ;;
            esac
        else
            _uninstall_all || rc=$?
        fi
        ;;
    *)
        log_err "[77] Unknown verb: '$VERB' -- run with --help for usage"
        rc=2
        ;;
esac

exit $rc
