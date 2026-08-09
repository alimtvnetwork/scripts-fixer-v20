# Code Quality Overhaul

## Goal
Implement a query wrapper for fetching data that explicitly logs failures and uses `isFail` booleans. Ensure no magic strings are used and typescript union strings are converted to Enums with `Type` suffix.

## Tasks
- [x] Create/update `src/utils/query-wrapper.ts` to return `isFail` and `status` (`StatusType`).
- [x] Refactor `src/pages/Settings.tsx` to use the new `safeQuery` interface and explicit `isFail === false` checks instead of inverted success booleans.
- [x] Document the changes in `.lovable/memory/features/10-code-quality-enums-query.md`.
- [x] Run vitest to ensure tests pass.
- [x] Check build.
- [x] Commit changes.
- [ ] Push changes.
