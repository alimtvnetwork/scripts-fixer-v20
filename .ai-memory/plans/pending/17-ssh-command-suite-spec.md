# SSH Command Suite — Implementation Specification & AI Instruction

> **Audience:** an AI coding agent implementing this feature set in a CLI repository.
> **Product-neutral:** the CLI binary is written as `<cli>` everywhere. Replace `<cli>` with the
> actual binary name of the target project (e.g. `mytool`). The local metadata folder is written
> as `<cli-dir>` (e.g. `.mytool`). Do not hardcode any other product name.
>
> This document is both a **specification** (what must exist) and an **instruction set**
> (how to build it, in what order, with what acceptance criteria).

---

## 0. TL;DR of the mandate

1. `<cli> ssh` with **no arguments** must _adopt_ whatever SSH key already exists on the machine:
   read it from disk, parse it, store it in the CLI's SQLite database, copy the public key to the
   clipboard, and print a standard, aligned status block **followed by a subcommand table and
   usage examples**.
2. Never regenerate a key that already exists. Never fail with `could not resolve email` when an
   email can be inferred.
3. A **profiles** subsystem provides alias-based identities: multiple named SSH keys, each usable
   for a specific repository or a whole tree of repositories, driving `git commit/pull/push`,
   editor launches, and GitHub Desktop.
4. **Keys only ever live in `~/.ssh/`.** Repo-local folders contain **JSON metadata only** and must
   be git-ignored.
5. **Help is a first-class feature.** Every command and subcommand has deep, example-rich help;
   nested levels are rendered with the `>>` marker; the same help content powers both the terminal
   and any UI surface, from one shared definition.

---

## 1. Mental model

```text
┌───────────────────────────────┐
│  ~/.ssh/                      │  ← the ONLY place private/public keys exist
│    id_rsa, id_rsa.pub         │     (default identity)
│    <slug>/id_ed25519(.pub)    │     (profile identities, one dir per profile)
│    config                     │     (generated Host blocks, managed section)
└───────────────┬───────────────┘
                │ referenced by path
                ▼
┌───────────────────────────────┐
│  SQLite database              │  ← source of truth
│  ~/.config/<cli>/<cli>.db     │     profiles, keys, repo bindings, history
└───────────────┬───────────────┘
                │ mirrored (read-optimised, human-inspectable)
                ▼
┌───────────────────────────────┐
│  <repo>/<cli-dir>/ssh/…json   │  ← JSON metadata ONLY, git-ignored
│    profile.json               │     "this repo uses profile X"
│    repos.json (tree root)     │     aggregate map for recursive binding
└───────────────────────────────┘
```

**Invariants (violating any of these is a bug):**

| #   | Invariant                                                                                                       |
| --- | --------------------------------------------------------------------------------------------------------------- |
| I1  | No private key material is ever written outside `~/.ssh/`.                                                      |
| I2  | No key material of any kind (public or private) is written into a repository working tree.                      |
| I3  | `<repo>/<cli-dir>/` contains only JSON, and is always present in `.gitignore` before any write.                 |
| I4  | SQLite is authoritative. Repo JSON is a cache; if they disagree, SQLite wins and the JSON is rewritten.         |
| I5  | Every operation is idempotent — running it twice produces the same end state and does not regenerate keys.      |
| I6  | Destructive actions (`rm`, `reset`, `--force`) back up first and require confirmation unless `--yes` is passed. |

---

## 2. Canonical terminal output contract

The following is the exact rendering contract, derived from real reference output. Any
implementation must reproduce this structure, spacing, and symbol usage.

### 2.1 The "key already exists" block

```text
 ℹ SSH key already exists on disk: C:\Users\Alim\.ssh\id_rsa
 Reusing existing key (no regeneration needed).

   Path:        C:\Users\Alim\.ssh\id_rsa
   Fingerprint: SHA256:Kqm0/r36P33xXo4FVN7fOfd+Ipa5jDLfEVr/WMZD5DU
   Public key:

 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDgV/6TjChaPqnJPBB0H2e5eaA31jnmv7C8P2PvTDgjFYAe1FBemY8sQ4rSuJWx1Pyh1N0I4UoapzI6CrJLxKQakTiJwIxv2CfLcUpXiEwEQH+qThwj2UYckAtT7comlidcfEr4onpkKeo8k4tB1VHhwjsrPHk2VajkPXJrVf31oKToJGRMWWOOVq91xxZAiv0EUcFzZQ4TCVfmCg1B7Q== alim.karim.aurea.16-dec-2024@desktop-corei9-direct.com

 ℹ Copy the public key above and add it to your Git provider.

 💡 Pass --force to back up and regenerate this key.
```

**Rules:**

- **`ℹ` info lines** — leading single space, symbol, single space, message. Rendered in cyan/blue.
- **Blank line**, then an **aligned detail block** indented by three spaces. Labels are left-aligned
  and padded to a common width (`Path:`, `Fingerprint:`, `Public key:` → pad to 12 characters +
  one space). Label in dim/grey, value in default foreground.
