#!/usr/bin/env bash
# scripts-linux/_shared/machine-info.sh
# Cross-platform Machine Identity, Hostname & Network Adapter Inspector.
# Features parity with GitMap's Go implementation and scripts/os/helpers/machine-info.ps1.

set -u

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$__DIR/../.." && pwd)"
STORE_DIR="$REPO_ROOT/.installed"
STORE_FILE="$STORE_DIR/machine-identity.json"

if ! command -v log_info >/dev/null 2>&1; then
  # shellcheck disable=SC1091
  . "$__DIR/logger.sh" 2>/dev/null || true
fi

if ! command -v log_file_error >/dev/null 2>&1; then
  # shellcheck disable=SC1091
  . "$__DIR/file-error.sh" 2>/dev/null || true
fi

get_hostname() {
  hostname 2>/dev/null || uname -n 2>/dev/null || echo "unknown"
}

get_current_user() {
  id -un 2>/dev/null || whoami 2>/dev/null || echo "${USER:-unknown}"
}

get_cpu_cores() {
  getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1
}

get_architecture() {
  uname -m 2>/dev/null || echo "unknown"
}

get_linux_os_version() {
  local os_release="/etc/os-release"
  local has_os_release=0

  if [ -f "$os_release" ]; then
    has_os_release=1
  fi

  if [ "$has_os_release" -eq 1 ]; then
    local p_name
    p_name=$(grep -E '^PRETTY_NAME=' "$os_release" 2>/dev/null | cut -d= -f2- | tr -d '"')
    echo "${p_name:-Linux}"
    return 0
  fi

  uname -sr 2>/dev/null || echo "Linux"
}

get_primary_ip() {
  local ip_out=""
  local os_type
  os_type=$(uname -s)

  case "$os_type" in
    Darwin)
      if command -v ipconfig >/dev/null 2>&1; then
        ip_out=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true)
      fi
      ;;
    CYGWIN*|MINGW*|MSYS*)
      if command -v ipconfig >/dev/null 2>&1; then
        ip_out=$(ipconfig 2>/dev/null | sed -n 's/.*IPv4.*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -n1 | tr -d '\r')
      fi
      ;;
    *)
      if command -v ip >/dev/null 2>&1; then
        ip_out=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')
      fi
      if [ -z "$ip_out" ] && command -v hostname >/dev/null 2>&1; then
        ip_out=$(hostname -I 2>/dev/null | awk '{print $1}')
      fi
      ;;
  esac

  if [ -n "$ip_out" ]; then
    echo "$ip_out"
    return 0
  fi

  if command -v ifconfig >/dev/null 2>&1; then
    ip_out=$(ifconfig 2>/dev/null | awk '/inet / && !/127\.0\.0\.1/ {print $2; exit}')
  fi

  if [ -n "$ip_out" ]; then
    echo "$ip_out"
    return 0
  fi

  echo "127.0.0.1"
}

read_store_field() {
  local field="$1"
  local has_file=0

  if [ -f "$STORE_FILE" ]; then
    has_file=1
  fi

  if [ "$has_file" -eq 0 ]; then
    echo ""
    return 0
  fi

  if command -v jq >/dev/null 2>&1; then
    jq -r --arg f "$field" '.[$f] // empty' "$STORE_FILE" 2>/dev/null || echo ""
    return 0
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import json, sys; d=json.load(open('$STORE_FILE')); sys.stdout.write(str(d.get('$field','')))" 2>/dev/null || echo ""
    return 0
  fi

  grep -o "\"$field\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$STORE_FILE" 2>/dev/null | head -n1 | sed -E "s/.*\"$field\"[[:space:]]*:[[:space:]]*\"([^\"]*)\".*/\1/"
}

