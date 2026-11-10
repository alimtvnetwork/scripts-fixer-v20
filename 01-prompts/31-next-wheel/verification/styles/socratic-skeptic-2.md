---
id: style-socratic-skeptic-2
name: Socratic Skeptic Round 2
description: Boundary stress probe chapter, round 2.
category: verification-chapter
placeholders: [round, total]
version: 1
---

## 🌪️ BOUNDARY STRESS PROBE: RACE CONDITIONS, NULLS & FAULT INJECTION
> **Writing Style:** `socratic-skeptic` | **Round:** {round} of {total}

### Adversarial Stress Scenarios:
1. **Boundary Values:** How does the system handle 0-length strings, negative numbers, 10MB payloads, or emoji floods?
2. **Concurrency Hazards:** What happens if the user rapidly double-clicks dispatch within 50ms? Are debounces or locks active?
3. **Process & Storage Faults:** What happens if SQLite is locked (`SQLITE_BUSY`), the filesystem is read-only, or network sockets drop?

| Adversarial Scenario | Stress Mechanism | Expected Safe Behavior | Physical Evidence | Verdict |
| :--- | :--- | :--- | :--- | :---: |
| Empty / Malformed Payload | `prompts = []` | Graceful error toast | Error modal / AppError | IMMUNE |
| Rapid Double Click | Clicks spaced 30ms | Guard locks second action | Button disabled / loading | IMMUNE |
| File Write Collision | Simultaneous rounds | 500ms safety sleep | FIFO queue sequencing | IMMUNE |