- **Fingerprint** is always `SHA256:` base64 (the output of `ssh-keygen -lf <key>.pub`), never MD5.
- **The public key is printed raw on its own line(s)** with no indentation guard and no truncation,
  so a terminal double-click / triple-click selects the whole key. It wraps naturally on narrow
  terminals — do **not** hard-wrap, hyphenate, or ellipsise it.
- **`💡` tip line** — the actionable next step. Rendered in yellow.
- Colour is applied only when stdout is a TTY and `NO_COLOR` is unset; otherwise emit plain text
  with the same layout so the output stays greppable and CI-safe.
- On Windows, paths render with backslashes; on POSIX, forward slashes. Never normalise away the
  platform's native separator in user-facing output.

### 2.2 The subcommand table (always printed after the block)

```text
Available SSH subcommands:
  ssh create [name]      Generate or reuse an SSH key
  ssh list (ls)          List all managed SSH keys
  ssh status (st)        Check ssh-agent and connection status
  ssh copy (cp)          Copy a public key to your clipboard
  ssh cat (view)         Print a public key to the terminal
  ssh delete (rm)        Remove a key from <cli> (and disk)
  ssh config             Rebuild ~/.ssh/config for all managed keys
  ssh join               Attach an existing on-disk key to <cli>
  ssh profiles           Manage alias-based SSH identities   >>
  ssh help               Full SSH help, including every subcommand
```

**Rules:**

- Two columns. Column 1 starts at indent 2; column 2 starts at a fixed column computed as
  `max(len(col1)) + 2`, minimum 25.
- Aliases are shown in parentheses after the canonical name: `list (ls)`.
- A command that has **its own subcommands** is marked with a trailing `>>` in the far-right
  position. `>>` means "this branch goes deeper — run `<cli> ssh <cmd> help` to expand it".
- The table is generated from the shared help registry (§8), never hand-written in two places.

### 2.3 Usage examples (always printed after the table)

```text
Examples:
  <cli> ssh                                  Adopt / show the default key
  <cli> ssh create work --email me@work.com  Create a named key
  <cli> ssh cp work                          Copy work's public key
  <cli> ssh profiles create "client-acme"    New alias identity
  <cli> ssh profiles set client-acme         Bind this repo to that identity
  <cli> ssh profiles set-repos client-acme   Bind every repo under this folder
  <cli> ssh help                             Everything, expanded
```

### 2.4 The failure that must not happen

Reference failure output:

```text
a@a:~$ <cli> ssh
could not resolve email; use --email flag
```

This is a **defect**, not acceptable behaviour. `<cli> ssh` must never require `--email` when a key
already exists, because the email is recoverable (§3.3). `--email` is only required when the CLI is
**creating a brand-new key** and no email can be inferred from any source. When it genuinely cannot
be resolved during creation, the error must be actionable:

```text
 ✖ Could not determine an email for the new key.
   Tried: existing key comment, git config user.email (repo, then global), $EMAIL, OS user@host.
   Fix:  <cli> ssh create <name> --email you@example.com
   Or:   git config --global user.email you@example.com
```

### 2.5 Symbol legend (use consistently everywhere)

| Symbol | Meaning                        | Colour |
| ------ | ------------------------------ | ------ |
| `ℹ`    | Information / neutral status   | cyan   |
| `✔`    | Success                        | green  |
| `⚠`    | Warning, non-fatal             | yellow |
| `✖`    | Error, operation failed        | red    |
| `💡`   | Tip / suggested next command   | yellow |
| `>>`   | Command has deeper subcommands | dim    |

If the terminal does not support UTF-8 (`LANG`/`LC_ALL` lacks UTF, or Windows legacy console),
fall back to ASCII: `i`, `+`, `!`, `x`, `*`, `>>`.

---

## 3. `<cli> ssh` — the adopt-and-report command

### 3.1 Contract

`<cli> ssh` (no arguments) is **read-first, non-destructive, and idempotent**. It never generates a
key.

### 3.2 Algorithm

```text
1.  Ensure the SQLite database exists; run pending migrations.
2.  Determine the SSH home: $SSH_HOME, else ~/.ssh (Windows: %USERPROFILE%\.ssh).
3.  Discover candidate default keys, in priority order:
       id_ed25519, id_ecdsa, id_rsa, id_dsa
    A candidate qualifies when BOTH <name> and <name>.pub exist and are readable.
4.  Also discover profile keys under ~/.ssh/<slug>/ (see §6) so the report is complete.
5.  For each discovered key:
      a. Read <name>.pub, split into  <type> <base64> <comment>.
      b. Compute the fingerprint via `ssh-keygen -lf <name>.pub` and parse the SHA256 field.
         If ssh-keygen is unavailable, compute it natively: SHA256 of the raw base64-decoded
         blob, base64-encoded, trailing '=' stripped.
      c. Stat the private key: mode, size, mtime. Warn (⚠, non-fatal) if mode is broader
         than 0600 on POSIX, and print the exact chmod command to fix it.
      d. Derive the email (§3.3).
      e. UPSERT into `ssh_keys` keyed by fingerprint (see §9). Update path/comment/type/
         last_seen_at. Never duplicate a row for a key that moved — match on fingerprint first,
         path second.
6.  Copy the primary (highest-priority default) public key to the clipboard (§4). Report the
    result with ℹ or ⚠; a clipboard failure never fails the command.
7.  Render §2.1 for the primary key, then §2.2 table, then §2.3 examples.
8.  Exit 0. Exit non-zero ONLY if the SSH home is unreadable or the database cannot be opened.
```

