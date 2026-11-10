# Cursor Prompt Formatters (`23-cursor-prompts`)

This collection contains deterministic prompt transformation templates specifically adapted for Cursor IDE environments, resolving skill dependencies directly against `.cursor/skills/`.

## Directory Index

| # | Prompt File | Target Mode | Description | Canonical Successor Skill |
| :---: | :--- | :--- | :--- | :--- |
| **01** | [`01-mobile-letterly-cursor.md`](01-mobile-letterly-cursor.md) | Mobile Single-Line | Compact one-liner without line breaks starting with `# High Priority Instruction:` | `execute-parent-task-with-n-steps-v6` |
| **02** | [`02-desktop-letterly-cursor.md`](02-desktop-letterly-cursor.md) | Desktop Structured | Formats voice dictation into high-priority instructions, action items, and V6 suffix | `execute-parent-task-with-n-steps-v6` |
| **03** | [`03-execute-n-steps-letterly-cursor.md`](03-execute-n-steps-letterly-cursor.md) | Execute N-Steps | Verbatim input capture with discrete action items and V6 execution engine | `execute-parent-task-with-n-steps-v6` |
| **04** | [`04-plan-letterly-cursor.md`](04-plan-letterly-cursor.md) | Planning Spec | Formats raw input into architectural planning directives with no-build rules | `plan-spec-steps-v2` |
| **05** | [`05-release-letterly-cursor.md`](05-release-letterly-cursor.md) | Minor Release (Letter U) | Formats input into minor release update ceremony directives | `minor-bump` |
| **06** | [`06-cicd-fix-release-letterly-cursor.md`](06-cicd-fix-release-letterly-cursor.md) | CI/CD Fix & Release | Formats input into `gitmap pe -t` telemetry diagnosis, 4-part RCA, and minor release | `ci-cd-fix-gitmap-release` |
| **07** | [`07-mobile-cicd-fix-letterly-cursor.md`](07-mobile-cicd-fix-letterly-cursor.md) | Mobile CI/CD Fix | One-liner mobile prompt diagnosing via `gitmap pe -t` and triggering release | `ci-cd-fix-gitmap-release` |
| **08** | [`08-run-letterly-cursor.md`](08-run-letterly-cursor.md) | Run Script | Formats input into run instructions via `./run.ps1` / `./run.sh` with auto dependency install | `run` |
| **09** | [`09-execute-with-verification-letterly-cursor.md`](09-execute-with-verification-letterly-cursor.md) | Execute + Retrospective Audit | Formats input into execute N-steps with mandatory retrospective AI verification at task end | `execute-parent-task-with-n-steps-v6` / `ai-verification` |
| **10** | [`10-execute-with-release-letterly-cursor.md`](10-execute-with-release-letterly-cursor.md) | Execute + Minor Release | Formats input into execute N-steps followed directly by green CI verification and minor release | `execute-parent-task-with-n-steps-v6` / `minor-bump` |
| **11** | [`11-git-pull-first-letterly-cursor.md`](11-git-pull-first-letterly-cursor.md) | Git Pull First | Formats input into pull-first execution directives ensuring gitmap pull runs before any work | `execute-parent-task-with-n-steps-v6` |
| **12** | [`12-muse-long-update-letterly-cursor.md`](12-muse-long-update-letterly-cursor.md) | Muse Long Update | Formats input into Muse long-running overnight execution with gitmap update first, rate-limited gitmap pa / repo pull, autopilot ambiguity logging, pragmatic commits, and conditional CI release | `execute-parent-task-with-n-steps-v6` |
| **13** | [`13-muse-sleepy-letterly-cursor.md`](13-muse-sleepy-letterly-cursor.md) | Muse Sleepy Mode | Formats input into "I am sleepy" autopilot execution with repo pull first, closest-choice ambiguity resolution, morning review log, no-build/no-test default, and pragmatic commits | `execute-parent-task-with-n-steps-v6` |
| **14** | [`14-execute-parent-task-v7-letterly-cursor.md`](14-execute-parent-task-v7-letterly-cursor.md) | Execute Parent Task (V7 Engine) | Formats voice dictation with V7 master autonomous execution engine (Option 1: Time-Restricted commits before 08:00 AM weekdays; Option 2: Unrestricted), autobot identity, and dual-window quotas | `execute-parent-task-with-n-steps-v7` |
| **15** | [`15-plan-parent-task-letterly-cursor.md`](15-plan-parent-task-letterly-cursor.md) | Plan Parent Task (N-Steps Blueprint) | Formats input into architectural planning specification and pending backlog task without immediate code execution | `plan-spec-steps-v2` |
| **16** | [`16-plan-steps-by-groups-letterly-cursor.md`](16-plan-steps-by-groups-letterly-cursor.md) | Plan Steps by Groups | Formats input into modular layer-by-layer architectural blueprint (Data, Core, API, UI, Verification) with zero code execution | `plan-steps-by-groups` |
| **17** | [`17-plan-coding-guideline-audit-letterly-cursor.md`](17-plan-coding-guideline-audit-letterly-cursor.md) | Plan Coding Guideline Audit | Formats input into coding standard compliance audit, scorecard, and remediation micro-batch backlog | `plan-coding-guideline-audit` |
| **18** | [`18-cursor-manager-memory-and-instruction.md`](18-cursor-manager-memory-and-instruction.md) | Manager: plan | How Cursor behaves as the manager: pull, resolve, push, then write the spec, the plan, and the copy-paste AI instruction | `ai-instruction-packet` |
| **19** | [`19-cursor-verify-and-replan.md`](19-cursor-verify-and-replan.md) | Manager: verify | Finds the prompt the task came from, checks the cited lines, and writes an improvement plan plus a copy-paste instruction for what is missing | `ai-instruction-packet` |

## Core Invariants

1. **Zero Conversational Filler:** Never output "Certainly! Here is your output:".
2. **Lossless Verbatim Capture:** Never drop specific technical flags, file paths, or commands from input.
3. **Mandatory Canonical Skill Triggers:** Every formatted prompt must conclude with its designated canonical skill trigger: `[<skill-name>](directory;.cursor/skills/<skill-name>)`.
4. **Dual-Item Agent Invocation:** All execution formatters enforce dual-item agent spawning:
   - Primary task execution engine (`execute-parent-task-with-n-steps-v6` or `v7`).
   - Grounded bug remediation trigger: `If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.cursor/skills/fix-with-rca)`.
5. **Immediate Execution Without Confirmation:** Under `## Additional Instructions`, all execution formatters strictly enforce:
   `- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.`
6. **Standard Cursor Suffix:** All formatters in this directory strictly carry the `-letterly-cursor.md` file suffix.
7. **Strict Relative Git Paths Only:** Only add the relative paths, never add the absolute path during your work, and ensure this is respected on the release page and in release notes as well.
8. **Decoupled Execution Engine:** Prompts remain generic and decoupled from internal engine step budgeting; lifecycle execution parameters and concurrency are encapsulated directly within the invoked skills.
9. **Heatmap Telemetry & Write Collision Mandate:** All formatters embed the GitMap Heatmap one-liner (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`) to track in-flight file touches, prevent write collisions across parallel agent swarms ($A = 3$, Capacity = 6), and transparently report 3-tier database locations.
