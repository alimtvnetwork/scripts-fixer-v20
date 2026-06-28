# zsh-fanout playbook

Lands `scripts-linux/60-install-zsh` (+ `61` theme switcher) on every host in
the target group. Mirrors what `60 install` does locally, just driven from the
controller over SSH.

## Inputs (orchestrator env)

| Variable                | Required | Purpose                                                                     |
|-------------------------|----------|-----------------------------------------------------------------------------|
| `ZSH_BUNDLE_B64`        | yes      | base64(`tar czf - scripts-linux/_shared scripts-linux/60-install-zsh scripts-linux/61-install-zsh-theme-switcher scripts-linux/62-install-zsh-clear`) |
| `TARGET_USER`           | no       | Drops privileges to that user on each host (`60 install --user <name>`).    |
| `THEME`                 | no       | Forwarded to `61 install --theme <name> --no-prompt`.                       |
| `SKIP_THEME_SWITCHER`   | no       | `1` to skip script 61.                                                      |
| `REMOTE_BUNDLE_DIR`     | no       | Where the tarball is unpacked (default `/opt/zsh-fanout`).                  |
| `DRY_RUN`               | no       | `1` prints the remote commands without running them.                        |

## Controller invocation

```bash
cd <repo>
TAR=$(mktemp -t zsh-fanout-XXXXXX.tgz)
tar czf "$TAR" -C . \
  scripts-linux/_shared \
  scripts-linux/60-install-zsh \
  scripts-linux/61-install-zsh-theme-switcher \
  scripts-linux/62-install-zsh-clear
export ZSH_BUNDLE_B64=$(base64 -w0 < "$TAR")
export TARGET_USER=alim
export THEME=robbyrussell

scripts-orchestrator/run.sh playbook zsh-fanout --group cluster
```

## Steps

1. `01-upload-bundle.sh`  -- decode + untar into `$REMOTE_BUNDLE_DIR`.
2. `02-apply-zsh.sh`      -- `sudo bash 60/run.sh install [--user $TARGET_USER]`, then 61.
3. `03-collect-summary.sh` -- one `[OK] zsh-fanout SUMMARY host=... zsh=... omz=... zshrc=... theme=...` line per host for the controller log.

## Idempotency

`60 install` is idempotent (marker-bounded extras block + `INSTALLED_MARK`),
so re-running this playbook is safe. Use `62-install-zsh-clear` separately for
removal.