### 3.3 Email resolution order (used for adopt _and_ create)

1. Explicit `--email <value>`.
2. The comment field of the existing public key, when it looks like an email
   (`/^[^\s@]+@[^\s@]+\.[^\s@]+$/`).
3. `git config user.email` in the current repository.
4. `git config --global user.email`.
5. `$EMAIL` / `$GIT_AUTHOR_EMAIL`.
6. Synthesised `"<os-user>@<hostname>"` — allowed only for **adopt**, never silently for
   **create** (creation prints a `⚠` and asks for confirmation unless `--yes`).

### 3.4 Empty-machine behaviour

When no key exists at all, `<cli> ssh` must **not** error. It prints:

```text
 ℹ No SSH key found in ~/.ssh
 💡 Create one:  <cli> ssh create default
```

…followed by the same subcommand table and examples, and exits 0.

---

## 4. Clipboard requirement (all platforms)

Copying the public key to the system clipboard is **mandatory** for `<cli> ssh`, `<cli> ssh copy`,
and `<cli> ssh profiles create`.

Detection chain, first available wins:

| Platform               | Order                                                                         |
| ---------------------- | ----------------------------------------------------------------------------- |
| Linux (Wayland)        | `wl-copy` → `xclip -selection clipboard` → `xsel --clipboard --input`         |
| Linux (X11)            | `xclip -selection clipboard` → `xsel --clipboard --input` → `wl-copy`         |
| macOS                  | `pbcopy`                                                                      |
| Windows                | `clip.exe` → `powershell -NoProfile -Command Set-Clipboard`                   |
| WSL                    | `clip.exe` → then the Linux chain                                             |
| Headless / SSH session | OSC 52 escape sequence write to the TTY, when `--osc52` or `TERM` supports it |

Rules:

- Write the key **without** a trailing newline; some provider web forms reject the trailing `\n`.
- On success: ` ✔ Public key copied to clipboard.`
- On failure: ` ⚠ Could not copy to clipboard (no clipboard tool found).` plus the one-line install
  hint for the platform (`sudo apt install xclip`, etc.). **Exit code stays 0.**
- `--no-clipboard` disables the attempt entirely; `--quiet` suppresses the confirmation line but
  still copies.

---

## 5. Base SSH subcommands

Every subcommand below supports the global flags `--json`, `--quiet`, `--no-color`, `--yes`,
and `help`.

### 5.1 `<cli> ssh create [name]`

Generate **or reuse** a key.

- `name` defaults to `default`. The key path is `~/.ssh/id_ed25519` for `default`, otherwise
  `~/.ssh/<name>/id_ed25519`.
- Default type is `ed25519`; `--type rsa` uses 4096 bits. `--bits` applies to RSA only.
- **If the key already exists:** print the §2.1 block verbatim and exit 0. Do not regenerate.
- `--force`: back up `<key>` and `<key>.pub` to `<key>.bak.<UTC-timestamp>`, then generate fresh.
  Requires confirmation unless `--yes`.
- The key comment is `"<name>-<os>-<yyyy>-v<n>@<email-domain-or-host>"` unless `--comment` is given.
- After creation: `chmod 600` the private key, `chmod 644` the public key, add to `ssh-agent`
  when one is running, upsert into SQLite, rebuild `~/.ssh/config` (§5.7), copy to clipboard.

Examples:

```bash
<cli> ssh create
<cli> ssh create work --email me@work.com
<cli> ssh create legacy --type rsa --bits 4096
<cli> ssh create default --force --yes
```

### 5.2 `<cli> ssh list` (alias `ls`)

Table of every key known to SQLite: name, type, fingerprint (short, first 12 chars + `…`), path,
comment/email, profile binding count, `in-agent` yes/no, last seen.
`--json` emits the full rows. `--all` includes keys found on disk but not yet adopted, flagged
`unmanaged` with a hint to run `<cli> ssh join`.

### 5.3 `<cli> ssh status` (alias `st`)

Reports:

- Is `ssh-agent` running? (`SSH_AUTH_SOCK` present and reachable.)
- Which managed keys are loaded in the agent (`ssh-add -l` fingerprints matched to SQLite).
- Connectivity probe per configured provider: `ssh -T git@github.com` (and gitlab/bitbucket/azure
  when hosts are configured), with a 10-second timeout each, reporting the authenticated username
  when the provider returns one.
