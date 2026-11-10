---
id: style-root-cause-auditor-2
name: Root-Cause Auditor Round 2
description: Deep forensic probe chapter, round 2.
category: verification-chapter
placeholders: [round, total]
version: 1
---

## 🔬 DEEP FORENSIC PROBE: REPRODUCTION TRACE & REGRESSION INVARIANTS
> **Writing Style:** `root-cause-auditor` | **Round:** {round} of {total}

### Reproduction & Flaw Isolation:
1. **Reproduction Mechanism:** State the exact physical CLI command, payload, or unit test that triggers the defect before fix.
2. **Secondary Regression Check:** Did the surgical fix perturb any adjacent data structures, schemas, or IPC calls?
3. **No Symptom Masking:** Verify that error handling does not suppress root errors (`catch {}` or silent `.ok()` are forbidden).

| Module Tested | Reproduction Trace | Regression Guard | Physical Proof | Verdict |
| :--- | :--- | :--- | :--- | :---: |
| `src/...` | Bounded repro trace | Tested against regression | Unit test / CLI output | VERIFIED |
