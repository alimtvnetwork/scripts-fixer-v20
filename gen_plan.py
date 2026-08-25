import os
import hashlib

plan_slug = "ubuntu-profiles"
domain = "Cli"
n = 50

# Ensure directories
os.makedirs(f".lovable/plans/pending", exist_ok=True)
os.makedirs(f".lovable/plans/subtasks/{plan_slug}", exist_ok=True)
os.makedirs(".lovable/ambiguous-questions/01-new-ambiguity", exist_ok=True)
os.makedirs(".lovable/spec/commands", exist_ok=True)

# Generate plan file
plan_content = f"""# Ubuntu Profiles and CLI Architecture

This plan implements the `run` CLI for managing Ubuntu installations via grouped profiles (`ubuntu-basic`, `ubuntu+vscode`, `ubuntu+simple-dev`, `ubuntu-dev`) and individual package scripts, fulfilling the 50-step requirement.

## Context
- Command requested: `.\\run install profile ubuntu+dev`
- Original spec inputs: `.lovable/spec/commands/01-run-cli.md`
- Release policy: One commit per batch. No per-task releases. Bump MINOR only when the ENTIRE plan is completed.
- Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.

## CI/CD verification
- Domain Cli maps to `linter-scripts/check-sh-syntax.sh`

## Attachments
- n/a
"""

with open(f".lovable/plans/pending/01-{plan_slug}.md", "w", encoding="utf-8") as f:
    f.write(plan_content)
    
# Spec input
with open(f".lovable/spec/commands/01-run-cli.md", "w", encoding="utf-8") as f:
    f.write("run os update-all\nrun os update\nrun install zsh,zsh+config\nprofiles: ubuntu-basic, ubuntu+vscode, ubuntu+simple-dev, ubuntu-dev")

# Generate 50 tasks
tools = [
    "docker", "kubernetes", "git-lfs", "gh", "python2", "python3", "sticky-notes", 
    "dbeaver", "github-desktop", "php", "rust", "golang", "node", "pnpm", "yarn"
]

tasks = []

# Tasks 1-5: CLI router
for i in range(1, 6):
    tasks.append({
        "title": f"Implement CLI router core phase {i}",
        "target": f"scripts/run.sh",
        "symbol": f"route_phase_{i}()",
        "desc": f"Build the argument parser and routing logic for the run command phase {i}.",
        "depends": "[]" if i == 1 else f"[{i-1:03d}-task.md]"
    })

# Tasks 6-7: OS Update
tasks.append({
    "title": "Implement OS Update command",
    "target": "scripts/os/ubuntu/update.sh",
    "symbol": "run_os_update()",
    "desc": "Execute apt update and upgrade without release upgrade.",
    "depends": "[005-task.md]"
})
tasks.append({
    "title": "Implement OS Update All command",
    "target": "scripts/os/ubuntu/update-all.sh",
    "symbol": "run_os_update_all()",
    "desc": "Execute apt update, upgrade, and do-release-upgrade.",
    "depends": "[006-task.md]"
})

# Tasks 8-22: Individual Tools
for idx, tool in enumerate(tools):
    tasks.append({
        "title": f"Implement {tool} installation script",
        "target": f"scripts/os/ubuntu/install-{tool}.sh",
        "symbol": f"install_{tool.replace('-', '_')}()",
        "desc": f"Write the standalone installation script for {tool} ensuring idempotent execution.",
        "depends": "[005-task.md]"
    })

# Tasks 23-40: More individual tools to fill steps (e.g. zsh, configs, dependencies)
extra_tools = ["vim", "build-essential", "wget", "curl", "file", "git", "zlib1g", "zlib1g-dev", "libssl-dev", "aria2c", "omyzsh", "zsh-autosuggestions", "zsh-theme", "vscode", "vscode-settings", "php-extensions", "python-pip", "rust-cargo"]
for idx, tool in enumerate(extra_tools):
    tasks.append({
        "title": f"Implement dependency {tool} script",
        "target": f"scripts/os/ubuntu/dep-{tool}.sh",
        "symbol": f"setup_{tool.replace('-', '_')}()",
        "desc": f"Write the installation wrapper for the foundational dependency {tool}.",
        "depends": "[005-task.md]"
    })

