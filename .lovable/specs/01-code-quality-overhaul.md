# Code Quality Overhaul Spec

## Overview
This spec outlines the mandatory coding practices implemented in v0.37.0+ for all TypeScript, Python, and PHP code within the repository. 

## Requirements

### 1. Enums over String Unions
- TypeScript string unions (`type Status = 'pass' | 'fail'`) are strictly prohibited.
- All predefined text options must use `enum`.
- Every Enum must be named with the suffix `Type` (e.g., `StatusType`, `ActionType`).

### 2. Explicit State Checks
- Never invert success booleans (e.g., `!response.isSuccess`).
- Use explicit properties for failure (e.g., `response.isFail`) or explicitly check positive states.

### 3. Magic Strings and Numbers
- Magic strings and numbers are strictly prohibited anywhere in the codebase.
- Exception: Magic strings/numbers are allowed ONLY when directly used in a logger statement.
- When used in a logger, the types/comments must mention this usage.

### 4. Query Wrappers with Automated Error Logging
- All queries in PHP, Python, and TypeScript must be routed through a dedicated wrapper function.
- The wrapper is responsible for automatically logging failures in accordance with the `spec/error-manage/` guidelines.
- Scattered `try/catch` logic solely for query failure logging is replaced by the wrapper.
