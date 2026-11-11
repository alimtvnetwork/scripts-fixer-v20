# Rule: Letterly Prompt Formatting, Zero-Mutation & 400-Step Plan Standards

## 1. Letterly Character Budget Ceiling (<= 5,500 Chars)
- Every prompt in `01-prompts/22-letterly/` and `01-prompts/23-cursor-prompts/` MUST strictly remain under 5,500 characters (absolute hard ceiling: 5,550 characters).
- Offboard repetitive boilerplate, verbose rules, and extensive checklists to the invoked skills (`@[plan-spec-steps-v2]`, `@[execute-parent-task-with-n-steps-v6]`, `@[coding-guidelines]`, `@[error-management]`, `@[execute-ai-instruction-writer]`).
- Validate character counts across all Letterly and Cursor prompt files prior to release.

## 2. Strict Input Zero-Mutation Invariant
- Every Letterly formatter must enforce a strict zero-mutation policy on the user's input text:
  `TOTAL BAN on mutating, softening, summarizing, or altering input text in any way. Keep input 100% strictly intact, preserving all tone, urgency, emotion, technical flags, and file paths.`
- Only conversational filler words (`um`, `ah`, `uh`, `like`, leading `Okay`, excess `so`) may be stripped.
- Never summarize, rephrase, soften, or alter parameters, code symbols, or directives.

## 3. 400-Step Standard for Plan V2 and Planning Prompts
- All planning specifications, Plan V2 prompts (`01-prompts/13-plan-audit/02-plan-spec-steps-v2.md`), and plan formatters (`04-plan-letterly.md`, `15-plan-parent-task-letterly.md`, `16-plan-steps-by-groups-letterly.md`, `17-plan-coding-guideline-audit-letterly.md`) MUST enforce exactly 400 granular self-looping steps:
  - **Phase 1 Budget:** Steps 1 .. 200 (Planning, Parallel Discovery, Detailed Architecture Spec, and Lean Subtasks).
  - **Phase 2 Budget:** Steps 201 .. 400 (Parallel Subagent Execution, Continuous Self-Looping, Quality Linting, and Verification).
- Every plan formatter must explicitly instruct the executing agent to construct a 400-step master plan under `.ai-memory/plans/pending/XX-<slug>.md` and subtasks under `.ai-memory/plans/subtasks/XX-<slug>/`.

## 4. Ambiguity Protocol & Autonomous Continuation
- When questions or missing details arise during planning, never block execution or ask the user questions in chat (unless explicitly instructed "Ask me the question").
- Always record ambiguities to `.ai-memory/ambiguous-questions/01-new-ambiguity/XX-<slug>-ambiguity.md` and continue planning autonomously.

## 5. File & Path Conventions
- Strictly relative Git paths only (`02-spec/...`, `.ai-memory/...`, `cmd/...`). TOTAL BAN on Windows drive letters or `file:///` URIs.
- Universal UNIX LF (`\n`) line endings. TOTAL BAN on CRLF (`\r\n`).
