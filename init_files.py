import os
import pathlib

files = [
    "spec/02-coding-guidelines/00-canonical-size-tier.md",
    "spec/02-coding-guidelines/01-cross-language/02-boolean-principles/01-naming-prefixes.md",
    "spec/02-coding-guidelines/01-cross-language/02-boolean-principles/02-guards-and-extraction.md",
    "spec/02-coding-guidelines/01-cross-language/02-boolean-principles/03-parameters-and-conditions.md",
    "spec/02-coding-guidelines/01-cross-language/02-boolean-principles/05-exemptions-and-api.md",
    "spec/02-coding-guidelines/01-cross-language/02-boolean-principles/04-quick-reference.md",
    "spec/02-coding-guidelines/01-cross-language/24-boolean-flag-methods.md",
    "spec/02-coding-guidelines/01-cross-language/12-no-negatives.md",
    "spec/02-coding-guidelines/01-cross-language/04-code-style/01-braces-and-nesting.md",
    "spec/02-coding-guidelines/01-cross-language/04-code-style/02-conditions-and-extraction.md",
    "spec/02-coding-guidelines/01-cross-language/04-code-style/03-blank-lines-and-spacing.md",
    "spec/02-coding-guidelines/01-cross-language/04-code-style/04-function-and-type-size.md",
    "spec/02-coding-guidelines/01-cross-language/04-code-style/05-multi-line-formatting.md",
    "spec/02-coding-guidelines/01-cross-language/04-code-style/07-checklist.md",
    "spec/02-coding-guidelines/01-cross-language/20-nesting-resolution-patterns.md",
    "spec/02-coding-guidelines/01-cross-language/06-cyclomatic-complexity.md",
    "spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md",
    "spec/02-coding-guidelines/01-cross-language/13-strict-typing.md",
    "spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md",
    "spec/02-coding-guidelines/01-cross-language/11-key-naming-pascalcase.md",
    "spec/02-coding-guidelines/08-file-folder-naming/powershell.md",
    "spec/02-coding-guidelines/08-file-folder-naming/bash.md",
    "spec/02-coding-guidelines/01-cross-language/14-test-naming-and-structure.md",
    "spec/03-error-manage/02-error-architecture/00-overview.md",
    "spec/03-error-manage/03-error-code-registry/index.md",
    "spec/21-app/07-error-and-logging/02-logging-and-stack-traces.md",
    "spec/21-app/04-json-contract/index.md",
    "spec/12-cicd-pipeline-workflows/01-ci-pipeline.md",
    "spec/12-cicd-pipeline-workflows/03-reusable-ci-guards/00-overview.md",
    "spec/12-cicd-pipeline-workflows/13-contract-testing.md",
    "spec/12-cicd-pipeline-workflows/14-e2e-testing-pattern.md",
    "spec/02-coding-guidelines/06-cicd-integration/01-sarif-contract.md",
    "spec/21-app/07-error-and-logging/01-error-code-allocation.md",
    "spec/21-app/07-error-and-logging/03-response-envelope.md",
    "spec/21-app/fixtures/chrome-profile-export.example.json",
    "spec/21-app/fixtures/conventions.md",
    ".lovable/strictly-avoid.md",
    "linter-scripts/check-powershell.ps1",
    "linter-scripts/check-bash.sh"
]

for f in files:
    path = pathlib.Path(f)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('w', encoding='utf-8') as out:
        out.write(f"# {path.stem}\n\n## Section\n\nContent here.\n")
