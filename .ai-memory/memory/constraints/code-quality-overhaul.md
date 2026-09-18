---
name: Code Quality Overhaul (Enums, State Checks, Query Wrappers)
description: Global requirements for Enums with Type suffix, explicit isFail booleans, query wrappers, and removing magic strings.
type: constraint
---

# Code Quality Overhaul

As of v0.37.0, all codebase additions (especially TypeScript/React, Python, and PHP) must adhere to the following strict rules:

1. **Enums over String Unions**: Do NOT use string union types (e.g. `'pass' | 'fail'`). You must use explicit `enum` types, and EVERY enum must end with the suffix `Type` (e.g., `enum StatusType { Pass = 'pass', Fail = 'fail' }`).
2. **Explicit State Checks**: Never invert success booleans (e.g. `!response.isSuccess`). Always explicitly check positive states, or use an explicit failure property like `response.isFail`.
3. **No Magic Strings/Numbers**: Do not embed magic strings or numbers inline. Extract them to named constants. The only exception is when they are directly used in a logger statement (e.g., `Logger.info("Action started")`).
4. **Query Wrappers**: Do not scatter `try/catch` handlers for queries. Use a centralized query wrapper (e.g., `safeQuery` in TS) to automatically log errors according to error-management specs.
