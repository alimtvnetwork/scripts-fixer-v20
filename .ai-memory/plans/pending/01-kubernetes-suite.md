# Kubernetes Suite Implementation Plan

## Overview
This plan coordinates the installation and configuration of the Kubernetes Suite (`kind`, `minikube`, and `k9s`) for both Windows (`run.ps1` managed tools) and Ubuntu (`scripts/os/ubuntu/*.sh`).

## Custom Rules & Constraints
1. **Idempotency**: All installation scripts must check if the tool is already installed before downloading or modifying system paths.
2. **Version Parameterization**: When possible, avoid hardcoding versions directly in the scripts. Fallback to latest stable releases if versions are omitted.
3. **Existing Tooling Respect**: Do not break or remove existing `kubectl` or `helm` installations. Our additions must cleanly integrate alongside them.
4. **Consistent Output Formatting**: Use the existing output styling (e.g. `log_message` in Windows, `\e[1;36m` bash codes in Ubuntu) to ensure a cohesive user experience.
5. **Path Validation**: All documentation links and script references must be strictly relative to the repository root.

## Subtasks
1. [Windows Kubernetes Tooling](subtasks/01-kubernetes-suite/01-windows-suite.md)
2. [Ubuntu Kubernetes Tooling](subtasks/01-kubernetes-suite/02-ubuntu-suite.md)
