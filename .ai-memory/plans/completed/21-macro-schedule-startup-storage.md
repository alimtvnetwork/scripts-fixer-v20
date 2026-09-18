# Plan 21: Macro, Startup, Schedule (Crontab), Async Monitoring, Storage & Split Database Architecture

> **Prompt Version:** 2.2.0
> **Orchestration:** Multi-Agent Continuous N-Step Loop (N = 130)
> **Main Task Origin:** User directive to implement cross-platform `startup`, `schedule` (and `crontab`), `macro`, `async`, `storage` (drive metrics, partition inspection, split DB footprint), and `pipeline errors -t` (ETA wait countdown) backed by a Split Database SQLite architecture under `~/.scripts-fixer/`.
> **Completion Status:** Completed & Verified (All verification tests passed with exit code 0).
> **Date Completed:** 2026-09-13

---

## Executive Summary & Deliverables

1. **Split Database Architecture (`~/.scripts-fixer/`)**:
   - Master catalog: `Root.db` (`RegisteredDatabases` table registering domain DBs and child DB paths).
   - Domain databases:
     - `Startup.db`: `StartupItems`, `StartupExecutions`
     - `Schedule.db`: `ScheduleItems`, `ScheduleDefinitions`
     - `Macro.db`: `MacroDefinitions`, `MacroSteps`, `MacroExecutions`
     - `Async.db`: `AsyncTasks`, `AsyncLogs`
     - `schedules/<ScheduleId>.db`: Dynamic per-schedule isolated execution logs (`ExecutionLogs`, `RunHistory`)
   - Schema convention: Strict **PascalCase** naming across all tables and columns.

2. **Startup Subsystem (`startup`)**:
   - Subcommands: `startup ls`, `startup <path> [--freq on-login|weekly]`, `startup add <path|macro>`, `startup remove <id>`, `startup run <id>`, `startup help`.
   - Supported target types: PowerShell (`.ps1`), Bash (`.sh`), JavaScript (`.js`), Icons / Shortcuts (`.ico`, `.png`, `.lnk`), Macros (`macro:<name>`), and native executables.
   - OS integration: Windows `shell:startup` shortcuts and Linux `~/.config/autostart` desktop entries.
   - Dual execution tracking: Database audit records in `StartupExecutions`.

3. **Schedule and Crontab Subsystem (`schedule` / `crontab`)**:
   - Multi-runtime execution support: PowerShell (`ps`), Bash (`bash`), POSIX Shell (`sh`), Node.js (`js`), and Macros (`macro`).
   - Per-schedule isolated logging: Each scheduled job logs executions, durations, exit codes, and stdout/stderr into its dedicated `schedules/<ScheduleId>.db`.
   - Subcommands: `schedule ls`, `schedule add <type> <path> <timing>`, `schedule run <id>`, `schedule debug <id>`, `schedule remove <id>`, `schedule help`.
   - Dedicated examples for each script type: `ps`, `bash`, `sh`, `js`, `macro`.

4. **Interactive Macro Engine (`macro`)**:
   - Multi-step pipelines executing sequentially with live real-time stdout/stderr streaming.
   - Bidirectional bindings:
     - `macro startup add <macro_or_path>`: Register macro or arbitrary script into startup.
     - `macro startup [ls|remove|help]`: Directly query and manage startup from within macro.
     - `macro schedule add <type> <path> <timing>` or `macro schedule add <name> <timing>`: Register tasks into crontab from within macro.
     - `macro schedule [ls|remove|help]`: Directly query and manage schedules from within macro.
   - Subcommands: `macro ls`, `macro add <name> <steps...>`, `macro run <name>`, `macro remove <name>`, `macro help`.

5. **Async Command Runner & Monitor (`async`)**:
   - Periodic execution loop (`-t <seconds>`) with optional iteration caps (`-c <count>`).
   - Logging of durations and execution results into `Async.db`.
   - Subcommands: `async <command> [-t <seconds>] [-c <count>]`, `async ls`.