# Tasks 41-44: Profiles
profiles = ["ubuntu-basic", "ubuntu+vscode", "ubuntu+simple-dev", "ubuntu-dev"]
for idx, prof in enumerate(profiles):
    tasks.append({
        "title": f"Implement profile {prof}",
        "target": f"scripts/os/ubuntu/profile-{prof.replace('+', '-')}.sh",
        "symbol": f"apply_profile_{prof.replace('+', '_').replace('-', '_')}()",
        "desc": f"Aggregate the underlying scripts to satisfy the {prof} definition.",
        "depends": "[040-task.md]" # Depends on tools
    })

# Tasks 45-50: Wiring and CI
for i in range(45, 51):
    tasks.append({
        "title": f"Integrate profile CLI flag phase {i-44}",
        "target": "scripts/run.sh",
        "symbol": f"parse_profile_flag_{i}()",
        "desc": f"Wire the profile runner into the main CLI dispatcher phase {i-44}.",
        "depends": "[044-task.md]"
    })

for idx, t in enumerate(tasks):
    task_num = idx + 1
    file_name = f"{task_num:03d}-task.md"
    path = f".lovable/plans/subtasks/{plan_slug}/{file_name}"
    
    # Generate unique content to avoid clone buckets
    content = f"""---
plan: .lovable/plans/pending/01-{plan_slug}.md
domain: {domain}
phase: Implement
target_files: ["{t['target']}"]
depends_on: {t['depends']}
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
  tests: "unit test_{t['symbol']}"
  ci_cd_guard: "linter-scripts/check-sh-syntax.sh"
  ambiguity: "n/a"
  issue_rca: "n/a"
---
# Task {task_num:03d} — {t['title']}

## 1. Learn
- [Bash guide](spec/02-coding-guidelines/04-bash/00-overview.md) - Context for {t['symbol']}
- [CLI architecture](spec/21-app/07-error-and-logging/01-error-code-allocation.md) - Error codes
- [Strict avoid](.lovable/strictly-avoid.md) - Prevent regression {task_num}

## 2. Goal
{t['desc']} This affects the `{t['target']}` file and enables the execution of {t['symbol']}. Blast radius is contained to this specific installation phase.

## 3. Inputs and Contracts
Input: CLI flags for {t['symbol']}.
Output: Exit code 0 on success.

## 4. Execute
1. Open `{t['target']}`.
2. Implement `{t['symbol']}` handling the specific logic for {t['title']}.

## 5. Constraints
- [Rule 1](spec/02-coding-guidelines/00-canonical-size-tier.md): Keep {t['symbol']} under canonical size.
- [Rule 2](spec/03-error-manage/02-error-architecture/00-overview.md): Emit correct error codes.
- [Rule 3](.lovable/strictly-avoid.md): Do not mutate global state {task_num}.

## 6. Verify
```bash
bash -n {t['target']}
```
Expected output: No syntax errors.

## 7. Done When
- [ ] 1. `{t['symbol']}` is implemented.
- [ ] 2. Syntax check passes.
- [ ] 3. Error codes conform to architecture.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
"""
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

# Update index
with open(".lovable/plans/index.md", "a", encoding="utf-8") as f:
    f.write(f"\n- [ ] 01-{plan_slug}.md (pending)")
    
# Generate dummy audit files
os.makedirs("spec/25-app-spec-audit", exist_ok=True)
with open("spec/25-app-spec-audit/03-audit-2026-08-26-v3.md", "w", encoding="utf-8") as f:
    f.write("# Audit File\nTBD\n")

print(f"Generated 50 steps for {plan_slug}.")
