#!/usr/bin/env python3
"""Hardens V6 Muse Master Prompts with real onboarding fixes from 2026-11-11.

Applies:
1. GitMap pinned install v6.98.1, tag check via git ls-remote, verify via `gitmap version`.
2. Post-installer ~/.bashrc inspection and comment out broken lines, verify source ~/.bashrc.
3. Remove non-existent `gitmap login --status`. Verify auth with `gh auth status` and `ssh -T git@github.com` only.
4. Run `gitmap ssh create "<email>-muse<sequence>-<operator>"` first (no ssh-keygen first, no -y flag).
5. SSH HOME mismatch: copy keys to /root/.ssh when running as root, test explicit identity first.
6. Clone with `--ssh --no-vscode-sync --target-dir ~/workspace/repos`. Handle DB self-lock bug via gitmap.json and git pull --ff-only.
7. Do not get stuck on `alim-seo-writing`: retry max 3 times, then defer as open item.
8. Prompt for missing identity variables; deliver public key strictly as a file.
"""

from __future__ import annotations

import os
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

CHANGELOG_BLOCK = """
> ### 📝 2026-11-11 Onboarding Hardening Changelog (v6.6.0)
> - **GitMap Pinned Install:** Unauthenticated GitHub API requests hit 403 rate-limits on `releases/latest`. Pinned install to `install-quick.sh --dir ~/.local/bin --version v6.98.1` with `git ls-remote --tags` fallback. Verify with `gitmap version` (not `gitmap --version`).
> - **Installer ~/.bashrc Fix:** Clean up plain-text syntax breaking lines added to `~/.bashrc` and verify `source ~/.bashrc`.
> - **Auth Check Cleanup:** Removed non-existent `gitmap login --status`. Verify auth strictly via `gh auth status` and `ssh -T git@github.com`.
> - **SSH Key Creation via GitMap First:** Run `gitmap ssh create "<email>-muse<sequence>-<operator>"` directly first (no `-y`, comment as positional, default path `~/.ssh/id_rsa`).
> - **SSH HOME Mismatch Fix:** When running as root, copy keys and known_hosts to `/root/.ssh` and test explicit identity first (`ssh -i ~/.ssh/id_rsa -T git@github.com`).
> - **Clone Flags & Self-Lock Workaround:** Clone with `--ssh --no-vscode-sync --target-dir ~/workspace/repos`. Work around v6.98.1 SQLite DB self-lock bug in `gitmap pa` by reading `~/workspace/repos/.gitmap/output/gitmap.json` and using plain `git pull --ff-only`.
> - **Problematic Repo Disconnect Handling:** Defer `alim-seo-writing` after 3 failed `fetch-pack: unexpected disconnect` attempts as an open item without stalling onboarding.
> - **Identity Invariant & File Delivery:** Mandatory prompt for missing identity variables; deliver public keys strictly as downloadable files.
"""


