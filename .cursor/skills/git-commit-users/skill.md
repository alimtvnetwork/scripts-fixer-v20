---
name: git-commit-users
description: >-
  Inspect recent Git commit authors and committers in clean piped or tabular format across repositories to verify identity attribution, multi-account commit hygiene, and detect author/committer mismatches.
---

# Git Commit Users: Fast Identity & Attribution Inspection

Use this skill when auditing repository commit history, checking which user/email authored or committed recent changes, verifying that local repository `user.name` and `user.email` are taking effect, or troubleshooting multi-account identity collisions across GitHub and GitLab.

## Core Capabilities
- `gitmap commit-users`: Quickly inspect the last 5 commits in the current repository displaying `%h | %an <%ae> | %cn <%ce> | %s`.
- `gitmap commit-users <count>`: Inspect a custom number of recent commits (e.g. `gitmap commit-users 10`).
- `gitmap commit-users <count> <repo-path>`: Inspect commit users for a specific target repository (e.g. `gitmap commit-users 5 d:\work\lxo.dxc\setup`).
- `gitmap log users [count] [path]`: Symmetrical alias under the `gitmap log` command family.
- `gitmap commit users [count] [path]`: Symmetrical alias under the `gitmap commit` command family.
- `gitmap commit-users --raw`: Output uncolored raw piped format for script parsing and AI toolchain integration.

## Usage Examples

### Example 1: Quick Check in Current Repository
```bash
gitmap commit-users
```
**Output:**
```text
  Commit Users (last 5 commits) · [.]:

  7b89ee3 | Alim <alimtvnetwork@gmail.com> | Alim <alimtvnetwork@gmail.com> | Release: v6.694.0 - hardened path handling
  3027bfe | Alim <alimtvnetwork@gmail.com> | Alim <alimtvnetwork@gmail.com> | Feature: add ssh-local repo-scoped key management
  c149eb5 | Alim <alimtvnetwork@gmail.com> | Alim <alimtvnetwork@gmail.com> | Refactor: optimize git author environment injection
```

### Example 2: Inspecting Specific Repository from Anywhere
```bash
gitmap commit-users 5 d:\work\lxo.dxc\setup
```
**Output:**
```text
  Commit Users (last 5 commits) · [d:\work\lxo.dxc\setup]:

  a1b2c3d | Alim <alimluxoftdxc@gmail.com> | Alim <alimluxoftdxc@gmail.com> | update setup configuration
  e5f6g7h | Alim <alimluxoftdxc@gmail.com> | Alim <alimluxoftdxc@gmail.com> | add deployment environment specs
```

### Example 3: Verifying Multi-Account Attribution Before Push
When switching between client and personal projects, run `gitmap commit-users` or `gitmap login status` to guarantee that your local git configuration is active before pushing:
```bash
# Verify author and committer emails match expectations
gitmap commit-users 1

# Check repository authentication context and local priority
gitmap login status
```

### Example 4: Script & AI Ingestion Mode
```bash
gitmap commit-users 3 --raw
```
**Output:**
```text
a1b2c3d | Alim <alimluxoftdxc@gmail.com> | Alim <alimluxoftdxc@gmail.com> | initial commit
```

## Architectural Invariants
1. **Piped Format Standard:** Always follows `%h | %an <%ae> | %cn <%ce> | %s` allowing immediate identification of:
   - Commit Short Hash (`%h`)
   - Author Name & Email (`%an <%ae>`)
   - Committer Name & Email (`%cn <%ce>`)
   - Commit Subject (`%s`)
2. **Local Repo Sovereignty:** Works alongside GitMap's local identity priority rule, ensuring developer commits maintain strictly clean attribution.