- The profile bound to the current directory, if any.
- `--repo <path>` targets another directory; `--no-network` skips the probes.

### 5.4 `<cli> ssh copy [name|slug]` (alias `cp`)

Copies that key's **public** key to the clipboard (§4). With no argument, uses the current repo's
bound profile, else the default key. `--print` also echoes it. Never touches private keys.

### 5.5 `<cli> ssh cat [name|slug]` (alias `view`)

Prints the public key to stdout, raw, no decoration, so it can be piped:
`<cli> ssh cat work >> ~/authorized_keys`. Decorated output only when stdout is a TTY and
`--pretty` is passed. Refuses to print private keys under any flag.

### 5.6 `<cli> ssh delete <name|slug>` (alias `rm`)

Removes the key from the CLI database. By default it **keeps files on disk**.

- `--purge` also deletes the key files, after backing them up to
  `~/.ssh/.<cli>-trash/<name>-<timestamp>/`.
- Refuses to proceed when repos are still bound to it, listing them, unless `--force`.
- Rebuilds `~/.ssh/config` and removes the key from the agent afterwards.

### 5.7 `<cli> ssh config`

Regenerates the managed section of `~/.ssh/config` from SQLite.

- Everything the CLI writes lives strictly between marker lines:
  `# >>> <cli> managed block >>>` … `# <<< <cli> managed block <<<`.
  User content outside the markers is never touched, and the file is backed up before each write.
- One `Host` entry per profile:

```sshconfig
# >>> <cli> managed block >>>
Host client-acme.github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/client-acme/id_ed25519
    IdentitiesOnly yes
# <<< <cli> managed block <<<
```

- `--check` performs a dry run and prints the diff; `--prune` removes orphaned entries.

### 5.8 `<cli> ssh join <path-to-key>` (alias `joiner`)

Adopts a key that exists on disk but is not yet in the database — the manual counterpart to the
automatic adoption in §3.

- Accepts the private key path, the `.pub` path, or a directory to scan.
- Validates the pair, computes the fingerprint, refuses on fingerprint collision with an existing
  row (prints the conflicting row instead).
- `--as <slug>` simultaneously registers it as a profile (§6) without generating anything.
- `--scan` walks `~/.ssh` (depth 2) and interactively offers each unmanaged key for joining;
  `--scan --yes` joins all of them non-interactively.

Examples:

```bash
<cli> ssh join ~/.ssh/id_rsa
<cli> ssh join ~/.ssh/old/work_ed25519 --as work
<cli> ssh join --scan
```

---

## 6. `<cli> ssh profiles` — alias-based identities

A **profile** is a named SSH identity: a slug, a key under `~/.ssh/<slug>/`, an email, an optional
provider host alias, and a set of repositories bound to it. Binding a repo makes every git
operation in that repo — `commit` signing, `pull`, `push`, `clone` of submodules, editor and
GitHub Desktop launches — use that identity, with zero manual `GIT_SSH_COMMAND` juggling.

### 6.1 `<cli> ssh profiles` and `<cli> ssh profiles status`

Both are the same command (`status` is the explicit alias). Show **everything**:

```text
 ℹ SSH profiles — 3 configured

   #  SLUG          KEY                              EMAIL                 REPOS
   1  personal      ~/.ssh/personal/id_ed25519       me@personal.com       4
   2  client-acme   ~/.ssh/client-acme/id_ed25519    alim@acme.io          12
   3  oss           ~/.ssh/oss/id_ed25519            alim@alimkarim.com    2

   Database:   ~/.config/<cli>/<cli>.db
   Key root:   ~/.ssh
   Active here: client-acme   (bound at /home/a/work/acme, via <cli-dir>/ssh/profile.json)

   Bound repositories for client-acme:
     /home/a/work/acme/api        ✔ .gitignore ok
     /home/a/work/acme/web        ✔ .gitignore ok
     /home/a/work/acme/infra      ⚠ .gitignore missing entry — run: <cli> ssh profiles set client-acme

 💡 <cli> ssh profiles help    for every profile subcommand   >>
```

`--json` returns the same data structurally. Exit 0 even with zero profiles (prints the create hint).

### 6.2 `<cli> ssh profiles create "<slug>"`

Creates a **new, isolated** identity.

- Slug normalisation: lowercase, spaces and `_` → `-`, strip anything outside `[a-z0-9-]`, collapse
  repeats, trim leading/trailing `-`. `"Client ACME  v2"` → `client-acme-v2`. The original input is
  stored as `display_name`.
- Key is created at `~/.ssh/<slug>/id_ed25519` (dir mode `0700`, key `0600`, pub `0644`).
  **Never inside a repository** (I1/I2).