6. **Storage Calculation & Database Footprint (`storage`)**:
   - Drive metrics: Exact filesystem detection (`NTFS`, `FAT32`, `ext4`), total size, used space, free space, and usage percentage across mounted drives (`psutil` / OS ctypes fallbacks).
   - Current drive indicator: Dynamically highlights the current working drive with `* (Current)`.
   - Split database footprint: Automatic discovery and size auditing for all SQLite databases registered in `~/.scripts-fixer/`.
   - Partitioning guidance & commands:
     - `storage partition swap [--size <size>]`: Step-by-step instructions and commands for Ubuntu swapfile and LVM volume resizing.
     - `storage partition gui`: One-click launch for Windows Disk Management (`diskmgmt.msc`) or GParted GUI.
   - Subcommands: `storage ls`, `storage info`, `storage partition [swap|gui]`, `storage help`.

7. **Pipeline Errors ETA Wait (`pipeline errors -t`)**:
   - ETA countdown wait timer integrating with `.ai-memory/temp/runner-eta.json`.
   - Clean terminal status indicators and exit code 0 on completion.

8. **Dispatcher & Documentation**:
   - `run.ps1`: Canonical verbs, argument dispatchers, top-level `$t` switch parameter binding precedence fix, and help filters (`help startup`).
   - `scripts/run.sh`: Linux bash dispatchers with `$PYTHON_BIN` resolution and colorized outputs.
   - `readme.md`: Full documentation and command reference.

---

## Consolidated Subtasks

### Subtask 1: Split Database Architecture
- **Implementation File:** `scripts/shared/split_db.py`
- Implemented master registry in `Root.db` with table `RegisteredDatabases`.
- Domain child DB initializers with PascalCase table schemas.
- Helper functions: `get_connection()`, `register_database()`, `get_schedule_db_connection()`, `list_registered_databases()`.

### Subtask 2: Startup Subsystem
- **Implementation File:** `scripts/shared/startup_manager.py`
- Implemented `add`, `remove`, `ls`, and `run` actions.
- Cross-platform hooks for Windows Startup folder and Linux `~/.config/autostart`.
- Execution records saved to `StartupExecutions`.

### Subtask 3: Schedule & Crontab Subsystem
- **Implementation File:** `scripts/shared/schedule_manager.py`
- Implemented `add`, `remove`, `ls`, `run`, and `debug` actions.
- Per-schedule dynamic database creation (`schedules/<ScheduleId>.db`).
- Runner support for `ps`, `bash`, `sh`, `js`, and `macro`.

### Subtask 4: Interactive Macro Engine
- **Implementation File:** `scripts/shared/macro_manager.py`
- Implemented multi-step command chaining with real-time stdout/stderr streaming.
- Bidirectional integration with `startup` and `schedule` subsystems.
- Definition and step storage in `Macro.db`.

### Subtask 5: Async Runner and Storage Subsystem
- **Implementation Files:** `scripts/shared/async_runner.py`, `scripts/shared/storage_manager.py`
- Implemented async periodic monitor logging into `AsyncTasks` and `AsyncLogs`.
- Implemented storage metrics inspector and split DB file size auditor.

### Subtask 6: Root Dispatchers and Documentation
- **Implementation Files:** `run.ps1`, `scripts/run.sh`, `readme.md`
- Wired all commands into Windows and Linux root runners.
- Updated root help screen and added comprehensive README section.

---

## Verification Summary
- `pwsh -Command ".\run.ps1 startup ls"`: Pass (exit 0)
- `pwsh -Command ".\run.ps1 schedule ls"`: Pass (exit 0)
- `pwsh -Command ".\run.ps1 macro ls"`: Pass (exit 0)
- `pwsh -Command ".\run.ps1 async ls"`: Pass (exit 0)
- `pwsh -Command ".\run.ps1 storage ls"`: Pass (exit 0)
- `pwsh -Command ".\run.ps1 pipeline errors -t"`: Pass (exit 0)
- `pwsh -Command ".\run.ps1 help startup"`: Pass (exit 0)
- `bash scripts/run.sh storage ls`: Pass (exit 0)
- `bash scripts/run.sh startup ls`: Pass (exit 0)
- `bash scripts/run.sh schedule ls`: Pass (exit 0)
- `bash scripts/run.sh pipeline errors -t`: Pass (exit 0)
