# Plan: Antigravity Cache Clear Enhancements, Colorful Bottom Summary & Dev-Clean Integration

- **Slug:** `20-agy-cache-clear-and-dev-clean`
- **Spec Reference:** [02-spec/21-app/20-agy-cache-clear-and-dev-clean.md](../../../02-spec/21-app/20-agy-cache-clear-and-dev-clean.md)
- **Status:** `completed`
- **Date Completed:** 2026-09-24
- **Initial Request:** Support attached short flag `-k<N>` syntax (e.g. `-k1`, `-k10`, `-k5`) across all entry points, relocate disk space reclamation summary to the very bottom of CLI output with vibrant ANSI colors, guarantee Linux/Ubuntu/macOS cross-OS parity, and inject Antigravity optimization into `os dev-clean` / `clean-dev`.
- **Total Execution Steps / Loops:** 1 unified plan & 4 subtasks executed in a continuous self-loop.

---

## 1. Traceability & Decomposed Subtasks

| Subtask ID | File | Description | Status |
|:---|:---|:---|:---:|
| `Task-01` | `01-short-flag-k.md` | Support `-k<N>` and `-t<KB>` attached short flags in PowerShell and Bash runners | `completed` |
| `Task-02` | `02-summary-and-colors.md` | Relocate savings summary to bottom with ANSI terminal styling & ASCII fallback | `completed` |
| `Task-03` | `03-cross-os-parity.md` | Ensure help and execution parity on Ubuntu / Linux / macOS bash scripts | `completed` |
| `Task-04` | `04-dev-clean-integration.md` | Auto-inject Antigravity cache/conversation cleanup as Step 12 in `dev-clean.ps1` | `completed` |

---

## 2. Key Architecture & Design Decisions

### 2.1 Attached Short Flag Parsing (`-k<N>` & `-t<KB>`)
- PowerShell's standard cmdlet parameter binding interprets `-k1` as an unknown parameter switch rather than `-Keep 1`.
- Implemented early token inspection and regex normalization in `run.ps1` and `scripts/69-install-antigravity/run.ps1` using `^(-k|--keep=?)(\d+)$` and `^(-t|--threshold=?)(\d+)$`.
- In `scripts-linux/run.sh` and `clear-agy.sh`, implemented bash pattern extraction with parameter expansion `${1#*-k}` and `${1#*=}`.

### 2.2 Terminal Visual Hierarchy & CP1252 Unicode Safety
- Relocated the `DISK SPACE RECLAMATION & CONVERSATION SUMMARY` box to the very end of both `predict_optimization` and `apply_optimization` in `agy_optimizer.py`.
- Formatted tables with itemized heavy conversations, Gemini Brain directories, and Application Cache paths first, culminating in the bottom summary box.
- Configured cross-platform ANSI color palette (`CYAN`, `GREEN`, `YELLOW`, `MAGENTA`, `WHITE`, `RED`, `GRAY`).
- Added `os.system("")` on Windows to enable VT100 ANSI sequences, along with `sys.stdout.reconfigure(encoding="utf-8", errors="replace")`.
- Replaced Unicode character `\u2605` with ASCII `[*]` to eliminate Windows `charmap` codec encoding crashes on legacy consoles.

### 2.3 Cross-OS Parity (Linux / Ubuntu / macOS)
- Updated `scripts-linux/69-install-antigravity/run.sh` with a dedicated `show_help()` function mirroring Windows help, ANSI colored headers, and examples.
- Updated aliases in `scripts-linux/69-install-antigravity/manifest.json` and `scripts-linux/run.sh` to route `agy cache clear`, `agy clear`, `agy predict`, and `agy help` identically.

### 2.4 Dev-Clean (clean-dev) Automation
- Extended `scripts/os/helpers/dev-clean.ps1` with micro-function `Invoke-AntigravityDevStep`.
- Step 12 automatically detects `clear-agy.ps1`.
- When invoked with `--dry-run` or `-d`, executes `clear-agy.ps1 -Predict -Keep 10`.
- When invoked in apply mode (`-y` / `--yes`), runs `clear-agy.ps1 -Yes -Keep 10`.

---

## 3. Modified & Created Files

| File | Type | Changes |
|:---|:---|:---|
| `run.ps1` | Modified | Added `-k<N>` attached flag parsing, `cache` verb routing, read-only help detection, and `Show-AgyHelp` fallback |
| `scripts/69-install-antigravity/run.ps1` | Modified | Added `Show-AgyHelp` invocation, parameter normalization for `-k<N>`, and verb routing table |
| `scripts/69-install-antigravity/helpers/clear-agy.ps1` | Modified | Added parameter aliases `[Alias("k")]` and `[Alias("t")]`, and `$RemainingArgs` parsing |
| `scripts/69-install-antigravity/helpers/agy_optimizer.py` | Modified | Relocated summary to bottom, added ANSI color engine, UTF-8 stdout reconfiguration, ASCII markers |
| `scripts/69-install-antigravity/helpers/help.ps1` | Created | Modularized `Show-AgyHelp` function for consistent rich terminal output |
| `scripts/dispatcher/root-help.ps1` | Modified | Updated root CLI help for `agy` and `clean-agy` with `-k<N>` syntax |
| `scripts/dispatcher/early-help.ps1` | Modified | Updated early help documentation for `agy` subcommands |
| `scripts/os/helpers/dev-clean.ps1` | Modified | Added Step 12 header entry and `Invoke-AntigravityDevStep` micro-function |
| `scripts-linux/run.sh` | Modified | Routed bare `agy` with no args to help screen |
| `scripts-linux/69-install-antigravity/run.sh` | Modified | Added `show_help()` function, colored help output, and verb routing |
| `scripts-linux/69-install-antigravity/helpers/clear-agy.sh` | Modified | Added `-k[0-9]*` and `-t[0-9]*` regex parsing in argument loop |
| `scripts-linux/69-install-antigravity/helpers/agy_optimizer.py` | Modified | Synchronized bottom-aligned summary and ANSI palette with Windows version |
| `02-spec/21-app/20-agy-cache-clear-and-dev-clean.md` | Created | Canonical application specification |
| `02-spec/21-app/01-index.md` | Modified | Registered spec #20 |

---

## 4. Verification & Testing

1. **Short Flag Parsing**:
   - `.\run.ps1 agy cache clear -k1` verified: parsed `Retention Policy: Keeping latest 1 conversations intact`, preserving 1 and targeting 9 older heavy conversations.
2. **Terminal Visual Layout**:
   - Output displayed top heavy conversations table, Gemini Brain cleanup targets table, and Application Cache scrub targets table first.
   - Output terminated with the highlighted `DISK SPACE RECLAMATION & CONVERSATION SUMMARY` box and Rollback tips.
3. **Help Screen**:
   - `.\run.ps1 agy help` and `.\run.ps1 agy` rendered formatted help with green actions and yellow flags.
4. **Dev-Clean Step 12**:
   - `.\run.ps1 os dev-clean --dry-run` successfully completed steps 1 through 12 without errors.
