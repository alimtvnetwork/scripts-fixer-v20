# Prompt: Database Sync, UUID Implementation for Heatmap & AUM Search Enhancements

> **Execution Prompt Sequence:** 115
> **Topic:** Heatmap UUID Primary Keys, Conflict-Free 6-Stage SQLite Sync Protocol, RC Command Discovery & AUM Search Extensions
> **Spec Reference:** `02-spec/21-app/115-database-sync-uuid-implementation-heatmap/01-architecture-spec.md`
> **Plan Reference:** `.ai-memory/plans/pending/115-database-sync-uuid-implementation-heatmap.md`

---

## 1. Context & Task Mission

Implement UUID primary keys across the heatmap and RC telemetry databases to prevent ID collisions in distributed multi-agent workflows, deploy the robust 6-stage SQLite database synchronization protocol (snapshot export -> discard binary changes -> pull rebase -> replay merge -> commit -> push), resolve `gitmap rc` discovery and routing parity for `gitmap rc agent` and `gitmap rc heatmap`, and enhance `gitmap aum search` with wildcard extension normalization (`-ext *.go`) and search match limit flags (`-l, --limit <int>`).

---

## 2. Invariants & Rules

1. **Pre-Flight Pull:** Always run `gitmap pull` before starting any modifications.
2. **Coding Guidelines:** Maximum 15 lines per function, zero nested ifs (guard clauses and early returns), blank line before returns and after closing braces.
3. **Boolean Hygiene:** Positive boolean prefixes only (`is*`, `has*`).
4. **Error Return Sovereignty:** Leaf functions return `error` or `*apperror.AppError`; top-level commands handle exit codes.
5. **Pre-Commit Skill Frontmatter Validation:** Run `python 03-ai-scripts/53-skill-frontmatter-validator.py` (exit code 0 mandatory).
6. **Throttled Build Concurrency:** Build with `$env:GOTMPDIR = "D:\tmp"; go build -C cli -p 2 -o ../bin/gitmap.exe .`.
7. **GitMap Commit Verbs:** Use `gitmap cpf` for feature commit and `gitmap cpr "v6.690.0 - ..."` for release commit.
