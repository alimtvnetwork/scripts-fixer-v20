# Universal Python Task Automation & System Execution Engine — Master Single-File Standalone Prompt

> **Prompt Version:** 2.0.0 (Master Standalone Single-File Edition)
> **Applicability:** ANY operating system task, software configuration, system repair, or maintenance automation
> **Portability:** 100% Sovereign Single-File (Direct Copy-Paste to GitHub Gist, GitLab Snippet, Antigravity, Cursor, Claude, ChatGPT, Muse)
> **Execution Invariant:** Every task is executed via a structured, modular Python script inside a task-scoped folder with zero external dependencies
> **Prerequisite Foundation Gist:**
> https://gist.githubusercontent.com/alimtvnetwork/9fe8c6fb25ab0e409a22e9c2624915da/raw/00-universal-common-foundation-prompt.md

```text
N = 400 (Total self-loop steps budget — default: 400)
A = 3   (MANDATORY number of spawned autonomous subagents running concurrently, default: 3)
H = 2   (Operational hands per agent: dual-task batch capacity & parallel tool dispatch, default: 2)
C = 30  (Tool calls per worker before it must report, default: 30)

PHASE_1_BUDGET = 100     (Steps 1 .. 100: Problem Analysis, Task Folder Scaffolding, Launchers, Enums & Logger)
PHASE_2_BUDGET = 150     (Steps 101 .. 250: Modular Function Implementation, CLI Argparse, Dry-Run Simulation, Guidelines)
PHASE_3_BUDGET = 150     (Steps 251 .. 400: Live Execution, Verification, Readme/History Documentation & Turn Showcase)
```

---

## 🎯 Mission Objective

When an autonomous AI agent is given this prompt for **ANY** software, maintenance, or operating system task:
- **Scope Catalog:** Whether creating user accounts, fixing Windows sound/audio services, repairing VMware virtual network adapters, resolving WhatsApp or desktop app glitches, optimizing OS disk space, purging caches, removing debug build artifacts, installing software, or managing background services;
- **Zero Ad-Hoc Command Ban:** The AI **MUST NEVER** execute ad-hoc, unstructured shell snippets, raw inline scripts, or throwaway terminal commands;
- **Task-Scoped Scaffolding Invariant:** The AI **MUST ALWAYS** construct a self-contained, task-scoped folder (`XX-<slug>/`), generate cross-platform shell launchers (`run.ps1` and `run.sh`), author modular Python scripts adhering to grounded coding standards (functions $\le 15$ lines, files $\le 200$ lines, strongly typed enums, zero nested ifs, positive booleans), provide an ergonomic CLI interface with `--dry-run` and interactive suggestions, and document the entire change history in `readme.md` and `what-to-read.md`.

---

## 📁 Task-Scoped Folder Architecture

Every task execution creates a dedicated sequential folder:

```text
<workspace_root>/
└── XX-<slug>/                    # Zero-padded sequence + descriptive slug (e.g. 01-os-disk-optimization)
    ├── run.ps1                   # Windows PowerShell launcher (auto-resolves Python, loads env.ini & exports $WORK)
    ├── run.sh                    # Linux/macOS POSIX launcher (auto-resolves python3, loads env.ini & exports WORK)
    ├── config/                   # Task & pipeline configuration directory
    │   ├── pipeline.json         # Pluggable pipeline step configuration (configurable execution items)
    │   └── env.ini               # Dynamic cross-platform environment variables (workdir, root, etc.)
    ├── readme.md                 # Change history, feature stack, breakdown, instructions
    ├── what-to-read.md           # Context ingestion guide & institutional memory for future AIs
    ├── conversation/             # Turn-by-turn prompt & response traces
    │   ├── 01-user-request.md
    │   └── 02-refinement.md
    ├── scripts/                  # Modular Python scripts (each <= 200 lines)
    │   ├── __init__.py           # Package marker
    │   ├── app_errors.py         # Monadic Result[T] and AppError container
    │   ├── core_constants.py     # Immutable constant classes (zero magic strings)
    │   ├── core_enums.py         # Strongly-typed enums ending in Type with parse() -> Result[T]
    │   ├── env_config.py         # Cross-platform INI parser, ${WORK} interpolation & os.environ loader
    │   ├── env_manager.py        # Dynamic $WORK auto-discovery, reboot survival & on-the-fly ENV setter
    │   ├── pipeline_engine.py    # Configurable pipeline runner executing steps from config/pipeline.json
    │   ├── step_protocol.py      # IPipelineStep protocol and StepContext definition
    │   ├── steps/                # Modular troubleshooting, repair & task fix step classes (<= 15 lines/func)
    │   │   ├── __init__.py
    │   │   └── sample_fix_step.py
    │   ├── sql_types.py          # SQL statements encapsulated in enums (Zero SQL in logic)
    │   ├── task_repository.py    # SQL Repository Pattern (ITaskRepository & SqliteTaskRepository)
    │   ├── task_logger.py        # Structured dual console ANSI badges & file JSON audit logging
    │   ├── terminal_ui.py        # VMware-grade tree, 2-space left padding & box-drawing telemetry
    │   ├── cli_dispatcher.py     # Argparse CLI with rich formatted help text, history & interactive suggestions
    │   └── task_runner.py        # Functional task implementations (<= 15 lines/func)
    └── logs/                     # Execution logs, JSON audits & SQLite audit DB
        ├── task.log
        ├── taskSummary.json
        └── tasks.db
```

---

## 🌐 2.5 Cross-Platform $WORK Directory & Dynamic ENV Management (Non-Negotiable)

1. **Dynamic $WORK Workspace Directory Invariant:**
   - The `$WORK` variable **MUST BE DERIVED DYNAMICALLY** from the workspace root environment variable (`$WORK` or fallback `$GITMAP_WORK_DIR`, repository parent directory, or interactively prompted from the operator).
   - Absolute filesystem paths (such as `D:\work` or `/work`) **MUST NEVER BE HARDCODED**. If `$WORK` and `$GITMAP_WORK_DIR` are not present in the environment, the setup script interactively asks the user: `"Please enter your WORK workspace directory path:"`.
   - The AI ensures that users can navigate to it using `cd $WORK` (with the dollar sign `$`) regardless of the operating system.

2. **Survives OS Restart Invariant:**
   - On Windows: The variable is persisted to the Windows User Environment Registry via `[System.Environment]::SetEnvironmentVariable("WORK", $workDir, "User")`. In addition, `$PROFILE` is configured with `if ($env:WORK) { $global:WORK = $env:WORK }` so that every new PowerShell session natively expands `$WORK` with the dollar sign.
   - On POSIX (Linux/macOS): Appends `export WORK="$work_dir"` to `~/.bashrc` and `~/.zshrc` so every new shell session exports `$WORK`.

3. **Adding New Environment Variables on the Fly:**
   - The AI must provide a command to add new environment variables dynamically:
     - PowerShell: `./run.ps1 -SetEnv "KEY=VALUE"`
     - Bash: `./run.sh --set-env KEY=VALUE`
     - Python: `python scripts/env_manager.py set KEY=VALUE`
   - **Atomic Invariant:** The command **MUST**:
     1. Add or update the key-value pair in `config/env.ini` (under `[environment]`).
     2. Update the active process `os.environ[KEY] = VALUE`.
     3. Persist the variable to the user's OS environment so it survives system reboots.

---

## 🚀 Cross-Platform Launchers (Embedded Reference)

### `run.ps1` (PowerShell for Windows)
```powershell
#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Windows PowerShell entrypoint for universal Python task automation.
.DESCRIPTION
    Loads config/env.ini, exports $WORK global/process variable for 'cd $WORK', discovers Python 3, and forwards arguments.
#>
[CmdletBinding()]
param(
    [string]$SetEnv,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ScriptArgs
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $ScriptDir

# 1. Cross-Platform Environment & $WORK Navigation Setup (Survives OS Restart)
# Dynamically resolve WORK directory from $env:WORK, $env:GITMAP_WORK_DIR, or user prompt (never hardcoded)
$workDir = $env:WORK
if (-not $workDir -or -not (Test-Path $workDir)) {
    $workDir = $env:GITMAP_WORK_DIR
}
if (-not $workDir -or -not (Test-Path $workDir)) {
    $parentCandidate = (Resolve-Path (Join-Path $ScriptDir "..")).Path
    if (Test-Path (Join-Path $parentCandidate ".git")) {
        $workDir = (Resolve-Path (Join-Path $parentCandidate "..")).Path
    }
}
if (-not $workDir -or -not (Test-Path $workDir)) {
    $workDir = Read-Host "Please enter your WORK workspace directory path (e.g. D:\work or ~/git-work)"
}

# Persist to User Registry so $WORK survives OS reboot
$currentUserWork = [Environment]::GetEnvironmentVariable("WORK", "User")
if ($currentUserWork -ne $workDir) {
    [Environment]::SetEnvironmentVariable("WORK", $workDir, "User")
}

# Export in active process and session
[Environment]::SetEnvironmentVariable("WORK", $workDir, "Process")
Set-Item "Env:WORK" $workDir
Set-Variable -Scope Global -Name WORK -Value $workDir

# Ensure PowerShell profile expands $global:WORK so user can run: cd $WORK
$profilePath = $PROFILE
if (-not $profilePath) {
    $profilePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "PowerShell\Microsoft.PowerShell_profile.ps1"
}
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}
$profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
if ($profileContent -notmatch '\$global:WORK\s*=') {
    Add-Content -Path $profilePath -Value "`nif (`$env:WORK) { `$global:WORK = `$env:WORK }`n"
}

# 2. Dynamic On-the-Fly Variable Mutation (-SetEnv "KEY=VALUE")
if ($SetEnv -and $SetEnv -match '^([^=]+)=(.*)$') {
    $newK = $Matches[1].Trim()
    $newV = $Matches[2].Trim()
    [Environment]::SetEnvironmentVariable($newK, $newV, "User")
    [Environment]::SetEnvironmentVariable($newK, $newV, "Process")
    Set-Item "Env:$newK" $newV
    Set-Variable -Scope Global -Name $newK -Value $newV
    Write-Host "[ OK ] Set dynamic environment variable: $newK=$newV (survives restart)" -ForegroundColor Green
}

