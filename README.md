# scripts-fixer

Cross-platform developer-environment installer suite (Windows / Linux / macOS) plus a small React control-room UI.

## Install

**Windows (PowerShell):**
```powershell
iwr -useb https://raw.githubusercontent.com/<owner>/<repo>/main/bootstrap.ps1 | iex
```

**Linux/macOS (bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/fix-repo.sh | bash
```

## At a Glance

| | |
|---|---|
| **65** Windows scripts | `scripts/` -- run with `./run.ps1` |
| **69** Linux/macOS scripts | `scripts-linux/` -- run with `./run.sh` |
| **43** scripts on all three OSes | see [Cross-OS Parity Matrix](docs/parity-matrix.md) |
| Single source of truth | [`registry.yaml`](registry.yaml) |
| Per-script metadata | `NN-*/manifest.json` (validated against [schema](core/contracts/manifest.schema.json)) |
| Unified events | `.state/events.jsonl` (see [event schema](core/contracts/event.schema.json)) |

## Indexes

- [Windows scripts](scripts/readme.md) -- auto-generated
- [Linux/macOS scripts](scripts-linux/readme.md) -- auto-generated
- [Cross-OS parity matrix](docs/parity-matrix.md) -- auto-generated
- [Core contracts (status / event / manifest)](core/README.md)
- [Changelog](CHANGELOG.md) -- auto-generated from git + `version.json`

## Doctor

Run all drift / hygiene checks in one command:

```powershell
./run.ps1 doctor          # report
./run.ps1 doctor --fix    # auto-repair where possible
./run.ps1 doctor --json   # machine-readable
```

## Development

```bash
# Verify everything before pushing:
node tools/registry-sync.cjs --check
node tools/sync-version.cjs --check
node tools/manifest-validate.cjs
node tools/docs-generate.cjs --check
node tools/spec-lint.cjs
node tools/allowlist-budget.cjs
node tools/gen-completions.cjs --check
node tools/manifest-aliases.cjs --check
bash tools/scan-legacy-fixer-refs.sh
```

The pre-commit hook (`bash tools/install-git-hooks.sh`) runs the same checks automatically.

## Shell completions

Generated from `registry.yaml`:

- bash: `source completions/run.bash`
- zsh:  `fpath+=(./completions); compinit; source completions/run.zsh`
- pwsh: `. ./completions/run.ps1`

## License

See [LICENSE](LICENSE).
