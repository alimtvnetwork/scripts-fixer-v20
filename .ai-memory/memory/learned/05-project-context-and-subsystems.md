---
name: Project Context and Subsystems Ingestion
description: Ingestion summary of repository identity, recent commits, split DB architecture, and subsystem contracts
type: learned
---

# Project Context and Subsystems Ingestion

> **Date:** 2026-09-14  
> **Repository Version:** v1.43.0  
> **Commit Inspected:** HEAD (`release: v1.43.0 automated release orchestrator and branch lifecycle suite`)

## 1. Architectural Summary & Recent Commit Intent
- **v1.43.0 / v1.42.0**: Release orchestrator tool (`03-ai-scripts/29-release-orchestrator.py`) and Antigravity skill (`.agents/skills/release-orchestrator/skill.md`) automating semantic version bumping, branch management, and git tagging.
- **v1.41.0**: Intelligent Linux Archive Installer (`scripts/os/ubuntu/install-archive.sh`) supporting `.tar.gz`, `.tar.xz`, `.tar.bz2`, `.tar`, `.zip`, and `.gz` with auto-extraction, executable discovery, desktop entries, and path configuration.
- **v1.40.0**: Cross-platform official Google Storage package installer for Antigravity IDE and CLI (`scripts/69-install-antigravity/run.ps1` and `scripts/os/ubuntu/install-antigravity.sh`).
- **v1.39.0**: Split SQLite database architecture (`~/.scripts-fixer/`) with `Root.db`, `Startup.db`, `Schedule.db`, `Macro.db`, `Async.db`, dynamic per-schedule logging databases, drive/storage inspection, and crontab subsystem.
- **v1.37.0 & v1.38.0**: Profile tree visualization (`profile tree <name>`), AI profiles update (Ollama decoupling).

## 2. Ingested Subsystems & Conventions
- **Split DB Conventions**: PascalCase naming across all SQLite tables and columns. Master catalog in `Root.db` (`RegisteredDatabases`).
- **Startup Subsystem**: Cross-platform support for `.ps1`, `.sh`, `.js`, macros, and shortcuts on Windows `shell:startup` and Linux `~/.config/autostart`.
- **Schedule Subsystem**: Dynamic per-schedule execution databases (`schedules/<ScheduleId>.db`) with multi-runtime runners (`ps`, `bash`, `sh`, `js`, `macro`).
- **Macro Engine**: Multi-step pipeline chaining with live streaming and bidirectional bindings with startup and schedule systems.
- **Async Runner**: Periodic monitoring with loop caps and logging into `AsyncTasks` and `AsyncLogs`.
- **Storage Subsystem**: Filesystem metrics detection across mounted drives with current drive indicators and split database footprint auditing.

## 3. Discovered Reference Discrepancies
- `.ai-memory/memory/01-index.md` referenced `features/error-management-file-path-rule.md`, which is mapped to the authoritative `02-spec/error-management/powershell-error-management.md`.
- Pending plan `01-kubernetes-suite.md` references subtasks `subtasks/01-kubernetes-suite/01-windows-suite.md` and `02-ubuntu-suite.md`, which were planned but not populated on disk.
