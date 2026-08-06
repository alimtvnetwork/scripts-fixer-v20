# Gitmap v28 upgrade, JSON bug fix, and new git-compact installer

Three pieces of work: fix the crash you hit, repoint gitmap at the new upstream repo, and add a new installer script for `git-compact`.

## 1. Fix the crash (Bad JSON escape sequence)

`scripts/07-install-git/config.json` line 6 contains a Windows path written with single backslashes inside a JSON string:

```
"_minFreeGB_note": "... install to system paths (C:\Program Files\Git). ..."
```

`\P` is not a valid JSON escape, so `ConvertFrom-Json` in `scripts/shared/logging.ps1` throws before script 07 can do anything.

Changes:
- Escape the path in `scripts/07-install-git/config.json` (`C:\\Program Files\\Git`).
- Same class of bug in `scripts/16-install-php/config.json` line 17: `C:\tools` parses as a literal TAB character, so the note renders wrong. Escape it to `C:\\tools`.
- Add a repo-wide guard so this cannot come back: a small validator (`tools/validate-json-configs.mjs`) that parses every `config.json`, `log-messages.json`, `manifest.json`, and `registry.json` under `scripts/`, `scripts-linux/`, `core/`, and `tools/`, and fails with the exact file path, line, column, and parser message (CODE RED rule: exact path plus reason). Wire it into the pre-commit hook and a CI workflow.

Note: two runtime artifacts under `scripts-linux/.logs/` and `scripts-linux/.summary/` are also malformed JSON. They are generated output, not source, so the validator will skip `.logs/`, `.summary/`, `.installed/`, and `.resolved/`.

## 2. Repoint gitmap from gitmap-v23 to gitmap-v28

Every reference to `alimtvnetwork/gitmap-v23` becomes `alimtvnetwork/gitmap-v28`, keeping the `{tag}` substitution and `-Tag` / `--tag` pinning behaviour intact.

Files touched:
- `scripts/35-install-gitmap/config.json` (installUrl, repo, releaseZipUrl)
- `scripts/35-install-gitmap/log-messages.json` (description, help examples)
- `scripts/35-install-gitmap/run.ps1` (comment referencing the v23 main branch)
- `scripts/35-install-gitmap/readme.md` (one-liners and badge links)
- `scripts-linux/35-install-gitmap/config.json` (installUrl)
- `scripts-linux/35-install-gitmap/run.sh`
- `spec/35-install-gitmap/readme.md`
- root `readme.md`

Canonical one-liners after the change:

```text
Windows: irm https://raw.githubusercontent.com/alimtvnetwork/gitmap-v28/main/install.ps1 | iex
Unix:    curl -fsSL https://raw.githubusercontent.com/alimtvnetwork/gitmap-v28/main/install.sh | sh
```

The Linux script currently deploys a bundled `payload/gitmap.sh` stub. It will be switched to the upstream `install.sh` one-liner (matching its own `config.json`, which already declares `curlOneLiner`), with the bundled payload kept as an offline fallback when the download fails.

## 3. New script: git-compact installer

New script id **71 - install-git-compact**, mirroring the structure of script 35 on both platforms:

```text
scripts/71-install-git-compact/         run.ps1, config.json, log-messages.json,
                                        manifest.json, readme.md, helpers/git-compact.ps1
scripts-linux/71-install-git-compact/   run.sh, config.json, log-messages.json,
                                        manifest.json, readme.txt
spec/71-install-git-compact/readme.md
```

Behaviour, same contract as every other installer here:
- `install` (default), `uninstall`, `--help`
- `-Tag` / `--tag` ref pinning, remote one-liner first, release ZIP fallback
- Triple-path logging via the shared `install-paths` helper
- `.installed/` tracking with `already-installed` status on rerun
- ASCII status glyphs (`[OK]`, `[==]`, `[XX]`) in the summary
- All user-facing strings live in `log-messages.json`, including a `help` block with commands, flags, and examples so `run.ps1 -I 71 -- -Help` and `run.sh --help` both print full text.

Registration:
- `scripts/registry.json` and `scripts-linux` equivalents get id `71`
- `tools/manifest-generate.cjs` / `registry-sync.cjs` regenerated
- shell completions regenerated (`completions/run.bash|zsh|ps1`)
- root `readme.md` script table gets a row

Assumption to confirm at build time: upstream is `https://raw.githubusercontent.com/alimtvnetwork/git-compact/main/install.ps1` and `.../install.sh`, same layout as gitmap. If the repo name or org differs, only `config.json` on both platforms needs updating.

## 4. Version bump

Minor bump in `version.json` (1.8.0 to 1.9.0) plus a `changelog.md` entry covering the JSON fix, the v28 repoint, and the new script 71.

## Verification

- `node tools/validate-json-configs.mjs` passes with zero bad files
- `node tools/manifest-validate.cjs` and `tools/spec-lint.cjs` pass
- `bash tools/check-read-memory-paths.sh` still 100 percent OK
- shellcheck workflow passes for the new `run.sh`
