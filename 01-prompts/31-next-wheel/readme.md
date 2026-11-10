# 31-next-wheel — Prompt Templates (spec 277)

Authoring source of truth for every prompt body the Next Breakdown
(`next` action), rerun, suffix, and verification flows dispatch.
No prompt prose lives in code anymore: code holds only IDs, placeholder
tokens, short format scaffolding, and the loaders that resolve these files.

## Resolution rule (both sides, single rule)

`custom (SQLite / localStorage, if present)` → `disk MD (Rust) /
generated registry (frontend)` → `embedded MD (Rust include_str!)` →
error via `AppError` (Rust) / `useErrorStore` (frontend).
Never a silent empty string. Never a hand-written template string in code.

## How the two bundled forms are produced

- Frontend: `scripts/generate-prompt-templates.js` reads this folder and
  writes `src/components/instances/PromptTreeView/templates.generated.ts`.
  That file carries a "DO NOT EDIT — generated" header. Re-run the script
  after editing any file here; `node scripts/generate-prompt-templates.js
  --check` fails if the generated file is stale.
- Backend: `src-tauri/src/modules/prompt_templates.rs` resolves disk MD
  first (workspace, `AGM_REPO_ROOT` / `AGM_IMPROVEMENTS_ROOT`, then cwd
  ancestors) and falls back to compile-time `include_str!` copies of these
  same files, so a packaged app without an `01-prompts/` tree still gets
  the full templates. The build fails if a referenced MD file is missing.
- Seeding: `src-tauri/src/modules/suffix_templates.rs` seeds SQLite from
  these MD bodies. Seeding only ever ADDS missing builtin IDs; it never
  overwrites an existing row (user customizations are never clobbered).
  Fresh databases get all 11 suffixes (see "Seed drift" below). Rerun
  seeds use the same INSERT OR IGNORE rule since Wave 3, so a seed added
  later (e.g. `testing-improvement`) is backfilled into existing
  databases instead of reaching fresh databases only.

## Placeholders

Existing contract, unchanged: `{nudge} {insert} {prompt} {attachments}
{round} {total} {question}`. New in this wave: `{rerun_context}` (prior
round outcome block; empty when absent) and `{time_effort}` (the shared
time/effort mandate in `partials/time-effort.md`; the Rust dispatch and
the frontend interpolator substitute the partial body when no explicit
value is given, so the instruction cannot be dropped by editing one file).
Rust-only dispatch placeholders: `{count} {slot} {total_waves}
{total_items} {batch_size} {kind_label} {prompt_ref} {action}`.
Chapter placeholders: `{title_label} {inventory_items} {touched_files_section}
{original_prompt} {style} {style_upper} {conversation_title}
{conversation_id} {round_focus}`.

## Seed drift — adjudicated (spec 277, Wave 2)

The 3 suffixes present in the frontend builtins but absent from the DB
seeds (`tested-e2e`, `tested-e2e-and-released`, `run-100-steps`) were an
oversight, not intentional: the 8 seeded bodies are word-for-word identical
to their frontend counterparts, and the 3 missing ones are first-class
verification options in the UI. Resolution: one registry of 11 suffixes.
Rust seeds now backfill any missing builtin ID on existing databases.

## Layout