save_stored_config() {
  local new_alias="$1"
  local new_name="$2"
  local prev_alias="$3"
  local prev_name="$4"
  local ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date '+%Y-%m-%d %H:%M:%S')

  if [ ! -d "$STORE_DIR" ]; then
    if ! mkdir -p "$STORE_DIR" 2>/dev/null; then
      if command -v log_file_error >/dev/null 2>&1; then
        log_file_error "$STORE_DIR" "could not create .installed directory"
      fi
      return 1
    fi
  fi

  cat > "$STORE_FILE" <<EOF
{
  "alias": "$new_alias",
  "machineName": "$new_name",
  "previousAlias": "$prev_alias",
  "previousName": "$prev_name",
  "updatedAt": "$ts"
}
EOF

  return $?
}

detect_tool_presence() {
  local tool_name="$1"
  local p
  p=$(command -v "$tool_name" 2>/dev/null || true)
  echo "$p"
}

show_identity_view() {
  local ip="$1"
  local alias="$2"
  local mach_name="$3"
  local host_name="$4"
  local user="$5"
  local prev_name="$6"
  local prev_alias="$7"
  local platform="$8"
  local os_ver="$9"
  local arch="${10}"
  local cores="${11}"
  local git_path="${12}"
  local bash_path="${13}"
  local ps_path="${14}"

  printf "\n"
  printf "  \033[36m● Machine Identity & Hostname\033[0m\n"
  printf "  \033[90m=============================\033[0m\n"
  printf "    Machine IP:      \033[32m%s\033[0m\n" "$ip"
  printf "    Machine Alias:   \033[33m%s\033[0m \033[90m(auto-defaults to IP if unset)\033[0m\n" "$alias"
  printf "    Machine Name:    \033[36m%s\033[0m \033[90m(OS Hostname: %s)\033[0m\n" "$mach_name" "$host_name"
  printf "    Current User:    \033[90m%s\033[0m\n" "$user"
  printf "    Previous Value:  \033[90mname=\"%s\" | alias=\"%s\"\033[0m\n" "$prev_name" "$prev_alias"
  printf "    OS Platform:     \033[90m%s\033[0m\n" "$platform"
  printf "    OS Version:      \033[32m%s\033[0m\n" "$os_ver"
  printf "    Hardware:        \033[90m%s, %s CPU core(s)\033[0m\n" "$arch" "$cores"
  printf "    Git Path:        \033[90m%s\033[0m\n" "${git_path:-not installed}"
  printf "    Bash Path:       \033[90m%s\033[0m\n" "${bash_path:-not installed}"
  printf "    PowerShell:      \033[90m%s\033[0m\n" "${ps_path:-not installed}"
  printf "\n"
}

show_identity_json() {
  local ip="$1"
  local alias="$2"
  local mach_name="$3"
  local host_name="$4"
  local user="$5"
  local prev_name="$6"
  local prev_alias="$7"
  local platform="$8"
  local os_ver="$9"
  local build="${10}"
  local arch="${11}"
  local cores="${12}"
  local git_path="${13}"
  local bash_path="${14}"
  local ps_path="${15}"

  local has_git="false"
  if [ -n "$git_path" ]; then has_git="true"; fi

  local has_bash="false"
  if [ -n "$bash_path" ]; then has_bash="true"; fi

  local has_ps="false"
  if [ -n "$ps_path" ]; then has_ps="true"; fi

  cat <<EOF
{
  "sequence": 1,
  "nodeId": "local-01",
  "ipAddress": "$ip",
  "alias": "$alias",
  "machineName": "$mach_name",
  "osHostname": "$host_name",
  "previousName": "$prev_name",
  "previousAlias": "$prev_alias",
  "osPlatform": "$platform",
  "osVersion": "$os_ver",
  "buildVersion": "$build",
  "architecture": "$arch",
  "platform": "$(uname -s | tr '[:upper:]' '[:lower:]')/$arch",
  "cpuCores": $cores,
  "currentUser": "$user",
  "scope": "local",
  "gitPath": "$git_path",
  "bashPath": "$bash_path",
  "powerShellPath": "$ps_path",
  "hasGit": $has_git,
  "hasBash": $has_bash,
  "hasPowerShell": $has_ps
}
EOF
}

