# Cursor Prompt Formatters (`23-cursor-prompts`)

Deterministic prompt transformation templates specifically adapted for Cursor IDE environments, resolving skill dependencies directly against `.cursor/skills/`.

## Directory Index

| # | Prompt File | Target Mode | Description | Canonical Successor Skill |
| :---: | :--- | :--- | :--- | :--- |
| **01** | [`01-mobile-letterly-cursor.md`](01-mobile-letterly-cursor.md) | Mobile Single-Line | Compact one-liner with `# High Priority Instruction:` | `execute-parent-task-with-n-steps-v6` |
| **02** | [`02-desktop-letterly-cursor.md`](02-desktop-letterly-cursor.md) | Desktop Structured | Voice dictation to structured instructions and V6 suffix | `execute-parent-task-with-n-steps-v6` |
| **03** | [`03-execute-n-steps-letterly-cursor.md`](03-execute-n-steps-letterly-cursor.md) | Execute N-Steps | Verbatim input capture with discrete action items and V6 | `execute-parent-task-with-n-steps-v6` |
| **04** | [`04-plan-letterly-cursor.md`](04-plan-letterly-cursor.md) | Planning Spec | Architectural planning directives with no-build rules | `plan-spec-steps-v2` |
| **05** | [`05-release-letterly-cursor.md`](05-release-letterly-cursor.md) | Minor Release (Letter U) | Minor release update ceremony directives | `minor-bump` |
| **06** | [`06-cicd-fix-release-letterly-cursor.md`](06-cicd-fix-release-letterly-cursor.md) | CI/CD Fix & Release | `gitmap pe -t` diagnosis, 4-part RCA, minor release | `ci-cd-fix-gitmap-release` |
| **07** | [`07-mobile-cicd-fix-letterly-cursor.md`](07-mobile-cicd-fix-letterly-cursor.md) | Mobile CI/CD Fix | Mobile prompt diagnosing via `gitmap pe -t` | `ci-cd-fix-gitmap-release` |
| **08** | [`08-run-letterly-cursor.md`](08-run-letterly-cursor.md) | Run Script | Run instructions via `./run.ps1` / `./run.sh` | `run` |
| **09** | [`09-execute-with-verification-letterly-cursor.md`](09-execute-with-verification-letterly-cursor.md) | Execute + Verify | Execute N-steps with retrospective AI verification | `execute-parent-task-with-n-steps-v6` |
| **10** | [`10-execute-with-release-letterly-cursor.md`](10-execute-with-release-letterly-cursor.md) | Execute + Release | Execute N-steps followed by CI check and release | `execute-parent-task-with-n-steps-v6` |
| **11** | [`11-git-pull-first-letterly-cursor.md`](11-git-pull-first-letterly-cursor.md) | Git Pull First | Directives ensuring `gitmap pull` runs first | `execute-parent-task-with-n-steps-v6` |
| **12** | [`12-muse-long-update-letterly-cursor.md`](12-muse-long-update-letterly-cursor.md) | Muse Long Update | Overnight execution with gitmap update and commits | `execute-parent-task-with-n-steps-v6` |
| **13** | [`13-muse-sleepy-letterly-cursor.md`](13-muse-sleepy-letterly-cursor.md) | Muse Sleepy Mode | Autopilot run with closest-choice ambiguity resolution | `execute-parent-task-with-n-steps-v6` |
| **14** | [`14-execute-parent-task-v7-letterly-cursor.md`](14-execute-parent-task-v7-letterly-cursor.md) | Execute V7 Engine | V7 engine (Option 1: Time-Restricted; 2: Unrestricted) | `execute-parent-task-with-n-steps-v7` |
| **15** | [`15-plan-parent-task-letterly-cursor.md`](15-plan-parent-task-letterly-cursor.md) | Plan Blueprint | Planning spec and pending backlog task | `plan-spec-steps-v2` |
| **16** | [`16-plan-steps-by-groups-letterly-cursor.md`](16-plan-steps-by-groups-letterly-cursor.md) | Plan Steps Groups | Modular blueprint with zero code execution | `plan-steps-by-groups` |
| **17** | [`17-plan-coding-guideline-audit-letterly-cursor.md`](17-plan-coding-guideline-audit-letterly-cursor.md) | Guideline Audit | Compliance audit, scorecard, remediation backlog | `plan-coding-guideline-audit` |
| **18** | [`18-cursor-manager-memory-and-instruction.md`](18-cursor-manager-memory-and-instruction.md) | Manager: plan | Cursor manager: pull, push, spec, plan, instructions | `ai-instruction-packet` |
| **19** | [`19-cursor-verify-and-replan.md`](19-cursor-verify-and-replan.md) | Manager: verify | Verifies cited lines, authors plan & instructions | `ai-instruction-packet` |

## Core Invariants

1. **Zero Conversational Filler:** Never output "Certainly! Here is your output:".
2. **Lossless Verbatim Capture:** Never drop specific technical flags, file paths, or commands from input.
3. **Mandatory Canonical Skill Triggers:** Every formatted prompt must conclude with its designated canonical skill trigger: `[<skill-name>](directory;.cursor/skills/<skill-name>)`.
4. **Dual-Item Agent Invocation:** All execution formatters enforce primary execution engine (`execute-parent-task-with-n-steps-v6` or `v7`) and bug remediation (`fix-with-rca`).
5. **Immediate Execution Without Confirmation:** Under `## Additional Instructions`, all execution formatters enforce immediate autonomous execution post-planning without asking user confirmation.
6. **Standard Cursor Suffix:** All formatters in this directory strictly carry the `-letterly-cursor.md` file suffix.
7. **Strict Relative Git Paths Only:** Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute filesystem paths.
8. **Decoupled Execution Engine:** Prompts remain generic and compact (< 5550 chars); execution lifecycle mechanics and concurrency are offboarded to invoked skills.
9. **Heatmap Telemetry & Write Collision Mandate:** All formatters embed GitMap Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`) to track file touches and prevent write collisions.
