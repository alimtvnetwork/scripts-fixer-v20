---
plan: .lovable/plans/pending/01-ubuntu-profiles.md
domain: Cli
phase: Implement
target_files: ["scripts/run.sh"]
depends_on: [044-task.md]
citations:
  app_spec: "spec/21-app/04-json-contract/02-section-and-asset-schema.md §Section"
  canonical_size: "spec/02-coding-guidelines/00-canonical-size-tier.md"
  language_guideline: "spec/02-coding-guidelines/04-bash/00-overview.md"
  boolean_styling: "spec/02-coding-guidelines/01-cross-language/02-boolean-principles/02-guards.md"
  folder_naming: "spec/02-coding-guidelines/08-file-folder-naming/04-bash.md"
  error_architecture: "spec/03-error-manage/02-error-architecture/00-overview.md"
  error_codes: "spec/21-app/07-error-and-logging/01-error-code-allocation.md"
  logging_traces: "spec/21-app/07-error-and-logging/02-logging-and-stack-traces.md"
  response_envelope: "spec/21-app/07-error-and-logging/03-response-envelope.md"
  golden_fixture: "spec/21-app/fixtures/example.json"
  strictly_avoid: ".lovable/strictly-avoid.md"
  database: "n/a - no db"
  ui_surface: "n/a - cli"
  tests: "unit test_parse_profile_flag_45()"
  ci_cd_guard: "linter-scripts/check-sh-syntax.sh"
  ambiguity: "n/a"
  issue_rca: "n/a"
---
# Task 045 — Integrate profile CLI flag phase 1

## 1. Learn
- [Bash guide](spec/02-coding-guidelines/04-bash/00-overview.md) - Context for parse_profile_flag_45()
- [CLI architecture](spec/21-app/07-error-and-logging/01-error-code-allocation.md) - Error codes
- [Strict avoid](.lovable/strictly-avoid.md) - Prevent regression 45

## 2. Goal
Wire the profile runner into the main CLI dispatcher phase 1. This affects the `scripts/run.sh` file and enables the execution of parse_profile_flag_45(). Blast radius is contained to this specific installation phase.

## 3. Inputs and Contracts
Input: CLI flags for parse_profile_flag_45().
Output: Exit code 0 on success.

## 4. Execute
1. Open `scripts/run.sh`.
2. Implement `parse_profile_flag_45()` handling the specific logic for Integrate profile CLI flag phase 1.

## 5. Constraints
- [Rule 1](spec/02-coding-guidelines/00-canonical-size-tier.md): Keep parse_profile_flag_45() under canonical size.
- [Rule 2](spec/03-error-manage/02-error-architecture/00-overview.md): Emit correct error codes.
- [Rule 3](.lovable/strictly-avoid.md): Do not mutate global state 45.

## 6. Verify
```bash
bash -n scripts/run.sh
```
Expected output: No syntax errors.

## 7. Done When
- [ ] 1. `parse_profile_flag_45()` is implemented.
- [ ] 2. Syntax check passes.
- [ ] 3. Error codes conform to architecture.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
