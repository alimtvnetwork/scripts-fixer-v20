---
id: code
name: Code Improvement Checklist
description: Sectioned code insert: planning, DRY, function size, booleans, and error routing.
category: insert
placeholders: []
version: 1
---

Why was this code written without proper planning and hygiene? Show the plan first (current behavior, required behavior, smallest change), eliminate duplicates via shared helpers, keep functions at most 15 lines with a single responsibility, flatten nesting with early returns, use positive booleans only, route all errors through AppError / the error store (no bare catches or swallowed failures), and verify thoroughly (targeted checks, happy path and error branches, clean tree before marking done).
