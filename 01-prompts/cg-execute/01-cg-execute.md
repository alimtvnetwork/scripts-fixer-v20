# Coding Guidelines Enforcement Prompt: `cg-execute`

> **Version:** 2.2.0  
> **Scope:** Automatic auditing and refactoring for guideline compliance.

---

## Directives
1. Verify function length ≤ 8 lines.
2. Verify absence of nested `if` statements (guard clauses only).
3. Verify strict `is`/`has` boolean variable prefixing.
4. Verify CODE RED exact file path and failure reason reporting.
5. Verify Windows Nginx forward-slash path normalization.
