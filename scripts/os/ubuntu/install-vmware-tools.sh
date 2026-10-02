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

if [ -f "$_ROOT_DIR/scripts-linux/_shared/logger.sh" ]; then
  . "$_ROOT_DIR/scripts-linux/_shared/logger.sh"
fi

if [ -f "$_ROOT_DIR/scripts-linux/_shared/install-paths.sh" ]; then
  . "$_ROOT_DIR/scripts-linux/_shared/install-paths.sh"
fi

if [ -f "$_ROOT_DIR/scripts/shared/db.sh" ]; then
  . "$_ROOT_DIR/scripts/shared/db.sh"
  ensure_db
fi

if ! command -v log_file_error >/dev/null 2>&1; then
  log_file_error() {
    local path="${1:-<unknown>}"
    local reason="${2:-<no reason supplied>}"
    echo -e "\e[1;31m✖ [FILE-ERROR] path='$path' reason='$reason'\e[0m" >&2
  }
fi

log_install_paths() {
  local source_path="$1"
  local temp_path="$2"
  local target_path="$3"
  local tool_name="${4:-VMware Tools}"

  if command -v write_install_paths >/dev/null 2>&1; then
    write_install_paths --tool "$tool_name" --source "$source_path" --temp "$temp_path" --target "$target_path"
    return 0
  fi

  echo -e "\e[1;35m  [ PATH ] Install paths -- $tool_name\e[0m"
  echo -e "          Source : $source_path"
  echo -e "          Temp   : $temp_path"
  echo -e "          Target : $target_path\n"

  return 0
}

is_force=false
for arg in "$@"; do
  if [ "$arg" = "--force" ] || [ "$arg" = "-f" ]; then
    is_force=true
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

copy_mount_runner() {
  local src="$_SCRIPT_DIR/vmware-mount-shared.sh"
  local runner="/usr/local/bin/vmware-mount-shared.sh"

  if [ ! -f "$src" ]; then
    log_file_error "$src" "source script vmware-mount-shared.sh missing"
    return 1
  fi

  sudo cp -f "$src" "$runner" || {
    log_file_error "$runner" "failed to copy mount script"
    return 1
  }
  sudo chmod +x "$runner"

  return 0
}

write_systemd_mount_unit() {
  local runner="/usr/local/bin/vmware-mount-shared.sh"
  local service_file="/etc/systemd/system/vmware-mount-shared.service"

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
EOF" || {
    log_file_error "$service_file" "failed to write systemd unit"
    return 1
  }

  return 0
}

enable_systemd_mount_service() {
  write_systemd_mount_unit || return 1
  sudo systemctl daemon-reload 2>/dev/null || true
  sudo systemctl enable vmware-mount-shared.service 2>/dev/null || true
  echo -e "  ${PRIMARY}[  OK  ] Configured systemd service: vmware-mount-shared.service${TEXT}"

  return 0
}

configure_crontab_mount() {
  local runner="/usr/local/bin/vmware-mount-shared.sh"
  local cron_job="@reboot $runner"

  if ! command -v crontab >/dev/null 2>&1; then
    return 0
  fi

  ( crontab -l 2>/dev/null | grep -F -v "$runner" ; echo "$cron_job" ) | crontab - 2>/dev/null || {
    log_file_error "/var/spool/cron" "failed to update crontab for @reboot mount"
    return 1
  }
  echo -e "  ${PRIMARY}[  OK  ] Configured crontab startup mount: $cron_job${TEXT}"

  return 0
}

setup_startup_mount() {
  echo -e "  ${SECONDARY}[  ..  ] Setting up persistent VMware shared mount on boot...${TEXT}"
  copy_mount_runner || true

  local has_systemd=false
  command -v systemctl >/dev/null 2>&1 && [ -d "/etc/systemd/system" ] && has_systemd=true
  if [ "$has_systemd" = "true" ]; then
    enable_systemd_mount_service
    return $?
  fi

  configure_crontab_mount
  return $?
}

install_open_vm_tools() {
  echo -e "  ${SECONDARY}[  ..  ] Installing open-vm-tools and open-vm-tools-desktop via apt...${TEXT}"

  if ! command -v apt-get >/dev/null 2>&1; then
    log_file_error "/usr/bin/apt-get" "apt-get package manager not available"
    return 1
  fi

  sudo apt-get update -y || true
  if ! sudo apt-get install -y open-vm-tools open-vm-tools-desktop; then
    echo -e "  ${ERROR}✖ Failed to install open-vm-tools via apt.${TEXT}"
    log_file_error "/usr/bin/open-vm-tools" "apt-get install failed for open-vm-tools"
    return 1
  fi

  return 0
}

main() {
  echo -e "  ${SECONDARY}[  ..  ] Checking VMware Tools & Shared Folder configuration...${TEXT}"
  log_install_paths "apt repository (open-vm-tools)" "/var/cache/apt/archives" "/usr/bin/vmware-toolbox-cmd" "VMware Tools"

  local is_installed=false
  is_tools_installed && is_installed=true
  if [ "$is_force" != "true" ] && [ "$is_installed" = "true" ] && db_is_installed package "vmware-tools"; then
    echo -e "  ${PRIMARY}[  OK  ] VMware Tools is already installed.${TEXT}"
    bash "$_SCRIPT_DIR/vmware-mount-shared.sh"
    db_record_skipped package "vmware-tools" "already installed"
    return 0
  fi

  db_record_start package "vmware-tools" "install"
  if ! install_open_vm_tools; then
    db_record_failure package "vmware-tools" 1 "apt-get install failed"
    return 1
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