- If that key already exists, reuse it and print the §2.1 block — do not regenerate.
- Flags: `--email`, `--type`, `--bits`, `--comment`, `--host <provider-host>` (default
  `github.com`), `--force`, `--no-clipboard`.
- Side effects: SQLite insert, `~/.ssh/config` rebuild (§5.7), agent add, clipboard copy, and the
  standard block + a `💡 Next: <cli> ssh profiles set <slug>` tip.

```bash
<cli> ssh profiles create "client-acme"
<cli> ssh profiles create "oss" --email alim@alimkarim.com --host github.com
<cli> ssh profiles create "gitlab-work" --host gitlab.com --type rsa --bits 4096
```

### 6.3 `<cli> ssh profiles ls`

Compact list: `#`, slug, display name, key path, email, host alias, repo count, created date.
`--json`, `--long`, `--sort name|repos|created` supported.

### 6.4 `<cli> ssh profiles set "<slug>"`

Binds **the current repository** to a profile. This is the command that "does the trick".

```text
1.  Resolve the git repo root from CWD (`git rev-parse --show-toplevel`).
    Not a repo → ✖ with a hint to run `git init` or pass `--repo <path>`.
2.  Resolve the slug in SQLite (accepts slug, display name, or numeric id).
    Unknown → ✖ listing the closest matches.
3.  GITIGNORE GUARD (mandatory, runs BEFORE any write):
      - Ensure <repo-root>/.gitignore exists.
      - Ensure it contains a line exactly `<cli-dir>/`.
      - If missing, append under a managed header:
            # >>> <cli> >>>
            <cli-dir>/
            # <<< <cli> <<<
      - Also verify the folder is not already tracked:
            git ls-files --error-unmatch <cli-dir> 2>/dev/null
        If tracked → ⚠ and run `git rm -r --cached <cli-dir>` (with confirmation) so no
        metadata or key path leaks into history.
4.  Write <repo-root>/<cli-dir>/ssh/profile.json  (§9.3) — JSON metadata only.
5.  UPSERT the binding row in SQLite (`repo_bindings`, unique on repo_path).
6.  Configure git for the repo, in this order:
      git config core.sshCommand "ssh -i ~/.ssh/<slug>/id_ed25519 -o IdentitiesOnly=yes"
      git config user.email "<profile email>"
      git config user.name  "<profile display name or --name>"
      Optionally rewrite the `origin` remote host to the profile host alias when
      `--rewrite-remote` is passed (git@client-acme.github.com:org/repo.git).
7.  Verify: run `GIT_SSH_COMMAND=... ssh -T git@<host>` unless `--no-verify`.
8.  Print ✔ summary: repo path, profile, key path, git identity, gitignore status, verify result.
```

Flags: `--repo <path>`, `--name`, `--email` (override for this repo only), `--rewrite-remote`,
`--no-verify`, `--dry-run`.

`<cli> ssh profiles set --none` / `--unset` removes the binding: deletes the repo JSON, unsets
`core.sshCommand`, and deletes the SQLite row. Keys are untouched.

```bash
cd ~/work/acme/api && <cli> ssh profiles set client-acme
<cli> ssh profiles set oss --repo ~/code/my-lib --rewrite-remote
<cli> ssh profiles set --unset
```

### 6.5 `<cli> ssh profiles set-repos "<slug>"`

Recursive binding across an entire folder tree.

```text
1.  Root = CWD (or --root <path>).
2.  Walk the tree to --depth N (default unlimited), collecting every directory that contains
    a `.git` entry (dir OR file, so worktrees and submodules are included).
      - Skip: node_modules, vendor, .venv, dist, build, target, and anything in --exclude globs.
      - Follow symlinks only with --follow.
3.  Print the discovered list and ask for confirmation (skipped with --yes / --dry-run).
4.  For EACH repo, perform the full §6.4 `set` procedure, including the gitignore guard.
    Failures are collected, never fatal; the run continues and reports a summary at the end.
5.  Write the AGGREGATE map at <root>/<cli-dir>/ssh/repos.json (§9.4) — JSON metadata only.
    The root folder itself need not be a git repo; if it is, apply the gitignore guard to it too.
6.  Summary: N bound, M skipped, K failed, with a per-item table.
```

**Reset:**

```bash
<cli> ssh profiles set-repos --reset
<cli> ssh profiles set-repos --reset --root ~/work --yes
```

Reset semantics (explicit, because this is easy to get wrong):

- Unbinds **every** repo under the root: deletes each `repo_bindings` row, unsets
  `core.sshCommand`, restores `user.email`/`user.name` to their pre-bind values when the CLI
  recorded them, and reverts any `--rewrite-remote` change.
- **Deletes the repo-local `<cli-dir>/ssh/` folders** (and `<cli-dir>/` itself when it becomes
  empty) at every level, including the aggregate `repos.json` at the root.
- **Does not touch `~/.ssh/` at all.** No key is deleted, moved, or regenerated by a reset. The
  profile itself continues to exist. Only bindings and their JSON caches disappear.