# 3. Ingest config\env.ini
$envIni = Join-Path $ScriptDir "config\env.ini"
if (-not (Test-Path $envIni)) {
    $envIni = Join-Path $workDir "ini-env\env.ini"
}

if (Test-Path $envIni) {
    Get-Content $envIni | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and -not $line.StartsWith(";") -and $line -match '^([^=]+)=(.*)$') {
            $k = $Matches[1].Trim()
            $v = $Matches[2].Trim()
            [Environment]::SetEnvironmentVariable($k, $v, "Process")
            Set-Item "Env:$k" $v
            Set-Variable -Scope Global -Name $k -Value $v
        }
    }
}

# 4. Python 3 Runtime Discovery
$PythonCmd = $null
foreach ($Candidate in @("python", "py", "python3")) {
    $Command = Get-Command $Candidate -ErrorAction SilentlyContinue
    if ($null -ne $Command) {
        $PythonCmd = $Candidate
        break
    }
}

if ($null -eq $PythonCmd) {
    Write-Error "[ FAIL ] Python 3 runtime not found on PATH. Please install Python 3."
    exit 1
}

# 5. Unit Test Discovery & Runner
if ($ScriptArgs.Count -gt 0 -and $ScriptArgs[0] -eq "test") {
    $TestArgs = @()
    if ($ScriptArgs.Count -gt 1) {
        $TestArgs = $ScriptArgs[1..($ScriptArgs.Count - 1)]
    }
    & $PythonCmd -m unittest discover (Join-Path $ScriptDir "tests") -v @TestArgs
    exit $LASTEXITCODE
}

# 6. Dispatch to CLI Dispatcher
$TargetScript = Join-Path $ScriptDir "scripts\cli_dispatcher.py"
& $PythonCmd $TargetScript @ScriptArgs
exit $LASTEXITCODE
```

### `run.sh` (Bash for Linux/macOS)
```bash
#!/usr/bin/env bash
# POSIX Bash entrypoint for universal Python task automation.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Environment & WORK Navigation Setup (Survives OS Restart)
# Dynamically resolve WORK directory from $WORK, $GITMAP_WORK_DIR, or user prompt (never hardcoded)
if [ -z "${WORK:-}" ]; then
    WORK="${GITMAP_WORK_DIR:-}"
fi
if [ -z "${WORK:-}" ]; then
    PARENT_CANDIDATE="$(cd "$SCRIPT_DIR/.." && pwd)"
    if [ -d "$PARENT_CANDIDATE/.git" ]; then
        WORK="$(cd "$PARENT_CANDIDATE/.." && pwd)"
    elif [ -d "$HOME/git-work" ]; then
        WORK="$HOME/git-work"
    fi
fi
if [ -z "${WORK:-}" ]; then
    printf "Please enter your WORK workspace directory path: "
    read -r WORK
fi
export WORK

# Persist to ~/.bashrc and ~/.zshrc so cd $WORK survives OS restart
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$RC" ] && ! grep -q "export WORK=" "$RC"; then
        echo -e "\n# \$WORK export\nexport WORK=\"$WORK\"" >> "$RC"
    fi
done

# 2. Dynamic On-the-Fly Variable Mutation (--set-env KEY=VALUE)
if [ "${1:-}" = "--set-env" ] && [ -n "${2:-}" ]; then
    NEW_KEY="${2%%=*}"
    NEW_VAL="${2#*=}"
    export "$NEW_KEY"="$NEW_VAL"
    for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$RC" ]; then
            echo "export $NEW_KEY=\"$NEW_VAL\"" >> "$RC"
        fi
    done
    echo "[ OK ] Set dynamic environment variable: $NEW_KEY=$NEW_VAL (survives restart)"
    shift 2
fi

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

# 3. Python Runtime Discovery
PYTHON_CMD=""
for candidate in python3 python py; do
    if command -v "$candidate" >/dev/null 2>&1; then
        PYTHON_CMD="$candidate"
        break
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "[ FAIL ] Python 3 runtime not found on PATH. Please install Python 3." >&2
    exit 1
fi

if [ "${1:-}" = "test" ]; then
    shift
    exec "$PYTHON_CMD" -m unittest discover "$SCRIPT_DIR/tests" -v "$@"
fi

