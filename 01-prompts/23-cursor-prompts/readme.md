# Cursor Prompt Formatters (`23-cursor-prompts`)

Deterministic prompt transformation templates specifically adapted for Cursor IDE environments, resolving skill dependencies directly against `.cursor/skills/`.

## Directory Index

| # | Prompt File | Target Mode | Description | Canonical Successor Skill |
| :---: | :--- | :--- | :--- | :--- |
| **01** | [`01-mobile-letterly-cursor.md`](01-mobile-letterly-cursor.md) | Mobile Single-Line | Compact one-liner with `# High Prio | `execute-parent-task-with-n-steps-v6` |
| **02** | [`02-desktop-letterly-cursor.md`](02-desktop-letterly-cursor.md) | Desktop Structured | Voice dictation to structured instr | `execute-parent-task-with-n-steps-v6` |
| **03** | [`03-execute-n-steps-letterly-cursor.md`](03-execute-n-steps-letterly-cursor.md) | Execute N-Steps | Verbatim input capture with discret | `execute-parent-task-with-n-steps-v6` |
| **04** | [`04-plan-letterly-cursor.md`](04-plan-letterly-cursor.md) | Planning Spec | Architectural planning directives w | `plan-spec-steps-v2` |
| **05** | [`05-release-letterly-cursor.md`](05-release-letterly-cursor.md) | Minor Release (Letter U) | Minor release update ceremony direc | `release` |
| **06** | [`06-cicd-fix-release-letterly-cursor.md`](06-cicd-fix-release-letterly-cursor.md) | CI/CD Fix & Release | `gitmap pe -t` diagnosis, 4-part RC | `ci-cd-fix-gitmap-release` |
| **07** | [`07-mobile-cicd-fix-letterly-cursor.md`](07-mobile-cicd-fix-letterly-cursor.md) | Mobile CI/CD Fix | Mobile prompt diagnosing via `gitma | `ci-cd-fix-gitmap-release` |
| **08** | [`08-run-letterly-cursor.md`](08-run-letterly-cursor.md) | Run Script | Run instructions via `./run.ps1` /  | `run` |
| **09** | [`09-execute-with-verification-letterly-cursor.md`](09-execute-with-verification-letterly-cursor.md) | Execute + Verify | Execute N-steps with retrospective  | `execute-parent-task-with-n-steps-v6` |
| **10** | [`10-execute-with-release-letterly-cursor.md`](10-execute-with-release-letterly-cursor.md) | Execute + Release | Execute N-steps followed by CI chec | `execute-parent-task-with-n-steps-v6` |
| **11** | [`11-git-pull-first-letterly-cursor.md`](11-git-pull-first-letterly-cursor.md) | Git Pull First | Directives ensuring `gitmap pull` r | `execute-parent-task-with-n-steps-v6` |
| **12** | [`12-muse-long-update-letterly-cursor.md`](12-muse-long-update-letterly-cursor.md) | Muse Long Update | Overnight execution with gitmap upd | `execute-parent-task-with-n-steps-v6` |
| **13** | [`13-muse-sleepy-letterly-cursor.md`](13-muse-sleepy-letterly-cursor.md) | Muse Sleepy Mode | Autopilot run with closest-choice a | `execute-parent-task-with-n-steps-v6` |
| **14** | [`14-execute-parent-task-v7-letterly-cursor.md`](14-execute-parent-task-v7-letterly-cursor.md) | Execute V7 Engine | V7 engine (Option 1: Time-Restricte | `execute-parent-task-with-n-steps-v7` |
| **15** | [`15-plan-parent-task-letterly-cursor.md`](15-plan-parent-task-letterly-cursor.md) | Plan Blueprint | Planning spec and pending backlog t | `plan-spec-steps-v2` |
| **16** | [`16-plan-steps-by-groups-letterly-cursor.md`](16-plan-steps-by-groups-letterly-cursor.md) | Plan Steps Groups | Modular blueprint with zero code ex | `plan-steps-by-groups` |
| **17** | [`17-plan-coding-guideline-audit-letterly-cursor.md`](17-plan-coding-guideline-audit-letterly-cursor.md) | Guideline Audit | Compliance audit, scorecard, remedi | `plan-coding-guideline-audit` |
| **18** | [`18-sync-letterly-cursor.md`](18-sync-letterly-cursor.md) | Sync Mode (Fleet Synchronizer) | Native fleet sync across prompts, skills, coding-guideline.json | `gitmap-fleet-sync` |
| **19** | [`19-cursor-manager-memory-and-instruction.md`](19-cursor-manager-memory-and-instruction.md) | Manager: plan | Cursor manager: pull, push, spec, p | `ai-instruction-packet` |
| **20** | [`20-cursor-verify-and-replan.md`](20-cursor-verify-and-replan.md) | Manager: verify | Verifies cited lines, authors plan  | `ai-instruction-packet` |

## Core Invariants

1. **Zero Conversational Filler:** Never output "Certainly! Here is your output:".
2. **Lossless Verbatim Anti-Mutation:** Never drop specific technical flags, file paths, or commands from input. TOTAL BAN on mutating, softening, or altering input text beyond verbal fillers; preserve tone, urgency, directives 100% intact.
3. **Mandatory Canonical Skill Triggers:** Every formatted prompt must conclude with its designated canonical skill trigger: `[<skill-name>](directory;.cursor/skills/<skill-name>)`.
4. **Dual-Item Agent Invocation:** All execution formatters enforce primary execution engine (`execute-parent-task-with-n-steps-v6` or `v7`) and bug remediation (`fix-with-rca`).
5. **Immediate Execution Without Confirmation:** Under `## Additional Instructions`, all execution formatters enforce immediate autonomous execution post-planning without asking user confirmation.
6. **Standard Cursor Suffix:** All formatters in this directory strictly carry the `-letterly-cursor.md` file suffix.
7. **Strict Relative Git Paths Only:** Only add relative paths (`02-spec/...`, `.ai-memory/...`, `cmd/...`); never add absolute filesystem paths.
8. **Decoupled Execution Engine:** Prompts remain compact (< 5550 chars); execution lifecycle mechanics are offboarded to invoked skills.
9. **Heatmap Telemetry & Collision Safety:** All formatters embed GitMap Heatmap (`gitmap rc heatmap status` / `gitmap rc heatmap tree` / `gitmap rc heatmap live` / `gitmap rc heatmap sync`) to track file touches and prevent write collisions.
