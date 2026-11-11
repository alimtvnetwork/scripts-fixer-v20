# Letterly Prompt Formatters (`22-letterly`)

Deterministic prompt transformation templates designed to ingest raw voice-dictated user transcripts from Letterly (mobile and desktop) and format them into rigorous, non-negotiable agent prompts.

## Directory Index

| # | Prompt File | Target Mode | Description | Canonical Successor Skill |
| :---: | :--- | :--- | :--- | :--- |
| **01** | [`01-mobile-letterly.md`](01-mobile-letterly.md) | Mobile Single-Line | Compact one-liner starting with `# High Priority Instruction:` | `execute-parent-task-with-n-steps-v6` |
| **02** | [`02-desktop-letterly.md`](02-desktop-letterly.md) | Desktop Structured | Formats voice dictation into high-priority instructions and V6 suffix | `execute-parent-task-with-n-steps-v6` |
| **03** | [`03-execute-n-steps-letterly.md`](03-execute-n-steps-letterly.md) | Execute N-Steps | Verbatim input capture with discrete action items and V6 engine | `execute-parent-task-with-n-steps-v6` |
| **04** | [`04-plan-letterly.md`](04-plan-letterly.md) | Planning Spec | Architectural planning directives with no-build rules | `plan-spec-steps-v2` |
| **05** | [`05-release-letterly.md`](05-release-letterly.md) | Minor Release (Letter U) | Minor release update ceremony directives | `minor-bump` |
| **06** | [`06-cicd-fix-release-letterly.md`](06-cicd-fix-release-letterly.md) | CI/CD Fix & Release | `gitmap pe -t` telemetry diagnosis, 4-part RCA, and minor release | `ci-cd-fix-gitmap-release` |
| **07** | [`07-mobile-cicd-fix-letterly.md`](07-mobile-cicd-fix-letterly.md) | Mobile CI/CD Fix | Mobile prompt diagnosing via `gitmap pe -t` and triggering release | `ci-cd-fix-gitmap-release` |
| **08** | [`08-run-letterly.md`](08-run-letterly.md) | Run Script | Run instructions via `./run.ps1` / `./run.sh` with auto install | `run` |
| **09** | [`09-execute-with-verification-letterly.md`](09-execute-with-verification-letterly.md) | Execute + Verification | Execute N-steps with mandatory retrospective AI verification | `execute-parent-task-with-n-steps-v6` |
| **10** | [`10-execute-with-release-letterly.md`](10-execute-with-release-letterly.md) | Execute + Release | Execute N-steps followed directly by green CI and minor release | `execute-parent-task-with-n-steps-v6` |
| **11** | [`11-git-pull-first-letterly.md`](11-git-pull-first-letterly.md) | Git Pull First | Pull-first execution directives ensuring `gitmap pull` runs first | `execute-parent-task-with-n-steps-v6` |
| **12** | [`12-muse-long-update-letterly.md`](12-muse-long-update-letterly.md) | Muse Long Update | Overnight execution with gitmap update first and pragmatic commits | `execute-parent-task-with-n-steps-v6` |
| **13** | [`13-muse-sleepy-letterly.md`](13-muse-sleepy-letterly.md) | Muse Sleepy Mode | Autopilot execution with closest-choice ambiguity resolution | `execute-parent-task-with-n-steps-v6` |
| **14** | [`14-execute-parent-task-v7-letterly.md`](14-execute-parent-task-v7-letterly.md) | Execute V7 Engine | V7 engine (Option 1: Time-Restricted; Option 2: Unrestricted) | `execute-parent-task-with-n-steps-v7` |
| **15** | [`15-plan-parent-task-letterly.md`](15-plan-parent-task-letterly.md) | Plan Blueprint | Architectural planning specification and pending backlog task | `plan-spec-steps-v2` |
| **16** | [`16-plan-steps-by-groups-letterly.md`](16-plan-steps-by-groups-letterly.md) | Plan Steps by Groups | Modular architectural blueprint with zero code execution | `plan-steps-by-groups` |
| **17** | [`17-plan-coding-guideline-audit-letterly.md`](17-plan-coding-guideline-audit-letterly.md) | Plan Guideline Audit | Compliance audit, scorecard, and remediation micro-batches | `plan-coding-guideline-audit` |

### Cursor Prompt Suite (`23-cursor-prompts/`)

For Cursor environments requiring `.cursor/skills/` resolution, see [`../23-cursor-prompts/readme.md`](../23-cursor-prompts/readme.md).

## Core Invariants

1. **Zero Conversational Filler:** Never output "Certainly! Here is your output:".
2. **Lossless Verbatim Capture:** Never drop specific technical flags, file paths, or commands from input.
3. **Mandatory Canonical Skill Triggers:** Every formatted prompt must conclude with its designated canonical skill trigger: `[<skill-name>](directory;.agents/skills/<skill-name>)`.
4. **Dual-Item Agent Invocation:** All execution formatters enforce primary execution engine (`execute-parent-task-with-n-steps-v6` or `v7`) and bug remediation (`fix-with-rca`).
5. **Immediate Execution Without Confirmation:** Under `## Additional Instructions`, all execution formatters enforce immediate autonomous execution post-planning without asking user confirmation.
6. **Standard Letterly Suffix:** All prompt files in this directory strictly carry the `-letterly.md` file suffix.
7. **Strict Relative Git Paths Only:** Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute filesystem paths.
8. **Decoupled Execution Engine:** Prompts remain generic and compact (< 5550 chars); execution lifecycle mechanics and concurrency are offboarded to invoked skills.
9. **Heatmap Telemetry & Write Collision Mandate:** All Letterly formatters embed GitMap Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`) to track file touches and prevent write collisions.
