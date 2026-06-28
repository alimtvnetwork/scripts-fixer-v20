# aukgit/kubernetes-training-v1 -- zsh install comparison

Reference repo: https://github.com/aukgit/kubernetes-training-v1
Mirrored files: `.lovable/reference/aukgit-kubernetes-training-v1/`

## Files studied

| Reference file | Purpose | Our counterpart |
|---|---|---|
| `02-ubuntu-install/05-omy-zsh-only.sh` | One-shot zsh + Oh-My-Zsh installer, chsh, plugin clone, append `.zshrc` | `scripts-linux/60-install-zsh/run.sh` |
| `02-ubuntu-install/01-zsh-theme-change-v2.sh` | Interactive theme switcher with catalog + line-by-line `.zshrc` dedup append | `scripts-linux/61-install-zsh-theme-switcher/run.sh` |
| `02-ubuntu-install/11-clear-ohmyzsh.sh` | Wipe `~/.oh-my-zsh` + `~/.zshrc` then reinstall fresh | `scripts-linux/62-install-zsh-clear/run.sh` |
| `02-ubuntu-install/.zshrc-base` | Curated `.zshrc` with aliases for git/k8s/nginx/vim/apt + kubectl completion | `scripts-linux/60-install-zsh/payload/zshrc-base` + `payload/zshrc-extras` |
| `02-ubuntu-install/08-create-root-user-nozsh.sh` | Provision a non-zsh root user with `authorized_keys` | -- (out of scope; covered by `68-user-mgmt`) |

## Where the reference is weaker -- already fixed in our scripts

1. **`export ZSH="~/.oh-my-zsh"`** (reference `.zshrc-base` line 4) -- the literal `~` does NOT expand inside double quotes; this leaves OMZ broken until manually edited. We write `export ZSH=$HOME/.oh-my-zsh` in our `payload/zshrc-base`.
2. **No backup before destructive `rm -rf ~/.zshrc ~/.oh-my-zsh`** in `11-clear-ohmyzsh.sh`. Our `62-install-zsh-clear` snapshots into `~/.zsh-backups/<timestamp>/` first and supports `restore_from_backup` + marker-bounded surgical removal.
3. **`chsh -s $(which zsh)` unconditional** in the reference -- breaks on hosts with no PAM / non-login shells. Our `60` gates this behind `config.set_default_shell` (default `false`) and downgrades to a warning on failure.
4. **No idempotency markers** -- the reference appends `.zshrc` line-by-line each run; over time the file accretes duplicates if any line is edited. We wrap our extras in `# >>> lovable zsh extras >>>` / `# <<< lovable zsh extras <<<` and skip when present.
5. **No validation report** -- the reference trusts the install worked. Our `60 validate` prints a PASS/WARN/FAIL table across 8 dimensions (binary, OMZ dirs, `.zshrc` structural lines, theme resolvability, plugin resolvability, extras markers).
6. **No structured `install/check/repair/validate/uninstall` verbs** -- reference has one mode. We follow the generic install-script spec.

## Where the reference is interesting -- worth borrowing

| Idea | Status in our repo | Action |
|---|---|---|
| Big curated alias pack (git/k8s/nginx/vim/apt) | **Already shipped** in `payload/zshrc-extras` (mirrors reference catalogue) | none |
| `kubectl completion zsh` auto-wiring | **Already shipped**, safer: guarded by `command -v kubectl` | none |
| Interactive theme picker with `read -p` fallback to `robbyrussell` | We accept `--theme NAME` non-interactively; could add interactive fallback when stdin is a TTY | small enhancement |
| Long named theme catalog in `--help` | Our `61` switcher knows themes but doesn't print a 40+ entry catalog | could mirror the reference catalogue |
| Brew shellenv auto-wiring | Only present as `brew_fix` alias today | optional `auto_brew_shellenv` block, guarded by `command -v brew` |
| `08-create-root-user-nozsh.sh` (user provisioning with keys) | Covered by `68-user-mgmt` (richer) | none |

## Ideas to improve our Linux installer further (not just zsh)

1. **Per-user vs system install** -- reference assumes single-user. Add `--user <name>` to `60/61/62` so root can install for a target user (resolve `$HOME`, run `chsh` against that user). Useful for fleet/VM bootstrap.
2. **Plugin-pack presets** -- expose `plugin_preset: minimal|developer|devops|kubernetes` in `60/config.json` so users don't hand-curate `custom_plugins[]`. The k8s preset would pull `zsh-autosuggestions`, `zsh-syntax-highlighting`, `kube-ps1`, `kubectx`.
3. **`zsh-syntax-highlighting`** -- not in current `custom_plugins[]`. It's the standard companion to `zsh-autosuggestions` and is in basically every "best zsh setup" guide. Cheap add to `60/config.json`.
4. **Powerlevel10k as a one-flag opt-in** -- the reference doesn't ship it. Add `theme_preset: powerlevel10k` that clones the repo into `custom/themes/powerlevel10k` and rewires `ZSH_THEME=powerlevel10k/powerlevel10k`.
5. **Tool completion hub** -- reference only wires `kubectl`. Generalize the conditional pattern: loop a list of `{tool, completion-emit-cmd}` and append guarded `command -v X && source <(...)` blocks for `kubectl`, `helm`, `kind`, `minikube`, `gh`, `docker`, `pnpm`, `rustup`, `flutter`. Driven by config.
6. **`Reference: <repo>` provenance line** in each `payload/zshrc-extras` so future contributors see where the alias catalogue came from.
7. **macOS parity** -- our `60/61/62` are gated on apt/Debian. Add `is_macos` branch that swaps `sudo apt install -y zsh git curl` for `brew install zsh git curl` (or skips when zsh is already the system default on macOS 10.15+).
8. **`zshrc-extras` modularization** -- split the single extras file into `extras/aliases.zsh`, `extras/k8s.zsh`, `extras/completions.zsh`, `extras/paths.zsh`. Deploy each into `${ZSH_CUSTOM}/` so OMZ auto-sources them; the user can disable a slice by `chmod -x` instead of editing `.zshrc`.
9. **Cross-host fan-out** -- our `scripts-orchestrator/` already has `ssh-keys-fanout` and `users-fanout` playbooks. Add a `zsh-fanout` playbook that uploads `60/61/62` + payloads and runs `60 install` across every host in `inventory/hosts.conf`. The reference assumes single-host.
10. **Manifest declaration** -- add `provides: ["zsh","oh-my-zsh"]` and `depends_on: ["07-install-git","02-install-package-managers"]` to `60/manifest.json` so the doctor can warn when prereqs are missing.

## Quick wins (1 small PR each)

- Add `zsh-syntax-highlighting` to `60/config.json:custom_plugins[]`.
- Add `theme_preset` enum to `60/config.json` with one-flag Powerlevel10k.
- Generalize completion wiring into `payload/zshrc-extras` for helm/minikube/gh/docker.
- Add `--user <name>` flag to `60/61/62`.
- Print theme catalog (40+ themes) in `61 --help`, mirroring the reference.
