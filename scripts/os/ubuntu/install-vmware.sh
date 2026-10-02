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

  if command -v vmplayer >/dev/null 2>&1 || [ -x "/usr/bin/vmplayer" ]; then
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
  echo -e "\e[1;33m[  ..  ] Installing core prerequisites: build-essential linux-headers-${kver} git dkms libssl-dev libelf-dev...\e[0m"

  sudo apt-get update -qq || true
  local core_pkgs=(
    "build-essential"
    "linux-headers-${kver}"
    "git"
    "dkms"
    "libssl-dev"
    "libelf-dev"
  )

  if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${core_pkgs[@]}"; then
    log_file_error "/usr/src/linux-headers-${kver}" "failed to install core build prerequisites via apt"

    return 1
  fi

  return 0
}

get_aio_package() {
  local has_t64=false

  if dpkg -s libaio1t64 >/dev/null 2>&1 || apt-cache show libaio1t64 >/dev/null 2>&1; then
    has_t64=true
  fi

  if [ "$has_t64" = "true" ]; then
    echo "libaio1t64"

    return 0
  fi

  echo "libaio1"

  return 0
}

install_aio_runtime() {
  local has_aio=false

  if dpkg -s libaio1t64 >/dev/null 2>&1 || dpkg -s libaio1 >/dev/null 2>&1; then
    has_aio=true
  fi

  if [ "$has_aio" = "true" ]; then
    return 0
  fi

  local aio_pkg
  aio_pkg="$(get_aio_package)"

  if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$aio_pkg" 2>/dev/null; then
    return 0
  fi

  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y libaio1 2>/dev/null || true

  return 0
}

install_gl_prerequisites() {
  echo -e "\e[1;33m[  ..  ] Installing GL/X11 runtime libraries...\e[0m"
  local aio_pkg
  aio_pkg="$(get_aio_package)"
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
    "$aio_pkg"
  )

  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${gl_pkgs[@]}" 2>/dev/null || true
  install_aio_runtime

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

get_local_bundle_path() {
  local has_env_bundle=false
  [ -n "${VMWARE_BUNDLE_PATH:-}" ] && [ -f "${VMWARE_BUNDLE_PATH:-}" ] && has_env_bundle=true

  if [ "$has_env_bundle" = "true" ]; then
    echo "$VMWARE_BUNDLE_PATH"

    return 0
  fi

  for candidate in /tmp/VMware-Workstation*.bundle /tmp/VMware-Player*.bundle /tmp/vmware-installer.bundle; do
    local has_candidate=false
    [ -f "$candidate" ] && [ -s "$candidate" ] && has_candidate=true

    if [ "$has_candidate" = "true" ]; then
      echo "$candidate"

      return 0
    fi
  done

  return 1
}

get_bundle_urls() {
  local version="${VMWARE_VERSION:-17.5.2}"
  local build="${VMWARE_BUILD:-23775571}"
  local custom_url="${VMWARE_DOWNLOAD_URL:-}"
  local local_bundle
  local_bundle="$(get_local_bundle_path 2>/dev/null || true)"

  if [ -n "$local_bundle" ]; then
    echo "$local_bundle"
  fi

  if [ -n "$custom_url" ]; then
    echo "$custom_url"
  fi

  echo "https://download3.vmware.com/software/WKST-1752-LX/VMware-Workstation-Full-${version}-${build}.x86_64.bundle"
  echo "https://archive.org/download/vmware-workstation-full-17.5.2-23775571/VMware-Workstation-Full-${version}-${build}.x86_64.bundle"
  echo "https://archive.org/download/vmware-workstation-full-17.6.0-24238078/VMware-Workstation-Full-17.6.0-24238078.x86_64.bundle"
  echo "https://download3.vmware.com/software/wkst/VMware-Workstation-Full-${version}-${build}.x86_64.bundle"
  echo "https://download3.vmware.com/software/WKST-1750-LX/VMware-Workstation-Full-17.5.0-22583795.x86_64.bundle"
}

download_bundle_from_url() {
  local url="$1"
  local target_file="$2"
  local has_local=false
  [ -f "$url" ] && has_local=true

  if [ "$has_local" = "true" ]; then
    echo -e "\e[1;33m[  ..  ] Using local VMware bundle: $url...\e[0m"
    [ "$url" != "$target_file" ] && cp -f "$url" "$target_file"

    return 0
  fi

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
  local has_file=false
  [ -f "$bundle_path" ] && has_file=true

  if [ "$has_file" = "true" ]; then
    rm -f "$bundle_path" || log_file_error "$bundle_path" "failed to remove temp bundle"
  fi
}

