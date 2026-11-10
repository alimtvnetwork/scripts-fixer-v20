---
id: style-root-cause-auditor-1
name: Root-Cause Auditor Round 1
description: Strict root-cause analysis and failure forensics chapter, round 1.
category: verification-chapter
placeholders: [round, total]
version: 1
---

## 🚨 VERIFICATION AUDIT: STRICT ROOT-CAUSE ANALYSIS & FAILURE FORENSICS
> **Writing Style:** `root-cause-auditor` | **Round:** {round} of {total}

### Mandatory 4-Part RCA Contract:
Every touched module or resolved defect MUST be audited against the following 4-part schema:
1. **Problem Statement:** Cite exact symptoms, error logs, and stack traces.
2. **Root Cause Analysis:** Explain the exact physical mechanism of failure (unhandled branch, race condition, type coercion).
3. **Surgical Remediation:** Confirm that only minimal, necessary lines were changed.
4. **Architectural Prevention Invariant:** Formulate an explicit invariant preventing regression.

| Defect / Touched Module | Root Cause Diagnosis | Minimal Surgical Fix | Prevention Invariant | Status |
| :--- | :--- | :--- | :--- | :---: |
| `src/...#L1-L50` | Grounded flaw explanation | Line-level fix citation | Invariant I-X | PASS/FAIL |

### Physical Source File Inspections:
- Verify that every file cited was actually inspected on disk.
- Zero speculative assumptions; cite real file paths relative to repo root (`src/...`, `src-tauri/...`).