show_network_view() {
  printf "\n"
  printf "  \033[36m● Network Interfaces & IP Configuration\033[0m\n"
  printf "  \033[90m=======================================\033[0m\n"
  printf "  \033[33m%-28s %-16s %-16s %-16s %-6s %-6s\033[0m\n" "INTERFACE" "IP ADDRESS" "NETMASK" "GATEWAY" "DHCP" "STATUS"
  printf "  \033[90m----------------------------------------------------------------------------------------\033[0m\n"

  local gw="-"
  local mask="255.255.255.0"
  local os_type
  os_type=$(uname -s)

  case "$os_type" in
    Darwin)
      gw=$(netstat -nr -f inet 2>/dev/null | awk '/default/{print $2; exit}')
      [ -z "$gw" ] && gw="-"
      ;;
    CYGWIN*|MINGW*|MSYS*)
      gw=$(ipconfig 2>/dev/null | sed -n 's/.*Default Gateway.*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -n1 | tr -d '\r')
      mask=$(ipconfig 2>/dev/null | sed -n 's/.*Subnet Mask.*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -n1 | tr -d '\r')
      [ -z "$gw" ] && gw="-"
      [ -z "$mask" ] && mask="255.255.255.0"
      ;;
    *)
      if command -v ip >/dev/null 2>&1; then
        gw=$(ip route show default 2>/dev/null | awk '{print $3; exit}')
        [ -z "$gw" ] && gw="-"
      fi
      ;;
  esac

  if [ "$os_type" = "Linux" ] && command -v ip >/dev/null 2>&1; then
    ip -o -4 addr show 2>/dev/null | while read -r _ iface _ addr _; do
      local pure_ip="${addr%%/*}"
      printf "  \033[32m%-28s %-16s %-16s %-16s %-6s %-6s\033[0m\n" "$iface" "$pure_ip" "$mask" "$gw" "yes" "up"
    done
    printf "\n"
    return 0
  fi

  local primary_ip
  primary_ip=$(get_primary_ip)
  printf "  \033[32m%-28s %-16s %-16s %-16s %-6s %-6s\033[0m\n" "default-adapter" "$primary_ip" "$mask" "$gw" "yes" "up"
  printf "\n"
}

show_network_json() {
  local primary_ip
  primary_ip=$(get_primary_ip)
  local gw="-"
  local mask="255.255.255.0"
  local os_type
  os_type=$(uname -s)

  case "$os_type" in
    Darwin)
      gw=$(netstat -nr -f inet 2>/dev/null | awk '/default/{print $2; exit}')
      [ -z "$gw" ] && gw="-"
      ;;
    CYGWIN*|MINGW*|MSYS*)
      gw=$(ipconfig 2>/dev/null | sed -n 's/.*Default Gateway.*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -n1 | tr -d '\r')
      mask=$(ipconfig 2>/dev/null | sed -n 's/.*Subnet Mask.*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -n1 | tr -d '\r')
      [ -z "$gw" ] && gw="-"
      [ -z "$mask" ] && mask="255.255.255.0"
      ;;
    *)
      if command -v ip >/dev/null 2>&1; then
        gw=$(ip route show default 2>/dev/null | awk '{print $3; exit}')
        [ -z "$gw" ] && gw="-"
      fi
      ;;
  esac

  cat <<EOF
[
  {
    "name": "default-adapter",
    "ip": "$primary_ip",
    "netmask": "$mask",
    "gateway": "$gw",
    "mac": "-",
    "isDHCP": true,
    "status": "up",
    "isLoopback": false
  }
]
EOF
}

show_help() {
  cat <<EOF

  Machine Identity & Network Configuration
  ========================================
  Usage: ./run.sh machine [command] [args] [flags]
         ./run.sh os machine [command] [args] [flags]

  Commands:
    ls, show, status             Display machine IP, alias, OS hostname, and specs
    set <name>, change <name>    Set machine alias and name (sample: dev-linux-01)
    revert, undo                 Restore previous machine alias and name
    ip, interfaces               Display active network adapters and IP addresses
    help                         Show this help message

  Flags:
    --json, -j                   Output machine identity as structured JSON
    -h, --help                   Show this help message

EOF
}

