---
name: cg-error-management
description: >-
  Autonomously audits, refactors, and validates repository-wide error management against 02-spec/03-error-manage/ using AppError wrappers, universal response envelopes, and CI linters.
---

# Error Management & Architecture Coding Guidelines (`cg-error-management`)

This skill provides autonomous audit, refactoring, and validation of repository-wide error handling based on `02-spec/03-error-manage/` and `.lovable/coding-guidelines.md`.

## Core Invariants

1. **No Bare Panics or Bare Exits**: Zero calls to `panic("...")`, `panic(err)`, or `os.Exit(...)` outside the central dispatcher (`cliexit.HandleError`).
2. **Context-Rich `*appfault.AppError` Wrappers**: All errors MUST use structured `*appfault.AppError` from `04-code/golang/pkg/appfault` and be wrapped with `Op`, `Code`, `Type`, `Severity`, `Creator`, `Message`, `Ctx`, and `Cause`. Raw standard library `error` returns are strictly prohibited.
3. **Single Result Container Return Types (`pkg/appfault`) & `types.go` Mandate**:
   - Multi-value returns returning errors (`(map[K]V, error)`, `([]T, error)`, `(T, error)`) are strictly banned.
   - Functions returning maps MUST return `appfault.ResultMap[K, V]` (or domain alias).
   - Functions returning slices MUST return `appfault.ResultSlice[T]` (or domain alias).
   - Functions returning single values MUST return `appfault.Result[T]` (or domain alias).
   - Functions with side-effects only MUST return `*appfault.AppError`.
   - **Mandatory `types.go` Single Reusable Type Definition:** All domain payload structs (e.g. `ScheduleExportBundle`) and repeated generic Result envelopes (`type ScheduleExportBundleResult = result.ResultSlice[ScheduleExportBundle]`) MUST be defined in a dedicated `types.go` file within the package as a single reusable named type everywhere. Never declare ad-hoc unexported structs or raw generic Result envelopes inline in implementation files.
   - Result struct fields MUST use affirmative prefixes (e.g. `isDefined bool`, TOTAL BAN on bare `defined bool`).
4. **Pointer-Attached Null Safety & Method Composition**:
   - All Result inspection methods MUST be attached to pointer receivers (`(r *Result[T])`, `(rs *ResultSlice[T])`, `(rm *ResultMap[K, V])`).
   - Total ban on value receivers on Result checking methods to eliminate nil pointer dereference panics.
   - **Method Composition Mandate:** Inspection methods MUST delegate to and compose existing methods (`r.IsFailure()`, `r.IsSuccess()`, `r.Count()`) rather than repeating raw pointer/error checks (`r == nil || r.err != nil`).
   - Line-1 `if r == nil` guards MUST return safe canonical defaults without crashing:
     - `IsFailure()` -> `true`
     - `IsSuccess()` -> `false`
     - `Count()` -> `0`
     - `IsEmpty()` -> `true`
     - `HasRecord()` / `HasRecords()` -> `false`
     - `IsDefined()` -> `false`
     - `IsCountOtherThan(n)` -> `true`
     - `AppError()` / `Fault()` -> `nil`
5. **The 4 Core Predicate Methods**:
   - `res.IsCountOtherThan(number int) bool`: Returns `true` if operation failed (or nil receiver) OR `Count() != number`. Replaces compound checks like `err != nil || len(...) != N` or `IsFailure() || Count() != N`.
   - `res.IsEmpty() bool`: Returns `true` if collection has 0 elements, payload data is empty/null/zero, or receiver is nil.
   - `res.HasRecord() bool` (and alias `res.HasRecords() bool`): Returns `true` if operation succeeded (no error) AND has **more than 0 records** (`Count() > 0 && !IsFailure()`).
   - `res.IsDefined() bool`: Returns `true` if operation succeeded (no error) AND `recordCount > 0` (or non-null/non-empty data `T`). Delegates error validation to `IsSuccess()`/`IsFailure()`.
6. **Universal Response Envelope**: All API endpoints return `{ "data": ..., "errors": [...], "meta": ... }`.
7. **Never Swallow Errors**: Every catch block and error return must be recorded and handled explicitly.
8. **Targeted Verification**: Continuous verification via `python linter-scripts/check-error-management.py <files>`. DO NOT run the full CI/CD pipeline runner (`06-cicd-local-runner.py`) during routine fixes.
9. **No Releases**: Strictly forbidden from bumping versions or cutting releases at the end of this task.
10. **Atomic Change Tracking**: Append all modified files to `.lovable/temp/recent-file-changes.json` under lock (`python 03-ai-scripts/33-test-inventory-generator.py --record <files...>`), mapping to associated tests in `.lovable/test-inventory.json`.

## Routine Execution Policy

- **NO FULL CI/CD RUNNER (Strict Policy):** DO NOT run `python 03-ai-scripts/06-cicd-local-runner.py` during routine coding guideline execution turns or micro-batch loops. Running the heavy 28-38 gate pipeline across the entire repository wastes massive amounts of time. Verify code strictly using targeted file-level linters / autofixers on the specific modified files.
