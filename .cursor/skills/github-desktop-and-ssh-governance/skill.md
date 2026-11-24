---
name: github-desktop-and-ssh-governance
description: >-
  Autonomously diagnose, repair, and govern GitHub Desktop authentication, SSH identity synchronization, url.insteadOf prefix matching, and repository namespace governance across Linux and Windows fleet nodes.
---

# GitHub Desktop & SSH Governance

> **Invocation:** `@[github-desktop-and-ssh-governance](directory;.agents/skills/github-desktop-and-ssh-governance)`

Autonomously resolves authentication freezes, browser sign-in modals, and permission rejections in GitHub Desktop and Git operations across developer workstations (such as Ubuntu node `u1`).

## 1. When to Use This Skill

Activate this skill when:
- GitHub Desktop displays: `"Sign in using your browser: Git requesting credentials to access https://github.com/ ."`.
- Git commands hang indefinitely on `git-credential-desktop get`.
- Pushes fail with `ERROR: Permission to <owner>/<repo>.git denied to alimtvnetwork`.
- Remote repositories have HTTPS URLs or embedded tokens (`https://ghp_...@github.com/...`) instead of SSH.
- `url."git@github.com:".insteadOf` rules in `~/.gitconfig` fail to rewrite HTTPS requests.

## 2. Core Operational Workflow

### Step 1: Terminate Hanging Subprocesses
If GitHub Desktop is blocked by an active push/fetch operation:
```bash
kill $(pgrep -f "git push origin") 2>/dev/null || true
kill $(pgrep -f "git-credential-desktop") 2>/dev/null || true
```

### Step 2: Validate & Fix `~/.gitconfig` URL Rewrites
Verify that `url.insteadOf` does NOT contain leading or trailing whitespace:
```bash
git config --global --unset-all "url. git@github.com:.insteadof" 2>/dev/null || true
git config --global "url.git@github.com:.insteadOf" "https://github.com/"
git config --global --add "url.git@github.com:.insteadOf" "git://github.com/"
git config --global --add "url.git@github.com:.insteadOf" "ssh://git@github.com/"
```
Also mirror to `/root/.gitconfig` when operating in elevated Linux environments.

### Step 3: Enforce `alimtvnetwork` Namespace Ownership
1. For any repository belonging to an upstream or third-party namespace (`aukgit`, `garrytan`, `Evatix`):
   ```bash
   gh repo fork <upstream>/<repo> --clone=false
   ```
2. Update the local `origin` remote:
   ```bash
   git -C <repo-path> remote set-url origin git@github.com:alimtvnetwork/<repo>.git
   ```

### Step 4: Convert HTTPS Remotes to SSH
Ensure all local repositories in developer directories (`~/git-work/`) use pure SSH:
- No `https://github.com/...` remotes.
- No embedded PAT tokens (`https://ghp_...@github.com/...`).
- Pure SSH format: `git@github.com:alimtvnetwork/<repo>.git`.

### Step 5: Synchronize SSH Agent & Keyring
1. **Load SSH Identity:**
   ```bash
   SSH_AUTH_SOCK="/run/user/$(id -u)/openssh_agent" ssh-add ~/.ssh/id_rsa
   ```
2. **Store GitHub Token in GNOME Keyring:**
   ```bash
   echo "<github_token>" | secret-tool store --label="GitHub - https://api.github.com" service "GitHub - https://api.github.com" account "alimtvnetwork"
   ```
3. **Mirror SSH Credentials to Root:**
   ```bash
   sudo cp -f ~/.ssh/id_rsa ~/.ssh/id_rsa.pub ~/.ssh/config ~/.ssh/known_hosts /root/.ssh/
   sudo chmod 600 /root/.ssh/id_rsa /root/.ssh/config
   ```

### Step 6: Verify Fleet State
1. Test SSH connection:
   ```bash
   ssh -T git@github.com
   ```
   Expected output: `Hi alimtvnetwork! You've successfully authenticated`.
2. Inspect fleet status:
   ```bash
   gitmap status
   ```
   Verify all repositories report clean status without credentials prompts.
