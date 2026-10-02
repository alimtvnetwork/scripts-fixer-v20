#!/bin/bash
# Install VMware Workstation/Player on Ubuntu
set -e

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
  local tool_name="${4:-VMware Workstation}"

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

is_vmware_installed() {
  if command -v vmware >/dev/null 2>&1; then
    return 0
  fi

  if [ -x "/usr/bin/vmware" ]; then
    return 0
  fi

  if [ -d "/usr/lib/vmware" ]; then
    return 0
  fi

  return 1
}

has_prerequisites() {
  local kver
  kver="$(uname -r)"
  local has_build=false
  local has_headers=false

  dpkg -s build-essential >/dev/null 2>&1 && has_build=true
  dpkg -s "linux-headers-$kver" >/dev/null 2>&1 && has_headers=true

  if [ "$has_build" = "true" ] && [ "$has_headers" = "true" ]; then
    return 0
  fi

  return 1
}

install_prerequisites() {
  local kver
  kver="$(uname -r)"
  echo -e "\e[1;33m[  ..  ] Installing prerequisites: build-essential linux-headers-${kver}...\e[0m"

  sudo apt-get update -qq || true
  if ! sudo apt-get install -y build-essential "linux-headers-${kver}"; then
    log_file_error "/usr/src/linux-headers-${kver}" "failed to install prerequisites via apt"
    return 1
  fi

  return 0
}

ensure_prerequisites() {
  if has_prerequisites; then
    echo -e "\e[1;32m✔ Prerequisites build-essential and kernel headers already present.\e[0m"
    return 0
  fi

  install_prerequisites
  return $?
}

get_bundle_url() {
  local version="${VMWARE_VERSION:-17.5.2}"
  local build="${VMWARE_BUILD:-23775571}"
  local default_url="https://download3.vmware.com/software/WKST-1752-LX/VMware-Workstation-Full-${version}-${build}.x86_64.bundle"
  local installer_url="${VMWARE_DOWNLOAD_URL:-$default_url}"

  echo "$installer_url"
}

download_bundle() {
  local url="$1"
  local target_file="$2"
  echo -e "\e[1;33m[  ..  ] Downloading VMware installer bundle...\e[0m"

  if ! curl -sLo "$target_file" "$url"; then
    log_file_error "$target_file" "curl download failed from $url"
    return 1
  fi

  if [ ! -f "$target_file" ]; then
    log_file_error "$target_file" "downloaded installer bundle missing on disk"
    return 1
  fi

  return 0
}

run_bundle_installer() {
  local bundle_path="$1"
  echo -e "\e[1;33m[  ..  ] Executing VMware installer bundle...\e[0m"

  if ! chmod +x "$bundle_path"; then
    log_file_error "$bundle_path" "chmod +x failed"
    return 1
  fi

  if ! sudo "$bundle_path" --console --required --eulas-agreed; then
    log_file_error "$bundle_path" "bundle execution failed with rc=$?"
    return 1
  fi

  return 0
}

remove_temp_bundle() {
  local bundle_path="$1"
  if [ -f "$bundle_path" ]; then
    rm -f "$bundle_path" || log_file_error "$bundle_path" "failed to remove temp bundle"
  fi
}

execute_vmware_setup() {
  local bundle_url="$1"
  local temp_path="$2"

  if ! ensure_prerequisites; then
    return 1
  fi

  if ! download_bundle "$bundle_url" "$temp_path"; then
    return 1
  fi

  local has_run_ok=true
  run_bundle_installer "$temp_path" || has_run_ok=false
  remove_temp_bundle "$temp_path"
  [ "$has_run_ok" = "true" ] || return 1

  return 0
}

for arg in "$@"; do
  if [ "$arg" = "tools" ] || [ "$arg" = "--tools" ] || [ "$arg" = "mount" ] || [ "$arg" = "--mount" ]; then
    exec bash "$_SCRIPT_DIR/install-vmware-tools.sh" "$@"
  fi
done

main() {
  echo -e "\e[1;36mℹ Installing VMware Workstation\e[0m"
  local installer_url
  installer_url="$(get_bundle_url)"
  local temp_bundle="/tmp/vmware-installer.bundle"
  local target_paths="/usr/bin/vmware, /usr/lib/vmware"
  log_install_paths "$installer_url" "$temp_bundle" "$target_paths" "VMware Workstation"

  if is_vmware_installed; then
    echo -e "\e[1;32m✔ VMware is already installed.\e[0m"
    db_record_skipped package "vmware" "already installed"
    return 0
  fi

  db_record_start package "vmware" "install"
  if ! execute_vmware_setup "$installer_url" "$temp_bundle"; then
    db_record_failure package "vmware" 1 "installation failed"
    return 1
  fi

  local ver="${VMWARE_VERSION:-17.5.2}"
  db_record_success package "vmware" "$ver" "VMware Workstation installed"
  echo -e "\e[1;32m✔ VMware installation complete.\e[0m"

  return 0
}

main "$@"
