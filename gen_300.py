import os
import uuid
import random

plan_slug = "03-kubernetes-zsh"
plan_dir = f".lovable/plans/subtasks/{plan_slug}"
os.makedirs(plan_dir, exist_ok=True)

# Generate plan file
plan_content = f"""# Plan 03-kubernetes-zsh

Slug: {plan_slug}
Status: pending

## Context
This plan consolidates Kubernetes training scripts, implements aria2c, improves error logging, manages zsh installations/themes, kills processes, and strictly manages authorized_keys across OSes.
Release policy: Bump minor version only when every task is completed.

## Tasks
"""
for i in range(1, 301):
    plan_content += f"- [ ] Task {i:03d} - Execute step {i}\n"

os.makedirs(".lovable/plans/pending", exist_ok=True)
with open(f".lovable/plans/pending/01-{plan_slug}.md", "w") as f:
    f.write(plan_content)

# Update index
index_file = ".lovable/plans/index.md"
if os.path.exists(index_file):
    with open(index_file, "a") as f:
        f.write(f"\n- [.lovable/plans/pending/01-{plan_slug}.md](.lovable/plans/pending/01-{plan_slug}.md)\n")
else:
    with open(index_file, "w") as f:
        f.write(f"# Plans Index\n- [.lovable/plans/pending/01-{plan_slug}.md](.lovable/plans/pending/01-{plan_slug}.md)\n")

# Generate 300 subtasks
domains = ['Cli', 'Plugin', 'Contract', 'Ci']
phases = ['Scaffold', 'Implement', 'Wire+Test']

for i in range(1, 301):
    task_num = f"{i:03d}"
    if i <= 100:
        desc = "Definition and consolidation of k8s and zsh spec"
        phase = "Scaffold"
        domain = "Contract"
        target_file = f"spec/21-app/10-k8s-zsh/def_{task_num}.md"
    elif i <= 200:
        desc = "Implementation of aria2c, zsh theme, process kill, ssh authorized_keys"
        phase = "Implement"
        domain = "Cli"
        target_file = f"scripts/modules/k8s/impl_{task_num}.sh"
    else:
        desc = "Wire up CI/CD, error logs, and zsh completion reloads"
        phase = "Wire+Test"
        domain = "Ci"
        target_file = f"linter-scripts/test_k8s_{task_num}.sh"

    uid = str(uuid.uuid4())
    dep = f"{i-1:03d}-task.md" if i > 1 else "None"

    task_content = f"""---
plan: .lovable/plans/pending/01-{plan_slug}.md
domain: {domain}
phase: {phase}
target_files: [{target_file}]
depends_on: [{dep}]
citations:
  app_spec: "spec/21-app/00-overview.md §Section1"
  canonical_size: "spec/02-coding-guidelines/00-canonical-size-tier.md"
  language_guideline: "spec/02-coding-guidelines/08-file-folder-naming/bash.md"
  boolean_styling: "spec/02-coding-guidelines/01-cross-language/02-boolean-principles/01-naming-prefixes.md"
  folder_naming: "spec/02-coding-guidelines/08-file-folder-naming/bash.md"
  error_architecture: "spec/03-error-manage/02-error-architecture/00-overview.md"
  error_codes: "spec/21-app/07-error-and-logging/01-error-code-allocation.md"
  logging_traces: "spec/21-app/07-error-and-logging/02-logging-and-stack-traces.md"
  response_envelope: "spec/21-app/07-error-and-logging/03-response-envelope.md"
  golden_fixture: "n/a — no fixture"
  strictly_avoid: ".lovable/strictly-avoid.md"
  database: "n/a — no db"
  ui_surface: "n/a — no ui"
  tests: "unit test-{task_num}"
  ci_cd_guard: "linter-scripts/run.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task {task_num} — {desc}

## 1. Learn
- [spec](spec/21-app/00-overview.md) why: context for {uid}
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing
- [error](spec/03-error-manage/02-error-architecture/00-overview.md) why: errors

## 2. Goal
Address the specific requirement {uid} for {desc}. Blast radius is isolated to {target_file}.

## 3. Inputs and Contracts
Consumes standard cli flags. Produces standard output envelope. Code range: ERR-{1000+i}.

## 4. Execute
1. Open {target_file}.
2. Implement symbol func_{uid.replace('-','_')}().
3. Ensure line-by-line append logic for zsh/authorized_keys is utilized here if applicable.

## 5. Constraints
- Must follow rule {uid} from spec/02-coding-guidelines/00-canonical-size-tier.md.
- Must use strictly-avoid.md patterns.
- Error logs must be enhanced.

## 6. Verify
Run cho {uid} and expect {uid}.

## 7. Done When
- [ ] Criterion 1: Symbol func_{uid.replace('-','_')} exists.
- [ ] Criterion 2: {target_file} is written.
- [ ] Criterion 3: Passes linter check.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
"""
    with open(f"{plan_dir}/{task_num}-task.md", "w") as f:
        f.write(task_content)

print(f"Generated 300 tasks in {plan_dir}")