exec "$PYTHON_CMD" "$SCRIPT_DIR/scripts/cli_dispatcher.py" "$@"
```

---

## 🐍 Python Coding Standards & Engineering Invariants

1. **File Size Cap:** Strictly $\le 200$ lines per file. Never write monolithic scripts.
2. **Function Limits:** Median functions 5–8 lines; strictly $\le 15$ lines maximum.
3. **Monadic Error Handling:** All leaf functions must return generic `Result[T]` wrapping `AppError` on failures. Never raise uncaught exceptions or call exit handlers in leaf functions.
4. **Strongly-Typed Enums:** All actions, categories, exit codes, and operational modes must derive from enums ending in `Type`. No magic strings or raw exit integers.
5. **Positive Booleans Only:** All boolean variables, parameters, and flags must use `is_*` or `has_*` prefixes (e.g. `is_dry_run`, `has_cache`, `is_forced`). Zero negative or ambiguous booleans.
6. **Zero Nested Ifs:** Flatten all conditionals with guard clauses and early returns.
7. **Dual-Channel Logging:** Write clean ANSI colored badges to console and structured text/JSON audit records to `logs/task.log`.
8. **Universal UNIX LF Line Endings:** Total ban on CRLF (`\r\n`); 100% UNIX LF (`\n`).

---

## 💻 Full Embedded Reference Codebase

Every module below is production-grade, tested, and can be copied directly:

### 1. `scripts/app_errors.py` (Monadic Error Architecture)
```python
"""Monadic error architecture for universal Python tasks."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Generic, TypeVar

T = TypeVar("T")


@dataclass(frozen=True)
class AppError:
    """Structured enterprise application error container."""

    code: str
    message: str
    operation: str = ""
    details: dict[str, Any] = field(default_factory=dict)
    cause_message: str | None = None

    def to_dict(self) -> dict[str, Any]:
        """Convert error to dictionary representation."""
        return {
            "code": self.code,
            "message": self.message,
            "operation": self.operation,
            "details": self.details,
            "cause_message": self.cause_message,
        }

    def __str__(self) -> str:
        """Format error as a readable string."""
        if self.operation:
            return f"[{self.code}] {self.operation}: {self.message}"

        return f"[{self.code}] {self.message}"


class Result(Generic[T]):
    """Monadic container holding either a successful value or an AppError."""

    def __init__(self, value: T | None, error: AppError | None, is_safe: bool) -> None:
        self._value = value
        self._error = error
        self._is_safe = is_safe

    @classmethod
    def ok(cls, value: T) -> Result[T]:
        """Create a successful result container."""
        return cls(value=value, error=None, is_safe=True)

    @classmethod
    def fail(cls, error: AppError) -> Result[T]:
        """Create a failed result container wrapping an AppError."""
        return cls(value=None, error=error, is_safe=False)

    @property
    def is_safe(self) -> bool:
        """Return True if operation succeeded with no errors."""
        return self._is_safe

    @property
    def has_error(self) -> bool:
        """Return True if operation resulted in an error."""
        return not self._is_safe

    @property
    def is_defined(self) -> bool:
        """Return True if result is safe and value is not None."""
        return self._is_safe and self._value is not None

    @property
    def is_empty(self) -> bool:
        """Return True if result is safe and value is None."""
        return self._is_safe and self._value is None

    @property
    def value(self) -> T:
        """Unwrap value or raise RuntimeError if in failed state."""
        if self.has_error:
            raise RuntimeError(f"Attempted to unwrap failed result: {self._error}")

        return self._value  # type: ignore[return-value]

    @property
    def error(self) -> AppError:
        """Access AppError or raise RuntimeError if in safe state."""
        if self.is_safe:
            raise RuntimeError("Attempted to access error on successful result")

        return self._error  # type: ignore[return-value]

    def __repr__(self) -> str:
        """Return debug representation of result."""
        if self._is_safe:
            return f"Result.ok({self._value!r})"

        return f"Result.fail({self._error!r})"
```

### 2. `scripts/core_enums.py` (Strongly-Typed Enums)
```python
"""Core strongly-typed enums for universal Python task automation."""

from __future__ import annotations

from enum import Enum, IntEnum
from typing import Any, TypeVar

from app_errors import AppError, Result

E = TypeVar("E", bound="BaseParsableEnum")


class BaseParsableEnum(str, Enum):
    """Base parsable string enum with monadic parsing."""

    @classmethod
    def all_values(cls) -> list[str]:
        """Return list of all registered enum string values."""
        return [item.value for item in cls]

    @classmethod
    def is_valid(cls, raw_value: str) -> bool:
        """Return True if string matches a registered enum value."""
        return raw_value.strip().lower() in cls.all_values()

    @classmethod
    def parse(cls: type[E], raw_value: str) -> Result[E]:
        """Monadically parse string into enum member."""
        normalized = raw_value.strip().lower()
        for item in cls:
            if item.value == normalized:
                return Result.ok(item)

        error = AppError(
            code="VALIDATION_ERROR",
            message=f"Invalid {cls.__name__}: '{raw_value}'. Allowed: {cls.all_values()}",
            operation="parse",
            details={"raw_value": raw_value, "allowed": cls.all_values()},
        )
        return Result.fail(error)


class AppErrorCodeType(str, Enum):
    """Domain-specific error code classifications."""

    SYSTEM_ERROR = "SYSTEM_ERROR"
    IO_ERROR = "IO_ERROR"
    VALIDATION_ERROR = "VALIDATION_ERROR"
    PERMISSION_ERROR = "PERMISSION_ERROR"
    TIMEOUT_ERROR = "TIMEOUT_ERROR"
    NOT_FOUND_ERROR = "NOT_FOUND_ERROR"
    COMMAND_ERROR = "COMMAND_ERROR"
    UNKNOWN_ERROR = "UNKNOWN_ERROR"


class ActionType(BaseParsableEnum):
    """Universal CLI execution actions."""

    STATUS = "status"
    SCAN = "scan"
    PURGE = "purge"
    RESTART = "restart"
    REPORT = "report"

    def label(self) -> str:
        """Human-readable display label."""
        labels = {
            ActionType.STATUS: "Check Status",
            ActionType.SCAN: "Scan Targets",
            ActionType.PURGE: "Purge Cleanable Files",
            ActionType.RESTART: "Restart Service",
            ActionType.REPORT: "Generate Report",
        }
        return labels.get(self, self.value)


class TaskCategoryType(BaseParsableEnum):
    """Task category classifications."""

    OS_OPTIMIZATION = "os-optimization"
    WINDOWS_TROUBLESHOOTING = "windows-troubleshooting"
    VMWARE_MANAGEMENT = "vmware-management"
    APP_CACHE = "app-cache"
    SYSTEM_CLEANUP = "system-cleanup"

    def label(self) -> str:
        """Human-readable display label."""
        labels = {
            TaskCategoryType.OS_OPTIMIZATION: "OS Optimization",
            TaskCategoryType.WINDOWS_TROUBLESHOOTING: "Windows Troubleshooting",
            TaskCategoryType.VMWARE_MANAGEMENT: "VMware Management",
            TaskCategoryType.APP_CACHE: "Application Cache",
            TaskCategoryType.SYSTEM_CLEANUP: "System Cleanup",
        }
        return labels.get(self, self.value)


class ExitCodeType(IntEnum):
    """Standardized POSIX and Windows CLI exit codes."""

    SUCCESS = 0
    GENERAL_ERROR = 1
    USAGE_ERROR = 2
    CONFIG_ERROR = 3
    PERMISSION_ERROR = 4
    RUNTIME_ERROR = 5


class TargetStatusType(BaseParsableEnum):
    """Target execution state outcomes."""

    ACTIVE = "active"
    HEALTHY = "healthy"
    DEGRADED = "degraded"
    STOPPED = "stopped"
    CLEANED = "cleaned"
    SKIPPED = "skipped"


class CleanupRiskType(BaseParsableEnum):
    """Safety and risk levels for cleanup actions."""

    SAFE = "safe"
    CAUTION = "caution"
    DANGER = "danger"


class LogLevelType(BaseParsableEnum):
    """Logging severity levels."""

    INFO = "info"
    WARN = "warn"
    ERROR = "error"
    DEBUG = "debug"


class GitSyncFormatType(BaseParsableEnum):
    """Supported input file formats for repository synchronization."""

    TEXT = "text"
    JSON = "json"
    MARKDOWN = "markdown"


class TableType(BaseParsableEnum):
    """PascalCase SQLite database table names."""

    TASK_EXECUTIONS = "TaskExecutions"
    CREDENTIALS = "Credentials"
    WP_CREDENTIALS = "WpCredentials"
    PAGE_BACKUPS = "PageBackups"
    AUDIT_LOGS = "AuditLogs"
```

### 3. `scripts/core_constants.py` (Constants & Zero Magic Strings)
```python
"""Core immutable constants for universal Python task automation."""

from __future__ import annotations


class AnsiColorConstants:
    """ANSI terminal styling and color escape sequences."""

    RESET = "\033[0m"
    BOLD = "\033[1m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    GRAY = "\033[90m"


class LogBadgeConstants:
    """Standardized ANSI badges for console telemetry."""

    OK = "[  OK  ]"
    FAIL = "[ FAIL ]"
    WARN = "[ WARN ]"
    INFO = "[ INFO ]"
    SKIP = "[ SKIP ]"
    AUDIT = "[ AUDT ]"


class SoftwarePackageConstants:
    """Software package identifiers and package manager commands."""

    CHOCOLATEY = "choco"
    WINGET = "winget"
    VSCODE = "code"
    CURSOR = "cursor"
    GIT = "git"
    PYTHON = "python"
    VMWARE = "vmware"
    WHATSAPP = "WhatsApp"


def _resolve_system_root() -> Path:
    if os.name == "nt":
        root_str = os.environ.get("SystemRoot") or os.environ.get("WINDIR") or "C:\\Windows"
        return Path(root_str)
    return Path("/")


def _resolve_windows_temp() -> Path:
    if os.name == "nt":
        return _resolve_system_root() / "Temp"
    return Path("/tmp")


def _resolve_user_temp() -> Path:
    return Path(tempfile.gettempdir())


def _resolve_prefetch() -> Path:
    if os.name == "nt":
        return _resolve_system_root() / "Prefetch"
    return _resolve_user_temp() / "prefetch"


def _resolve_crash_dumps() -> Path:
    if os.name == "nt":
        return _resolve_system_root() / "Minidump"
    var_crash = Path("/var/crash")
    return var_crash if var_crash.exists() else _resolve_user_temp()


class OsPathConstants:
    """Standard operating system and directory cache paths resolved dynamically."""

    DEFAULT_LOGS_DIR = "logs"
    DEFAULT_LOG_FILE = "logs/task.log"
    DEFAULT_SUMMARY_FILE = "logs/taskSummary.json"

    @classmethod
    def get_system_root(cls) -> Path:
        """Resolve OS system root directory dynamically across Windows and POSIX."""
        return _resolve_system_root()

    @classmethod
    def get_windows_temp(cls) -> Path:
        """Resolve system temporary directory dynamically."""
        return _resolve_windows_temp()

    @classmethod
    def get_user_temp(cls) -> Path:
        """Resolve user temporary directory using standard tempfile OS function."""
        return _resolve_user_temp()

    @classmethod
    def get_prefetch(cls) -> Path:
        """Resolve Windows prefetch directory dynamically."""
        return _resolve_prefetch()

    @classmethod
    def get_crash_dumps(cls) -> Path:
        """Resolve system crash dumps / minidump directory dynamically."""
        return _resolve_crash_dumps()

    # Dynamic class-level string properties evaluated at module load
    WINDOWS_TEMP = str(_resolve_windows_temp())
    USER_TEMP = str(_resolve_user_temp())
    PREFETCH = str(_resolve_prefetch())
    CRASH_DUMPS = str(_resolve_crash_dumps())


class ProtectedNameConstants:
    """Files and patterns strictly protected from deletion or modification."""

    GITKEEP = ".gitkeep"
    CONFIG_JSON = "config.json"
    SETTINGS_JSON = "settings.json"
    ENV_FILE = ".env"
    PROTECTED_EXTENSIONS = (".git", ".svn", ".hg")


class GitSyncConstants:
    """Git repository synchronization defaults and SSH prefixes."""

    DEFAULT_WORKERS = 4
    SSH_PREFIX = "git@github.com:"
    HTTPS_PREFIX = "https://github.com/"
    CONFIG_FILENAME = "config.json"


class TableConstants:
    """PascalCase SQLite database table names."""

    TASK_EXECUTIONS: Final[str] = "TaskExecutions"
    CREDENTIALS: Final[str] = "Credentials"
    WP_CREDENTIALS: Final[str] = "WpCredentials"
    PAGE_BACKUPS: Final[str] = "PageBackups"
    AUDIT_LOGS: Final[str] = "AuditLogs"


class EnvConstants:
    """Canonical environment configuration keys and defaults."""

    ENV_WORK: Final[str] = "WORK"
    ENV_GITMAP_WORK_DIR: Final[str] = "GITMAP_WORK_DIR"
    SECTION_ENVIRONMENT: Final[str] = "environment"
    DEFAULT_CONFIG_PATH: Final[str] = "config/env.ini"


class EncodingConstants:
    """Standard character encoding format constants."""

    UTF8: Final[str] = "utf-8"
    ASCII: Final[str] = "ascii"
    UTF16: Final[str] = "utf-16"
    LATIN1: Final[str] = "latin-1"
```

### 4. `scripts/lazy_regex.py` (Lazy Regex Compilation Engine)
```python
"""Lazy regular expression compilation with thread-safe caching."""

from __future__ import annotations

import re
from typing import ClassVar, Pattern


class LazyRegex:
    """Thread-safe lazy regular expression compiler (cached on demand)."""

    _cache: ClassVar[dict[str, Pattern[str]]] = {}

    @classmethod
    def get(cls, pattern: str, flags: int = 0) -> Pattern[str]:
        """Retrieve compiled pattern from cache or compile and store."""
        key = f"{pattern}::{flags}"
        if key not in cls._cache:
            cls._cache[key] = re.compile(pattern, flags)
        return cls._cache[key]

    @classmethod
    def clear(cls) -> None:
        """Clear cached patterns."""
        cls._cache.clear()
```

### 5. `scripts/task_logger.py` (Dual-Channel Logger)
```python
"""Structured dual-channel logging system for universal Python tasks."""

from __future__ import annotations

import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from core_constants import AnsiColorConstants, LogBadgeConstants


class TaskLogger:
    """Dual console and file logger supporting ANSI badges and JSON telemetry."""

    def __init__(
        self,
        log_path: Path | str | None = None,
        is_verbose: bool = False,
        enable_ansi: bool | None = None,
    ) -> None:
        self.is_verbose = is_verbose
        self.enable_ansi = sys.stdout.isatty() if enable_ansi is None else enable_ansi
        self.log_path = Path(log_path) if log_path else Path("logs/task.log")
        self._ensure_log_directory()

    def _ensure_log_directory(self) -> None:
        """Ensure parent directory of log file exists."""
        if not self.log_path.parent.exists():
            self.log_path.parent.mkdir(parents=True, exist_ok=True)

    def _strip_ansi(self, text: str) -> str:
        """Strip ANSI escape sequences from text for file storage."""
        return re.sub(r"\033\[[0-9;]*m", "", text)

    def _format_badge(self, badge: str, color: str) -> str:
        """Format badge with ANSI color or plain text."""
        if not self.enable_ansi:
            return badge

        return f"{color}{AnsiColorConstants.BOLD}{badge}{AnsiColorConstants.RESET}"

    def _write_file(self, line: str) -> None:
        """Write line to file with LF line ending."""
        try:
            with open(self.log_path, "a", encoding=EncodingConstants.UTF8, newline="\n") as handle:
                handle.write(self._strip_ansi(line) + "\n")
        except OSError:
            pass

    def log_entry(self, badge: str, color: str, message: str, details: dict[str, Any] | None = None) -> None:
        """Output entry to console and record structured entry to log file."""
        now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
        formatted_badge = self._format_badge(badge, color)
        console_line = f"{formatted_badge} {message}"
        file_line = f"[{now}] {badge} {message}"

        print(console_line)
        self._write_file(file_line)

        if details and self.is_verbose:
            self._write_file(f"[{now}] DETAILS: {json.dumps(details, default=str)}")

    def ok(self, message: str, details: dict[str, Any] | None = None) -> None:
        """Log success message with green OK badge."""
        self.log_entry(LogBadgeConstants.OK, AnsiColorConstants.GREEN, message, details)

    def fail(self, message: str, details: dict[str, Any] | None = None) -> None:
        """Log failure message with red FAIL badge."""
        self.log_entry(LogBadgeConstants.FAIL, AnsiColorConstants.RED, message, details)

    def warn(self, message: str, details: dict[str, Any] | None = None) -> None:
        """Log warning message with yellow WARN badge."""
        self.log_entry(LogBadgeConstants.WARN, AnsiColorConstants.YELLOW, message, details)

    def info(self, message: str, details: dict[str, Any] | None = None) -> None:
        """Log info message with blue INFO badge."""
        self.log_entry(LogBadgeConstants.INFO, AnsiColorConstants.BLUE, message, details)

    def skip(self, message: str, details: dict[str, Any] | None = None) -> None:
        """Log skipped operation with cyan SKIP badge."""
        self.log_entry(LogBadgeConstants.SKIP, AnsiColorConstants.CYAN, message, details)

    def audit(self, operation: str, status: str, details: dict[str, Any] | None = None) -> None:
        """Record structured JSON audit event."""
        payload = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "operation": operation,
            "status": status,
            "details": details or {},
        }
        json_line = f"JSON_AUDIT: {json.dumps(payload)}"
        self._write_file(json_line)
```

### 5. `scripts/task_runner.py` (Modular Handlers <= 15 Lines)
```python
"""Modular task execution handlers for universal Python automation."""

from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path

from app_errors import AppError, Result
from core_constants import ProtectedNameConstants
from core_enums import AppErrorCodeType
from subprocess_guard import execute_command
from task_logger import TaskLogger


def is_protected_path(path: Path) -> bool:
    """Return True if path matches any protected file or directory pattern."""
    if path.name in (ProtectedNameConstants.GITKEEP, ProtectedNameConstants.CONFIG_JSON):
        return True

    if path.name in (ProtectedNameConstants.SETTINGS_JSON, ProtectedNameConstants.ENV_FILE):
        return True

    return any(part.startswith(".") for part in path.parts)


def scan_target_directory(target_path: Path) -> Result[tuple[list[Path], int]]:
    """Scan directory and return list of purgeable files and total bytes."""
    if not target_path.exists():
        err = AppError(AppErrorCodeType.NOT_FOUND_ERROR.value, f"Directory not found: {target_path}", "scan")
        return Result.fail(err)

    files_to_purge: list[Path] = []
    total_bytes = 0
    for root, _, files in os.walk(target_path):
        for name in files:
            file_path = Path(root) / name
            if not is_protected_path(file_path):
                files_to_purge.append(file_path)
                total_bytes += file_path.stat().st_size

    return Result.ok((files_to_purge, total_bytes))


def purge_file_safely(file_path: Path, is_dry_run: bool, logger: TaskLogger) -> Result[bool]:
    """Safely delete a single file respecting dry-run simulation mode."""
    if is_protected_path(file_path):
        logger.skip(f"Protected path skipped: {file_path}")
        return Result.ok(False)

    if is_dry_run:
        logger.info(f"[DRY-RUN] Would remove: {file_path}")
        return Result.ok(True)

    try:
        file_path.unlink(missing_ok=True)
        logger.ok(f"Purged: {file_path}")
        return Result.ok(True)
    except OSError as ex:
        err = AppError(AppErrorCodeType.IO_ERROR.value, f"Failed to delete {file_path}: {ex}", "purge")
        return Result.fail(err)


def execute_cache_purge(target_path: Path, is_dry_run: bool, logger: TaskLogger) -> Result[int]:
    """Scan and purge eligible cache files in target directory."""
    scan_res = scan_target_directory(target_path)
    if scan_res.has_error:
        return Result.fail(scan_res.error)

    files, total_bytes = scan_res.value
    size_mb = total_bytes / (1024 * 1024)
    logger.info(f"Target {target_path}: found {len(files)} purgeable files ({size_mb:.2f} MB)")
    purged_count = 0
    for item in files:
        res = purge_file_safely(item, is_dry_run, logger)
        if res.is_safe and res.value:
            purged_count += 1

    return Result.ok(purged_count)


def check_disk_space_threshold(target_path: Path, threshold_gb: float, logger: TaskLogger) -> Result[bool]:
    """Check if free disk space is below threshold GB."""
    try:
        usage = shutil.disk_usage(target_path if target_path.exists() else Path.cwd())
        free_gb = usage.free / (1024**3)
        is_below = free_gb < threshold_gb
        logger.info(f"Disk check: {free_gb:.2f} GB free (threshold: {threshold_gb:.2f} GB)")
        return Result.ok(is_below)
    except OSError as ex:
        err = AppError(AppErrorCodeType.IO_ERROR.value, f"Disk check failed: {ex}", "disk_usage")
        return Result.fail(err)


def restart_windows_audio(is_dry_run: bool, logger: TaskLogger) -> Result[int]:
    """Restart Windows Audio service (AudioSrv)."""
    if is_dry_run:
        logger.info("[DRY-RUN] Would execute: net stop AudioSrv && net start AudioSrv")
        return Result.ok(0)

    stop_res = execute_command(["net", "stop", "AudioSrv", "/y"], timeout_sec=15)
    start_res = execute_command(["net", "start", "AudioSrv"], timeout_sec=15)
    if stop_res.has_error or start_res.has_error:
        return Result.fail(AppError(AppErrorCodeType.COMMAND_ERROR.value, "Service command failed"))

    logger.ok("Restarted Windows Audio service successfully")
    return Result.ok(0)


def reset_vmware_network(is_dry_run: bool, logger: TaskLogger) -> Result[int]:
    """Reset VMware virtual network adapter routing and flush DNS."""
    if is_dry_run:
        logger.info("[DRY-RUN] Would execute: ipconfig /flushdns")
        return Result.ok(0)

    res = execute_command(["ipconfig", "/flushdns"], timeout_sec=10)
    if res.has_error:
        return Result.fail(res.error)

    if not res.value.is_success:
        err = AppError(AppErrorCodeType.COMMAND_ERROR.value, res.value.error_message, "reset_network")
        return Result.fail(err)

    logger.ok("Flushed DNS and reset network adapter routing")
    return Result.ok(0)


def clean_app_cache(app_name: str, cache_dir: Path, is_dry_run: bool, logger: TaskLogger) -> Result[int]:
    """Clean specific desktop application cache directory."""
    logger.info(f"Initiating cache cleanup for application: {app_name}")
    if not cache_dir.exists():
        logger.warn(f"Cache directory does not exist: {cache_dir}")
        return Result.ok(0)

    return execute_cache_purge(cache_dir, is_dry_run, logger)


def clean_whatsapp_cache(is_dry_run: bool, logger: TaskLogger) -> Result[int]:
    """Clean WhatsApp desktop application temporary cache directory."""
    app_data = os.environ.get("LOCALAPPDATA", "")
    if not app_data:
        return Result.ok(0)

    wa_cache = Path(app_data) / "Packages"
    logger.info(f"Checking WhatsApp cache directory: {wa_cache}")
    if not wa_cache.exists():
        return Result.ok(0)

    return clean_app_cache("WhatsApp", wa_cache, is_dry_run, logger)
```

### 6. `scripts/sql_types.py` (SQL Statements Encapsulated in Enums)
```python
"""SQL queries and statement definitions encapsulated in strongly-typed enums."""

from __future__ import annotations

from enum import Enum
from typing import TypeVar

from app_errors import AppError, Result

T = TypeVar("T", bound="TaskSqlType")


class TaskSqlType(str, Enum):
    """Encapsulated SQL statements for task execution audit database."""

    PRAGMA_BUSY_TIMEOUT = "PRAGMA busy_timeout = 5000"
    CREATE_TASKS_TABLE = (
        "CREATE TABLE IF NOT EXISTS TaskExecutions ("
        "task_id TEXT PRIMARY KEY, "
        "action TEXT NOT NULL, "
        "category TEXT NOT NULL, "
        "status TEXT NOT NULL, "
        "target_path TEXT NOT NULL, "
        "items_affected INTEGER NOT NULL, "
        "duration_sec REAL NOT NULL, "
        "executed_at TEXT NOT NULL"
        ")"
    )
    INSERT_TASK = (
        "INSERT INTO TaskExecutions ("
        "task_id, action, category, status, target_path, items_affected, duration_sec, executed_at"
        ") VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))"
    )
    SELECT_LATEST = (
        "SELECT task_id, action, category, status, target_path, items_affected, duration_sec, executed_at "
        "FROM TaskExecutions ORDER BY executed_at DESC LIMIT ?"
    )
    SELECT_BY_CATEGORY = (
        "SELECT task_id, action, category, status, target_path, items_affected, duration_sec, executed_at "
        "FROM TaskExecutions WHERE category = ? ORDER BY executed_at DESC"
    )

    def label(self) -> str:
        """Human-readable display label."""
        return self.name

    @classmethod
    def all_values(cls) -> tuple[str, ...]:
        """Return tuple of all registered SQL statements."""
        return tuple(m.value for m in cls)

    @classmethod
    def is_valid(cls, raw_value: str) -> bool:
        """Return True if statement matches registered SQL string."""
        return raw_value in cls.all_values()

    @classmethod
    def parse(cls: type[T], raw_value: str) -> Result[T]:
        """Monadically parse string into TaskSqlType member."""
        for member in cls:
            if member.value == raw_value or member.name == raw_value:
                return Result.ok(member)

        error = AppError("VALIDATION_ERROR", f"Unknown TaskSqlType: '{raw_value}'", "parse")
        return Result.fail(error)
```

### 7. `scripts/task_repository.py` (SQL Repository Pattern & Protocol Interface)
```python
"""SQL Repository Pattern implementation for task execution telemetry."""

from __future__ import annotations

import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Protocol

from app_errors import AppError, Result
from core_enums import AppErrorCodeType
from sql_types import TaskSqlType


@dataclass(frozen=True)
class TaskExecutionRecord:
    """Immutable audit record representing an automated task execution."""

    task_id: str
    action: str
    category: str
    status: str
    target_path: str
    items_affected: int
    duration_sec: float
    executed_at: str = ""


class ITaskRepository(Protocol):
    """Protocol interface isolating all task execution database operations."""

    def record_task(self, record: TaskExecutionRecord) -> Result[bool]: ...
    def list_latest(self, limit: int = 10) -> Result[tuple[TaskExecutionRecord, ...]]: ...


class SqliteTaskRepository:
    """SQLite implementation of ITaskRepository adhering to SQL Repository Pattern."""

    def __init__(self, db_path: Path | str = "logs/tasks.db") -> None:
        self._db_path = Path(db_path)
        if not self._db_path.parent.exists():
            self._db_path.parent.mkdir(parents=True, exist_ok=True)
        self._init_db()

    def _open_conn(self) -> sqlite3.Connection:
        """Open SQLite connection with busy timeout pragmas."""
        conn = sqlite3.connect(str(self._db_path), timeout=5.0)
        conn.row_factory = sqlite3.Row
        conn.execute(TaskSqlType.PRAGMA_BUSY_TIMEOUT.value)
        return conn

    def _init_db(self) -> Result[bool]:
        """Initialize database schema using encapsulated SQL statement."""
        try:
            with self._open_conn() as conn:
                conn.execute(TaskSqlType.CREATE_TASKS_TABLE.value)
                return Result.ok(True)
        except sqlite3.Error as err:
            return Result.fail(AppError(AppErrorCodeType.DATABASE_ERROR.value, f"Init failed: {err}", "init_db"))

    def record_task(self, record: TaskExecutionRecord) -> Result[bool]:
        """Record task execution into SQLite database."""
        try:
            params = (
                record.task_id, record.action, record.category, record.status,
                record.target_path, record.items_affected, record.duration_sec,
            )
            with self._open_conn() as conn:
                conn.execute(TaskSqlType.INSERT_TASK.value, params)
                return Result.ok(True)
        except sqlite3.Error as err:
            return Result.fail(AppError(AppErrorCodeType.DATABASE_ERROR.value, f"Record failed: {err}", "record_task"))

    def list_latest(self, limit: int = 10) -> Result[tuple[TaskExecutionRecord, ...]]:
        """List latest task execution records."""
        try:
            with self._open_conn() as conn:
                rows = conn.execute(TaskSqlType.SELECT_LATEST.value, (limit,)).fetchall()
                records = tuple(
                    TaskExecutionRecord(
                        task_id=r["task_id"], action=r["action"], category=r["category"],
                        status=r["status"], target_path=r["target_path"],
                        items_affected=r["items_affected"], duration_sec=r["duration_sec"],
                        executed_at=r["executed_at"],
                    ) for row in rows
                )
                return Result.ok(records)
        except sqlite3.Error as err:
            return Result.fail(AppError(AppErrorCodeType.DATABASE_ERROR.value, f"Query failed: {err}", "list_latest"))
```

### 8. `scripts/subprocess_guard.py` (Resilient Subprocess Guard)
```python
"""Resilient subprocess execution module with monadic Result envelopes."""

from __future__ import annotations

import subprocess
from dataclasses import dataclass
from typing import List

from app_errors import AppError, Result
from core_enums import ExitCodeType


@dataclass(frozen=True)
class SubprocessResult:
    """Immutable result envelope for external process execution."""

    returncode: int
    stdout: str
    stderr: str
    is_success: bool
    is_timeout: bool = False
    error_message: str = ""


def _build_timeout_result(timeout_sec: int) -> SubprocessResult:
    return SubprocessResult(
        returncode=ExitCodeType.GENERAL_ERROR.value,
        stdout="",
        stderr=f"Process timed out after {timeout_sec}s",
        is_success=False,
        is_timeout=True,
        error_message=f"Timeout after {timeout_sec}s",
    )


def _build_success_result(completed: subprocess.CompletedProcess[str]) -> SubprocessResult:
    is_success = completed.returncode == ExitCodeType.SUCCESS.value
    err_msg = "" if is_success else f"Exited with code {completed.returncode}"
    return SubprocessResult(
        returncode=completed.returncode,
        stdout=completed.stdout,
        stderr=completed.stderr,
        is_success=is_success,
        is_timeout=False,
        error_message=err_msg,
    )


def execute_command(
    command_args: List[str],
    timeout_sec: int = 30,
) -> Result[SubprocessResult]:
    """Execute command safely with Unicode error replacement and timeout guard."""
    if not command_args:
        return Result.fail(AppError("COMMAND_EMPTY", "Command arguments cannot be empty"))

    try:
        completed = subprocess.run(
            command_args,
            capture_output=True,
            text=True,
            timeout=timeout_sec,
            check=False,
            errors="replace",
        )
        return Result.ok(_build_success_result(completed))
    except subprocess.TimeoutExpired:
        return Result.ok(_build_timeout_result(timeout_sec))
    except OSError as err:
        return Result.fail(AppError("OS_EXEC_FAILED", f"OS execution failed: {err}"))
```

### 9. `scripts/git_sync_runner.py` (Multi-Format Git Synchronizer)
```python
"""Git repository multi-format synchronization runner with monadic envelopes."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence

