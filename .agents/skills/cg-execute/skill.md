---
name: cg-execute
description: Execute coding guidelines enforcement, guard clause flattening, boolean standardization, and micro-function refactoring across repository scripts.
---

# Coding Guidelines Enforcement (`cg-execute`)

Audits and enforces zero-tolerance repository coding guidelines across PowerShell, Bash, Python, and TypeScript.

## Core Directives
1. **Guard Clauses Over Nesting**: Eliminate nested `if` statements. Replace with guard clauses and early returns. Indentation depth must be ≤ 1 level for conditional branching.
2. **Micro-Functions (Target ≤ 8 Lines)**: Keep execution logic atomic and decomposed into modular helpers.
3. **Strict Boolean Standards**: All booleans, parameters, and flags must use `is*` or `has*` prefixes (banned: `can`, `should`, `was`, negative flags).
4. **CODE RED Logging**: Every file/path error must log the exact absolute path and raw failure reason via `Write-FileError` or `log_file_error`.
5. **No Magic Strings or Numbers**: Centralize constants, status indicators, and configuration keys.
6. **Windows Nginx Path Normalization**: Strictly normalize paths in Nginx `.conf` files to forward slashes `/`.
