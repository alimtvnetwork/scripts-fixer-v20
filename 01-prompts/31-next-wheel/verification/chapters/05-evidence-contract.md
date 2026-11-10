---
id: chapter-05-evidence-contract
name: Chapter 5 Evidence Contract
description: Concluding evidence scorecard contract chapter.
category: verification-chapter
placeholders: []
version: 1
---

# 📝 CHAPTER 5: EVIDENCE SCORECARD CONTRACT

You MUST conclude your audit with the following Evidence Scorecard table:

| Verification Gate | Status | File / Line Reference | Verifiable Proof / Output |
| :--- | :---: | :--- | :--- |
| Codebase Citation & Reading | PASS / FAIL | `src/...#L12-L45` | File inspected and verified |
| 1-Sentence Root Cause | PASS / FAIL | N/A | Diagnostic statement provided |
| Surgical Code Change | PASS / FAIL | `src/...` | Zero extraneous edits or code churn |
| Quality Gates (Clippy / Build) | PASS / FAIL | Terminal Output | Build passes cleanly |
| Coding Guidelines (Booleans/Errors) | PASS / FAIL | `src/...` | Positive booleans, error store routed |
| Memory & Plan Synchronization | PASS / FAIL | `.ai-memory/...` | Subtask marked COMPLETED |

### Concluding Verdict:
- **ALL_CRITERIA_MET:** `[TRUE | FALSE]`
- **BLOCKING_ISSUES:** `[None | Describe any unresolved issues]`
- **RECOMMENDED_NEXT_STEP:** `[Proceed to next subtask | Fix failing items | Release]`
