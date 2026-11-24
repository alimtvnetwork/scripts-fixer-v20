---
name: bug-in-prompt-tree-view
description: >-
  Diagnose, root-cause, fix, and verify prompt tree view falsified image attachment calculation, preventing image leaking from prior turns or whole conversation to queued prompts and reruns.
---

# Bug in Prompt Tree View (Falsified Image Leakage Elimination)

> **Invocation:** `@[bug-in-prompt-tree-view](directory;.agents/skills/bug-in-prompt-tree-view)`

## Operational Scope
This skill governs the systematic investigation, elimination, and end-to-end verification of falsified image leakage in the Prompt Tree View. When queued prompts or turn-specific prompts have zero attached images, they must never inherit images from past turns, sub-runs, or conversation-level media aggregates.

---

## Invariant Rules
1. **Strict Turn Isolation**: A prompt turn only displays images explicitly attached to or embedded within that specific turn.
2. **Zero False Fallbacks**: Never fall back from an image-less turn (`list.length === 0`) to `conv.media_paths` or `conv.media_thumbnails`.
3. **Pristine Scoped Node Creation**: Scoped conversation nodes created in `createTurnConv` and `applySelectedTurnScope` must strictly set `media_paths: turn.media_paths || []` without fallback to conversation aggregates.
4. **Pristine Dispatch Payloads**: Rerun, enqueue, and send dispatches must only attach images belonging to the active prompt or explicitly attached for that dispatch.
5. **Universal Attachment Stripping**: `stripGeneratedAttachmentsBlock` (TypeScript) and `strip_generated_attachment_blocks` (Rust) must strip all generated list variations (headered, unheadered numbered lists `1. [Attachment ...]`, Antigravity `[Attachment: ...]`, standalone `@[]` bracket paths) before calculating assets or re-enqueuing.
6. **Transcript Context Summary Hygiene**: When parsing system-generated conversation transcripts, `<CONTEXT_SUMMARY>...</CONTEXT_SUMMARY>` sections must be bypassed to prevent quoting historical turn attachments.
7. **GitMap Toolchain Primacy**: All code searches, file inspections, and AST diffs use `gitmap aum search` and `gitmap find`.

---

## 4-Part Root Cause Analysis (4-Part RCA)

### 1. Defective Attachment Block Stripping
- **Symptom**: Unheadered numbered lists (`1. [Attachment 1 | ...](file;...) @[...]`) persisted in prompt bodies.
- **Root Cause**: `stripGeneratedAttachmentsBlock` in `src/utils/promptAttachment/extract.ts` required a mandatory `\bAttachments:\s*` prefix. When prompts contained unheadered numbered lists, the regex failed, leaving the 20 lines in `preBlockText` to be re-parsed as genuine turn images.
- **Remediation**: Added multi-pattern regexes in TypeScript and Rust supporting numbered lists, Antigravity bullet attachments, standalone bracket paths, and orphan headers.

### 2. Turn Media Sovereignty Violation
- **Symptom**: Inspecting image-less Turn 56 displayed `Attached Images (20)`.
- **Root Cause**: `extractImagesFromPrompt` in `PromptInstructionView.tsx` and `countPromptImages` in `clipboard.ts` fell back to `conv.media_paths` whenever a turn had 0 locally detected images.
- **Remediation**: If `effectiveTurnNumber != null`, 0 local images returns `[]` immediately without conversation fallback, completely hiding the image gallery.

### 3. Backend Transcript History Bleed
- **Symptom**: Backend `turn.media_paths` contained historical images.
- **Root Cause**: In `src-tauri/src/modules/repo_db/transcript.rs`, when a turn had no explicit `media` field, fallback regexes scanned the full `content` string, parsing quoted paths from `<CONTEXT_SUMMARY>` sections.
- **Remediation**: Implemented `sanitize_prompt_for_media_extraction` in `detection.rs` to strip context summaries and attachment blocks before fallback media extraction.

### 4. Active Prompt Representation Duplication
- **Symptom**: Queued prompts in SQLite `active_prompts` table inherited conversation images.
- **Root Cause**: In `tree_node_conv.rs`, queued active prompt candidates without explicit image payloads copied conversation-level media.
- **Remediation**: Sanitized `ap.prompt_content` with `sanitize_prompt_for_media_extraction` in `resolve_ap_media`.

---

## Verification Test Matrix

Run targeted checks across touched modules:

```bash
# 1. Frontend Turn Image Isolation Unit Tests (34 assertions)
npx tsx src/components/instances/PromptTreeView/__tests__/turnImageIsolation.test.ts

# 2. Frontend Production Build & Bundle Gate
npm run build

# 3. Backend Media Detection & Sanitization Tests (11 tests)
cargo test --manifest-path src-tauri/Cargo.toml --lib -- detection::tests

# 4. Backend Tree Node Conversion Tests (10 tests)
cargo test --manifest-path src-tauri/Cargo.toml --lib -- tree_node_conv::tests

# 5. Backend Transcript Parser Tests (13 tests)
cargo test --manifest-path src-tauri/Cargo.toml --lib -- transcript::tests

# 6. Rust Linter Gate
cd src-tauri && cargo clippy --lib

# 7. Rust Formatting Gate
cd src-tauri && cargo fmt -- --check

# 8. Transient Test Sandbox Lifecycle (Caller IDE Protected)
agm instances test-create "test-falsified-image-fix"
agm instances test-clean
```
