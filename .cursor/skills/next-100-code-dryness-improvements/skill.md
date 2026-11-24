---
name: next-100-code-dryness-improvements
description: "Autonomously scan, audit, discover, and document 100 concrete code dryness, anti-duplication, and structural hygiene improvements across 10 DRY rule families using a 10-field specification schema, GitMap streaming search, and pending plan enqueueing."
---

# Next 100 Code Dryness Improvements

> **Invocation:** `@[next-100-code-dryness-improvements](directory;.agents/skills/next-100-code-dryness-improvements)`

Source Prompt: `01-prompts/30-improvements/10-next-100-code-dryness-and-library-extraction.md`

This skill governs the systematic, autonomous discovery, technical specification, and backlog enqueueing of exactly 100 high-impact code dryness (DRY), anti-duplication, and structural hygiene improvements across the repository.

## When to Use

- When eliminating duplicated logic, functions, handlers, and UI patterns across the codebase.
- When centralizing enum definitions and eradicating magic strings or raw literals.
- When flattening nested conditionals and simplifying complex control flows with early returns.
- When decomposing bloated functions (>15 lines) into pure single-responsibility utilities.
- When invoked via `[/next-100-code-dryness-improvements](file;.agents/skills/next-100-code-dryness-improvements)` or the Next Breakdown dropdown menu.

## The 10 Code Dryness Rule Families

1. **Family 01: Function Logic Duplication & Utility Extraction**: Extract identical/near-identical logic into shared domain utilities; cap functions to 8–15 lines.
2. **Family 02: Magic String Eradication & Enum Centralization**: Eliminate raw strings/numbers into strongly-typed enums (`PascalCase`, `Type` suffix).
3. **Family 03: Nested Conditionals & Guard Clause Inversion**: Flatten deep `if/else` ladders; enforce max nesting depth 1 with positive boolean flags.
4. **Family 04: UI Component Logic Duplication & Custom Hook Extraction**: Consolidate repeated React UI widgets, styling patterns, and lifecycle logic.
5. **Family 05: Monadic Error Envelope Unification & Swallowed Error Elimination**: Route every fallible operation through AppError / error store; zero swallowed errors.
6. **Family 06: Parallel Data Structures & Single Source of Truth**: Merge parallel maps, arrays, and duplicate stores into normalized single sources of truth.
7. **Family 07: Parameter Struct Consolidation & Signature Slimming**: Replace functions taking >3 parameters with dedicated parameter structs.
8. **Family 08: Database Query & Repository Pattern Centralization**: Wrap SQLite queries and ORM logic behind clean repository interfaces.
9. **Family 09: Pure Function Construction & Immutability Guarantees**: Eliminate in-place mutations of shared objects across conditional branches.
10. **Family 10: Polyglot Standard Library & Framework Helper Adoption**: Replace ad-hoc reinvented logic with standard library and existing framework helpers.
