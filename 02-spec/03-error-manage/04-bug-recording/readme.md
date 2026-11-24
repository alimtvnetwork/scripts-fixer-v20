# Bug Recording & Error Management Specifications (`02-spec/03-error-manage/04-bug-recording/`)

## 1. Overview
This directory contains the canonical specifications, data models, state machines, and audit criteria for the unified Bug Recorder subsystem. It establishes an unambiguous foundation for autonomous AI agents ("Blind AI") to implement bug recording, telemetry interception, visual rasterization, prompt synthesis, and automated reproduction across Antigravity Manager, Antigravity Tools, Cat MY, and GitMap.

---

## 2. Specification Index

| Document | Title | Description |
| :--- | :--- | :--- |
| [01-bug-record-schema-spec.md](01-bug-record-schema-spec.md) | Schema & State Machine Spec | Relational SQLite Split-DB tables, 7-state lifecycle machine, universal JSON envelopes, and positive boolean typing. |
| [02-recording-pipeline-spec.md](02-recording-pipeline-spec.md) | Recording Pipeline Spec | 3-stage pipeline (Capture $\rightarrow$ Persist $\rightarrow$ Surface), HUD invariants, 4-tier detail inspector, SVG rasterization, offline sync, V6/V7 prompts, and ZIP packager. |
| [03-blind-readiness-audit-spec.md](03-blind-readiness-audit-spec.md) | Blind-Readiness Audit Spec | 9-dimensional compliance matrix, Convergence Gap Register (`G1`–`G9`), and automated verification gates. |
| [error-codes.json](error-codes.json) | Registered Error Codes | Registered `BUG` error codes in range `18250`–`18260` with severity levels and error symbols. |

---

## 3. Related Application Specifications & Audits
- **Spec 455 (Canonical Enhancement)**:
  - Architecture Spec: [01-architecture-spec.md](../../21-app/455-enhance-bug-recorder-from-antigravity-manager-or-antigravity-tools/01-architecture-spec.md)
  - AI Execution Instructions: [02-ai-instructions.md](../../21-app/455-enhance-bug-recorder-from-antigravity-manager-or-antigravity-tools/02-ai-instructions.md)
  - Root Audit Report: [audit-report.md](../../../audit/455-enhance-bug-recorder-from-antigravity-manager-or-antigravity-tools/audit-report.md)
  - Master Plan: [455-enhance-bug-recorder-from-antigravity-manager-or-antigravity-tools.md](../../../.ai-memory/plans/completed/455-enhance-bug-recorder-from-antigravity-manager-or-antigravity-tools.md)
- **Spec 454 (Repocache Migration Foundation)**:
  - Architecture Spec: [01-architecture-spec.md](../../21-app/454-repocache-to-gitmap-migration-and-bug-recording-enhancement/01-architecture-spec.md)
  - AI Execution Instructions: [02-ai-instructions.md](../../21-app/454-repocache-to-gitmap-migration-and-bug-recording-enhancement/02-ai-instructions.md)
  - Root Audit Report: [audit-report.md](../../../audit/454-repocache-to-gitmap-migration-and-bug-recording-enhancement/audit-report.md)
  - Master Plan: [454-repocache-to-gitmap-migration-and-bug-recording-enhancement.md](../../../.ai-memory/plans/completed/454-repocache-to-gitmap-migration-and-bug-recording-enhancement.md)
