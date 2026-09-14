#!/usr/bin/env bash
# --------------------------------------------------------------------------
#  Step 7 -- Kubernetes Multi-Node Remote Command Executor
#  Executes commands on cluster nodes using SQLite node inventory & SSH RSA key auth.
#  Usage:  ./run-cmd.sh <target> "<command>" [--sudo]
# --------------------------------------------------------------------------
set -u

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_REPO_ROOT="$(cd "$_SCRIPT_DIR/../.." && pwd)"
_DB_BRIDGE="$_REPO_ROOT/scripts/shared/db_bridge.py"
_SSH_MGR="$_SCRIPT_DIR/cluster-ssh-manager.sh"

source "$_REPO_ROOT/kubernetes/01-base-helpers/import-all.sh"

show_help() {
  echo ""
  echo "  Kubernetes Remote Command Executor (SSH RSA & SQLite Engine)"
  echo ""
  echo "  Usage:"
  echo "    $0 <target> \"<command>\" [--sudo]"
  echo ""
  echo "  Targets:"
  echo "    all        Run on control + all worker nodes"
  echo "    control    Run on control / master node only"
  echo "    workers    Run on all worker nodes"
  echo "    <node>     Run on a specific node (e.g. worker-1, control)"
  echo ""
  echo "  Options:"
  echo "    --sudo     Execute command with sudo privileges"
  echo "    -h, --help Show this help message"
  echo ""
  echo "  Examples:"
  echo "    $0 all \"hostname -I\""
  echo "    $0 control \"kubectl get nodes\""
  echo "    $0 workers \"df -h /\""
  echo "    $0 worker-1 \"systemctl status kubelet\" --sudo"
  echo ""
}

get_python_bin() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"

    return 0
  fi

  echo "python"
}

has_registered_nodes() {
  local py_bin
  py_bin="$(get_python_bin)"
  local count
  count=$("$py_bin" -c "import json, subprocess; out=subprocess.getoutput('$py_bin $_DB_BRIDGE cluster-list-nodes --json'); print(len(json.loads(out)) if out.startswith('[') else 0)" 2>/dev/null || echo "0")

  [ "$count" -gt 0 ]
}

ensure_node_inventory() {
  if has_registered_nodes; then
    return 0
  fi

  local legacy_json="$_SCRIPT_DIR/../config.json"

  if [ -f "$legacy_json" ]; then
    log_message "Importing cluster nodes from legacy $legacy_json..." "info"
    local py_bin
    py_bin="$(get_python_bin)"
    "$py_bin" "$_DB_BRIDGE" cluster-import-json "$legacy_json" >/dev/null 2>&1
  fi

  return 0
}

get_target_nodes() {
  local target="$1"
  local py_bin
  py_bin="$(get_python_bin)"

  case "$target" in
    all)
      "$py_bin" -c "import json, subprocess; out=subprocess.getoutput('$py_bin $_DB_BRIDGE cluster-list-nodes --json'); nodes=json.loads(out) if out.startswith('[') else []; print(' '.join(n['node_name'] for n in nodes))" 2>/dev/null
      ;;
    control)
      "$py_bin" -c "import json, subprocess; out=subprocess.getoutput('$py_bin $_DB_BRIDGE cluster-list-nodes control --json'); nodes=json.loads(out) if out.startswith('[') else []; print(' '.join(n['node_name'] for n in nodes))" 2>/dev/null
      ;;
    workers)
      "$py_bin" -c "import json, subprocess; out=subprocess.getoutput('$py_bin $_DB_BRIDGE cluster-list-nodes worker --json'); nodes=json.loads(out) if out.startswith('[') else []; print(' '.join(n['node_name'] for n in nodes))" 2>/dev/null
      ;;
    *)
      echo "$target"
      ;;
  esac
}

execute_on_node() {
  local node_name="$1"
  local command="$2"
  local is_sudo="$3"

  log_message "Executing on [$node_name]: \"$command\"" "info"
  bash "$_SSH_MGR" exec "$node_name" "$command" "$is_sudo"
}

main() {
  if [ $# -lt 2 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help

    return 0
  fi

  local target="$1"
  local command="$2"
  local is_sudo="false"

  if [ "${3:-}" = "--sudo" ] || [ "${3:-}" = "sudo" ]; then
    is_sudo="true"
  fi

  ensure_node_inventory

  local target_nodes
  target_nodes="$(get_target_nodes "$target")"

  if [ -z "$target_nodes" ]; then
    log_message "No nodes found for target: $target. Use 'run.sh cluster add' first." "error"

    return 1
  fi

  local has_failure="false"

  for node in $target_nodes; do
    echo ""

    if ! execute_on_node "$node" "$command" "$is_sudo"; then
      log_message "Command failed on node $node" "error"
      has_failure="true"
    fi
  done

  echo ""

  if [ "$has_failure" = "true" ]; then
    log_message "Cluster execution completed with errors for target: $target" "warn"

    return 1
  fi

  log_message "Cluster execution successfully completed for target: $target" "success"

  return 0
}

main "$@"
