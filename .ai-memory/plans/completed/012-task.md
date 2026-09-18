---
plan: .ai-memory/plans/pending/01-ubuntu-profiles.md
domain: Cli
phase: Implement
target_files: ["scripts/os/ubuntu/install-python2.sh"]
depends_on: [005-task.md]
citations:
  app_spec: "02-spec/21-app/04-json-contract/02-section-and-asset-schema.md §Section"
  canonical_size: "02-spec/02-coding-guidelines/00-canonical-size-tier.md"
  language_guideline: "02-spec/02-coding-guidelines/04-bash/00-overview.md"
  boolean_styling: "02-spec/02-coding-guidelines/01-cross-language/02-boolean-principles/02-guards.md"
  folder_naming: "02-spec/02-coding-guidelines/08-file-folder-naming/04-bash.md"
  error_architecture: "02-spec/03-error-manage/02-error-architecture/00-overview.md"
  error_codes: "02-spec/21-app/07-error-and-logging/01-error-code-allocation.md"
  logging_traces: "02-spec/21-app/07-error-and-logging/02-logging-and-stack-traces.md"
  response_envelope: "02-spec/21-app/07-error-and-logging/03-response-envelope.md"
  golden_fixture: "02-spec/21-app/fixtures/example.json"
  strictly_avoid: ".ai-memory/strictly-avoid.md"
  database: "n/a - no db"
  ui_surface: "n/a - cli"
  tests: "unit test_install_python2()"
  ci_cd_guard: "linter-scripts/check-sh-syntax.sh"
  ambiguity: "n/a"
  issue_rca: "n/a"
---
# Task 012 — Implement python2 installation script

## 1. Learn
- [Bash guide](02-spec/02-coding-guidelines/04-bash/00-overview.md) - Context for install_python2()
- [CLI architecture](02-spec/21-app/07-error-and-logging/01-error-code-allocation.md) - Error codes
- [Strict avoid](.ai-memory/strictly-avoid.md) - Prevent regression 12

## 2. Goal
Write the standalone installation script for python2 ensuring idempotent execution. This affects the `scripts/os/ubuntu/install-python2.sh` file and enables the execution of install_python2(). Blast radius is contained to this specific installation phase.

## 3. Inputs and Contracts
Input: CLI flags for install_python2().
Output: Exit code 0 on success.

## 4. Execute
1. Open `scripts/os/ubuntu/install-python2.sh`.
2. Implement `install_python2()` handling the specific logic for Implement python2 installation script.

## 5. Constraints
- [Rule 1](02-spec/02-coding-guidelines/00-canonical-size-tier.md): Keep install_python2() under canonical size.
- [Rule 2](02-spec/03-error-manage/02-error-architecture/00-overview.md): Emit correct error codes.
- [Rule 3](.ai-memory/strictly-avoid.md): Do not mutate global state 12.

## 6. Verify
```bash
bash -n scripts/os/ubuntu/install-python2.sh
```
Expected output: No syntax errors.

## 7. Done When
- [ ] 1. `install_python2()` is implemented.
- [ ] 2. Syntax check passes.
- [ ] 3. Error codes conform to architecture.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
