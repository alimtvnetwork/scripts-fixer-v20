# Universal Python Task Automation Prompts (`33-universal-python-task`)

This directory hosts the canonical, standalone execution prompt for accomplishing any software, operating system, configuration, troubleshooting, or maintenance task via structured, task-scoped Python execution engines.

## Prompt Index

- [`01-universal-python-task-automation-prompt.md`](01-universal-python-task-automation-prompt.md) — Master Standalone Prompt (v2.1.0). Scaffolds task-scoped sequential folders (`XX-<slug>/`), cross-platform launchers (`run.ps1` with `cd $WORK` and `run.sh`), pluggable pipeline architecture (`config/pipeline.json`), dynamic cross-platform environment configuration (`config/env.ini` & `env_config.py`), modular step protocol (`step_protocol.py` & `scripts/steps/`), modular Python functions ($\le 15$ lines), strongly-typed enums (`enum.StrEnum`), dual console/file logging, positive booleans (`is_*`, `has_*`), zero nested conditionals, and argparse CLI dispatch with `--dry-run`, category switches (OS cache, debug builds, audio services, VMware network, WhatsApp glitches), and interactive next-step suggestions.

## Reference Implementation & Fixtures

- [`code/`](code/) — Production-grade executable blueprint and reference architecture. Includes complete implementation of `app_errors.py` (monadic `Result[T]` & `AppError`), `core_enums.py` (with monadic parsing), `core_constants.py` (zero magic strings), `task_logger.py` (ANSI badges & structured JSON logging), `cli_dispatcher.py` (argparse & interactive suggestions), and `task_runner.py` with cross-platform launchers (`run.ps1`, `run.sh`) and comprehensive root `readme.md`.
- [`fixture/01-os-disk-optimization/`](fixture/01-os-disk-optimization/) — Complete, tested runnable reference implementation featuring working launchers (`run.ps1`, `run.sh`), modular scripts, disk space gauge, and conversation traces.

## Key Capabilities & Architecture

1. **100% Standalone Portability:** Can be copy-pasted directly to GitHub Gists, GitLab Snippets, or IDE chat sessions (Antigravity, Cursor, Claude, ChatGPT, Muse) with zero unstated dependencies.
2. **Task-Scoped Workspace Topology:** Every execution creates a self-contained sequential folder (`XX-<slug>/`) housing launchers, scripts, logs, history, and conversation traces.
3. **Multi-Domain Task Coverage:** Concrete implementation handlers for Windows audio services restart, VMware network adapter reset, WhatsApp/Electron cache purge, OS cache optimization, and user provisioning.
4. **Strict Coding Guidelines:** Enforces functions $\le 15$ lines, files $\le 200$ lines, strongly typed enums, positive booleans, and early return guard clauses.
5. **Ergonomic CLI Dispatch:** Exposes granular task targets (`--category os_cache`, `--category debug_builds`), `--dry-run` simulation, and automated suggestions.
6. **Memory & Traceability:** Maintains institutional memory via `readme.md`, `what-to-read.md`, and turn traces under `conversation/`.
