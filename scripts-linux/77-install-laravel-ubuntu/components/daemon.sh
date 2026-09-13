#!/usr/bin/env bash
# scripts-linux/77-install-laravel-ubuntu/components/daemon.sh
# Configures systemd queue worker units and crontab schedule runner for Laravel.
set -u

component_daemon_verify() {
    local q_unit="/etc/systemd/system/laravel-queue.service"
    local c_file="/etc/cron.d/laravel-scheduler"
    [ -f "$q_unit" ] || return 1
    [ -f "$c_file" ] || return 1
    return 0
}

component_daemon_install() {
    local install_path="${LARAVEL_INSTALL_PATH:-/var/www/laravel}"
    local app_name="${LARAVEL_APP_NAME:-laravel-app}"
    local enable_queue="${LARAVEL_ENABLE_QUEUE:-1}"
    local enable_scheduler="${LARAVEL_ENABLE_SCHEDULER:-1}"

    log_info "[77][daemon] setting up background daemons (queue=$enable_queue, scheduler=$enable_scheduler)"

    # 1. Systemd generic instanced queue unit: laravel-queue@.service
    local instance_unit="/etc/systemd/system/laravel-queue@.service"
    log_info "[77][daemon] writing instanced systemd unit -> $instance_unit"
    if ! sudo tee "$instance_unit" >/dev/null <<'EOF'
[Unit]
Description=Laravel Queue Worker (%i)
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
Restart=always
RestartSec=5s
ExecStart=/usr/bin/php %I/artisan queue:work --sleep=3 --tries=3 --max-time=3600

[Install]
WantedBy=multi-user.target
EOF
    then
        log_file_error "$instance_unit" "failed to write laravel-queue@.service"
        return 1
    fi

    # 2. Systemd dedicated queue unit: laravel-queue.service
    local main_unit="/etc/systemd/system/laravel-queue.service"
    log_info "[77][daemon] writing systemd unit -> $main_unit"
    if ! sudo tee "$main_unit" >/dev/null <<EOF
[Unit]
Description=Laravel Queue Worker (${app_name})
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
Restart=always
RestartSec=5s
WorkingDirectory=${install_path}
ExecStart=/usr/bin/php ${install_path}/artisan queue:work --sleep=3 --tries=3 --max-time=3600

[Install]
WantedBy=multi-user.target
EOF
    then
        log_file_error "$main_unit" "failed to write laravel-queue.service"
        return 1
    fi

    sudo systemctl daemon-reload 2>/dev/null || true

    if [ "$enable_queue" = "1" ]; then
        log_info "[77][daemon] enabling and starting laravel-queue.service"
        sudo systemctl enable laravel-queue.service >/dev/null 2>&1 || true
        if ! sudo systemctl restart laravel-queue.service 2>/dev/null; then
            log_warn "[77][daemon] systemctl restart laravel-queue.service had warnings (may need jobs table migration first)"
        else
            log_ok "[77][daemon] laravel-queue.service active"
        fi
    fi

    # 3. Crontab scheduler: /etc/cron.d/laravel-scheduler
    local cron_file="/etc/cron.d/laravel-scheduler"
    if [ "$enable_scheduler" = "1" ]; then
        log_info "[77][daemon] configuring artisan crontab scheduler -> $cron_file"
        if ! sudo tee "$cron_file" >/dev/null <<EOF
# Written by 77-install-laravel-ubuntu (Laravel Schedule Runner)
* * * * * www-data cd ${install_path} && /usr/bin/php artisan schedule:run >> /dev/null 2>&1
EOF
        then
            log_file_error "$cron_file" "failed to write /etc/cron.d/laravel-scheduler"
            return 1
        fi
        sudo chmod 644 "$cron_file" 2>/dev/null || true
        sudo systemctl reload cron 2>/dev/null || true
        log_ok "[77][daemon] artisan scheduler cron installed"
    fi

    mkdir -p "$ROOT/.installed" && touch "$ROOT/.installed/77-daemon.ok"
    return 0
}

component_daemon_uninstall() {
    local main_unit="/etc/systemd/system/laravel-queue.service"
    local instance_unit="/etc/systemd/system/laravel-queue@.service"
    local cron_file="/etc/cron.d/laravel-scheduler"

    log_info "[77][daemon] removing queue worker units and crontab scheduler"
    sudo systemctl stop laravel-queue.service 2>/dev/null || true
    sudo systemctl disable laravel-queue.service 2>/dev/null || true

    sudo rm -f "$main_unit" "$instance_unit" 2>/dev/null || true
    sudo systemctl daemon-reload 2>/dev/null || true

    if [ -f "$cron_file" ]; then
        sudo rm -f "$cron_file" 2>/dev/null || true
        sudo systemctl reload cron 2>/dev/null || true
        log_ok "[77][daemon] removed $cron_file"
    fi

    rm -f "$ROOT/.installed/77-daemon.ok" 2>/dev/null || true
    log_ok "[77][daemon] daemon uninstallation complete"
    return 0
}
