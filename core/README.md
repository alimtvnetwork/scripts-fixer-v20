# Core Layer

> Cross-platform contracts and shared utilities that PowerShell (`scripts/shared/`) and Bash (`scripts-linux/_shared/`) implementations MUST honor identically.

## Contracts (`core/contracts/`)

| File | Purpose |
|---|---|
| `status.schema.json`   | End-of-run JSON every script emits. PS and Bash MUST produce structurally identical output for the same tool. |
| `manifest.schema.json` | Per-script `manifest.json` plugin descriptor (name, aliases, platforms, depends_on, idempotent, destructive). Single source for dispatcher/registry/help/docs. |
| `event.schema.json`    | Append-only event written to `.state/events.jsonl`. Replaces ad-hoc `.installed/` / `.resolved/` / `.logs/` scraping. |

## State store (`.state/events.jsonl`)

Append-only JSONL — grep-able, atomic per-line, cross-platform. Helpers:

- `core/state.ps1`   → `Write-StateEvent`, `Get-StateEvents`
- `core/state.sh`    → `state_emit`, `state_query`
- `tools/state-query.cjs` → unified query CLI (used by `doctor`, `audit`, `kimodo`)

## Parity testing

`tools/test-parity.cjs` runs a script's PS and Bash entrypoints in `--version` mode and diffs their emitted status JSON. CI runs the parity matrix per release.

## Manifest tooling

- `tools/manifest-generate.cjs --bootstrap` — stub a `manifest.json` in every `NN-*/` folder from `registry.yaml`.
- `tools/manifest-validate.cjs` — schema-validate every manifest (run by pre-commit + CI).
- `tools/manifest-query.cjs <id|alias>` — resolve a dispatcher token to a folder/entrypoint.

## Migration policy

The contracts are **additive**: existing scripts keep working unchanged. New scripts MUST emit status JSON and a state event. Existing scripts adopt the contracts during their next touch.
