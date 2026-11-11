# Multi-Repository Synchronization Standards

## Core Principles

1. **Pre-Flight Safety Protocol:** Always pull the latest base branch via GitMap (`gitmap pull`, fallback `git pull origin <base_branch> --no-rebase`), create and push a safety backup branch (`backup/sync-<timestamp>`), and return to the base branch (`git checkout <base_branch>`) before mirroring assets.
2. **Spec 21 Exclusion (TOTAL BAN):** NEVER synchronize, copy, or touch `02-spec/21-*` through `02-spec/25-*` (private application domain specs, issues, db, and UI designs). Only shared specifications `02-spec/01-*` through `02-spec/20-*` are synchronized.
3. **Additive-Only AI Scripts:** Brand-new AI scripts (`03-ai-scripts/`, `.agents/scripts/`) that do not exist in the target repository are copied cleanly. Existing scripts modified by the target repository must NEVER be overwritten.
4. **Bump Script Protection (IMMUTABLE):** NEVER overwrite version bump scripts or manifests (`bump*`, `bump_versions.py`, `bump-version.mjs`, `version.json`). Each repository maintains custom SemVer targets and release logic.
5. **Memory & Plans Protection (TOTAL ISOLATION):** NEVER modify, sync, or mirror `.ai-memory/memory/` or `.ai-memory/plans/` in target repositories.
6. **Zero Secrets Leakage:** NEVER synchronize `.env` files, tokens, or credentials across repositories. Secrets reside strictly in `repo-secrets` via `gitmap rs`.
7. **Atomic Commit via GitMap Chore Verb:** Always commit synchronization updates via `gitmap cpc "Sync - update prompts, skills, and shared specs"` (or `gitmap cpc "sync - ..."`). TOTAL BAN on raw `git commit`, `git add -A`, misusing `gitmap cpf` for sync chores, or using `commit` as a module name. Format with Title Case or lowercase module and hyphen.