- SQLite retains the key rows and profile rows and records the reset in `history`, so
  `<cli> ssh profiles` immediately reflects `REPOS = 0` for that profile.
- `--reset --purge-gitignore` additionally removes the managed `# >>> <cli> >>>` block from each
  `.gitignore` it previously added. Without that flag the ignore entry is left in place (harmless).

Because SQLite stores the **absolute path of every repo-local metadata folder**, reset works even
when invoked from a different directory: `<cli> ssh profiles set-repos --reset --slug client-acme`
resets by profile rather than by tree.

Flags: `--root`, `--depth`, `--exclude <glob>` (repeatable), `--include-submodules`,
`--dry-run`, `--yes`, `--reset`, `--slug`, `--purge-gitignore`, `--json`.

### 6.6 `<cli> ssh profiles rm "<slug>"`

Deletes the profile from the database.

- Lists bound repos and refuses without `--force`; with `--force` it unbinds them first (same
  cleanup path as reset).
- Key files are **kept** unless `--purge-key`, which backs them up to
  `~/.ssh/.<cli>-trash/<slug>-<timestamp>/` before deleting.
- Rebuilds `~/.ssh/config`, removes the agent entry, records the deletion in `history`.
- Requires typed confirmation of the slug unless `--yes`.

### 6.7 `<cli> ssh profiles github-desktop "<slug|id>"`

Opens GitHub Desktop (or the configured GUI client) with the profile's identity active.

```text
1.  Resolve the profile (slug, display name, or numeric SQLite id).
2.  Determine the target repo: --repo, else CWD's repo root, else the profile's most recently
    bound repo, else open the app with no repo.
3.  Ensure the repo is bound (run the §6.4 set procedure when it is not, or fail with a hint
    under --no-autobind).
4.  Export the identity into the launch environment:
        GIT_SSH_COMMAND="ssh -i ~/.ssh/<slug>/id_ed25519 -o IdentitiesOnly=yes"
        GIT_AUTHOR_EMAIL / GIT_COMMITTER_EMAIL / GIT_AUTHOR_NAME / GIT_COMMITTER_NAME
5.  Launch, per platform:
        macOS    open -a "GitHub Desktop" <repo>
        Windows  start "" "%LOCALAPPDATA%\GitHubDesktop\GitHubDesktop.exe" <repo>
        Linux    github-desktop <repo>   (flatpak fallback: flatpak run io.github.shiftey.Desktop)
    Detached, non-blocking; the CLI exits 0 immediately after a successful spawn.
6.  Missing app → ✖ with the install hint and the exact manual command.
```

The same launcher mechanism backs sibling commands that MUST be provided with identical
flag/behaviour semantics:

```bash
<cli> ssh profiles code "<slug>"       # VS Code, identity in the environment
<cli> ssh profiles shell "<slug>"      # subshell with the identity exported
<cli> ssh profiles exec "<slug>" -- <command…>   # run any command under the identity
```

### 6.8 `<cli> ssh profiles export "<slug>" [path]`

Exports a single profile as JSON.

- Default output path: `./<cli>-ssh-profile.json` in the current folder. A directory argument means
  "write the default filename inside it". Collisions get `-1`, `-2`, … unless `--overwrite`.
- **What is exported:** slug, display name, email, host alias, key _type_ and _comment_, the
  **public key**, the fingerprint, created/updated timestamps, and the list of bound repo paths.
- **What is NOT exported:** the private key. Ever — unless the user passes
  `--include-private --yes`, which additionally requires `--passphrase` and encrypts the payload;
  the resulting file is written `0600` and the CLI prints a loud `⚠` warning.
- `--stdout` writes to stdout for piping; `--pretty` / `--compact` control formatting.

```bash
<cli> ssh profiles export client-acme
<cli> ssh profiles export client-acme ./backups/acme.json
<cli> ssh profiles export client-acme --stdout | jq .
<cli> ssh profiles export client-acme --include-private --passphrase-stdin --yes
```

### 6.9 `<cli> ssh profiles export-all [path]`

- Default output: `./<cli>-ssh-profiles.zip` in the current folder.
- Archive layout:

```text
<cli>-ssh-profiles.zip
  manifest.json            schema version, cli version, exported_at, profile count, checksums
  profiles/<slug>.json     one §6.8 payload per profile
  repos.json               the global repo→profile map
  README.txt               human note on what is and is not included
```

- `--format json` writes a single combined JSON file instead of a zip.
- `--slugs a,b,c` limits the set; `--include-private` obeys the same guard rails as §6.8.

### 6.10 `<cli> ssh profiles import [path]`

- Reads the §6.8 JSON (path, or default filename in CWD, or `-` for stdin).
- Validates the schema version; refuses unknown major versions with a clear message.
- Conflict policy: `--on-conflict skip|rename|overwrite` (default `skip`, printing what it skipped).
  `rename` appends `-2`, `-3`, ….
