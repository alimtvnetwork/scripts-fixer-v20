---
id: chapter-03-telemetry-gates
name: Chapter 3 Telemetry Gates
description: Environment, git, and release telemetry gates chapter.
category: verification-chapter
placeholders: []
version: 1
---

# 🔍 CHAPTER 3: ENVIRONMENT, GIT & RELEASE TELEMETRY GATES

Run or verify the following diagnostic commands before completing your report:
1. **Working Tree Cleanliness:** Check `git status --porcelain` to identify any uncommitted, modified, or untracked files.
2. **Active Branch Validation:** Check `git branch --show-current` to confirm alignment with your task scope (`main` vs `beta`).
3. **Pipeline Health & Telemetry:** Ensure recent CI/CD pipeline steps are not failing (`gitmap pe -t` or local pre-flight runner).
