# Prompts Master Reference: `prompts.md`

> **Updated:** 2026-09-13  
> **Status:** Canonical Prompt Reference  
> **Source Directory:** [`.lovable/prompts/`](prompts/)

---

## 1. Core Workflow Prompts

| Prompt ID | File | Version | Trigger Phrase | Purpose |
| :---: | :--- | :---: | :--- | :--- |
| 01 | [`prompts/01-read-prompt.md`](prompts/01-read-prompt.md) | v1.1 | `read memory` | AI Onboarding & Context Ingestion |
| 02 | [`prompts/02-write-prompt.md`](prompts/02-write-prompt.md) | v2.2.0 | `write memory`, `end memory` | Memory Persistence, Issue Logging & Learning |

---

## 2. Execution Sub-Prompt Architecture (`01-prompts/`)

- [`01-prompts/cg-execute/`](../01-prompts/cg-execute/) — Coding guideline enforcement execution prompts.
- [`01-prompts/execute/`](../01-prompts/execute/) — Multi-agent atomic subtask execution prompts.
- [`01-prompts/ci-cd/`](../01-prompts/ci-cd/) — CI/CD validation and local pre-flight runner prompts.