| File | ID | Migrated from |
|---|---|---|
| `partials/time-effort.md` | `time-effort` | NEW (no time/effort instruction existed anywhere) |
| `next-wheel/01-execution.md` | `next-wheel-execution` | `improvements/mod.rs` next `actionable_items` (M21), rewritten bulletproof |
| `next-wheel/02-fallback.md` | `next-wheel-fallback` | `improvements/mod.rs` 3-bullet `source_hint` fallback (M18) |
| `next-wheel/03-terminal-verification.md` | `next-wheel-terminal-verification` | `improvements/mod.rs` terminal `verification_block` (M19) |
| `next-wheel/04-wave-notice.md` | `next-wheel-wave-notice` | `improvements/mod.rs` wave `verification_block` (M19) |
| `next-wheel/05-mode-plan.md` | `next-wheel-mode-plan` | `improvements/mod.rs` plan `mode_guidance` (M20) |
| `next-wheel/06-mode-detail.md` | `next-wheel-mode-detail` | `improvements/mod.rs` detail `mode_guidance` (M20) |
| `next-wheel/07-mode-next.md` | `next-wheel-mode-next` | `improvements/mod.rs` next `mode_guidance` (M20) |
| `next-wheel/08-actionable-plan.md` | `next-wheel-actionable-plan` | `improvements/mod.rs` plan `actionable_items` (M21) |
| `suffixes/v6.md` | `suffix-v6` | `improvements/mod.rs` `V6_SUFFIX` (M16) |
| `suffixes/v7.md` | `suffix-v7` | `improvements/mod.rs` `V7_SUFFIX` (M17) |
| `suffixes/is-it-done.md` etc. (11 files) | suffix id verbatim | `verificationTemplates.ts` `BUILTIN_SUFFIX_TEMPLATES` (M03) + DB seeds (M23), reconciled to 11 |
| `inserts/discipline.md` | `discipline` | `verificationTemplates.ts` `RERUN_INSERT_PRESETS.discipline` (M01) + DB seed (M22), expanded into sections |
| `inserts/ui.md` | `ui` | `verificationTemplates.ts` `RERUN_INSERT_PRESETS.ui` (M01) + DB seed (M22), expanded |
| `inserts/code.md` | `code` | `verificationTemplates.ts` `RERUN_INSERT_PRESETS.code` (M01) + DB seed (M22), expanded |
| `inserts/testing.md` | `testing` | NEW (Wave 3): test-evidence insert — targeted checks, error branches, honest-green criteria; selectable in the rerun Insert picker alongside discipline / ui / code, with a `testing-improvement` DB seed |
| `rerun/formats/standard-clean.md` | `standard-clean` | `verificationTemplates.ts` `BUILTIN_RERUN_TEMPLATES` (M02) |
| `rerun/formats/minimal-nudge.md` | `minimal-nudge` | (M02) |
| `rerun/formats/detailed-audit.md` | `detailed-audit` | (M02) |
| `rerun/formats/sectioned-audit.md` | `sectioned-audit` | NEW opt-in format: sectioned rerun with `{time_effort}` + `{rerun_context}` + discipline groupings |
| `rerun/formats/failed-items-audit.md` | `failed-items-audit` | NEW (Wave 3) opt-in format: context-first rerun that triages `{rerun_context}` failed / carried-forward items before the nudge, insert, and original task; the first-class consumer of the threaded `rerunContext` field |
| `rerun/nudges.md` | `rerun-nudges` (list) | `usePromptTreePromptActions.ts` `RERUN_RANDOM_MESSAGE_SET` (M13) + `RERUN_FIXED_MESSAGES` (M14), deduplicated: the 18 fixed messages are a subset of the 40-entry pool, tagged `[option]` in the list |
| `rerun/fallback-nudges.md` | `rerun-fallback-nudges` (list) | `verificationTemplates.ts` `getFallbackNudge` (M12) |
| `rerun/schema.md` | `rerun-schema` | `RerunTemplateModal.tsx` `AI_MARKDOWN_SCHEMA_PROMPT` (M15) |
| `verification/chapters/01-audit-mandate.md` | `chapter-01-audit-mandate` | `verificationTemplates.ts` `buildChapter1AuditMandate` (M04) |
| `verification/chapters/02-*.md` (12 files) | `chapter-02-*` | `verificationTemplates.ts` `buildChapter2Checklist` cases (M05) |
| `verification/chapters/03-telemetry-gates.md` | `chapter-03-telemetry-gates` | `buildChapter3TelemetryGates` (M06) |
| `verification/chapters/04-original-prompt-wrapper.md` | `chapter-04-original-prompt-wrapper` | `buildChapter4OriginalPrompt` prose (M07); the `<<<ORIGINAL_TASK_PROMPT_*>>>` markers stay in the template body |
| `verification/chapters/05-evidence-contract.md` | `chapter-05-evidence-contract` | `buildChapter5EvidenceContract` (M08) |
| `verification/multi-prompt/01-mandate.md` … `05-remediation.md` | `multi-01-*` … `multi-05-*` | `buildMultiPromptVerificationPrompt` chapters (M09) |
| `verification/styles/<style>-<1..3>.md` (12 files) | `style-<style>-<round>` | `build*Chapters` style builders (M10) |
| `verification/round-banner.md` | `round-banner` | `buildMultiRoundVerificationPrompts` banner (M11) |
| `verification/round-conclusion.md` | `round-conclusion` | `buildMultiRoundVerificationPrompts` conclusion (M11) |

Not migrated (reclassified, not dropped): M24 resend-as seeds in
`suffix_templates.rs` are title patterns + mode + suffix-id references
(`verify` / `fix` / `rerun` / `audit` / `followup`), not prompt prose;
they stay in code as metadata and now point at the migrated suffix IDs.