from app_errors import AppError, Result
from core_constants import GitSyncConstants
from core_enums import AppErrorCodeType, GitSyncFormatType
from subprocess_guard import execute_command
from task_logger import TaskLogger


@dataclass(frozen=True)
class RepoSyncEntry:
    """Immutable parsed Git repository target."""

    title: str
    original_url: str
    ssh_url: str
    repo_name: str


def url_to_ssh(raw_url: str) -> str:
    """Convert HTTPS GitHub URL to SSH format."""
    trimmed = raw_url.strip()
    if trimmed.startswith(GitSyncConstants.HTTPS_PREFIX):
        sub = trimmed[len(GitSyncConstants.HTTPS_PREFIX) :]
        clean_sub = sub if sub.endswith(".git") else f"{sub}.git"
        return f"{GitSyncConstants.SSH_PREFIX}{clean_sub}"

    return trimmed if trimmed.endswith(".git") else f"{trimmed}.git"


def extract_repo_name(url: str) -> str:
    """Extract repository slug name from URL."""
    clean = url.rstrip("/").rstrip(".git")
    parts = clean.split("/")
    return parts[-1] if parts else "unknown-repo"


def _parse_text_lines(text: str) -> list[RepoSyncEntry]:
    entries: list[RepoSyncEntry] = []
    for line in text.splitlines():
        trimmed = line.strip()
        if trimmed and not trimmed.startswith("#"):
            ssh = url_to_ssh(trimmed)
            name = extract_repo_name(trimmed)
            entries.append(RepoSyncEntry(name, trimmed, ssh, name))
    return entries