# ── Main Entrypoint Dispatcher ────────────────────────────────────────────────

IS_JSON=0
HAS_HELP=0
POSITIONAL=()

while [ $# -gt 0 ]; do
  case "$1" in
    --json|-j|json)
      IS_JSON=1; shift ;;
    --help|-h|help)
      HAS_HELP=1; shift ;;
    *)
      POSITIONAL+=("$1"); shift ;;
  esac
done

if [ "$HAS_HELP" -eq 1 ]; then
  show_help
  exit 0
fi

SUB_CMD="ls"
if [ "${#POSITIONAL[@]}" -gt 0 ]; then
  SUB_CMD="${POSITIONAL[0]}"
fi

# Detect Core Specs
IP=$(get_primary_ip)
HOST_NAME=$(get_hostname)
USER_NAME=$(get_current_user)
CORES=$(get_cpu_cores)
ARCH=$(get_architecture)

GIT_PATH=$(detect_tool_presence "git")
BASH_PATH=$(detect_tool_presence "bash")
PS_PATH=$(detect_tool_presence "pwsh")
if [ -z "$PS_PATH" ]; then
  PS_PATH=$(detect_tool_presence "powershell")
fi

OS_PLATFORM="Linux (linux)"
OS_VER="Linux"
BUILD_VER=""

case "$(uname -s)" in
  Darwin)
    OS_PLATFORM="macOS (darwin)"
    _sw_v=$(sw_vers -productVersion 2>/dev/null || echo "")
    _sw_b=$(sw_vers -buildVersion 2>/dev/null || echo "")
    OS_VER="macOS ${_sw_v} (Build ${_sw_b})"
    BUILD_VER="$_sw_b"
    ;;
  Linux)
    OS_PLATFORM="Linux (linux)"
    OS_VER=$(get_linux_os_version)
    BUILD_VER=$(uname -r 2>/dev/null || echo "")
    ;;
  CYGWIN*|MINGW*|MSYS*)
    OS_PLATFORM="Windows (windows)"
    OS_VER="Windows ($(uname -s))"
    BUILD_VER=$(uname -r 2>/dev/null || echo "")
    ;;
  *)
    OS_PLATFORM="$(uname -s)"
    OS_VER="$(uname -sr 2>/dev/null || echo "")"
    BUILD_VER=""
    ;;
esac

STORED_ALIAS=$(read_store_field "alias")
STORED_NAME=$(read_store_field "machineName")
PREV_ALIAS=$(read_store_field "previousAlias")
PREV_NAME=$(read_store_field "previousName")

ACTIVE_ALIAS="${STORED_ALIAS:-$IP}"
ACTIVE_NAME="${STORED_NAME:-$HOST_NAME}"