- **Key handling:** the import registers the profile and looks for the matching key in `~/.ssh` by
  fingerprint. If found, it links it. If not found, the profile is imported in state
  `key-missing`, and the CLI prints the exact `<cli> ssh profiles create <slug>` /
  `<cli> ssh join` command to complete it. Import never fabricates a key.
- `--bind-repos` re-applies the repo bindings from the payload for paths that exist locally,
  running the full §6.4 procedure (including the gitignore guard) for each.
- `--dry-run` prints the plan and changes nothing.

### 6.11 `<cli> ssh profiles import-all [path]`

Same semantics as §6.10, but reads the zip (or combined JSON) produced by §6.9, iterates every
profile, and prints a per-profile result table plus a final summary. Identical flags:
`--on-conflict`, `--bind-repos`, `--dry-run`, `--slugs`.

---

## 7. Git integration details

- **Per-repo identity** is applied through `core.sshCommand` (repo-scoped git config), not through
  global config, so unbound repos are never affected.
- **Host aliasing** (`git@<slug>.github.com:org/repo.git`) is offered via `--rewrite-remote` for
  users who prefer URL-based routing; the managed `~/.ssh/config` block makes those aliases work.
  Both mechanisms are supported and may coexist; `core.sshCommand` wins when both are present.
- **Submodules:** `set-repos --include-submodules` also writes `submodule.<name>.url` rewrites when
  remotes were rewritten.
- **Commit signing:** when `--sign` is passed, additionally set
  `gpg.format=ssh`, `user.signingkey=<pubkey path>`, `commit.gpgsign=true`, and append the key to
  the configured allowed-signers file.
- The CLI records the **previous values** of any git config key it overwrites in the
  `repo_bindings.prev_config` JSON column, so `--unset` and `--reset` restore them exactly.

---

## 8. Help system contract (mandatory, applies to ALL command groups)

### 8.1 One registry, two renderers

Help text lives in a **single declarative registry** in the codebase — one node per command with
`name`, `aliases`, `summary`, `description`, `args`, `flags`, `examples`, `children`. Both the
terminal renderer and the UI help surface consume that registry. Duplicating help text in two
places is forbidden; a test must assert that every registered command node is reachable from both
renderers and that no command exists without a help node.

### 8.2 Depth rules

- `<cli> ssh help` prints the **entire** SSH tree, fully expanded: base subcommands, the profiles
  group, and every profiles leaf including `export`, `export-all`, `import`, `import-all`,
  `set-repos`, `github-desktop`, `code`, `shell`, `exec`.
- `<cli> ssh profiles help` prints the profiles subtree, fully expanded.
- `<cli> ssh profiles export help` prints only that leaf: synopsis, every flag, and at least three
  worked examples.
- `help`, `--help`, and `-h` are interchangeable at every level.
- `<cli> help ssh …` (help-first form) resolves to the same node.

### 8.3 The `>>` marker

Any command that has children is rendered with a trailing `>>` in listings, and its expanded form
indents children beneath it with the same marker chain:

```text
 ssh                                   SSH keys and identities                >>
   ssh create [name]                   Generate or reuse an SSH key
   ssh list (ls)                       List all managed keys
   …
   ssh profiles                        Alias-based SSH identities             >>
     ssh profiles create "<slug>"      Create a new identity + key
     ssh profiles ls                   List identities
     ssh profiles set "<slug>"         Bind the current repo
     ssh profiles set-repos "<slug>"   Bind every repo under this folder      >>
       ssh profiles set-repos --reset  Unbind a tree, delete repo JSON only
     ssh profiles export "<slug>"      Export one identity as JSON            >>
     ssh profiles export-all           Export everything as a zip
     ssh profiles import [path]        Import one identity
     ssh profiles import-all [path]    Import a bundle
     ssh profiles github-desktop <id>  Open GitHub Desktop as this identity
     ssh profiles rm "<slug>"          Delete an identity
```

### 8.4 Leaf help template

Every leaf renders in this exact order:

```text
 <cli> ssh profiles export — Export one SSH profile as JSON

 USAGE
   <cli> ssh profiles export "<slug>" [path] [flags]

 ARGUMENTS
   <slug>    Profile slug, display name, or numeric id (required)
   [path]    Output file or directory. Default: ./<cli>-ssh-profile.json

 FLAGS
   --stdout            Write JSON to stdout instead of a file
   --overwrite         Replace an existing file instead of suffixing -1, -2…
   --include-private   Include the private key (requires --yes and --passphrase)
   --pretty | --compact
   --json              Machine-readable command result

 EXAMPLES
   <cli> ssh profiles export client-acme
   <cli> ssh profiles export client-acme ./backups/acme.json
   <cli> ssh profiles export client-acme --stdout | jq .

 SEE ALSO
   <cli> ssh profiles export-all   >>
   <cli> ssh profiles import       >>
```

### 8.5 Discoverability rules

