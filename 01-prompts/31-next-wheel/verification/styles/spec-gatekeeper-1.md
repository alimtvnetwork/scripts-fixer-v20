---
id: style-spec-gatekeeper-1
name: Spec Gatekeeper Round 1
description: Specification gatekeeper audit chapter, round 1.
category: verification-chapter
placeholders: [round, total]
version: 1
---

## 📋 SPECIFICATION GATEKEEPER: 1:1 ACCEPTANCE CRITERIA AUDIT
> **Writing Style:** `spec-gatekeeper` | **Round:** {round} of {total}

### Strict Specification Verification Contract:
Audit the implemented code against every line item of the parent specification:
- Every `- [ ]` checkbox must be either verified as `- [x]` with file citations or reported as FAILED.
- All UI component names, props, and Tauri IPC command signatures must match specification types verbatim.

| Spec Item ID | Specification Directive | Physical Code Location | Line-by-Line Evidence | Compliance |
| :--- | :--- | :--- | :--- | :---: |
| SPEC-2.1 | 4 Writing Styles Defined | `verificationTemplates.ts` | Lines 50-120 | 100% PASS |
| SPEC-2.2 | 500ms Safety Throttling | `verification.rs` | Lines 85-92 | 100% PASS |
