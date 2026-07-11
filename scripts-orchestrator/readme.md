# scripts-orchestrator

Multi-OS SSH orchestrator. Bash CLI at the project root level. No UI.

## Quick start

```sh
# 1. Install controller deps (Ubuntu/Debian example)
sudo apt-get install -y openssh-client sshpass sqlite3 openssl

# 2. Copy the example inventory and edit
cp -r scripts-orchestrator/inventory.example scripts-orchestrator/inventory
$EDITOR scripts-orchestrator/inventory/hosts.conf

# 3. Bootstrap one host (password->key)
./scripts-orchestrator/run.sh bootstrap k8s-master

# 4. Run an inline command across the whole cluster group, in parallel
./scripts-orchestrator/run.sh run "uptime" --group cluster --parallel 8 --allow-inline

# 5. Provision Kubernetes (kubeadm v1.31, CRI-O, Weave, Helm)
./scripts-orchestrator/run.sh playbook k8s-kubeadm --group cluster --role control-plane
./scripts-orchestrator/run.sh playbook k8s-kubeadm --group cluster --role worker

# 6. View audit log
./scripts-orchestrator/run.sh log tail
```

## Requirements

| Side | Tools |
|---|---|
| Controller | bash, openssh-client, sshpass, sqlite3, openssl |
| Targets    | sshd, sudo (or root), bash |

Targets in scope: Ubuntu, Debian, RHEL, CentOS, Fedora, Alpine, Arch, macOS.
Windows targets are **out of scope** in this version.

## File layout

See `mem://specs/01-ssh-orchestration` for the full spec.

## Playbook index

| Playbook | Purpose | Key inputs |
| --- | --- | --- |
| [`zsh-fanout`](playbooks/zsh-fanout/readme.md) | Install zsh + Oh-My-Zsh + curated `.zshrc` (script 60/61/62) on every host. | `ZSH_BUNDLE_B64`, `TARGET_USER`, `THEME`, `SKIP_THEME_SWITCHER`, `DRY_RUN` |
| [`users-fanout`](playbooks/users-fanout/readme.md) | Cross-OS user/group management (script 68). | `USERS_JSON`, `USERS_BUNDLE_B64` |
| [`ssh-keys-fanout`](playbooks/ssh-keys-fanout/readme.md) | Distribute authorized_keys, collect and merge ledgers. | `SSH_KEYS_TARBALL_B64` |
| [`groups-fanout`](playbooks/groups-fanout/readme.md) | Group membership sync. | `GROUPS_JSON`, `GROUPS_BUNDLE_B64` |
| `k8s-kubeadm` | kubeadm v1.31 + CRI-O + Weave + Helm bring-up. | see `playbook.json` |

Example:

```sh
TAR=$(mktemp -t zsh-fanout-XXXXXX.tgz)
tar czf "$TAR" -C . scripts-linux/_shared scripts-linux/60-install-zsh \
  scripts-linux/61-install-zsh-theme-switcher scripts-linux/62-install-zsh-clear
ZSH_BUNDLE_B64=$(base64 -w0 < "$TAR") TARGET_USER=alim THEME=robbyrussell \
  ./scripts-orchestrator/run.sh playbook zsh-fanout --group cluster
```

## Reference

K8s playbook ported from
[aukgit/kubernetes-training-v1/03-kube-Installer](https://github.com/aukgit/kubernetes-training-v1/tree/main/03-kube-Installer).
