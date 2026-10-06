# Specification: Universal Subcommand Help Routing Parity

> **Author:** Antigravity AI Orchestrator  
> **Target:** `run.ps1` (PowerShell) & `scripts-linux/run.sh` (Linux/macOS Bash)  
> **Status:** Approved Architecture Spec  
> **Date:** 2026-10-03  

---

## 1. Architectural Intent

Across both PowerShell (`run.ps1`) and Bash (`scripts-linux/run.sh`), any command followed by `help` (e.g. `<command> help`, `<command> -h`, `<command> --help`, `<command> /?`) MUST cleanly display that command's available subcommands, options, and usage examples (identical to `gitmap help` and `os help`), rather than:
1. Treating `"help"` as an install keyword and failing with `[ FAIL ] Unknown keyword: 'help'`.
2. Treating `"help"` as a model name or URL to download and failing with parser/JSON errors.
3. Silently falling through to the generic 500-line root help catalog.

---

## 2. Windows PowerShell Subsystems (`run.ps1`)

### 2.1 Services Subcommand Group (`services`)
- **Keywords / Aliases:** `services`, `service`
- **Handler:** Route to `Show-HelpServices` from `scripts/dispatcher/help/services-cmds.ps1`.
- **Behavior:**
  - `.\run.ps1 services` -> displays full services menu (Nginx, Startup, Schedule, Macro, Storage, Cluster).
  - `.\run.ps1 services help` / `.\run.ps1 services -h` -> displays full services menu and exits 0 cleanly.

### 2.2 Database Subcommand Group (`db`)
- **Keywords / Aliases:** `db`, `database`, `databases`
- **Handler:** Route to `Show-HelpDatabasesAndCombos` from `scripts/dispatcher/help/database-remote-cmds.ps1`.
- **Behavior:**
  - `.\run.ps1 db help` / `.\run.ps1 database help` -> displays interactive and keyword database options (MySQL, PostgreSQL, SQLite, MongoDB, Redis) and exits 0 cleanly.

### 2.3 Universal Tool / Keyword Help Interceptor
- **Problem:** When a user enters `.\run.ps1 vscode help` or `.\run.ps1 python help`, `$normalizedCommand` is `"vscode"`, and `$Install` is `@("help")`. Line 2441 currently constructs `$Install = @("vscode", "help")`, and `Resolve-InstallKeywords` throws `Unknown keyword: 'help'`.
- **Fix Architecture:**
  - Before delegating `$Install` to `Resolve-InstallKeywords`:
    Inspect whether `$Install` contains any help token (`"help"`, `"-h"`, `"--help"`, `"-help"`, `"help"`, `"?"`, `"/? "`):
  - If a help token is detected:
    - Strip the help token from the keyword array.
    - Check if the remaining keyword(s) match a known tool or script ID.
    - If matched: call `Show-RootHelp -Filter $keyword` (or the tool's specific help renderer), and exit 0!
    - This provides instant, accurate, non-crashing help for `.\run.ps1 <tool> help` across all 80+ tools.

---

## 3. Linux / macOS Bash Subsystems (`scripts-linux/run.sh`)

### 3.1 Models Help Interceptor (`models help`)
- Under `models|model)`:
  - If the first argument is `help`, `-h`, `--help`, or empty:
    Display the models orchestrator command syntax, capabilities, and catalog filters directly, avoiding premature calls to `model-pull.sh` or missing `jq` dependencies.

### 3.2 Database Tools (`db`, `database`, `databases`)
- Add `db|database|databases)` verb to `scripts-linux/run.sh`.
- When invoked with `help`, `-h`, `--help`, or empty args, display available database installation scripts and recipes.

### 3.3 Services Group (`services`, `service`)
- Add `services|service)` verb to `scripts-linux/run.sh`.
- Display all service orchestration commands (Nginx, startup, scheduling, macros, storage, cluster).

### 3.4 Multi-Layer Cleaner (`clean`, `clear`)
- Add `clean|clear)` verb to `scripts-linux/run.sh`.
- When invoked with `help`, `-h`, `--help`, route to `python3 03-ai-scripts/44-work-and-system-cache-cleaner.py --help` (or display multi-layer cleaner usage).

### 3.5 Automation Tools (`startup`, `schedule`, `macro`, `storage`, `cluster`)
- Add direct top-level verbs in `scripts-linux/run.sh` to route to their respective shared Python managers or bash scripts when `help` or subcommands are invoked.

---

## 4. Acceptance Criteria

1. **PowerShell (`run.ps1`)**:
   - `.\run.ps1 db help` exits 0 and prints database tool options.
   - `.\run.ps1 services help` exits 0 and prints services subcommands.
   - `.\run.ps1 vscode help` exits 0 and prints VS Code help/install usage.
   - `.\run.ps1 python help` exits 0 and prints Python help/install usage.
2. **Bash (`scripts-linux/run.sh`)**:
   - `./scripts-linux/run.sh models help` exits 0 and prints models help without `jq` errors.
   - `./scripts-linux/run.sh db help` exits 0 and prints database options.
   - `./scripts-linux/run.sh services help` exits 0 and prints services options.
   - `./scripts-linux/run.sh clean help` exits 0 and prints cleaner usage.