def harden_01_muse_master() -> None:
    path = os.path.join(REPO_ROOT, "01-prompts", "27-muse-prompts", "01-muse-master-prompt.md")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Update Version and add Changelog
    content = content.replace("Prompt Version: 6.5.0", "Prompt Version: 6.6.0 (2026-11-11 Real Onboarding Hardened Edition)\n> Date: 2026-11-11")
    if "### 📝 2026-11-11 Onboarding Hardening Changelog" not in content:
        target = "Prompt Version: 6.6.0 (2026-11-11 Real Onboarding Hardened Edition)\n> Date: 2026-11-11"
        content = content.replace(target, target + CHANGELOG_BLOCK)

    # 2. Update Checklist
    content = content.replace(
        "- [ ] `/goal` **Step 1: Install or Update GitMap & Prerequisite Check:** Verify/install GitMap (Linux/macOS curl, Windows PowerShell irm `irm https://raw.githubusercontent.com/alimtvnetwork/gitmap-v28/main/install.ps1 | iex`), update gitmap (`gitmap update`), source build fallback (`cd ~/workspace/repos/gitmap-v28 && git pull --ff-only && cd cli && go build -o ~/.local/bin/gitmap .` requiring Go 1.26+), check `gh --version`, and REPORT gitmap version.",
        "- [ ] `/goal` **Step 1: Install or Update GitMap & Prerequisite Check:** Pinned install (`install-quick.sh --dir ~/.local/bin --version v6.98.1` discovering tags via `git ls-remote --tags` to avoid 403 on releases/latest), verify ~/.bashrc and comment broken lines, update gitmap (`gitmap update`), check `gh --version`, and REPORT `gitmap version` (never `gitmap --version`)."
    )
    content = content.replace(
        "- [ ] `/goal` **Step 2: Login Before Cloning & Hard Gate Protocol:** Check `gh auth status`. If not logged in, pick ONE (a. Browser login, b. SSH keygen formatted as `<email>-muse<muse-sequence>-<operator-name>` using `gitmap ssh create` with account email auto-discovery or operator prompt fallback, downloadable file delivery protocol banning chat text pasting, and explicit Authentication vs Signing Key designation). Hard gate stopping until login succeeds. Fast-path bypass if already authenticated. REPORT `gh auth status`.",
        "- [ ] `/goal` **Step 2: Login Before Cloning & Hard Gate Protocol:** Check `gh auth status` and `ssh -T git@github.com` (no `gitmap login --status`). If not logged in, prompt for missing identity variables, run `gitmap ssh create \"<email>-muse<sequence>-<operator>\"` first (no -y), fix root /root/.ssh mismatch, deliver public key strictly as a file, and verify SSH connection."
    )
    content = content.replace(
        "- [ ] `/goal` **Step 3: Clone Default Repositories & Establish Side Chats:** Clone 8 default repos table (`gitmap-v28`, `Antigravity-Manager`, `cat-my-v12`, `alim-seo-writing`, `story-telling-v1`, `coding-guidelines-v24`, `repo-cache`, `repo-secrets`), create 5 side chats seeded from `chat-seeds/<name>.md`, define 3 vault/infra repos without side chats, discover secondary repos via `12-muse-ai/02-repos.md` with explicit user approval gate, and REPORT.",
        "- [ ] `/goal` **Step 3: Clone Default Repositories & Establish Side Chats:** Clone 8 default repos using `gitmap clone <url> --ssh --no-vscode-sync --target-dir ~/workspace/repos` (defer `alim-seo-writing` after max 3 fetch-pack disconnect retries as an open item), create 5 side chats seeded from `chat-seeds/<name>.md`, define 3 vault/infra repos without side chats, discover secondary repos with approval gate, and REPORT."
    )
    content = content.replace(
        "- [ ] `/goal` **Step 4: Pull All Handpicked Repositories:** Run `cd ~/workspace/repos && gitmap pa`. Verify clean, conflict-free working trees, and REPORT pull summary.",
        "- [ ] `/goal` **Step 4: Pull All Handpicked Repositories:** Pull repos avoiding v6.98.1 DB self-lock bug: treat `~/workspace/repos/.gitmap/output/gitmap.json` as source of truth and verify pulls with plain `git pull --ff-only` per repo."
    )

    # 3. Step 1 Body
    old_step1_install = """   - **Linux / macOS:**
     ```bash
     eval "$(curl -fsSL https://raw.githubusercontent.com/alimtvnetwork/gitmap-v28/main/install-quick.sh)"
     ```
     *Alternative:* `curl -fsSL https://raw.githubusercontent.com/alimtvnetwork/gitmap-v28/main/install-quick.sh | bash`"""

    new_step1_install = """   - **Linux / macOS (Pinned Install — Avoid 403 on releases/latest):**
     ```bash
     # Unauthenticated GitHub API rate-limits with 403 on releases/latest. Do not rely on 'latest'.
     # Discover working tag via git ls-remote:
     git ls-remote --tags https://github.com/alimtvnetwork/gitmap-v28.git
     # Pinned installation (v6.98.1):
     curl -fsSL https://raw.githubusercontent.com/alimtvnetwork/gitmap-v28/main/install-quick.sh | bash -s -- --dir ~/.local/bin --version v6.98.1
     ```
   - **Installer ~/.bashrc Side-Effect Remediation:**
     ```bash
     # The installer script can write plain-text lines into ~/.bashrc that break sourcing it.
     # Inspect ~/.bashrc, comment out any non-comment lines added by the installer, and verify:
     source ~/.bashrc
     ```"""
    content = content.replace(old_step1_install, new_step1_install)

    content = content.replace(
        "Run `gitmap --version` and `gh --version`. Output the Step 1 Report with the exact GitMap version string.",
        "Run `gitmap version` (NOT `gitmap --version`, which is an unknown command) and `gh --version`. Output the Step 1 Report with the exact GitMap version string."
    )

    # 4. Step 2 Body
    old_step2_check = """1. **Pre-Flight Authentication Check:**
   ```bash
   gh auth status
   gitmap login --status
   ```"""
    new_step2_check = """1. **Pre-Flight Authentication Check:**
   ```bash
   gh auth status
   # Note: gitmap login --status does NOT exist in GitMap v6.98.1. Check auth via gh and ssh only:
   ssh -T git@github.com
   ```"""
    content = content.replace(old_step2_check, new_step2_check)

    old_step2_ssh = """     2. **Git User Configuration & Key Generation:**
        ```bash
        # 1. Configure Git global user identity
        git config --global user.email "<email>"
        git config --global user.name "<operator-name> (Muse <muse-sequence>)"

        # 2. Preferred GitMap SSH command (creates and registers key with exact identity):
        gitmap ssh create "<email>-muse<muse-sequence>-<operator-name>" -y
        # Or standard SSH keygen:
        ssh-keygen -t ed25519 -C "<email>-muse<muse-sequence>-<operator-name>" -f ~/.ssh/id_ed25519 -N ""
        eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519

        # 3. Add to GitHub via CLI if authorized:
        gh ssh-key add ~/.ssh/id_ed25519.pub --title "<email>-muse<muse-sequence>-<operator-name>" --type authentication || true
        ```

     3. **MANDATORY KEY DELIVERY FILE PROTOCOL (Anti-Corruption Rule):**
        > [!CRITICAL]
        > **TOTAL BAN ON PASTING KEYS, TOKENS, OR LONG STRINGS AS CHAT TEXT:**
        > Chat formatting and terminal text wrapping frequently inject unintended line breaks into base64 SSH public keys, corrupting the key payload and causing GitHub to reject it with `Key is not in a proper SSH format`.
        > - **Deliver as Downloadable File:** Muse MUST ALWAYS deliver the generated key as a file path on disk: `~/.ssh/id_ed25519.pub` or copied into the repository workspace at `.ai-memory/ssh/<identity>.pub` so the operator can download or read it without line break corruption.
        > - **Clipboard Copy via GitMap:** Alternatively, use `gitmap ssh copy "<identity>"` to copy the exact raw string directly to the clipboard.
        > - **Explicit Key Type Designation:** ALWAYS declare the exact key type in the report:
        >   - **Key Type:** **Authentication Key** (tell the operator explicitly to choose "Authentication Key" in GitHub Settings -> SSH and GPG keys, NOT "Signing Key" unless specifically generating GPG commit signing keys).

     4. **Verify SSH Connection:**
        ```bash
        ssh -T git@github.com
        ```"""

    new_step2_ssh = """     2. **SSH Key Generation — Run GitMap First (No ssh-keygen first, No -y flag):**
        Run `gitmap ssh create` first. In v6.98.1, `create` is an alias for generate, the positional text becomes the key comment, the key name is `default`, the default path is `~/.ssh/id_rsa`, and there is no `-y` flag:
        ```bash
        # 1. Configure Git global user identity
        git config --global user.email "<email>"
        git config --global user.name "<operator-name> (Muse <muse-sequence>)"

        # 2. Preferred GitMap SSH command first:
        gitmap ssh create "<email>-muse<muse-sequence>-<operator-name>"

        # For a named key only afterwards if required:
        # gitmap ssh create --name "<identity>" --path ~/.ssh/id_rsa_<name> --email "<email>" --force
        ```

     3. **SSH HOME Mismatch Fix (Root vs User Execution):**
        When running as root, `ssh` looks in `/root/.ssh`, not `$HOME/.ssh` (e.g. `/home/hatch/.ssh`):
        ```bash
        if [ "$(id -u)" -eq 0 ] && [ "$HOME" != "/root" ]; then
          mkdir -p /root/.ssh && chmod 700 /root/.ssh
          cp -f "$HOME/.ssh/"* /root/.ssh/ 2>/dev/null || true
          chmod 600 /root/.ssh/id_* 2>/dev/null || true
        fi
        ```

     4. **MANDATORY KEY DELIVERY FILE PROTOCOL (Anti-Corruption Rule):**
        > [!CRITICAL]
        > **TOTAL BAN ON PASTING KEYS, TOKENS, OR LONG STRINGS AS CHAT TEXT:**
        > Chat formatting and terminal text wrapping frequently inject unintended line breaks into base64 SSH public keys, corrupting the key payload and causing GitHub to reject it with `Key is not in a proper SSH format`.
        > - **Deliver as Downloadable File:** Muse MUST ALWAYS deliver the generated key as a file path on disk: `~/.ssh/id_rsa.pub` so the operator can download or read it without line break corruption.
        > - **Explicit Key Type Designation:** ALWAYS declare the exact key type in the report:
        >   - **Key Type:** **Authentication Key** (tell the operator explicitly to choose "Authentication Key" in GitHub Settings -> SSH and GPG keys, NOT "Signing Key").

     5. **Verify SSH Connection:**
        Test explicit identity first, then test default:
        ```bash
        # Test explicit first:
        ssh -i ~/.ssh/id_rsa -T git@github.com
        # Test default:
        ssh -T git@github.com
        ```
        Verification success string: `Hi alimtvnetwork! You've successfully authenticated`."""
    content = content.replace(old_step2_ssh, new_step2_ssh)

    # 5. Step 3 Clone Flags & alim-seo-writing Handling
    old_step3_clone = """2. **The 8 Default Repositories Table (Cloned Automatically):**
   Clone missing repositories using `gitmap clone <url> ~/workspace/repos/<repo>`:"""
    new_step3_clone = """2. **The 8 Default Repositories Table (Cloned Automatically):**
   Clone missing repositories using `gitmap clone <url> --ssh --no-vscode-sync --target-dir ~/workspace/repos`:"""
    content = content.replace(old_step3_clone, new_step3_clone)

    old_table_alim = "| 4 | `alim-seo-writing` | `https://github.com/alimtvnetwork/alim-seo-writing.git` | SEO articles, Medium publishing, infographics |"
    new_table_alim = "| 4 | `alim-seo-writing` | `https://github.com/alimtvnetwork/alim-seo-writing.git` | SEO articles, Medium publishing, infographics (*max 3 retries*) |"
    content = content.replace(old_table_alim, new_table_alim)

    if "**Do Not Get Stuck on One Repo (`alim-seo-writing` Disconnect Invariant):**" not in content:
        target_after_table = "| 8 | `repo-secrets` | `https://github.com/alimtvnetwork/repo-secrets.git` | **Vault repo:** Credentials, RSA-encrypted keys (`gitmap rs`) |\n\n3. **Dedicated Side Chats (5 Seeded from Repo Cache):**"
        replacement_after_table = """| 8 | `repo-secrets` | `https://github.com/alimtvnetwork/repo-secrets.git` | **Vault repo:** Credentials, RSA-encrypted keys (`gitmap rs`) |

   > [!IMPORTANT]
   > **Do Not Get Stuck on One Repo (`alim-seo-writing` Disconnect Invariant):**
   > `alim-seo-writing` frequently fails with `fetch-pack: unexpected disconnect` (SSH and HTTPS, shallow clones included).
   > - Retry at most **3 times**.
   > - If it fails 3 times, **DO NOT STALL ONBOARDING**: immediately defer `alim-seo-writing`, mark it as an open item in the Step 9 report, and continue cloning the remaining 7 repositories.

3. **Dedicated Side Chats (5 Seeded from Repo Cache):**"""
        content = content.replace(target_after_table, replacement_after_table)

    # 6. Step 4 GitMap DB Self-Lock Workaround
    old_step4 = """### Step 4: Pull All Handpicked Repositories (`gitmap pa`)

1. **Execution Procedure:**
   ```bash
   cd ~/workspace/repos && gitmap pa
   ```
   `gitmap pa` fetches remote heads, executes fast-forward pulls across all workspace repositories, and verifies working trees."""

    new_step4 = """### Step 4: Pull All Handpicked Repositories (`gitmap pa` / Fallback)

1. **Execution Procedure:**
   ```bash
   cd ~/workspace/repos && gitmap pa
   ```
   > [!IMPORTANT]
   > **GitMap DB Self-Lock Workaround (v6.98.1):**
   > In GitMap v6.98.1, a SQLite DB self-lock condition can cause `gitmap ls` or `gitmap pa` to report 0 repositories and error with `"another gitmap process is running"` displaying its own PID.
   > **Do not get stuck on this:**
   > 1. Treat `~/workspace/repos/.gitmap/output/gitmap.json` (7 records) as the scan source of truth.
   > 2. Fall back to plain `git pull --ff-only` within each individual repository directory:
   >    ```bash
   >    for repo in ~/workspace/repos/*/; do
   >      [ -d "$repo/.git" ] && (cd "$repo" && git pull --ff-only)
   >    done
   >    ```"""
    content = content.replace(old_step4, new_step4)

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated 01-muse-master-prompt.md.")


