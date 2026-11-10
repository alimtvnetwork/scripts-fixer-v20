---
id: chapter-02-run-100-steps
name: Chapter 2 100 Steps Checklist
description: Grounded verification matrix for the run-100-steps type.
category: verification-chapter
placeholders: []
version: 1
---

# 📊 CHAPTER 2: GROUNDED VERIFICATION MATRIX & ACTIONABLE CHECKLIST

### Chapter 2.10: 100-Step Parent Task Execution
Must follow and spawn agent using
[execute-parent-task-with-n-steps-v6](directory;.agents/skills/execute-parent-task-with-n-steps-v6)

- [ ] **1. Skill Load:** Load `.agents/skills/execute-parent-task-with-n-steps-v6` before executing the original prompt.
- [ ] **2. Breakdown:** Split the original request into 100+ sequential, independently revertable steps.
- [ ] **3. Continuous Loop:** Execute without pausing for permission except on true blockers; keep A=3 workers saturated.
- [ ] **4. FIFO Restore:** Enqueue, restore, and dispatch with `ORDER BY created_at ASC, id ASC`.
- [ ] **5. Done & Released:** Finish only after end-to-end proof and a relative-path changelog attributed to `@aukgit`.
