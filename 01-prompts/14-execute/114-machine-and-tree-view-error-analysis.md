# Prompt 114: Machine and Tree View Error Analysis

> **Sequence:** 114
> **Target:** Fleet Binary Deployment Hardening, Tree View Error Decomposition & Offline Node Aggregation
> **Canonical Spec:** [`02-spec/21-app/114-machine-and-tree-view-error-analysis/01-architecture-spec.md`](file;02-spec/21-app/114-machine-and-tree-view-error-analysis/01-architecture-spec.md)
> **Master Plan:** [`.ai-memory/plans/pending/114-machine-and-tree-view-error-analysis.md`](file;.ai-memory/plans/pending/114-machine-and-tree-view-error-analysis.md)

## Task Overview
Resolve Windows OpenSSH remote binary swap failure (RCA-04.9), decompose error messages in the deployment tree view without execution wrapper codes, aggregate offline/switched-off nodes into a compact top summary, suppress pre-tree noisy stream output during `deploy-bin all`, and provide an interactive single-suggestion execution prompt.

## Execution Directives
1. Replace brittle `cmd.exe` remote swap command with robust PowerShell script terminating stale processes and handling locked files.
2. Strip `[E9000:EXECUTION]` and `(at=...)` wrapper codes from tree failure details.
3. Decompose checksum mismatch errors into readable `error:`, `expected:`, and `actual:` child leaves.
4. Aggregate offline nodes (`SkipReasonNodeOffline`) into a single top branch `├── ⊘ Offline machines (N) — alias (IP), ...`.
5. Suppress verbose per-node transfer/sync logs during `deploy-bin all` so the tree view is the clean authoritative console report.
6. Verify via comprehensive unit and end-to-end integration tests.
7. Perform minor bump (`v6.689.0`), swap local binary, commit via `gitmap cpf` and `gitmap cpr`, and push to remote.
