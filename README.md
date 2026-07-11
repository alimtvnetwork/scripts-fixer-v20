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

## For AI Agents / Contributors

**Read [`.lovable/what-to-read.md`](.lovable/what-to-read.md) first.** It is the canonical onboarding guide covering folder structure, read-first files, and workflows for adding features, writing tests, fixing bugs, and authoring specs.

Quick map of the knowledge base:

| Path | Purpose |
|------|---------|
| [`.lovable/what-to-read.md`](.lovable/what-to-read.md) | **Start here** — read-first guide, folder map, workflows, hard rules |
| [`.lovable/overview.md`](.lovable/overview.md) | Project shape, tech stack, key directories |
| [`.lovable/memory/index.md`](.lovable/memory/index.md) | Master index of every memory file (core rules + topic memories) |
| [`.lovable/plan.md`](.lovable/plan.md) | Active roadmap and pending tasks |
| [`.lovable/strictly-avoid.md`](.lovable/strictly-avoid.md) | Hard prohibitions — never violate |
| [`.lovable/suggestions.md`](.lovable/suggestions.md) | Active + implemented suggestions tracker |
| [`.lovable/cicd-index.md`](.lovable/cicd-index.md) | CI/CD issue ledger |
| [`.lovable/prompts/index.md`](.lovable/prompts/index.md) | Reusable prompts (incl. `write-memory`, `read-memory`) |
| [`.lovable/memory/workflow/`](.lovable/memory/workflow/) | Current workflow status markers |
| [`.lovable/pending-issues/`](.lovable/pending-issues/) | Open issues (one file each) |
| [`.lovable/solved-issues/`](.lovable/solved-issues/) | Resolved issues with `## Solution` + `## Learning` |
| [`.lovable/memory/specs/`](.lovable/memory/specs/) | Verbatim user specs and directives |
| [`spec/`](spec/) | Per-script specifications (source of truth for behavior) |
| [`core/contracts/`](core/contracts/) | JSON schemas: manifest, status, event |
| [`registry.yaml`](registry.yaml) | Single source of truth for script registry |

Workflows (see `what-to-read.md` §3 for full detail):

- **Add a feature** → read spec/ + memory/index.md → update plan.md → implement → add unit test → bump `version.json` (minor) → update changelog.
- **Add a unit test** → PowerShell: `tests/pester/*.Tests.ps1`; Bash: `scripts-linux/<script>/tests/*.bats`; JS/TS: `src/test/*.test.ts` (vitest).
- **Fix a bug** → create `.lovable/pending-issues/NN-name.md` → fix → move to `solved-issues/` with `## Solution` + `## Learning` → add pattern to `strictly-avoid.md` if applicable.
- **Author a spec** → `spec/NN-name/readme.md` following [`spec/00-generic-install-script-behavior/`](spec/00-generic-install-script-behavior/) as the template.

Hard rules (non-negotiable — see [`.lovable/strictly-avoid.md`](.lovable/strictly-avoid.md) and [`.lovable/memory/constraints/strictly-prohibited.md`](.lovable/memory/constraints/strictly-prohibited.md)):

- kebab-case filenames only; numeric prefix for sequenced files (`01-name.md`).
- Every code change bumps at least the minor version in `version.json`.
- Every file/path error logs the exact path + reason (CODE RED).
- No date/time content in any `readme.txt` (SP-1..SP-4).
- Booleans use `is`/`has` prefix; no bare `-not` checks.
- No Unicode box-drawing or em dashes in terminal banners — ASCII only.

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