- Running a group command with no arguments (`<cli> ssh`, `<cli> ssh profiles`) shows **status
  plus** the subcommand table plus examples — never a bare error.
- Unknown subcommands produce a `✖` with a "did you mean" suggestion (Levenshtein ≤ 2) and the
  parent's subcommand table.
- Every error message ends with a `💡` line naming the exact command that fixes it.
- **This whole §8 contract applies to every command group in the CLI, not only `ssh`.** Any group
  lacking deep help, examples, `>>` markers, or UI parity is incomplete.

---

### 9.3 `<repo>/<cli-dir>/ssh/profile.json`

```json
{
  "schema": 1,
  "profile": { "slug": "client-acme", "display_name": "Client ACME", "email": "alim@acme.io", "host_alias": "github.com" },
  "key": { "path": "~/.ssh/client-acme/id_ed25519", "type": "ed25519", "fingerprint": "SHA256:…" },
  "repo": { "path": "/home/a/work/acme/api", "bound_at": "2026-08-27T02:28:00Z" },
  "note": "Metadata only. No key material is stored here. This folder must stay git-ignored."
}
```

Never contains a private key. The `key.path` is a **reference**, not content.

### 9.4 `<tree-root>/<cli-dir>/ssh/repos.json`

```json
{
  "schema": 1,
  "tree_root": "/home/a/work/acme",
  "profile": "client-acme",
  "generated_at": "2026-08-27T02:28:00Z",
  "repos": [
    { "path": "/home/a/work/acme/api",   "bound": true,  "gitignore_ok": true },
    { "path": "/home/a/work/acme/web",   "bound": true,  "gitignore_ok": true },
    { "path": "/home/a/work/acme/infra", "bound": false, "error": "not a git repository" }
  ]
}
```

---

## 10. Security rules

1. Private keys never leave `~/.ssh` and are never printed, logged, exported (without the explicit
   double opt-in of §6.8), or written into a repository.
2. Permissions are enforced on every write: `~/.ssh` `0700`, profile dirs `0700`, private keys
   `0600`, public keys `0644`, database `0600`.
3. The gitignore guard (§6.4 step 3) runs before **any** repo-local write; if it cannot be
   satisfied, the command aborts rather than writing.
4. Passphrases are read from a TTY prompt or `--passphrase-stdin`; never from argv, never echoed,
   never stored.
5. All destructive operations back up first into `~/.ssh/.<cli>-trash/` and log to `history`.
6. `--json` output is scrubbed of secrets identically to human output.

---

## 11. Implementation checklist (ordered, each item independently verifiable)

1. SQLite layer: open/create, WAL, migrations, all four tables, typed accessors.
2. Key discovery + public-key parsing + SHA256 fingerprinting (with and without `ssh-keygen`).
3. Email resolution chain (§3.3) with unit tests for every fallback step.
4. Output renderer: symbols, colours, alignment, TTY/NO_COLOR/ASCII fallbacks; golden-file tests
   against the §2.1 block.
5. Clipboard abstraction with the full platform chain (§4) and graceful degradation.
6. `<cli> ssh` adopt flow end-to-end (§3), including the empty-machine path and idempotency test.
7. Help registry (§8) + terminal renderer + `>>` markers; test asserting every command has a node
   and every node is reachable from `<cli> ssh help`.
8. Base subcommands: `create`, `list`, `status`, `copy`, `cat`, `delete`, `config`, `join`.
9. `~/.ssh/config` managed-block writer with marker preservation and backup.
10. Profiles: `create`, `ls`, `status`/bare.
11. Gitignore guard as a standalone, tested unit.
12. `profiles set` / `--unset` with git config capture and restore.
13. `profiles set-repos` with recursive discovery, aggregate JSON, and full `--reset` semantics
    (verifying `~/.ssh` is untouched).
14. `profiles rm`.
15. `export` / `export-all` / `import` / `import-all` with schema versioning and conflict policies.
16. Launchers: `github-desktop`, `code`, `shell`, `exec`.
17. UI help surface fed by the same registry; parity test between terminal and UI.
18. Apply the §8 help contract to every other command group in the CLI.

### Acceptance criteria

- `<cli> ssh` on a machine with an existing `~/.ssh/id_rsa` prints the §2.1 block, copies the key to
  the clipboard, inserts exactly one `ssh_keys` row, and exits 0 — and running it ten times changes
  nothing.
- `<cli> ssh` never emits `could not resolve email` when a key exists.
- `<cli> ssh help` output contains every command named in this document.
- Every group listing shows `>>` on branches that go deeper.
- After `profiles set`, `git push` in that repo authenticates with the profile key, and
  `<cli-dir>/` is git-ignored and untracked.
- After `set-repos --reset`, every binding and repo-local JSON folder is gone and `~/.ssh` is
  byte-for-byte unchanged.
- `grep -r "PRIVATE KEY"` over every exported file, repo-local JSON, and log finds nothing
  (absent the explicit `--include-private` opt-in).
