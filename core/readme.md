# Core Layer

> Cross-platform contracts and shared utilities that PowerShell (`scripts/shared/`) and Bash (`scripts-linux/_shared/`) implementations MUST honor identically.

## Contracts (`core/contracts/`)

| File | Purpose |
|---|---|
| `contracts/status.schema.json`   | End-of-run JSON every script emits. PS and Bash MUST produce structurally identical output. |
| `contracts/manifest.schema.json` | Per-script `manifest.json` plugin descriptor. |
| `contracts/event.schema.json`    | Append-only event written to `.state/events.jsonl`. |

## DX helpers (`core/`)

| File | Purpose |
|---|---|
| `state.ps1` / `state.sh`             | Unified state store API (`Write-StateEvent` / `state_emit`). |
| `picker.ps1` / `picker.sh`           | TUI picker. Backend order: PS7 `Out-ConsoleGridView` / `gum` → `fzf` → numbered fallback. Set `LOVABLE_PICKER` to force. |
| `progress.ps1` / `progress.sh`       | Progress bar + ETA wrapper (`Write-ProgressETA` / `progress_step` + `pv_pipe`). Silent when `LOVABLE_JSON_OUT=1`. |
| `json-output.ps1` / `json-output.sh` | `--json` mode helpers. `LOVABLE_JSON_OUT=1` reroutes decorative output to stderr; `Write-JsonEnvelope` / `json_envelope` emit canonical status JSON. |

## doctor --fix

`.\run.ps1 doctor` runs the legacy fast checks. `.\run.ps1 doctor --fix` runs every drift / hygiene probe (registry sync, version sync, manifest schema, legacy-ref scan, required-packages) and auto-repairs the ones with writer counterparts. Always ends with a GRANT-style "missing pieces" report. `--json` switches to machine-readable output for the React site and external tooling.

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