def harden_02_muse_generic() -> None:
    path = os.path.join(REPO_ROOT, "01-prompts", "27-muse-prompts", "02-muse-generic.md")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # Changelog
    if "### 📝 2026-11-11 Onboarding Hardening Changelog" not in content:
        content = content.replace(
            "## 📋 1. Letterly-Style Task Ingestion & Planning Initiation Template",
            f"> [!IMPORTANT]{CHANGELOG_BLOCK}\n\n## 📋 1. Letterly-Style Task Ingestion & Planning Initiation Template"
        )

    # Step 1
    old_step1 = """   - Verify `gitmap version`.
   - If missing, install immediately:
     - Linux/macOS:
       ```bash
       curl -fsSL https://raw.githubusercontent.com/alimtvnetwork/gitmap-v28/main/install-quick.sh | bash
       ```"""
    new_step1 = """   - Verify with `gitmap version` (NOT `gitmap --version`, which is an unknown command).
   - If missing, install pinned version (avoid unauthenticated GitHub API 403 on releases/latest):
     - Linux/macOS:
       ```bash
       # Discover working tag via git ls-remote:
       git ls-remote --tags https://github.com/alimtvnetwork/gitmap-v28.git
       # Pinned install v6.98.1:
       curl -fsSL https://raw.githubusercontent.com/alimtvnetwork/gitmap-v28/main/install-quick.sh | bash -s -- --dir ~/.local/bin --version v6.98.1
       # Inspect ~/.bashrc, comment out any non-comment broken lines added by installer, and verify:
       source ~/.bashrc
       ```"""
    content = content.replace(old_step1, new_step1)

    # Step 2
    old_step2 = """2. **Step 2: Check Git & GitHub Authentication:**
   - Run `gh auth status` and `gitmap login --status`.
   - If unauthenticated, choose:
     - (a) Browser login via `gh auth login --web` or `gitmap login --web`.
     - (b) SSH key generation via GitMap (Standardized Identity):
       ```bash
       gitmap ssh create "<email>-muse<muse-sequence>-<operator-name>" -y
       ```
       Deliver public key as a downloadable file at `.ai-memory/ssh/<identity>.pub` (never paste raw key into chat text to prevent corruption) and designate as **Authentication Key** in GitHub.
   - **REPORT:** Active authenticated account and SSH status."""

    new_step2 = """2. **Step 2: Check Git & GitHub Authentication:**
   - Run `gh auth status` and `ssh -T git@github.com` (note: `gitmap login --status` does NOT exist in v6.98.1).
   - If unauthenticated, prompt the operator for missing `<email>`, `<sequence>`, `<operator>` before generating key (never guess).
   - Run `gitmap ssh create` first (no `ssh-keygen` first, no `-y` flag; positional text is comment, default path is `~/.ssh/id_rsa`):
     ```bash
     gitmap ssh create "<email>-muse<muse-sequence>-<operator-name>"
     ```
   - SSH HOME mismatch: If running as root, copy keys to `/root/.ssh` (`chmod 700 /root/.ssh && chmod 600 /root/.ssh/*`) and test explicit identity first (`ssh -i ~/.ssh/id_rsa -T git@github.com`).
   - Deliver public key strictly as a downloadable file at `~/.ssh/id_rsa.pub` (never paste into chat text) and designate as **Authentication Key** in GitHub.
   - **REPORT:** Active authenticated account (`Hi <user>! You've successfully authenticated`)."""
    content = content.replace(old_step2, new_step2)

    # Step 3
    old_step3 = """   - Clone provided repositories into `~/workspace/repos/<repo-name>` using `gitmap clone <url> ~/workspace/repos/<dir>` (or link existing folders)."""
    new_step3 = """   - Clone provided repositories using `gitmap clone <url> --ssh --no-vscode-sync --target-dir ~/workspace/repos` (or link existing folders). If a repository disconnects repeatedly (`fetch-pack: unexpected disconnect`), retry max 3 times then defer as open item."""
    content = content.replace(old_step3, new_step3)

    # Step 4
    old_step4 = """4. **Step 4: Pull & Sync Handpicked Repositories:**
   - Run `cd ~/workspace/repos && gitmap pa` (or `gitmap pull` in current repository).
   - Ensure clean, conflict-free working trees.
   - **REPORT:** Pull summary across repositories."""

    new_step4 = """4. **Step 4: Pull & Sync Handpicked Repositories:**
   - Run `cd ~/workspace/repos && gitmap pa` (or `gitmap pull` in current repository).
   - Work around v6.98.1 DB self-lock bug: if `gitmap pa` locks itself, treat `~/workspace/repos/.gitmap/output/gitmap.json` as source of truth and verify with plain `git pull --ff-only` per repo directory.
   - Ensure clean, conflict-free working trees.
   - **REPORT:** Pull summary across repositories."""
    content = content.replace(old_step4, new_step4)

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated 02-muse-generic.md.")