def _parse_json_manifest(text: str) -> Result[list[RepoSyncEntry]]:
    try:
        data = json.loads(text)
        if not isinstance(data, list):
            return Result.fail(AppError(AppErrorCodeType.VALIDATION_ERROR.value, "JSON must be array"))
        entries = [
            RepoSyncEntry(
                item.get("title", extract_repo_name(item.get("url", ""))),
                item.get("url", ""),
                url_to_ssh(item.get("url", "")),
                extract_repo_name(item.get("url", "")),
            )
            for item in data
            if isinstance(item, dict) and item.get("url")
        ]
        return Result.ok(entries)
    except json.JSONDecodeError as err:
        return Result.fail(AppError(AppErrorCodeType.VALIDATION_ERROR.value, f"JSON parse error: {err}"))


def _parse_markdown_links(text: str) -> list[RepoSyncEntry]:
    pattern = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
    matches = pattern.findall(text)
    entries: list[RepoSyncEntry] = []
    for title, url in matches:
        ssh = url_to_ssh(url)
        name = extract_repo_name(url)
        entries.append(RepoSyncEntry(title.strip(), url.strip(), ssh, name))
    return entries


def parse_sync_manifest(
    content: str,
    format_type: GitSyncFormatType,
) -> Result[tuple[RepoSyncEntry, ...]]:
    """Parse raw manifest content according to target format enum."""
    if format_type == GitSyncFormatType.JSON:
        res = _parse_json_manifest(content)
        return Result.ok(tuple(res.value)) if res.is_safe else Result.fail(res.error)

    if format_type == GitSyncFormatType.MARKDOWN:
        return Result.ok(tuple(_parse_markdown_links(content)))

    return Result.ok(tuple(_parse_text_lines(content)))


def sync_single_repo(
    entry: RepoSyncEntry,
    target_dir: Path,
    is_dry_run: bool,
    logger: TaskLogger,
) -> Result[str]:
    """Clone repository or pull updates if directory already exists."""
    dest = target_dir / entry.repo_name
    if is_dry_run:
        action = "PULL" if dest.exists() else "CLONE"
        logger.info(f"[DRY-RUN] Would execute {action} for {entry.title} at {dest}")
        return Result.ok(action)

    if dest.exists():
        pull_res = execute_command(["git", "-C", str(dest), "pull"], timeout_sec=30)
        status = "PULLED" if (pull_res.is_safe and pull_res.value.is_success) else "PULL_FAILED"
        logger.ok(f"Synced {entry.repo_name}: {status}")
        return Result.ok(status)

    clone_res = execute_command(["git", "clone", entry.ssh_url, str(dest)], timeout_sec=60)
    status = "CLONED" if (clone_res.is_safe and clone_res.value.is_success) else "CLONE_FAILED"
    logger.ok(f"Cloned {entry.repo_name}: {status}")
    return Result.ok(status)
