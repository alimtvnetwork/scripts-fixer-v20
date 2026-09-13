# Windows Kubernetes Suite

## Objective
Update the Windows `run.ps1` ecosystem (specifically within `scripts/46-install-kubernetes`) to support `kind` and `k9s` alongside the existing `minikube`, `kubectl`, and `helm`.

## Tasks
1. Update `scripts/46-install-kubernetes/config.json` to include configurations for `kind` and `k9s` (e.g., enable by default, specify `chocoPackageName`).
2. Update `scripts/46-install-kubernetes/log-messages.json` with new log definitions for `kind` and `k9s`.
3. Modify `scripts/46-install-kubernetes/run.ps1` to parse the new configuration sections and call Chocolatey installation commands (`choco install kind -y`, `choco install k9s -y`).
4. Ensure the output logs correctly detect already installed versions and display them cleanly without re-downloading if already present.
