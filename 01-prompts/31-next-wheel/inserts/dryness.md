---
id: dryness
name: Code Dryness & Anti-Duplication Checklist
description: Sectioned DRY insert: deduplication, enum centralization, magic strings, guard clauses, and single source of truth.
category: insert
placeholders: []
version: 1
---

Eliminate duplicate logic across functions, handlers, and components via shared reusable domain utilities. Centralize enums with PascalCase formatting and Type suffixes; eradicate magic strings and numbers into typed constants. Flatten all nested conditionals with early-return guard clauses (max nesting depth: 1). Keep functions between 8 and 15 lines max with a single responsibility. Unify parallel data structures into single sources of truth, guarantee branch immutability, and route every fallible operation through AppError or the error store.