get_vmware_version() {
  if [ -n "${VMWARE_VERSION:-}" ]; then
    echo "$VMWARE_VERSION"

    return 0
  fi

  if command -v vmware >/dev/null 2>&1; then
    local raw_ver
    raw_ver="$(vmware -v 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)"

    if [ -n "$raw_ver" ]; then
      echo "$raw_ver"

      return 0
    fi
  fi

  echo "17.5.2"

  return 0
}

clone_community_repo() {
  local target_dir="$1"
  local version
  version="$(get_vmware_version)"
  local repo_url="https://github.com/mkubecek/vmware-host-modules.git"
  local branch="workstation-${version}"

  echo -e "\e[1;33m[  ..  ] Cloning vmware-host-modules ($branch)...\e[0m"

  if git clone --depth 1 -b "$branch" "$repo_url" "$target_dir" 2>/dev/null; then
    return 0
  fi

  echo -e "\e[1;33m[  ..  ] Branch $branch not found; cloning default branch...\e[0m"

  if git clone --depth 1 "$repo_url" "$target_dir" 2>/dev/null; then
    return 0
  fi

  log_file_error "$target_dir" "failed to git clone vmware-host-modules"

  return 1
}

fetch_community_patch() {
  local patch_tar="$1"
  local patch_url="$2"
  echo -e "\e[1;33m[  ..  ] Downloading VMware host modules community patch...\e[0m"

  if curl -f -sLo "$patch_tar" "$patch_url"; then
    return 0
  fi

  log_file_error "$patch_tar" "failed to download community patch from $patch_url"

  return 1
}

extract_community_patch() {
  local patch_tar="$1"
  local target_dir="$2"

  if tar -xzf "$patch_tar" -C "$target_dir" 2>/dev/null; then
    return 0
  fi

  log_file_error "$patch_tar" "failed to extract community patch archive"

  return 1
}

compile_community_patch() {
  local patch_dir="$1"
  echo -e "\e[1;33m[  ..  ] Compiling vmmon and vmnet from community patch...\e[0m"
  make -C "$patch_dir" clean 2>/dev/null || true

  if make -C "$patch_dir" -j"$(nproc 2>/dev/null || echo 2)"; then
    return 0
  fi

  log_file_error "$patch_dir" "community kernel module compilation failed"

  return 1
}

install_community_modules() {
  local patch_dir="$1"
  sudo make -C "$patch_dir" install 2>/dev/null || true

  if [ -f "$patch_dir/vmmon.tar" ] && [ -f "$patch_dir/vmnet.tar" ] && [ -d "/usr/lib/vmware/modules/source" ]; then
    sudo cp -f "$patch_dir/vmmon.tar" "$patch_dir/vmnet.tar" "/usr/lib/vmware/modules/source/" 2>/dev/null || true
  fi

  sudo depmod -a 2>/dev/null || true
  sudo modprobe vmmon 2>/dev/null || true
  sudo modprobe vmnet 2>/dev/null || true

  local has_vmmon=false
  lsmod | grep -q "^vmmon" && has_vmmon=true

  if [ "$has_vmmon" = "true" ]; then
    echo -e "\e[1;32m✔ Modern kernel modules vmmon and vmnet built and loaded.\e[0m"

    return 0
  fi

  log_file_error "/lib/modules/$(uname -r)" "failed to load compiled vmmon module"

  return 1
}

fetch_community_source() {
  local patch_dir="$1"
  local patch_tar="$2"
  local patch_url="$3"

  if fetch_community_patch "$patch_tar" "$patch_url" && extract_community_patch "$patch_tar" "/tmp"; then
    return 0
  fi

  local fallback_url="https://github.com/mkubecek/vmware-host-modules/archive/refs/heads/master.tar.gz"

  if fetch_community_patch "$patch_tar" "$fallback_url" && extract_community_patch "$patch_tar" "/tmp"; then
    return 0
  fi

  rm -rf "$patch_dir" "$patch_tar" 2>/dev/null || true

  if clone_community_repo "$patch_dir"; then
    return 0
  fi

  return 1
}

