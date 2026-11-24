---
name: universal-python-task-automation
description: >-
  Autonomously execute any operating system, configuration, troubleshooting, or maintenance task using a standalone, task-scoped Python execution engine. Scaffolds sequential folders (XX-<slug>/), cross-platform launchers (run.ps1 with cd $WORK and run.sh), modular Python scripts (functions <= 15 lines, files <= 200 lines, strongly typed enums, positive booleans, 0 nested ifs), dynamic cross-platform environment configuration (config/env.ini & env_config.py), pluggable task steps (IPipelineStep) with JSON pipeline support (config/pipeline.json), mandatory AI documentation header contract, dual console/file logging, and ergonomic argparse CLI with --dry-run simulation and interactive suggestions.
---

# Universal Python Task Automation

When an autonomous AI agent is tasked with **ANY** software or system task:
- Account creation, Windows sound/audio device troubleshooting, VMware network adapter repairs, WhatsApp desktop glitches, OS disk space optimization, cache cleanup, debug build artifact removal, software installation, or background service management;
- The AI **MUST NEVER** execute ad-hoc, unstructured shell snippets or inline throwaway commands;
- The AI **MUST ALWAYS** construct a self-contained, task-scoped folder (`XX-<slug>/`), generate cross-platform shell launchers (`run.ps1` and `run.sh`), author modular Python scripts adhering to grounded coding standards, provide an ergonomic CLI interface with `--dry-run` and interactive suggestions, and document the entire change history in `readme.md` and `what-to-read.md`.

## Task Folder Topology

```text
<workspace_root>/
└── XX-<slug>/                    # E.g. 01-os-disk-optimization
    ├── run.ps1                   # Windows PowerShell launcher (loads env.ini & exports $WORK)
    ├── run.sh                    # Linux/macOS POSIX launcher (loads env.ini & exports WORK)
    ├── config/                   # Configuration directory
    │   ├── pipeline.json         # Pluggable execution pipeline configuration
    │   └── env.ini               # Cross-platform environment variables (workdir, root, logs)
    ├── readme.md                 # Change history, feature stack, breakdown, instructions
    ├── what-to-read.md           # Context ingestion guide & institutional memory for future AIs
    ├── conversation/             # Turn-by-turn prompt & response traces
    │   ├── 01-user-request.md
    │   └── 02-refinement.md
    ├── scripts/                  # Modular Python scripts (each <= 200 lines)
    │   ├── __init__.py
    │   ├── app_errors.py         # Monadic Result[T] and AppError container
    │   ├── core_enums.py         # Strong typed enums (actions, categories, exit codes)
    │   ├── env_config.py         # Cross-platform INI parser, ${WORK} interpolation & os.environ loader
    │   ├── pipeline_engine.py    # Pipeline runner loading steps from config/pipeline.json
    │   ├── step_protocol.py      # IPipelineStep and StepContext protocol
    │   ├── steps/                # Modular troubleshooting & repair step implementations
    │   ├── logger.py             # Structured dual console/file logging
    │   ├── terminal_ui.py        # VMware-grade tree, 2-space left padding & box-drawing telemetry
    │   ├── cli_dispatcher.py     # Argparse CLI with rich formatted help text
    │   └── task_runner.py        # Functional task implementations (<= 15 lines/func)
    └── logs/                     # Execution logs with timestamps
        └── task.log
```

## Cross-Platform Launchers

