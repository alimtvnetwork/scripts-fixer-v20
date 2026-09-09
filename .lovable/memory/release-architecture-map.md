# Release Architecture Map

## Current Release
- **Version**: 1.35.0
- **Previous Version**: 1.34.0
- **Source of Truth**: `version.json`
- **Synchronized Mirror**: `scripts/version.json`
- **Line Ending Standard**: Strict Unix LF (`\n`) enforced via `.gitattributes` (`*.sh text eol=lf`)
- **File Naming Standard**: All markdown files MUST be lowercase (`readme.md`, `changelog.md`).
- **Dynamic Readers**: `run.ps1` (PowerShell), `scripts/run.sh` (Linux Bash)

## Features in v1.35.0
- **Cross-platform IaC & Cloud Tools**: Kubernetes Suite, VMware, AWS CLI v2, gcloud, az, Terraform, VirtualBox, Vagrant, Ansible.
- **Antigravity**: Manager & CLI native dynamic installers & profiles.
- **Modern Dev Tools & Databases**: Zellij, uv, fnm, jq, yq, PostgreSQL, MongoDB, DBeaver, Compass, pgAdmin.
