#!/usr/bin/env bash
# --------------------------------------------------------------------------
#  cluster-ssh-manager.sh -- SSH RSA key lifecycle & bootstrap for cluster
# --------------------------------------------------------------------------
set -u

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_REPO_ROOT="$(cd "$_SCRIPT_DIR/../.." && pwd)"
_DB_BRIDGE="$_REPO_ROOT/scripts/shared/db_bridge.py"

source "$_REPO_ROOT/kubernetes/01-base-helpers/logger.sh"

get_cluster_key_path() {
  local default_key="${HOME:-/root}/.ssh/id_cluster_rsa"
  echo "${SCRIPTS_FIXER_CLUSTER_KEY:-$default_key}"
}

has_cluster_key() {
  local key_path
  key_path="$(get_cluster_key_path)"

  [ -f "$key_path" ] && [ -f "${key_path}.pub" ]
}

ensure_cluster_key() {
  local key_path
  key_path="$(get_cluster_key_path)"

  if has_cluster_key; then
    return 0
  fi

  local key_dir
  key_dir="$(dirname "$key_path")"
  mkdir -p "$key_dir"
  chmod 700 "$key_dir"

  log_message "Generating 4096-bit RSA cluster keypair at $key_path..." "info"
  ssh-keygen -t rsa -b 4096 -f "$key_path" -N "" -C "scripts-fixer-cluster" >/dev/null 2>&1
  chmod 600 "$key_path"
  chmod 644 "${key_path}.pub"

  log_message "Cluster keypair created successfully." "success"

  return 0
}

get_python_bin() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"

    return 0
  fi

  echo "python"
}

get_node_info() {
  local name="$1"
  local py_bin
  py_bin="$(get_python_bin)"

  "$py_bin" "$_DB_BRIDGE" cluster-get-node "$name" 2>/dev/null || echo "{}"
}

prompt_password_if_needed() {
  local given_pass="${1:-}"

  if [ -n "$given_pass" ]; then
    echo "$given_pass"

    return 0
  fi

  local input_pass=""
  read -s -p "Enter SSH password for node: " input_pass >&2
  echo "" >&2
  echo "$input_pass"
}

inject_public_key() {
  local user="$1"
  local ip="$2"
  local port="$3"
  local pass="$4"
  local pub_key="$5"

  if ! command -v sshpass >/dev/null 2>&1; then
    apt-get update -qq >/dev/null 2>&1 && apt-get install -y -qq sshpass >/dev/null 2>&1 || true
  fi

  local remote_cmd="mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
  sshpass -p "$pass" ssh -p "$port" -o StrictHostKeyChecking=accept-new "$user@$ip" "$remote_cmd" < "$pub_key"
}

configure_sudo_nopasswd() {
  local user="$1"
  local ip="$2"
  local port="$3"
  local pass="$4"

  local sudo_cmd="echo '$pass' | sudo -S bash -c 'echo \"$user ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/$user && chmod 0440 /etc/sudoers.d/$user' 2>/dev/null"
  sshpass -p "$pass" ssh -p "$port" -o StrictHostKeyChecking=accept-new "$user@$ip" "$sudo_cmd" || true
}

test_ssh_key_auth() {
  local user="$1"
  local ip="$2"
  local port="$3"
  local key_path="$4"

  ssh -i "$key_path" -p "$port" -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new "$user@$ip" "echo ssh_ok" 2>/dev/null | grep -q "ssh_ok"
}

bootstrap_node() {
  local node_name="$1"
  local pass_arg="${2:-}"

  ensure_cluster_key
  local key_path
  key_path="$(get_cluster_key_path)"
  local pub_key="${key_path}.pub"

  local node_json
  node_json="$(get_node_info "$node_name")"

  if [ -z "$node_json" ] || [ "$node_json" = "{}" ]; then
    log_message "Node '$node_name' not found in SQLite database." "error"

    return 1
  fi

  local py_bin
  py_bin="$(get_python_bin)"
  local ip
  local port
  local user
  ip=$("$py_bin" -c "import json; d=json.loads('''$node_json'''); print(d.get('ip_address',''))")
  port=$("$py_bin" -c "import json; d=json.loads('''$node_json'''); print(d.get('port', 22))")
  user=$("$py_bin" -c "import json; d=json.loads('''$node_json'''); print(d.get('ssh_user','root'))")

  log_message "Bootstrapping SSH RSA key for $node_name ($user@$ip:$port)..." "info"

  local pass
  pass="$(prompt_password_if_needed "$pass_arg")"

  inject_public_key "$user" "$ip" "$port" "$pass" "$pub_key"
  configure_sudo_nopasswd "$user" "$ip" "$port" "$pass"

  # Revert / wipe password from memory immediately
  pass=""

  if ! test_ssh_key_auth "$user" "$ip" "$port" "$key_path"; then
    log_message "SSH RSA verification failed for $node_name." "error"

    return 1
  fi

  "$py_bin" "$_DB_BRIDGE" cluster-add-node "$node_name" "node" "$ip" "$port" "$user" "$key_path" >/dev/null 2>&1
  log_message "SSH RSA key successfully installed on $node_name. Passwordless access verified." "success"

  return 0
}

exec_remote_cmd() {
  local node_name="$1"
  local cmd="$2"
  local is_sudo="${3:-false}"

  ensure_cluster_key
  local key_path
  key_path="$(get_cluster_key_path)"

  local node_json
  node_json="$(get_node_info "$node_name")"

  if [ -z "$node_json" ] || [ "$node_json" = "{}" ]; then
    log_message "Node '$node_name' not found in database." "error"

    return 1
  fi

  local py_bin
  py_bin="$(get_python_bin)"
  local ip
  local port
  local user
  local custom_key
  ip=$("$py_bin" -c "import json; d=json.loads('''$node_json'''); print(d.get('ip_address',''))")
  port=$("$py_bin" -c "import json; d=json.loads('''$node_json'''); print(d.get('port', 22))")
  user=$("$py_bin" -c "import json; d=json.loads('''$node_json'''); print(d.get('ssh_user','root'))")
  custom_key=$("$py_bin" -c "import json; d=json.loads('''$node_json'''); print(d.get('ssh_key_path',''))")

  [ -n "$custom_key" ] && [ -f "$custom_key" ] && key_path="$custom_key"

  local final_cmd="$cmd"

  if [ "$is_sudo" = "true" ]; then
    final_cmd="sudo bash -c '$cmd'"
  fi

  log_message "[$node_name] Executing: $cmd" "info"

  local output
  local exit_code=0
  output=$(ssh -i "$key_path" -p "$port" -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new "$user@$ip" "$final_cmd" 2>&1) || exit_code=$?

  echo "$output"

  "$py_bin" "$_DB_BRIDGE" cluster-log-cmd "$node_name" "$cmd" "$exit_code" "$output" "" >/dev/null 2>&1

  return $exit_code
}

show_help() {
  echo ""
  echo "Cluster SSH Key Manager"
  echo "Usage:"
  echo "  $0 keygen                                  Generate cluster keypair"
  echo "  $0 bootstrap <node-name> [password]        Deploy SSH RSA key to node"
  echo "  $0 exec <node-name> \"<command>\" [is_sudo]  Run remote command via SSH key"
  echo ""
}

case "${1:-}" in
  keygen)
    ensure_cluster_key
    ;;
  bootstrap)
    shift
    bootstrap_node "$@"
    ;;
  exec)
    shift
    exec_remote_cmd "$@"
    ;;
  *)
    show_help
    exit 0
    ;;
esac