def harden_04_muse_universal() -> None:
    path = os.path.join(REPO_ROOT, "01-prompts", "27-muse-prompts", "04-muse-universal-master-prompt.md")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # Changelog
    content = content.replace("Prompt Version: 6.5.0", "Prompt Version: 6.6.0 (2026-11-11 Real Onboarding Hardened Edition)")
    if "### 📝 2026-11-11 Onboarding Hardening Changelog" not in content:
        content = content.replace(
            "Prompt Version: 6.6.0 (2026-11-11 Real Onboarding Hardened Edition)",
            "Prompt Version: 6.6.0 (2026-11-11 Real Onboarding Hardened Edition)" + CHANGELOG_BLOCK
        )

    # Step 1
    content = content.replace(
        "gitmap version",
        "gitmap version (NOT gitmap --version)"
    )
    if "install-quick.sh --dir ~/.local/bin --version v6.98.1" not in content:
        content = content.replace(
            "Check if `gitmap` is installed (`gitmap version`).",
            "Check if `gitmap` is installed via pinned install (`curl -fsSL https://raw.githubusercontent.com/alimtvnetwork/gitmap-v28/main/install-quick.sh | bash -s -- --dir ~/.local/bin --version v6.98.1` discovering tags via `git ls-remote --tags`). Inspect ~/.bashrc and comment out broken lines, then verify `gitmap version` (never `gitmap --version`)."
        )

    # Step 2
    old_ssh_block = """    - **Option (b): SSH Key Generation & File Delivery Protocol**
      1. Generate SSH key with standardized identifier:
         ```bash
         # GitMap SSH generation (preferred):
         gitmap ssh create "<email>-muse<muse-sequence>-<operator-name>" -y
         # Or standard native ssh-keygen fallback:
         ssh-keygen -t ed25519 -C "<user-email>-muse-session" -f ~/.ssh/id_ed25519 -N ""
         eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
         ```"""

    new_ssh_block = """    - **Option (b): SSH Key Generation & File Delivery Protocol**
      1. Prompt for missing identity parameters before generating key (never guess).
      2. Run `gitmap ssh create` first (no `ssh-keygen` first, no `-y` flag; positional text is comment, default path is `~/.ssh/id_rsa`):
         ```bash
         gitmap ssh create "<email>-muse<muse-sequence>-<operator-name>"
         ```
      3. SSH HOME mismatch: If running as root, copy keys to `/root/.ssh` (`chmod 700 /root/.ssh && chmod 600 /root/.ssh/*`) and test explicit first (`ssh -i ~/.ssh/id_rsa -T git@github.com`).
      4. Deliver public key strictly as a downloadable file at `~/.ssh/id_rsa.pub` (never paste in chat)."""
    content = content.replace(old_ssh_block, new_ssh_block)

    # Step 3
    content = content.replace(
        "git clone <provided-url>",
        "gitmap clone <provided-url> --ssh --no-vscode-sync --target-dir ~/workspace/repos || git clone <provided-url>"
    )

    # Step 4
    content = content.replace(
        "git pull --ff-only origin $(git branch --show-current) || git pull origin $(git branch --show-current)",
        "git pull --ff-only origin $(git branch --show-current) || git pull origin $(git branch --show-current) # Work around DB self-lock via gitmap.json if gitmap pa errors"
    )

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated 04-muse-universal-master-prompt.md.")