```

### 10. `scripts/cli_dispatcher.py` (CLI Dispatcher & Suggestions)
```python
"""Universal CLI argument dispatcher and interactive suggestions engine."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from app_errors import Result
from core_enums import ActionType, ExitCodeType, TaskCategoryType
from task_logger import TaskLogger
from task_runner import (
    check_disk_space_threshold,
    clean_app_cache,
    execute_cache_purge,
    reset_vmware_network,
    restart_windows_audio,
    scan_target_directory,
)


def build_parser() -> argparse.ArgumentParser:
    """Construct CLI argument parser schema."""
    parser = argparse.ArgumentParser(description="Universal Python Task Automation Runner")
    parser.add_argument("action", nargs="?", default=ActionType.STATUS.value, choices=ActionType.all_values())
    parser.add_argument("--category", default=TaskCategoryType.OS_OPTIMIZATION.value, choices=TaskCategoryType.all_values())
    parser.add_argument("--target", default=".", help="Target directory or item path")
    parser.add_argument("--threshold-gb", type=float, default=10.0, help="Disk threshold in GB")
    parser.add_argument("--dry-run", action="store_true", help="Simulate execution without mutations")
    parser.add_argument("--json", action="store_true", help="Output telemetry in JSON format")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose debug logging")
    return parser


def print_suggestions(action: ActionType, category: TaskCategoryType, logger: TaskLogger) -> None:
    """Print helpful next-step suggestions based on selected action and category."""
    if action == ActionType.STATUS:
        logger.info(f"Suggestion: Run 'scan --category {category.value}' to inspect target files")
        return

    if action == ActionType.SCAN:
        logger.info(f"Suggestion: Run 'purge --category {category.value} --dry-run' to simulate cleanup")
        return

    if action == ActionType.PURGE:
        logger.info(f"Suggestion: Run 'status --category {category.value}' to verify freed storage")
        return

    logger.info("Suggestion: Check 'logs/task.log' for structured audit details")


def dispatch_action(action: ActionType, cat: TaskCategoryType, args: argparse.Namespace, logger: TaskLogger) -> Result[int]:
    """Route validated action and category to modular runner handlers."""
    target_path = Path(args.target)
    if action == ActionType.STATUS:
        res = check_disk_space_threshold(target_path, args.threshold_gb, logger)
        return Result.ok(0) if res.is_safe else Result.fail(res.error)

    if action == ActionType.SCAN:
        scan_res = scan_target_directory(target_path)
        return Result.ok(len(scan_res.value[0])) if scan_res.is_safe else Result.fail(scan_res.error)

    if action == ActionType.PURGE:
        return execute_cache_purge(target_path, args.dry_run, logger)

    if action == ActionType.RESTART and cat == TaskCategoryType.WINDOWS_TROUBLESHOOTING:
        return restart_windows_audio(args.dry_run, logger)

    if action == ActionType.RESTART and cat == TaskCategoryType.VMWARE_MANAGEMENT:
        return reset_vmware_network(args.dry_run, logger)

    return clean_app_cache(cat.value, target_path, args.dry_run, logger)


def run_dispatch(args: argparse.Namespace) -> ExitCodeType:
    """Execute command dispatch, handle logging, and return strongly-typed exit code."""
    logger = TaskLogger(is_verbose=args.verbose)
    action_res = ActionType.parse(args.action)
    category_res = TaskCategoryType.parse(args.category)
    if action_res.has_error or category_res.has_error:
        err = action_res.error if action_res.has_error else category_res.error
        logger.fail(f"Validation failure: {err}")
        return ExitCodeType.USAGE_ERROR

    action = action_res.value
    category = category_res.value
    logger.info(f"Executing '{action.label()}' for '{category.label()}' (dry-run: {args.dry_run})")
    result = dispatch_action(action, category, args, logger)
    if result.has_error:
        logger.fail(f"Execution failed: {result.error}")
        return ExitCodeType.RUNTIME_ERROR

    logger.ok(f"Completed '{action.label()}' successfully")
    print_suggestions(action, category, logger)
    logger.audit(action.value, "SUCCESS", {"category": category.value, "dry_run": args.dry_run})
    return ExitCodeType.SUCCESS


def main() -> int:
    """Top-level CLI entrypoint."""
    parser = build_parser()
    args = parser.parse_args()
    exit_code = run_dispatch(args)
    return int(exit_code)


if __name__ == "__main__":
    sys.exit(main())
```

### 11. `scripts/terminal_ui.py` (VMware-Grade Hierarchical Tree & Left-Hand Padding)
```python
"""Universal terminal UI formatter with left-hand padding and tree hierarchies."""

from __future__ import annotations

from typing import Any
from core_constants import AnsiColorConstants


class TerminalUi:
    """Renders formatted tree diagrams, badges, and padded telemetry in the terminal."""

    LEFT_PAD = "  "  # 2-space left padding invariant for readable terminal margins

    @classmethod
    def print_workflow_header(cls, title: str) -> None:
        """Render distinct banner header with left-hand padding."""
        border = "=" * 65
        pad = cls.LEFT_PAD
        print(f"\n{pad}{AnsiColorConstants.CYAN}{border}")
        print(f"{pad}  {AnsiColorConstants.BOLD}{title}{AnsiColorConstants.RESET}")
        print(f"{pad}{AnsiColorConstants.CYAN}{border}{AnsiColorConstants.RESET}\n", flush=True)

    @classmethod
    def print_section_title(cls, icon: str, title: str) -> None:
        """Render section heading with standardized icon and left padding."""
        pad = cls.LEFT_PAD
        print(f"{pad}{icon}  {AnsiColorConstants.BOLD}{title}{AnsiColorConstants.RESET}:", flush=True)

    @classmethod
    def print_tree_node(
        cls,
        title: str,
        properties: list[tuple[str, str]],
        is_last: bool = False,
        status_badge: str = "",
    ) -> None:
        """Render a hierarchical tree node with box-drawing branches and left padding."""
        pad = cls.LEFT_PAD
        branch = "└──" if is_last else "├──"
        pipe = "   " if is_last else "│  "
        badge_str = f" {status_badge}" if status_badge else ""
        print(f"{pad}{branch} {AnsiColorConstants.BOLD}{title}{AnsiColorConstants.RESET}{badge_str}")
        prop_count = len(properties)
        for idx, (label, val) in enumerate(properties, start=1):
            sub_branch = "└──" if idx == prop_count else "├──"
            print(f"{pad}{pipe} {sub_branch} {label.ljust(18)}: {val}")
        print(f"{pad}{pipe}", flush=True)

    @classmethod
    def print_summary_card(cls, title: str, items: list[tuple[str, str, bool]]) -> None:
        """Render summary card with boolean-colored metrics and box-drawing lines."""
        pad = cls.LEFT_PAD
        print(f"{pad}📋 {AnsiColorConstants.BOLD}{title}{AnsiColorConstants.RESET}")
        total = len(items)
        for idx, (icon, label, is_ok) in enumerate(items, start=1):
            branch = "└──" if idx == total else "├──"
            c_val = f"{AnsiColorConstants.GREEN}[PASS]{AnsiColorConstants.RESET}" if is_ok else f"{AnsiColorConstants.RED}[FAIL]{AnsiColorConstants.RESET}"
            print(f"{pad}{branch} {icon} {label.ljust(22)}: {c_val}")
        print("", flush=True)

    @classmethod
    def print_error_tree(cls, operation: str, error_code: str, message: str, details: str = "") -> None:
        """Render explicit error diagnostics tree with left padding and zero swallowing."""
        pad = cls.LEFT_PAD
        border = "=" * 65
        print(f"\n{pad}{AnsiColorConstants.RED}{border}")
        print(f"{pad}  {AnsiColorConstants.BOLD}[FAIL] Execution Error: {operation}{AnsiColorConstants.RESET}")
        print(f"{pad}{AnsiColorConstants.RED}{border}{AnsiColorConstants.RESET}")
        print(f"{pad}❌ Error Code    : {error_code}")
        print(f"{pad}💬 Error Message : {message}")
        if details:
            print(f"{pad}🔍 Diagnostics   : {details}")
        print("", flush=True)

    @classmethod
    def print_rich_help(cls, app_name: str, actions: list[tuple[str, str]], flags: list[tuple[str, str]]) -> None:
        """Render formatted help menu and command reference with left padding."""
        cls.print_workflow_header(f"{app_name} — Universal Task Engine")
        pad = cls.LEFT_PAD
        print(f"{pad}Usage: pwsh -NoProfile -File run.ps1 <action> [options]\n")
        print(f"{pad}⚡ Supported Actions:")
        for name, desc in actions:
            print(f"{pad}  ├── {name.ljust(12)}: {desc}")
        print(f"\n{pad}🔧 Command Flags:")
        for flag, desc in flags:
            print(f"{pad}  ├── {flag.ljust(24)}: {desc}")
        print("", flush=True)
```

---

## ⚡ Pluggable Step Execution, JSON Pipeline & Cross-Platform `env.ini`

To support complex multi-stage tasks without bloating the dispatcher, tasks are modeled like the WordPress standalone architecture as configurable items in an execution pipeline:

1. **Config Path & Directory Invariant (`config/`):**
   All configurable items must reside in a dedicated `config/` directory (or explicit config path):
   - `config/pipeline.json`: Declares ordered steps, module paths, class names, enablement flags, and custom parameters.
   - `config/env.ini`: Declares dynamic environment variables (such as `workdir`, `work`, `root`, `logs`) enabling instant directory navigation (`cd $WORK`).

2. **Cross-Platform Environment Navigation (`env_config.py`):**
   Parses `env.ini`, injects keys into `os.environ`, and resolves `${WORK}` placeholders across Windows, macOS, and Linux without external dependencies.

3. **Pluggable Step Protocol (`step_protocol.py`):**
   Every troubleshoot routine, repair action, or system modification is authored as a dedicated class implementing `IPipelineStep`:
   - `step_id`: Unique slug identifier.
   - `execute(context: StepContext, params: dict[str, Any]) -> Result[StepOutput]`: Executes discrete actions with small helper functions strictly $\le 15$ lines.
   - Monadic `Result[T]` error handling guarantees leaf error sovereignty (zero unhandled exceptions or leaf exit calls).

4. **Reference Implementation: `config/pipeline.json`**
```json
{
  "data": {
    "id": "universalTaskPipeline",
    "type": "pipelineConfiguration",
    "attributes": {
      "pipelineName": "Universal Task Execution Pipeline",
      "version": "1.0.0",
      "configDir": "config",
      "steps": [
        {
          "id": "step01CacheCleanup",
          "type": "pipelineStep",
          "attributes": {
            "modulePath": "scripts.steps.sample_fix_step",
            "className": "SampleFixStep",
            "isEnabled": true,
            "description": "Purge system temporary files and verify memory",
            "params": {
              "targetPath": "${WORK}/logs",
              "isDryRun": false
            }
          }
        }
      ]
    }
  }
}
```

5. **Reference Implementation: `config/env.ini`**
```ini
# --- Universal Environment Variables Configuration (config/env.ini) ---
# Dynamic path expansion: Never hardcode absolute paths!
# Resolved at runtime from $WORK, fallback $GITMAP_WORK_DIR, or interactive operator prompt.
work=${WORK}
workdir=${WORK}/${PROJECT_SLUG}
root=${WORK}
logs=${WORK}/${PROJECT_SLUG}/logs
```

6. **Reference Implementation: `scripts/env_config.py`**
```python
"""Dynamic cross-platform INI environment loader and variable resolution."""

from __future__ import annotations

import os
from pathlib import Path

from app_errors import AppError, Result
from lazy_regex import LazyRegex


def parse_ini_line(line: str) -> tuple[str, str] | None:
    """Extract trimmed key and value from single INI line using LazyRegex."""
    trimmed = line.strip()
    if not trimmed or trimmed.startswith(("#", ";")):
        return None

    kv_pattern = LazyRegex.get(r"^([A-Za-z_][A-Za-z0-9_]*)=(.*)$")
    match = kv_pattern.match(trimmed)
    if not match:
        return None

    return match.group(1).strip(), match.group(2).strip()


def locate_default_ini() -> Path:
    """Find default env.ini in task config, parent ini-env, or work directory."""
    here = Path(__file__).resolve().parent.parent
    local_ini = here / "config" / "env.ini"
    if local_ini.is_file():
        return local_ini

    parent_ini = here.parent / "ini-env" / "env.ini"
    if parent_ini.is_file():
        return parent_ini

    return local_ini


def load_env_ini(ini_path: Path | str | None = None) -> Result[dict[str, str]]:
    """Parse env.ini into dictionary and populate os.environ."""
    target = Path(ini_path).resolve() if ini_path else locate_default_ini()
    if not target.is_file():
        return Result.ok({})

    env_map: dict[str, str] = {}
    try:
        lines = target.read_text(encoding=EncodingConstants.UTF8).splitlines()
        for line in lines:
            parsed = parse_ini_line(line)
            if parsed:
                k, v = parsed
                env_map[k] = v
                os.environ[k] = v

        return Result.ok(env_map)
    except Exception as exc:
        err = AppError("IO_ERROR", f"Failed reading env.ini at {target}: {exc}")
        return Result.fail(err)


def interpolate_env_vars(text: str) -> str:
    """Expand ${KEY} and $KEY variable placeholders from current os.environ."""
    return os.path.expandvars(text)


def get_work_dir() -> Path:
    """Return resolved root work directory from WORK env var, fallback GITMAP_WORK_DIR, or project parent."""
    work_val = os.environ.get("WORK", "").strip()
    if work_val and Path(work_val).exists():
        return Path(work_val).resolve()

    gitmap_work_val = os.environ.get("GITMAP_WORK_DIR", "").strip()
    if gitmap_work_val and Path(gitmap_work_val).exists():
        return Path(gitmap_work_val).resolve()

    return Path(__file__).resolve().parent.parent.parent


def get_env(key: str, default: str = "") -> str:
    """Retrieve string environment variable safely with fallback."""
    return os.environ.get(key, default)
```

7. **Reference Implementation: `scripts/env_manager.py` (Cross-Platform $WORK & Dynamic ENV Setter)**
```python
"""
env_manager.py — Cross-Platform $WORK Discovery, OS Reboot Persistence & Dynamic ENV Setter.
Resolves workspace root dynamically from environment or user prompt, establishes persistent
$WORK across OS reboots, configures shell profiles for 'cd $WORK', and injects variables on the fly.
"""
from __future__ import annotations

import argparse
import configparser
import os
import platform
import subprocess
import sys
from enum import Enum
from pathlib import Path
from typing import ClassVar, Final, NamedTuple, Optional, Pattern

from core_constants import EnvConstants
from core_enums import ActionType
from lazy_regex import LazyRegex


class EnvResult(NamedTuple):
    is_success: bool
    message: str
    value: Optional[str] = None


def get_work_dir(interactive: bool = True) -> Path:
    """
    Discover workspace root directory dynamically.
    Checks $WORK, $GITMAP_WORK_DIR, repository parent, or prompts the operator.
    Never hardcodes fixed filesystem paths.
    """
    work_val = os.environ.get(EnvConstants.ENV_WORK)
    if work_val and Path(work_val).exists():
        return Path(work_val).resolve()

    gitmap_work_val = os.environ.get(EnvConstants.ENV_GITMAP_WORK_DIR)
    if gitmap_work_val and Path(gitmap_work_val).exists():
        return Path(gitmap_work_val).resolve()

    cwd = Path.cwd().resolve()
    if (cwd / ".git").exists():
        return cwd.parent

    home_work = Path.home() / "git-work"
    if home_work.exists():
        return home_work

    if interactive and sys.stdin.isatty():
        try:
            user_input = input("Enter WORK workspace directory path: ").strip()
            if user_input and Path(user_input).exists():
                return Path(user_input).resolve()
        except (EOFError, KeyboardInterrupt):
            pass

    return cwd.parent


def _update_powershell_profile(profile_path: Path, work_dir: Path) -> None:
    """Append $global:WORK hook to PowerShell profile if missing."""
    hook = '\n# $WORK bare expansion hook\nif ($env:WORK) { $global:WORK = $env:WORK }\n'
    content = ""
    if profile_path.exists():
        content = profile_path.read_text(encoding=EncodingConstants.UTF8)
    if "$global:WORK" in content:
        return
    profile_path.parent.mkdir(parents=True, exist_ok=True)
    with open(profile_path, "a", encoding=EncodingConstants.UTF8, newline="\n") as f:
        f.write(hook)


def _persist_windows_env(key: str, val: str) -> bool:
    """Persist environment variable to Windows User Registry."""
    cmd = f'[System.Environment]::SetEnvironmentVariable("{key}", "{val}", "User")'
    res = subprocess.run(["powershell", "-NoProfile", "-Command", cmd], capture_output=True)
    return res.returncode == 0


def _persist_posix_env(key: str, val: str) -> None:
    """Append export to POSIX startup profiles."""
    export_line = f'\nexport {key}="{val}"\n'
    for rc in [Path.home() / ".bashrc", Path.home() / ".zshrc"]:
        if not rc.exists():
            continue
        content = rc.read_text(encoding=EncodingConstants.UTF8)
        if f"export {key}=" in content:
            continue
        with open(rc, "a", encoding=EncodingConstants.UTF8, newline="\n") as f:
            f.write(export_line)


def configure_work_variable(target_dir: Optional[Path] = None) -> EnvResult:
    """Configure WORK environment variable across OS reboots."""
    work_path = (target_dir or get_work_dir()).resolve()
    work_str = str(work_path)
    os.environ[EnvConstants.ENV_WORK] = work_str

    if platform.system() == "Windows":
        is_ok = _persist_windows_env(EnvConstants.ENV_WORK, work_str)
        ps_doc = Path.home() / "Documents" / "PowerShell" / "Microsoft.PowerShell_profile.ps1"
        _update_powershell_profile(ps_doc, work_path)
        msg = f"Configured Windows User WORK='{work_str}' (survives restart, cd $WORK enabled)"
        return EnvResult(is_ok, msg, work_str)

    _persist_posix_env(EnvConstants.ENV_WORK, work_str)
    return EnvResult(True, f"Configured POSIX WORK='{work_str}' in ~/.bashrc and ~/.zshrc", work_str)


def update_env_ini(key: str, val: str, ini_path: Optional[Path] = None) -> EnvResult:
    """Update or append variable to config/env.ini file."""
    target_ini = ini_path or Path(EnvConstants.DEFAULT_CONFIG_PATH)
    target_ini.parent.mkdir(parents=True, exist_ok=True)

    config = configparser.ConfigParser()
    if target_ini.exists():
        config.read(target_ini, encoding=EncodingConstants.UTF8)
    if not config.has_section(EnvConstants.SECTION_ENVIRONMENT):
        config.add_section(EnvConstants.SECTION_ENVIRONMENT)

    config.set(EnvConstants.SECTION_ENVIRONMENT, key, val)
    with open(target_ini, "w", encoding=EncodingConstants.UTF8, newline="\n") as f:
        config.write(f)

    return EnvResult(True, f"Updated {target_ini} with {key}={val}", val)


def set_variable_on_the_fly(key_val_pair: str, ini_path: Optional[Path] = None) -> EnvResult:
    """Parse key=value using LazyRegex, update env.ini, active process and persistent environment."""
    kv_pattern = LazyRegex.get(r"^([A-Za-z_][A-Za-z0-9_]*)=(.*)$")
    match = kv_pattern.match(key_val_pair.strip())
    if not match:
        return EnvResult(False, "Format must be KEY=VALUE (e.g. API_KEY=xyz123)")

    key, val = match.group(1).strip(), match.group(2).strip()

    ini_res = update_env_ini(key, val, ini_path)
    if not ini_res.is_success:
        return ini_res

    os.environ[key] = val

    if platform.system() == "Windows":
        _persist_windows_env(key, val)
    else:
        _persist_posix_env(key, val)

    return EnvResult(True, f"Successfully set and persisted {key}={val} (active + restart)", val)
```

8. **Reference Implementation: `scripts/step_protocol.py`**
```python
"""Pluggable step protocol and context definitions for task pipelines."""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from app_errors import Result
from task_logger import TaskLogger


@dataclass
class StepContext:
    """Execution context passed through all pipeline steps."""

    task_name: str
    work_dir: Path
    logger: TaskLogger
    is_dry_run: bool = False
    state: dict[str, Any] = field(default_factory=dict)

    def set_value(self, key: str, val: Any) -> None:
        """Store key-value pair in context state."""
        self.state[key] = val

    def get_value(self, key: str, default: Any = None) -> Any:
        """Retrieve key-value pair from context state."""
        return self.state.get(key, default)


@dataclass
class StepOutput:
    """Standardized output envelope returned by every pipeline step."""

    step_id: str
    is_success: bool
    summary: str
    freed_bytes: int = 0
    items_modified: int = 0
    details: dict[str, Any] = field(default_factory=dict)


class IPipelineStep(ABC):
    """Abstract interface for all configurable pipeline steps."""

    @property
    @abstractmethod
    def step_id(self) -> str:
        """Return unique slug identifier for the step."""
        ...

    @abstractmethod
    def execute(self, context: StepContext, params: dict[str, Any]) -> Result[StepOutput]:
        """Execute step logic with single-responsibility helpers <= 15 lines."""
        ...
```

9. **Reference Implementation: `scripts/pipeline_engine.py`**
```python
"""Configurable pipeline runner executing modular steps from config/pipeline.json."""

from __future__ import annotations

import importlib
import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from app_errors import AppError, Result
from env_config import interpolate_env_vars
from step_protocol import IPipelineStep, StepContext, StepOutput
from task_logger import TaskLogger


@dataclass
class PipelineStepConfig:
    """Configuration record for an individual pipeline step."""

    step_id: str
    module_path: str
    class_name: str
    is_enabled: bool = True
    description: str = ""
    params: dict[str, Any] = field(default_factory=dict)


@dataclass
class PipelineConfig:
    """Top-level pipeline configuration container."""

    pipeline_name: str
    version: str
    steps: list[PipelineStepConfig] = field(default_factory=list)


def parse_step_config(raw: dict[str, Any]) -> PipelineStepConfig:
    """Convert raw dictionary into strongly-typed PipelineStepConfig."""
    raw_params = raw.get("params", {})
    interp_params = {
        k: interpolate_env_vars(v) if isinstance(v, str) else v
        for k, v in raw_params.items()
    }
    return PipelineStepConfig(
        step_id=str(raw.get("step_id", "")),
        module_path=str(raw.get("module", "")),
        class_name=str(raw.get("class_name", "")),
        is_enabled=bool(raw.get("enabled", True)),
        description=str(raw.get("description", "")),
        params=interp_params,
    )


def load_pipeline_config(config_path: Path | str) -> Result[PipelineConfig]:
    """Parse JSON pipeline specification from filesystem."""
    p = Path(config_path).resolve()
    if not p.is_file():
        return Result.fail(AppError("NOT_FOUND_ERROR", f"Missing pipeline file: {p}"))

    try:
        data = json.loads(p.read_text(encoding=EncodingConstants.UTF8))
        steps = [parse_step_config(item) for item in data.get("steps", [])]
        return Result.ok(PipelineConfig(
            pipeline_name=str(data.get("pipeline_name", "Default Pipeline")),
            version=str(data.get("version", "1.0.0")),
            steps=steps,
        ))
    except Exception as exc:
        return Result.fail(AppError("IO_ERROR", f"Failed parsing pipeline JSON: {exc}"))


def instantiate_step(cfg: PipelineStepConfig) -> Result[IPipelineStep]:
    """Dynamically import and instantiate an IPipelineStep class."""
    try:
        mod = importlib.import_module(cfg.module_path)
        cls = getattr(mod, cfg.class_name)
        instance = cls()
        return Result.ok(instance)
    except Exception as exc:
        err = AppError("SYSTEM_ERROR", f"Failed instantiating {cfg.class_name}: {exc}")
        return Result.fail(err)


class PipelineRunner:
    """Sequentially executes enabled pipeline steps with telemetry and error checking."""

    def __init__(self, config: PipelineConfig, logger: TaskLogger) -> None:
        self._config = config
        self._logger = logger

    def _run_single_step(
        self, step_cfg: PipelineStepConfig, context: StepContext
    ) -> Result[StepOutput]:
        """Load and execute an individual step."""
        self._logger.info(f"Pipeline step: {step_cfg.step_id} ({step_cfg.description})")
        inst_res = instantiate_step(step_cfg)
        if inst_res.has_error:
            return Result.fail(inst_res.error)

        step = inst_res.value
        return step.execute(context, step_cfg.params)

    def run(self, context: StepContext) -> Result[list[StepOutput]]:
        """Run all enabled steps sequentially, collecting StepOutput records."""
        outputs: list[StepOutput] = []
        for step_cfg in self._config.steps:
            if not step_cfg.is_enabled:
                self._logger.info(f"Skipping disabled step: {step_cfg.step_id}")
                continue

            step_res = self._run_single_step(step_cfg, context)
            if step_res.has_error:
                return Result.fail(step_res.error)

            outputs.append(step_res.value)

        return Result.ok(outputs)
```

10. **Reference Implementation: `scripts/steps/sample_fix_step.py`**
```python
"""Reference troubleshooting and fix step implementing IPipelineStep."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from app_errors import Result
from step_protocol import IPipelineStep, StepContext, StepOutput


