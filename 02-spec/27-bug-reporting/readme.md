# Specification 27: Universal Bug Reporting System (Flight Recorder & AI Diagnostics)

## Overview & Index

This specification directory defines the complete, language-agnostic architecture of the **Universal Bug Reporting & Flight Recorder System**. It provides all blueprints, database schemas, UI wireframes, CLI protocols, and step-by-step algorithms required for any software engineer or blind AI to construct this system from scratch in any tech stack.

---

## Detailed Specifications Directory Index

| Document | Topic | Description |
| :--- | :--- | :--- |
| [`01-architecture-and-philosophy.md`](01-architecture-and-philosophy.md) | **Architecture & Philosophy** | Core flight-recorder invariant, deterministic reproduction, zero-context blind AI contract, and subsystem topology. |
| [`02-ui-ux-and-interaction-design.md`](02-ui-ux-and-interaction-design.md) | **UI/UX & Interaction Design** | Tokyo Night design language, 32px Floating Recorder HUD, Bug Summary Modal, and Previous Bugs Tracker with Import/Export dropzone. |
| [`03-normalized-sqlite-schema.md`](03-normalized-sqlite-schema.md) | **Normalized SQLite Schema** | Complete 3NF relational database schema (DDL), primary/foreign keys, indexes, and high-speed diagnostic queries. |
| [`04-full-project-bundle-and-zip-contract.md`](04-full-project-bundle-and-zip-contract.md) | **Project Bundle & ZIP Contract** | `.bug.zip` specification, `manifest.json` schema, machine auto-harvesting, and 1-click full project reproduction. |
| [`05-cli-specification-and-ai-command-matrix.md`](05-cli-specification-and-ai-command-matrix.md) | **CLI Specification & AI Matrix** | Universal CLI commands (`--recent-bugs`, `--step <N>`, `--drill-down`, `--import-zip`, `--export-bundle`) and AI suggested follow-up commands. |
| [`06-step-by-step-ai-build-guide.md`](06-step-by-step-ai-build-guide.md) | **Blind AI Step-by-Step Build Guide** | 6-phase chronological build guide with algorithms and implementation recipes for building from zero knowledge. |
| [`07-wave-6-delta-notes.md`](07-wave-6-delta-notes.md) | **Wave 6 Implementation Delta Notes** | Grounded inventory of extensions, deltas, and proofs established during Wave 6 implementation. |
| [`08-script-notification-and-alerting.md`](08-script-notification-and-alerting.md) | **Script Notification & Alerting Protocol** | Webhook JSON dispatch, local shell alert execution, email formatting, and offline queue resilience. |

---

## Quick Reference: CLI AI Diagnostic Flow

```bash
# 1. Discover recent bug reports and their step counts
python bin/errors-cli.py --recent-bugs

# 2. Inspect step 7 of the most recent bug (reveals code location and screenshot)
python bin/errors-cli.py --step 7

# 3. Drill down into deep stack trace or code snippet
python bin/errors-cli.py --drill-down <SESSION_ID> --step 7

# 4. Import a portable bug bundle archive from another machine
python bin/errors-cli.py --import-zip ./defect-report.bug.zip

# 5. Export complete session and project configuration
python bin/errors-cli.py --export-bundle <SESSION_ID> --out ./reproduced.bug.zip
```