build_community_modules() {
  local version
  version="$(get_vmware_version)"
  local patch_url="https://github.com/mkubecek/vmware-host-modules/archive/refs/heads/workstation-${version}.tar.gz"
  local patch_tar="/tmp/vmware-host-modules-${version}.tar.gz"
  local patch_dir="/tmp/vmware-host-modules-workstation-${version}"

  rm -rf "$patch_dir" "$patch_tar" 2>/dev/null || true

  if ! fetch_community_source "$patch_dir" "$patch_tar" "$patch_url"; then
    return 1
  fi

  if ! compile_community_patch "$patch_dir"; then
    rm -rf "$patch_dir" "$patch_tar" 2>/dev/null || true

    return 1
  fi

  local has_installed=false
  install_community_modules "$patch_dir" && has_installed=true
  rm -rf "$patch_dir" "$patch_tar" 2>/dev/null || true

  if [ "$has_installed" = "true" ]; then
    return 0
  fi

  return 1
}

build_kernel_modules() {
  local has_modconfig=false

  if command -v vmware-modconfig >/dev/null 2>&1 || [ -x "/usr/bin/vmware-modconfig" ]; then
    has_modconfig=true
  fi

  if [ "$has_modconfig" = "false" ]; then
    echo -e "\e[1;33m[ WARN ] vmware-modconfig not found; attempting community host modules fallback...\e[0m"
    build_community_modules

    return $?
  fi

  echo -e "\e[1;33m[  ..  ] Building VMware kernel modules (vmmon, vmnet)...\e[0m"

  if sudo vmware-modconfig --console --install-all 2>/dev/null; then
    echo -e "\e[1;32m✔ Kernel modules vmmon and vmnet built successfully.\e[0m"

    return 0
  fi

  echo -e "\e[1;33m[ WARN ] vmware-modconfig failed. Invoking modern kernel patch fallback...\e[0m"

  if build_community_modules; then
    return 0
  fi

  log_file_error "/usr/lib/vmware/modules" "vmware-modconfig and community fallback failed to build kernel modules"

  return 1
}

validate_vmware_installation() {
  local has_bin=false
  local has_lib=false

  if [ -x "/usr/bin/vmware" ] || command -v vmware >/dev/null 2>&1; then
    has_bin=true
  fi

  if [ -x "/usr/bin/vmplayer" ] || command -v vmplayer >/dev/null 2>&1; then
    has_bin=true
  fi

  if [ -d "/usr/lib/vmware" ]; then
    has_lib=true
  fi

  if [ "$has_bin" = "true" ] && [ "$has_lib" = "true" ]; then
    echo -e "\e[1;32m✔ Validated VMware installation: binary (vmware/vmplayer) and /usr/lib/vmware present.\e[0m"

    return 0
  fi

  log_file_error "/usr/bin/vmware" "validation failed: vmware/vmplayer binary or /usr/lib/vmware missing"

  return 1
}

enable_vmware_services() {
  if ! command -v systemctl >/dev/null 2>&1; then
    if [ -x "/etc/init.d/vmware" ]; then
      sudo /etc/init.d/vmware start 2>/dev/null || true
    fi

    return 0
  fi

  echo -e "\e[1;33m[  ..  ] Enabling and starting VMware systemd services...\e[0m"
  sudo systemctl daemon-reload 2>/dev/null || true
  sudo systemctl enable --now vmware.service 2>/dev/null || true
  sudo systemctl enable --now vmware-USBArbitrator.service 2>/dev/null || true
  sudo systemctl start vmware.service 2>/dev/null || true

  local is_active=false

  if systemctl is-active --quiet vmware.service 2>/dev/null; then
    is_active=true
  fi

  if [ "$is_active" = "true" ]; then
    echo -e "\e[1;32m✔ VMware systemd service is active and enabled.\e[0m"

    return 0
  fi

  echo -e "\e[1;33m[ WARN ] vmware.service not active; attempting init.d start...\e[0m"

  if [ -x "/etc/init.d/vmware" ]; then
    sudo /etc/init.d/vmware start 2>/dev/null || true
  fi

  return 0
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
  enable_vmware_services || true

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
  echo -e "\e[1;36mℹ Installing VMware Workstation/Player\e[0m"
  local temp_bundle="/tmp/vmware-installer.bundle"
  local target_paths="/usr/bin/vmware, /usr/bin/vmplayer, /usr/lib/vmware"
  local urls
  urls="$(get_bundle_urls)"
  local primary_url
  primary_url="$(echo "$urls" | head -n 1)"
  log_install_paths "$primary_url" "$temp_bundle" "$target_paths" "VMware Workstation/Player"

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
  db_record_success package "vmware" "$ver" "VMware Workstation/Player installed"
  echo -e "\e[1;32m✔ VMware installation complete.\e[0m"

  return 0
}

main "$@"
