---
id: style-spec-gatekeeper-2
name: Spec Gatekeeper Round 2
description: Negative specification audit chapter, round 2.
category: verification-chapter
placeholders: [round, total]
version: 1
---

## 🔍 NEGATIVE SPECIFICATION AUDIT: BOUNDARY CONSTRAINTS & BANNED PATTERNS
> **Writing Style:** `spec-gatekeeper` | **Round:** {round} of {total}

### Negative Specification Directives:
1. **Zero Git Commands:** Verify that no prohibited git commands (`git add`, `git commit`, `git push`, `git status`) were executed.
2. **Search Discipline:** Verify that search strictly used `gitmap` and zero banned tools (`grep`, `rg`, `findstr`).
3. **Disjoint Ownership:** Verify that only assigned owned files were edited; zero collateral changes.
4. **Strict Relative Paths:** All paths must be relative (`src/...`, `src-tauri/...`), never machine-absolute.

| Guard Rule | Restriction Scope | Compliance Audit | Status |
| :--- | :--- | :--- | :---: |
| Git Command Ban | Whole session | Zero git calls in transcript | COMPLIANT |
| Search Tool Ban | Whole session | Gitmap used exclusively | COMPLIANT |
| Relative Paths | All files & templates | Zero absolute paths found | COMPLIANT |
