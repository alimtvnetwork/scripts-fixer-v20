---
id: are-you-confident
name: Sure? (Quality Audit)
description: Code quality, <= 15-line functions, positive booleans & error routing
category: quality
placeholders: []
version: 1
default: false
---

### Code Quality & Confidence Audit:
- Keep core functions bounded to <= 15 lines with single responsibility.
- Flatten nested conditionals with early returns and guard clauses.
- Enforce positive boolean polarity (no double negatives).
- Route all errors through AppError and useErrorStore (no bare catch {}).
