#!/usr/bin/env bash
# --------------------------------------------------------------------------
#  set-static-ip.sh -- Configure static IP via Netplan for cluster node
# --------------------------------------------------------------------------
set -u

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_REPO_ROOT="$(cd "$_SCRIPT_DIR/../.." && pwd)"

source "$_REPO_ROOT/kubernetes/01-base-helpers/logger.sh"

show_help() {
  echo ""
  echo "Usage: $0 <ip-address> [gateway-ip] [interface]"
  echo ""
  echo "Example:"
  echo "  $0 192.168.0.21 192.168.0.1 ens33"
  echo ""
}

assert_root_user() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    log_message "This script must be executed as root (sudo)." "error"

    return 1
  fi

  return 0
}

write_netplan_yaml() {
  local ip="$1"
  local gateway="$2"
  local iface="$3"
  local netplan_file="/etc/netplan/00-installer-config.yaml"

  mkdir -p /etc/netplan

  cat > "$netplan_file" <<EOF
network:
  renderer: networkd
  ethernets:
    $iface:
      dhcp4: false
      addresses:
        - $ip/24
      routes:
        - to: default
          via: $gateway
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
  version: 2
EOF

  log_message "Netplan configuration written to $netplan_file" "success"
}

apply_netplan() {
  log_message "Testing and applying netplan configuration..." "info"

  if ! netplan try 2>/dev/null; then
    netplan apply
  else
    netplan apply
  fi

  log_message "Netplan applied successfully." "success"
}

main() {
  if [ $# -lt 1 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help

    return 0
  fi

  if ! assert_root_user; then
    return 1
  fi

  local ip="$1"
  local gateway="${2:-192.168.0.1}"
  local iface="${3:-ens33}"

  write_netplan_yaml "$ip" "$gateway" "$iface"
  apply_netplan

  return 0
}

main "$@"
