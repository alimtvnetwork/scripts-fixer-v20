---
name: gitmap-ssh-local
description: >-
  Autonomously manage repository-scoped SSH keys (create, view, list, delete, bind, test) with automatic Git operation interception across GitMap commands.
---

# GitMap SSH-Local: Repository-Scoped SSH Key Management

Use this skill when managing repository-scoped SSH keys, creating deploy keys for specific repositories, viewing bound keys, or troubleshooting SSH authentication failures during Git operations.

## Core Capabilities
- `gitmap ssh-local create [email]`: Generates dedicated ED25519 (or RSA) key in `~/.ssh/gitmap-local/<repo>/`, records binding in SQLite DB, synchronizes `core.sshCommand` into `.git/config`, copies public key to clipboard, and renders formatted key card.
- `gitmap ssh-local view`: Inspects current repository's bound SSH key and auto-copies public key to clipboard.
- `gitmap ssh-local list`: Lists all repository bindings on workstation with status, paths, and fingerprints.
- `gitmap ssh-local delete`: Safely unbinds and removes key files.
- `gitmap ssh-local bind <path>`: Associates an existing private key file with the target repository.
- `gitmap ssh-local test`: Probes SSH authentication against remote host (`github.com`, `gitlab.com`).
- `gitmap ssh list`: Workstation-wide discovery displaying all stored, local, and instance SSH keys along with their bound target repositories.

## Automatic Git Interception Invariant
Once bound, GitMap automatically injects `GIT_SSH_COMMAND="ssh -F /dev/null -o IdentitiesOnly=yes -i <keyPath> -o StrictHostKeyChecking=accept-new -o BatchMode=yes -o ConnectTimeout=15"` into all commit and pull commands:
- `gitmap cpf "Feature: summary"`
- `gitmap cbf "Bug: summary"`
- `gitmap pull` / `gitmap pull cwd`
- `gitmap push`

## Safety & Security Guidelines
1. Keys are strictly kept outside the repository working tree in `~/.ssh/gitmap-local/` to eliminate accidental credential leakage in Git commits.
2. File permissions are enforced at `0700` for directories and `0600` for private keys.