### `run.ps1` (PowerShell)
```powershell
[CmdletBinding()]
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$RemainingArgs)
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $ScriptDir

# Cross-platform environment & $WORK navigation setup
$workDir = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$envIni = Join-Path $ScriptDir "config\env.ini"
if (-not (Test-Path $envIni)) { $envIni = Join-Path $workDir "ini-env\env.ini" }
if (Test-Path $envIni) {
    Get-Content $envIni | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and -not $line.StartsWith(";") -and $line -match '^([^=]+)=(.*)$') {
            Set-Item "Env:$($Matches[1].Trim())" $Matches[2].Trim()
            Set-Variable -Scope Global -Name $Matches[1].Trim() -Value $Matches[2].Trim()
        }
    }
}
if (-not [Environment]::GetEnvironmentVariable("WORK", "Process")) {
    Set-Item "Env:WORK" $workDir
    Set-Variable -Scope Global -Name WORK -Value $workDir
}

$python = (Get-Command python.exe -ErrorAction SilentlyContinue).Source
if (-not $python) { $python = (Get-Command py.exe -ErrorAction SilentlyContinue).Source }
if (-not $python) { Write-Error "Python 3 is required but not found in PATH."; exit 1 }

$scriptPath = Join-Path $ScriptDir "scripts\cli_dispatcher.py"
& $python $scriptPath @RemainingArgs
exit $LASTEXITCODE
```

### `run.sh` (POSIX)
```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

WORK="$(cd "$SCRIPT_DIR/.." && pwd)"
export WORK

ENV_INI="$SCRIPT_DIR/config/env.ini"
if [ ! -f "$ENV_INI" ] && [ -f "$WORK/ini-env/env.ini" ]; then
    ENV_INI="$WORK/ini-env/env.ini"
fi
if [ -f "$ENV_INI" ]; then
    while IFS='=' read -r key val || [ -n "$key" ]; do
        key="$(echo "$key" | tr -d ' \r\t')"
        val="$(echo "$val" | tr -d '\r')"
        if [ -n "$key" ] && [[ ! "$key" =~ ^[#;] ]]; then
            export "$key"="$val"
        fi
    done < "$ENV_INI"
fi

PYTHON_BIN="$(command -v python3 || command -v python || true)"
if [ -z "$PYTHON_BIN" ]; then
    echo "Error: Python 3 is required but not found in PATH." >&2
    exit 1
fi

SCRIPT_PATH="$SCRIPT_DIR/scripts/cli_dispatcher.py"
exec "$PYTHON_BIN" "$SCRIPT_PATH" "$@"
```

## Python Coding Standards & Invariants

1. **File Size Cap:** Strictly $\le 200$ lines per file.
2. **Function Limits:** Median functions 5–8 lines; strictly $\le 15$ lines maximum.
3. **Strongly-Typed Enums:** All actions, categories, and exit codes derive from `enum.StrEnum` or `enum.IntEnum`. Zero magic strings or raw exit integers.
4. **Positive Booleans Only:** All boolean variables, parameters, and flags must use `is_*` or `has_*` prefixes (e.g. `is_dry_run`, `has_cache`). Zero negative booleans.
5. **Zero Nested Ifs:** Flatten all conditionals with guard clauses and early returns.
6. **In-Memory Caching Wrapper:** Cache assets, configurations, and schema files via `FileSystemCache` tracking file `stat().st_mtime_ns` and SHA-256 for instant disk-freshness invalidation.
7. **Pluggable Step Injection:** Modularize discrete operations into pluggable classes or functions adhering to `ITaskStep` and orchestrate via `pipeline.json` without modifying the core CLI runner.
8. **Mandatory AI Documentation Header Contract:** Every modular task step file authored by an AI must include a standardized header specifying `USER REQUEST`, `PURPOSE`, `PROCESS`, and a verifiable `CHECKLIST`.
9. **Dual-Channel Logging:** Write timestamped logs to console and `logs/task.log`.
10. **Strict Relative Git Paths:** Zero drive letters or `file:///` URIs.
11. **Terminal Display Standard & Left-Hand Padding Invariant:** All terminal outputs must maintain a minimum 2-space left padding (`LEFT_PAD = "  "`), hierarchical Unicode box-drawing characters (`├──`, `│  `, `└──`), bracketed ANSI status badges (`[PASS]`, `[FAIL]`, `[ACTIVE]`, `[DRY-RUN]`), and zero error swallowing via `scripts/terminal_ui.py`.
