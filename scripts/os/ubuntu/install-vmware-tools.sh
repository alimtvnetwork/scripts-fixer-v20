#!/bin/bash
# install-vmware-tools.sh -- Install VMware Tools, mount shared folders, and configure startup automount
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
MUTED='\033[0;37m'
ERROR='\033[1;31m'
TEXT='\033[0m'

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ROOT_DIR="$(cd "$_SCRIPT_DIR/../../.." && pwd)"

if [ -f "$_ROOT_DIR/scripts/shared/db.sh" ]; then
    . "$_ROOT_DIR/scripts/shared/db.sh"
    ensure_db
fi

IS_FORCE=false
for arg in "$@"; do
    if [ "$arg" = "--force" ] || [ "$arg" = "-f" ]; then
        IS_FORCE=true
    fi
done

is_tools_installed() {
    if command -v vmware-toolbox-cmd >/dev/null 2>&1; then
        return 0
    fi

    if [ -x "/usr/bin/vmware-toolbox-cmd" ]; then
        return 0
    fi

    if command -v vmhgfs-fuse >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

setup_startup_mount() {
    local runner="/usr/local/bin/vmware-mount-shared.sh"
    local service_file="/etc/systemd/system/vmware-mount-shared.service"

    echo -e "  ${SECONDARY}[  ..  ] Setting up persistent VMware shared mount on boot...${TEXT}"

    if [ -f "$_SCRIPT_DIR/vmware-mount-shared.sh" ]; then
        sudo cp -f "$_SCRIPT_DIR/vmware-mount-shared.sh" "$runner"
        sudo chmod +x "$runner"
    fi

    if command -v systemctl >/dev/null 2>&1 && [ -d "/etc/systemd/system" ]; then
        sudo bash -c "cat <<'EOF' > $service_file
[Unit]
Description=Mount VMware Shared Folders
ConditionVirtualization=vmware
After=open-vm-tools.service

[Service]
Type=oneshot
ExecStart=$runner
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF"
        sudo systemctl daemon-reload 2>/dev/null || true
        sudo systemctl enable vmware-mount-shared.service 2>/dev/null || true
        echo -e "  ${PRIMARY}[  OK  ] Configured systemd service: vmware-mount-shared.service${TEXT}"

        return 0
    fi

    # Fallback to crontab @reboot if systemd not active
    local cron_job="@reboot $runner"
    if command -v crontab >/dev/null 2>&1; then
        ( crontab -l 2>/dev/null | grep -F -v "$runner" ; echo "$cron_job" ) | crontab - 2>/dev/null || true
        echo -e "  ${PRIMARY}[  OK  ] Configured crontab startup mount: $cron_job${TEXT}"

        return 0
    fi

    return 0
}

main() {
    echo -e "  ${SECONDARY}[  ..  ] Checking VMware Tools & Shared Folder configuration...${TEXT}"

    if [ "$IS_FORCE" != "true" ] && is_tools_installed && db_is_installed package "vmware-tools"; then
        echo -e "  ${PRIMARY}[  OK  ] VMware Tools is already installed.${TEXT}"
        bash "$_SCRIPT_DIR/vmware-mount-shared.sh"
        db_record_skipped package "vmware-tools" "already installed"

        return 0
    fi

    db_record_start package "vmware-tools" "install"
    echo -e "  ${SECONDARY}[  ..  ] Installing open-vm-tools and open-vm-tools-desktop via apt...${TEXT}"

    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y || true
        sudo apt-get install -y open-vm-tools open-vm-tools-desktop || {
            echo -e "  ${ERROR}✖ Failed to install open-vm-tools via apt.${TEXT}"
            db_record_failure package "vmware-tools" 1 "apt-get install failed"

            return 1
        }
    fi

    local ver="unknown"
    if [ -x "/usr/bin/vmware-toolbox-cmd" ]; then
        ver=$(/usr/bin/vmware-toolbox-cmd -v 2>/dev/null || echo "installed")
        echo -e "  ${PRIMARY}[  OK  ] VMware Tools verified: $ver${TEXT}"
    fi

    bash "$_SCRIPT_DIR/vmware-mount-shared.sh" || true
    setup_startup_mount || true

    db_record_success package "vmware-tools" "$ver" "open-vm-tools and shared folders mounted"
    echo -e "  ${PRIMARY}[ DONE ] VMware Tools setup & shared folder automount complete.${TEXT}"

    return 0
}

main "$@"
