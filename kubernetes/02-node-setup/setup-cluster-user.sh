#!/usr/bin/env bash
# --------------------------------------------------------------------------
#  setup-cluster-user.sh -- Provision sudo user with SSH key & ZSH/Oh-My-Zsh
# --------------------------------------------------------------------------
set -u

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_REPO_ROOT="$(cd "$_SCRIPT_DIR/../.." && pwd)"

source "$_REPO_ROOT/kubernetes/01-base-helpers/logger.sh"

show_help() {
  echo ""
  echo "Usage: $0 <username> [password] [theme] [homedir]"
  echo ""
  echo "Example:"
  echo "  $0 auk mySecretPass robbyrussell /home/auk"
  echo ""
}

assert_root_user() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    log_message "This script must be executed as root (sudo)." "error"

    return 1
  fi

  return 0
}

create_system_user() {
  local user="$1"
  local homedir="$2"

  if id "$user" >/dev/null 2>&1; then
    log_message "User '$user' already exists." "info"

    return 0
  fi

  useradd -m -d "$homedir" -s /bin/bash "$user"
  log_message "User '$user' created with home $homedir." "success"
}

set_user_password() {
  local user="$1"
  local pass="$2"

  if [ -n "$pass" ]; then
    echo "$user:$pass" | chpasswd
    log_message "Password set for $user." "success"
  fi
}

grant_sudo_nopasswd() {
  local user="$1"
  local sudoers_file="/etc/sudoers.d/$user"

  usermod -aG sudo "$user"
  echo "$user ALL=(ALL) NOPASSWD:ALL" > "$sudoers_file"
  chmod 0440 "$sudoers_file"

  log_message "Granted NOPASSWD sudo access to $user." "success"
}

setup_user_ssh_keys() {
  local user="$1"
  local homedir="$2"
  local ssh_dir="$homedir/.ssh"
  local auth_keys="$ssh_dir/authorized_keys"

  mkdir -p "$ssh_dir"
  touch "$auth_keys"
  chmod 700 "$ssh_dir"
  chmod 600 "$auth_keys"
  chown -R "$user:$user" "$ssh_dir"

  log_message "SSH directory and authorized_keys initialized for $user." "success"
}

setup_user_oh_my_zsh() {
  local user="$1"
  local homedir="$2"
  local theme="${3:-robbyrussell}"

  apt-get update -qq >/dev/null 2>&1 && apt-get install -y -qq zsh git curl wget >/dev/null 2>&1 || true

  local zsh_bin
  zsh_bin="$(command -v zsh || echo '/usr/bin/zsh')"
  chsh -s "$zsh_bin" "$user"

  if [ ! -d "$homedir/.oh-my-zsh" ]; then
    sudo -u "$user" sh -c "wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s -- --unattended" >/dev/null 2>&1 || true
  fi

  if [ -f "$homedir/.zshrc" ]; then
    sed -i "s/^ZSH_THEME=.*$/ZSH_THEME=\"$theme\"/" "$homedir/.zshrc"
  fi

  log_message "Configured Oh-My-Zsh with theme '$theme' for $user." "success"
}

main() {
  if [ $# -lt 1 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help

    return 0
  fi

  if ! assert_root_user; then
    return 1
  fi

  local user="$1"
  local pass="${2:-}"
  local theme="${3:-robbyrussell}"
  local homedir="${4:-/home/$user}"

  create_system_user "$user" "$homedir"
  set_user_password "$user" "$pass"
  grant_sudo_nopasswd "$user"
  setup_user_ssh_keys "$user" "$homedir"
  setup_user_oh_my_zsh "$user" "$homedir" "$theme"

  log_message "User provisioning completed for $user." "success"

  return 0
}

main "$@"