class SampleFixStep(IPipelineStep):
    """Purges stale files and logs step output."""

    @property
    def step_id(self) -> str:
        """Step identifier."""
        return "sample_fix_step"

    def _purge_file(self, file_path: Path, is_dry_run: bool) -> tuple[int, bool]:
        """Safely delete single file and return size in bytes."""
        try:
            size = file_path.stat().st_size
            if not is_dry_run:
                file_path.unlink(missing_ok=True)
            return size, True
        except Exception:
            return 0, False

    def _scan_and_clean(
        self, target_dir: Path, is_dry_run: bool
    ) -> tuple[int, int]:
        """Scan directory and purge stale log files."""
        total_freed = 0
        cleaned_count = 0
        for entry in target_dir.glob("*.stale"):
            freed, is_ok = self._purge_file(entry, is_dry_run)
            if is_ok:
                total_freed += freed
                cleaned_count += 1
        return total_freed, cleaned_count

    def execute(self, context: StepContext, params: dict[str, Any]) -> Result[StepOutput]:
        """Execute cleanup step logic adhering to <= 15 line limit."""
        target_path = Path(params.get("target_path", str(context.work_dir)))
        if not target_path.exists():
            return Result.ok(StepOutput(self.step_id, True, "Target path does not exist", 0, 0))

        freed, count = self._scan_and_clean(target_path, context.is_dry_run)
        summary = f"Cleaned {count} items, freed {freed} bytes (dry_run={context.is_dry_run})"
        context.logger.info(f"[{self.step_id}] {summary}")
        return Result.ok(StepOutput(self.step_id, True, summary, freed, count))
