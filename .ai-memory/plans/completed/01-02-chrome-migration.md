# Plan: 02-chrome-migration

Status: pending

## Context
The goal is to export a Chrome profile from Windows and import it into Linux.
Release Policy:
Individual task runs NEVER release. No version bump, no changelog entry, no release-notes update, no root readme.md version pin on a per-task basis. A run that touches the version while sibling tasks are pending is auto-reject.
The release fires ONLY when the ENTIRE plan is finished, meaning every task and subtask of plan-file has moved out of .ai-memory/plans/pending/ into .ai-memory/plans/completed/ with Status: completed.

Execution model:
One step per run. Exactly one step is executed per run. Never batch two steps into a single run, even tiny ones, even "while I'm in the file".
Every step is standalone.
Self-loop after verify.
Concurrency ceiling, hard limits: at most 2 spawned agents at any one time, each agent runs at most 3 parallel threads.

## CI/CD verification
- cli jobs: `check-bash.sh`, `check-powershell.ps1`

## Attachments
- `assets/chrome-migration/spec.md`: User provided spec.

## Checklist
| Topic                            | Single source file                                                          | Duplicates found |
| canonical size tier              | 02-spec/02-coding-guidelines/00-canonical-size-tier.md                         | none             |
| boolean naming prefixes          | 02-spec/02-coding-guidelines/01-cross-language/02-boolean-principles/01-naming-prefixes.md      | none |
| boolean guards + extraction      | 02-spec/02-coding-guidelines/01-cross-language/02-boolean-principles/02-guards-and-extraction.md | none |
| boolean params + conditions      | 02-spec/02-coding-guidelines/01-cross-language/02-boolean-principles/03-parameters-and-conditions.md | none |
| boolean exemptions + api         | 02-spec/02-coding-guidelines/01-cross-language/02-boolean-principles/05-exemptions-and-api.md   | none |
| boolean quick reference          | 02-spec/02-coding-guidelines/01-cross-language/02-boolean-principles/04-quick-reference.md      | none |
| boolean flag methods             | 02-spec/02-coding-guidelines/01-cross-language/24-boolean-flag-methods.md      | none             |
| no negatives                     | 02-spec/02-coding-guidelines/01-cross-language/12-no-negatives.md              | none             |
| braces + nesting                 | 02-spec/02-coding-guidelines/01-cross-language/04-code-style/01-braces-and-nesting.md | none      |
| conditions + extraction (style)  | 02-spec/02-coding-guidelines/01-cross-language/04-code-style/02-conditions-and-extraction.md | none |
| blank lines + spacing            | 02-spec/02-coding-guidelines/01-cross-language/04-code-style/03-blank-lines-and-spacing.md | none |
| function + type size             | 02-spec/02-coding-guidelines/01-cross-language/04-code-style/04-function-and-type-size.md | none  |
| multi-line formatting            | 02-spec/02-coding-guidelines/01-cross-language/04-code-style/05-multi-line-formatting.md | none   |
| code-style checklist             | 02-spec/02-coding-guidelines/01-cross-language/04-code-style/07-checklist.md   | none             |
| nesting resolution               | 02-spec/02-coding-guidelines/01-cross-language/20-nesting-resolution-patterns.md | none           |
| cyclomatic complexity            | 02-spec/02-coding-guidelines/01-cross-language/06-cyclomatic-complexity.md     | none             |
| code mutation avoidance          | 02-spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md   | none             |
| strict typing                    | 02-spec/02-coding-guidelines/01-cross-language/13-strict-typing.md             | none             |
| null-pointer safety              | 02-spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md       | none             |
| naming + casing (keys)           | 02-spec/02-coding-guidelines/01-cross-language/11-key-naming-pascalcase.md     | none             |
| file/folder naming               | 02-spec/02-coding-guidelines/08-file-folder-naming/powershell.md               | none             |
| testing                          | 02-spec/02-coding-guidelines/01-cross-language/14-test-naming-and-structure.md | none             |
| error handling + codes           | 02-spec/03-error-manage/02-error-architecture/00-overview.md                   | none             |
| error code registry              | 02-spec/03-error-manage/03-error-code-registry/index.md                        | none             |
| logging + stack traces           | 02-spec/21-app/07-error-and-logging/02-logging-and-stack-traces.md             | none             |
| serialization/determinism        | 02-spec/21-app/04-json-contract/index.md                                       | none             |
| ci/cd verification               | 02-spec/12-cicd-pipeline-workflows/01-ci-pipeline.md                           | none             |
| ci guards                        | 02-spec/12-cicd-pipeline-workflows/03-reusable-ci-guards/00-overview.md        | none             |
| contract + e2e testing           | 02-spec/12-cicd-pipeline-workflows/13-contract-testing.md, 14-e2e-testing-pattern.md | none       |
| static analysis / sarif          | 02-spec/02-coding-guidelines/06-cicd-integration/01-sarif-contract.md          | none             |
