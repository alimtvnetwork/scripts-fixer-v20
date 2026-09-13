# Antigravity Rule: Coding Guidelines

> **Version:** 2.3.0  
> **Status:** Active Rule

1. **Strict Boolean Standard**: Variables, parameters, and return booleans must use `is*` or `has*` only (`can`, `should`, `was`, negative booleans are strictly banned).
2. **Micro-Functions**: Functions must be ≤ 8 lines of execution logic (15 lines max absolute cap).
3. **No Nested `if` Statements**: Guard clauses only; maximum one level of conditional indentation.
4. **Vertical Line Gaps**: Mandatory blank lines before `if`, after `}`, before `return`, and around multiline struct/object calls.
5. **Parameter Structs**: Banned loose >2-3 parameters; pass typed `*Params` structs or configuration hashtables/objects.
6. **No Bare Void in Go / Typed Returns**: Functions must return explicit `Result[T]` or typed error envelopes (`*appfault.AppError`).
7. **5–8 Files Micro-Batching**: All refactors and code tasks broken into bounded batches of 5–8 files.
8. **CODE RED (File/Path Errors)**: Always log exact absolute file path + raw failure reason via `Write-FileError` or `log_file_error`.
9. **Forward-Slash Path Normalization**: Windows Nginx configuration paths must strictly use forward slashes `/`.
10. **Zero `any` Policy**: Strict typing in TypeScript and schema validation for JSON configs.