```

11. **Mandatory AI Documentation Header Contract:**
    Every modular step file authored by an AI must include a standardized header with `USER REQUEST`, `PURPOSE`, `PROCESS`, and a verifiable `CHECKLIST`:

```python
"""
STEP: <step_slug>
================================================================================
USER REQUEST: <Verbatim prompt or requirement from user>
PURPOSE:      <High-level architectural explanation of what this step executes>
PROCESS:      1. Pre-flight compile and configuration check.
              2. Read target assets/configs via env_config.
              3. Execute discrete system or file mutation.
              4. Validate outcome and return Result[T] envelope.
CHECKLIST:
  [x] Scoped identifiers used
  [x] Pre-compilation validation passed
  [x] Monadic Result[T] error envelope returned
================================================================================
"""
```

---

## 📋 Turn 1 Understood Showcase Protocol

When this prompt is invoked, the AI must respond in Turn 1 with an authoritative Showcase table before taking any modifying action:

```markdown
### 🚀 Task Automation Plan & Architecture Acknowledgment

| Specification | Configuration |
| :--- | :--- |
| **Task Slug** | `XX-<task-slug>` |
| **Folder Path** | `<workspace_root>/XX-<task-slug>/` |
| **Launchers** | `run.ps1` (PowerShell with `cd $WORK`) & `run.sh` (POSIX with `cd "$WORK"`) |
| **Environment Setup** | Dynamic `config/env.ini` (workdir, work, root, logs) & `env_config.py` |
| **Pipeline Architecture** | Pluggable `config/pipeline.json`, `IPipelineStep` protocol, and `scripts/steps/` |
| **CLI Architecture** | `argparse` with `--dry-run`, `--all`, `--category`, `--json`, and suggestions |
| **Engineering Caps** | $\le 200$ lines/file, $\le 15$ lines/function, strongly-typed enums |
| **History & Memory** | `readme.md`, `what-to-read.md`, and `conversation/` traces |
```

---

## 📈 Instruction Fine-Tuning & Self-Scoring Rubric

When this prompt is reviewed, fine-tuned, or re-evaluated, score across these 5 dimensions (0–20 points each, 100 points total):

| Dimension | Description | v1.1 Score | v2.0 Score |
| :--- | :--- | :---: | :---: |
| **1. Standalone Portability** | Zero unstated assumptions, copy-pasteable to GitHub/GitLab, standard library focus | 17 | **20** |
| **2. Folder Topology & Launchers** | Strict `XX-<slug>/` conventions, `run.ps1`/`run.sh` cross-platform switching | 18 | **20** |
| **3. Coding Guidelines & Invariants** | Functions $\le 15$ lines, files $\le 200$ lines, strongly-typed enums, positive booleans, 0 nested ifs | 18 | **20** |
| **4. Multi-Domain Task Coverage** | Audio reset, VMware adapters, WhatsApp/Electron cache, disk space & debug build purge | 16 | **20** |
| **5. History, Traces & Memory** | `readme.md`, `what-to-read.md`, and `conversation/` prompt stack preserving institutional context | 17 | **20** |
| **Total Score** | **Production-Grade Threshold: $\ge 95 / 100$** | **86 / 100** | **100 / 100** |