def harden_24_muse_master() -> None:
    path = os.path.join(REPO_ROOT, "01-prompts", "24-muse-prompts", "01-muse-master-prompt.md")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # Changelog
    if "### 📝 2026-11-11 Onboarding Hardening Changelog" not in content:
        content = content.replace(
            "> **Prompt Version:** 1.0.0",
            f"> **Prompt Version:** 2.0.0 (2026-11-11 Real Onboarding Hardened Edition){CHANGELOG_BLOCK}"
        )

    # Phase 1 Auth Check
    old_p1_auth = """3. **GitHub CLI & SSH Authentication:** `gh auth status`.
   - If authenticated → record the account, continue.
   - If NOT authenticated → choose (a) `gh auth login` for browser device flow, or (b) generate and register SSH key using GitMap:
     `gitmap ssh create "<email>-muse<muse-sequence>-<operator-name>" -y`
     Deliver public key as a downloadable file at `.ai-memory/ssh/<identity>.pub` (never paste raw key into chat text to prevent corruption) and designate as **Authentication Key** in GitHub.
   - **STOP here until it passes.** No repo cloning, no pushing, no private reads before this.
4. **GitMap auth:** `gitmap login --status` (or `gitmap login` then verify).
   - If not authenticated → run `gitmap login` (paste a token when asked, or use
     the `--web` browser flow), then verify with `gitmap login --status`.
   - **STOP here until it passes.** GitMap's GitHub-backed commands need this."""

    new_p1_auth = """3. **GitHub CLI & SSH Authentication:** `gh auth status` and `ssh -T git@github.com` (note: `gitmap login --status` does NOT exist in v6.98.1; remove it).
   - If authenticated → record the account, continue.
   - If NOT authenticated → prompt for missing email, sequence, operator (never guess), then run `gitmap ssh create \"<email>-muse<sequence>-<operator>\"` first (no `ssh-keygen` first, no `-y` flag; positional text is comment, default path is `~/.ssh/id_rsa`).
   - SSH HOME mismatch: If running as root, copy keys to `/root/.ssh` (`chmod 700 /root/.ssh && chmod 600 /root/.ssh/*`) and test explicit first (`ssh -i ~/.ssh/id_rsa -T git@github.com`).
   - Deliver public key as a downloadable file at `~/.ssh/id_rsa.pub` (never paste raw key into chat text to prevent corruption) and designate as **Authentication Key** in GitHub.
   - **STOP here until it passes.** Verification success: `Hi alimtvnetwork! You've successfully authenticated`.
4. **GitMap Verification:** Verify with `gitmap version` (NOT `gitmap --version`, which is an unknown command)."""
    content = content.replace(old_p1_auth, new_p1_auth)

    # Phase 2 GitMap Build & Pinned install
    content = content.replace("`gitmap --version`", "`gitmap version`")
    content = content.replace(
        "`git clone https://github.com/alimtvnetwork/gitmap-v28.git`",
        "`curl -fsSL https://raw.githubusercontent.com/alimtvnetwork/gitmap-v28/main/install-quick.sh | bash -s -- --dir ~/.local/bin --version v6.98.1` (pinned install to avoid 403 on releases/latest; check ~/.bashrc and comment broken lines; source ~/.bashrc)"
    )

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated 24-muse 01-muse-master-prompt.md.")


def main() -> int:
    harden_01_muse_master()
    harden_02_muse_generic()
    harden_04_muse_universal()
    harden_24_muse_master()
    print("All Muse master prompts successfully hardened with 2026-11-11 onboarding fixes.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
