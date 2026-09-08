# Ubuntu Kubernetes Suite

## Objective
Enhance `scripts/os/ubuntu/install-kubernetes.sh` to install `kind`, `minikube`, and `k9s` along with the currently supported `kubectl` and `helm`.

## Tasks
1. **Kind**: Add installation logic for `kind` using the official curl-based binary fetch (e.g., `curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64` and move to `/usr/local/bin`).
2. **Minikube**: Add installation logic for `minikube` (e.g., `curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64` and install).
3. **K9s**: Add installation logic for `k9s` (download the latest release `.tar.gz` from GitHub, extract, and move to `/usr/local/bin/`).
4. Ensure these additions use the existing bash color codes (`\e[1;36m`, `\e[1;33m`, etc.) and `echo` statements for visual consistency.
5. Verify idempotency so that rerunning the script does not cause duplicate downloads if the tools are already installed.
