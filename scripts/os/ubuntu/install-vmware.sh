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
  local has_bin=false
  local has_lib=false

  if command -v vmware >/dev/null 2>&1 || [ -x "/usr/bin/vmware" ]; then
    has_bin=true
  fi

  if [ -d "/usr/lib/vmware" ]; then
    has_lib=true
  fi

  if [ "$has_bin" = "true" ] || [ "$has_lib" = "true" ]; then
    return 0
  fi

  return 1
}

has_prerequisites() {
  local kver
  kver="$(uname -r)"
  local has_build=false
  local has_headers=false
  local has_gl=false

  dpkg -s build-essential >/dev/null 2>&1 && has_build=true
  dpkg -s "linux-headers-$kver" >/dev/null 2>&1 && has_headers=true
  (dpkg -s libgl1 >/dev/null 2>&1 || dpkg -s libgl1-mesa-glx >/dev/null 2>&1) && has_gl=true

  if [ "$has_build" = "true" ] && [ "$has_headers" = "true" ] && [ "$has_gl" = "true" ]; then
    return 0
  fi

  return 1
}

install_core_prerequisites() {
  local kver
  kver="$(uname -r)"
  echo -e "\e[1;33m[  ..  ] Installing core prerequisites: build-essential linux-headers-${kver}...\e[0m"

  sudo apt-get update -qq || true
  local core_pkgs=(
    "build-essential"
    "linux-headers-${kver}"
  )

  if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${core_pkgs[@]}"; then
    log_file_error "/usr/src/linux-headers-${kver}" "failed to install core build prerequisites via apt"

    return 1
  fi

  return 0
}

install_gl_prerequisites() {
  echo -e "\e[1;33m[  ..  ] Installing GL/X11 runtime libraries...\e[0m"
  local gl_pkgs=(
    "libgl1"
    "libglx-mesa0"
    "libgl1-mesa-glx"
    "libcanberra-gtk-module"
    "libcanberra-gtk3-module"
    "libx11-6"
    "libxext6"
    "libxrender1"
    "libxtst6"
    "libxi6"
    "libaio1"
  )

  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${gl_pkgs[@]}" 2>/dev/null || true

  return 0
}

install_prerequisites() {
  if ! install_core_prerequisites; then
    return 1
  fi

  install_gl_prerequisites

  return 0
}

ensure_prerequisites() {
  if has_prerequisites; then
    echo -e "\e[1;32m✔ Prerequisites build-essential, kernel headers, and GL/X11 libraries already present.\e[0m"

    return 0
  fi

  install_prerequisites

  return $?
}

get_bundle_urls() {
  local version="${VMWARE_VERSION:-17.5.2}"
  local build="${VMWARE_BUILD:-23775571}"
  local custom_url="${VMWARE_DOWNLOAD_URL:-}"

  if [ -n "$custom_url" ]; then
    echo "$custom_url"
  fi

  echo "https://download3.vmware.com/software/WKST-1752-LX/VMware-Workstation-Full-${version}-${build}.x86_64.bundle"
  echo "https://download3.vmware.com/software/wkst/VMware-Workstation-Full-${version}-${build}.x86_64.bundle"
  echo "https://download3.vmware.com/software/WKST-1750-LX/VMware-Workstation-Full-17.5.0-22583795.x86_64.bundle"
}

download_bundle_from_url() {
  local url="$1"
  local target_file="$2"
  echo -e "\e[1;33m[  ..  ] Downloading VMware bundle from $url...\e[0m"

  if curl -f -sLo "$target_file" "$url" && [ -s "$target_file" ]; then
    return 0
  fi

  log_file_error "$target_file" "curl download failed from $url"
  rm -f "$target_file" 2>/dev/null || true

  return 1
}

download_bundle() {
  local target_file="$1"
  local urls
  urls="$(get_bundle_urls)"

  for url in $urls; do
    if download_bundle_from_url "$url" "$target_file"; then
      return 0
    fi
  done

  log_file_error "$target_file" "all bundle download fallbacks failed"

  return 1
}

run_bundle_installer() {
  local bundle_path="$1"
  echo -e "\e[1;33m[  ..  ] Executing VMware installer bundle unattended...\e[0m"

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

build_kernel_modules() {
  local has_modconfig=false

  if command -v vmware-modconfig >/dev/null 2>&1 || [ -x "/usr/bin/vmware-modconfig" ]; then
    has_modconfig=true
  fi

  if [ "$has_modconfig" = "false" ]; then
    echo -e "\e[1;33m[ WARN ] vmware-modconfig not found; skipping kernel module compilation.\e[0m"

    return 0
  fi

  echo -e "\e[1;33m[  ..  ] Building VMware kernel modules (vmmon, vmnet)...\e[0m"
  if sudo vmware-modconfig --console --install-all; then
    echo -e "\e[1;32m✔ Kernel modules vmmon and vmnet built successfully.\e[0m"

    return 0
  fi

  log_file_error "/usr/lib/vmware/modules" "vmware-modconfig failed to build kernel modules"

  return 1
}

validate_vmware_installation() {
  local has_bin=false
  local has_lib=false

  if [ -x "/usr/bin/vmware" ] || command -v vmware >/dev/null 2>&1; then
    has_bin=true
  fi

  if [ -d "/usr/lib/vmware" ]; then
    has_lib=true
  fi

  if [ "$has_bin" = "true" ] && [ "$has_lib" = "true" ]; then
    echo -e "\e[1;32m✔ Validated VMware installation: /usr/bin/vmware and /usr/lib/vmware present.\e[0m"

    return 0
  fi

  log_file_error "/usr/bin/vmware" "validation failed: /usr/bin/vmware or /usr/lib/vmware missing"

  return 1
}

execute_vmware_setup() {
  local temp_path="$1"

  if ! ensure_prerequisites; then
    return 1
  fi

  if ! download_bundle "$temp_path"; then
    return 1
  fi

  local has_run_ok=true
  run_bundle_installer "$temp_path" || has_run_ok=false
  remove_temp_bundle "$temp_path"

  if [ "$has_run_ok" = "false" ]; then
    return 1
  fi

  build_kernel_modules || true

  if ! validate_vmware_installation; then
    return 1
  fi

  return 0
}

for arg in "$@"; do
  if [ "$arg" = "tools" ] || [ "$arg" = "--tools" ] || [ "$arg" = "mount" ] || [ "$arg" = "--mount" ]; then
    exec bash "$_SCRIPT_DIR/install-vmware-tools.sh" "$@"
  fi
done

main() {
  echo -e "\e[1;36mℹ Installing VMware Workstation\e[0m"
  local temp_bundle="/tmp/vmware-installer.bundle"
  local target_paths="/usr/bin/vmware, /usr/lib/vmware"
  local urls
  urls="$(get_bundle_urls)"
  local primary_url
  primary_url="$(echo "$urls" | head -n 1)"
  log_install_paths "$primary_url" "$temp_bundle" "$target_paths" "VMware Workstation"

  if is_vmware_installed; then
    echo -e "\e[1;32m✔ VMware is already installed.\e[0m"
    db_record_skipped package "vmware" "already installed"

    return 0
  fi

  db_record_start package "vmware" "install"
  if ! execute_vmware_setup "$temp_bundle"; then
    db_record_failure package "vmware" 1 "installation failed"

    return 1
  fi

  local ver="${VMWARE_VERSION:-17.5.2}"
  db_record_success package "vmware" "$ver" "VMware Workstation installed"
  echo -e "\e[1;32m✔ VMware installation complete.\e[0m"

  return 0
}

main "$@"