case "$SUB_CMD" in
  ls|list|show|status|st)
    if [ "$IS_JSON" -eq 1 ]; then
      show_identity_json "$IP" "$ACTIVE_ALIAS" "$ACTIVE_NAME" "$HOST_NAME" "$USER_NAME" "$PREV_NAME" "$PREV_ALIAS" "$OS_PLATFORM" "$OS_VER" "$BUILD_VER" "$ARCH" "$CORES" "$GIT_PATH" "$BASH_PATH" "$PS_PATH"
    else
      show_identity_view "$IP" "$ACTIVE_ALIAS" "$ACTIVE_NAME" "$HOST_NAME" "$USER_NAME" "$PREV_NAME" "$PREV_ALIAS" "$OS_PLATFORM" "$OS_VER" "$ARCH" "$CORES" "$GIT_PATH" "$BASH_PATH" "$PS_PATH"
    fi
    exit 0
    ;;

  ip|ips|net|network|interfaces)
    if [ "$IS_JSON" -eq 1 ]; then
      show_network_json
    else
      show_network_view
    fi
    exit 0
    ;;

  set|change|rename|update)
    if [ "${#POSITIONAL[@]}" -lt 2 ]; then
      printf "\033[31m  [ FAIL ] Missing new name/alias. Usage: ./run.sh machine set <name>\033[0m\n" >&2
      exit 1
    fi
    RAW_VAL="${POSITIONAL[1]}"
    CLEAN_VAL=$(echo "$RAW_VAL" | tr ' ' '-')
    save_stored_config "$CLEAN_VAL" "$CLEAN_VAL" "$ACTIVE_ALIAS" "$ACTIVE_NAME"

    if [ "$IS_JSON" -eq 1 ]; then
      show_identity_json "$IP" "$CLEAN_VAL" "$CLEAN_VAL" "$HOST_NAME" "$USER_NAME" "$ACTIVE_NAME" "$ACTIVE_ALIAS" "$OS_PLATFORM" "$OS_VER" "$BUILD_VER" "$ARCH" "$CORES" "$GIT_PATH" "$BASH_PATH" "$PS_PATH"
    else
      printf "\n\033[32m  [  OK  ] Updated machine alias and name to '%s' (previous saved for 'revert').\033[0m\n" "$CLEAN_VAL"
      show_identity_view "$IP" "$CLEAN_VAL" "$CLEAN_VAL" "$HOST_NAME" "$USER_NAME" "$ACTIVE_NAME" "$ACTIVE_ALIAS" "$OS_PLATFORM" "$OS_VER" "$ARCH" "$CORES" "$GIT_PATH" "$BASH_PATH" "$PS_PATH"
    fi
    exit 0
    ;;

  revert|rollback|undo)
    TARGET_PREV="${PREV_NAME:-$PREV_ALIAS}"
    if [ -z "$TARGET_PREV" ]; then
      TARGET_PREV="$HOST_NAME"
    fi
    save_stored_config "$TARGET_PREV" "$TARGET_PREV" "$ACTIVE_ALIAS" "$ACTIVE_NAME"

    if [ "$IS_JSON" -eq 1 ]; then
      show_identity_json "$IP" "$TARGET_PREV" "$TARGET_PREV" "$HOST_NAME" "$USER_NAME" "$ACTIVE_NAME" "$ACTIVE_ALIAS" "$OS_PLATFORM" "$OS_VER" "$BUILD_VER" "$ARCH" "$CORES" "$GIT_PATH" "$BASH_PATH" "$PS_PATH"
    else
      printf "\n\033[32m  [  OK  ] Reverted machine alias and name back to '%s'.\033[0m\n" "$TARGET_PREV"
      show_identity_view "$IP" "$TARGET_PREV" "$TARGET_PREV" "$HOST_NAME" "$USER_NAME" "$ACTIVE_NAME" "$ACTIVE_ALIAS" "$OS_PLATFORM" "$OS_VER" "$ARCH" "$CORES" "$GIT_PATH" "$BASH_PATH" "$PS_PATH"
    fi
    exit 0
    ;;

  *)
    # Bare custom name
    CLEAN_VAL=$(echo "$SUB_CMD" | tr ' ' '-')
    save_stored_config "$CLEAN_VAL" "$CLEAN_VAL" "$ACTIVE_ALIAS" "$ACTIVE_NAME"
    if [ "$IS_JSON" -eq 1 ]; then
      show_identity_json "$IP" "$CLEAN_VAL" "$CLEAN_VAL" "$HOST_NAME" "$USER_NAME" "$ACTIVE_NAME" "$ACTIVE_ALIAS" "$OS_PLATFORM" "$OS_VER" "$BUILD_VER" "$ARCH" "$CORES" "$GIT_PATH" "$BASH_PATH" "$PS_PATH"
    else
      printf "\n\033[32m  [  OK  ] Updated machine alias and name to '%s' (previous saved for 'revert').\033[0m\n" "$CLEAN_VAL"
      show_identity_view "$IP" "$CLEAN_VAL" "$CLEAN_VAL" "$HOST_NAME" "$USER_NAME" "$ACTIVE_NAME" "$ACTIVE_ALIAS" "$OS_PLATFORM" "$OS_VER" "$ARCH" "$CORES" "$GIT_PATH" "$BASH_PATH" "$PS_PATH"
    fi
    exit 0
    ;;
esac
