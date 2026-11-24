# Context Ingestion Guide: Universal Python Task Automation Reference

> **Subsystem:** `01-prompts/33-universal-python-task/code/`
> **Target Audience:** Autonomous AI Agents, Developers, CI/CD Runners

---

## What to Ingest Before Modifying or Executing

1. **`readme.md` (Root Reference):**
   - High-level architectural overview, replication instructions, CLI arguments, and examples.
2. **`scripts/app_errors.py` (Error Sovereignty Contract):**
   - Dataclass `AppError` and generic container `Result[T]`. All leaf handlers MUST return `Result[T]`.
3. **`scripts/core_enums.py` (Domain Enums):**
   - Strongly-typed enums ending in `Type`: `ActionType`, `TaskCategoryType`, `ExitCodeType`, `AppErrorCodeType`.
4. **`scripts/core_constants.py` (Zero Magic Strings):**
   - Constants classes for paths, packages, badges, and protected file patterns.
5. **`scripts/task_logger.py` (Dual-Channel Telemetry):**
   - Console ANSI badges (`[  OK  ]`, `[ FAIL ]`, `[ WARN ]`, `[ INFO ]`, `[ SKIP ]`) and structured text/JSON logging to `logs/task.log`.
6. **`scripts/task_runner.py` (Modular Handlers):**
   - Modular execution logic; functions strictly $\le 15$ lines.
7. **`scripts/cli_dispatcher.py` (Argparse & Suggestions):**
   - CLI entrypoint unpacking `Result[T]` and exiting with `ExitCodeType`.
8. **`tests/` (Unit Test Suite):**
   - Automated tests verifying `AppError`, `Result[T]`, `core_enums.py`, `task_logger.py`, and `task_runner.py`. Run via `./run.ps1 test` or `./run.sh test`.
