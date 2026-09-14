# Kubernetes Cluster Setup (Unix/Ubuntu)

Reference scripts for setting up a bare-metal Kubernetes cluster on Ubuntu
using kubeadm. Inspired by
[kubernetes-training-v1](https://github.com/aukgit/kubernetes-training-v1)
by Md Alim Ul Karim.

## Folder Structure

| Folder / File | Purpose |
|---------------|---------|
| `01-base-helpers/` | Reusable shell helpers (logger, apt installer, package checker) |
| `02-node-setup/` | Node preparation (static IP, sudo user, ZSH theme, cleanup, repo permissions) |
| `02-ubuntu-prereq/` | Ubuntu prerequisites and server bootstrap (kernel modules, swapoff) |
| `03-kube-install/` | kubeadm, kubelet, kubectl installation |
| `04-kube-init/` | Cluster initialization (master + worker join) |
| `05-helm-install/` | Helm package manager installation |
| `06-nfs-setup/` | NFS server + Helm NFS provisioner |
| `07-remote-commands/` | Multi-node SSH command executor (SQLite & SSH RSA auth engine) |
| `config-sample.json` | Node IP configuration template (importable into SQLite) |
| `cheat-sheet.md` | Quick-reference kubectl/kubeadm commands |

## Quick Start & CLI Usage

### 1. Cluster Management via `./run.sh` / `.\run.ps1`

```bash
# Register nodes in SQLite database
./run.sh cluster add control control 192.168.0.20 22 root
./run.sh cluster add worker-1 worker 192.168.0.21 22 root
./run.sh cluster add worker-2 worker 192.168.0.22 22 root

# Or import from existing JSON
./run.sh cluster import kubernetes/config-sample.json

# List registered cluster nodes
./run.sh cluster list

# Deploy SSH RSA keys to nodes (zero-password authentication)
./run.sh cluster bootstrap all

# Execute remote commands across cluster
./run.sh cluster run all "hostname -I"
./run.sh cluster run control "kubectl get nodes"
./run.sh cluster run workers "df -h /"

# View execution audit history
./run.sh cluster history
```

### 2. Manual Setup Sequence

```bash
# 1. Copy config
cp config-sample.json config.json
# Edit config.json with your node IPs and credentials

# 2. Run on EACH node (master + workers)
chmod +x 02-ubuntu-prereq/run.sh && sudo ./02-ubuntu-prereq/run.sh
chmod +x 03-kube-install/run.sh  && sudo ./03-kube-install/run.sh

# 3. Initialize master (run on master node only)
chmod +x 04-kube-init/init-master.sh && sudo ./04-kube-init/init-master.sh

# 4. Join workers (run on each worker node)
# Use the join command printed by step 3
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>

# 5. Apply network plugin (run on master)
kubectl apply -f https://reweave.azurewebsites.net/k8s/v1.31/net.yaml

# 6. Install Helm (run on master)
chmod +x 05-helm-install/run.sh && sudo ./05-helm-install/run.sh
```

## Prerequisites

- Ubuntu 20.04+ (or Debian-based)
- Root/sudo access
- Internet connectivity
- Minimum 2 GB RAM per node
- Unique hostname per node

## Network Topology

```
+-------------------+
|   Master Node     |  192.168.0.20  (control plane)
+-------------------+
        |
   +---------+---------+
   |         |         |
+------+ +------+ +------+
|  W1  | |  W2  | |  W3  |
+------+ +------+ +------+
.0.21    .0.22    .0.23
```

## Related Scripts

- **Script 45** (`install-docker`) -- Docker Engine installation
- **Script 46** (`install-kubernetes`) -- Windows-based kubectl/minikube/Helm via Chocolatey

## Credits

Shell script patterns and cluster setup flow adapted from
[aukgit/kubernetes-training-v1](https://github.com/aukgit/kubernetes-training-v1)
(MIT License) by Md Alim Ul Karim.
