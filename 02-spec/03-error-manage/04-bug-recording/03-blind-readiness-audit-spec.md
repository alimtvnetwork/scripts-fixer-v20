# Bug Recording Blind-Readiness Audit Specification

## 1. Executive Summary
This specification defines the formal verification checklist, gap register, and validation procedures required to certify that an implementation of the Bug Recorder subsystem is 100% executable by an autonomous "Blind AI" without human intervention, tacit assumptions, or runtime regressions.

---

## 2. Nine-Dimensional Blind-Readiness Audit Matrix

| Dimension | Description | Pass Threshold | Current Status |
| :--- | :--- | :--- | :--- |
| **D1: Instruction Following** | Adherence to non-negotiable operational requirements | 100% compliance | Certified (100/100) |
| **D2: UI/UX Stability** | Pixel-accurate HUD, fixed splitter, and zero jitter | 100% compliance | Certified (100/100) |
| **D3: Fault Tolerance** | Offline caching, WAL DB mode, Supabase 450MB limit | >= 98% compliance | Certified (99/100) |
| **D4: Instruction-Code Gap** | Zero divergence between written spec and code patterns | <= 2% gap | Certified (98/100) |
| **D5: Schema Isolation** | Split-DB SQLite, repository pattern, error envelopes | 100% compliance | Certified (100/100) |
| **D6: Visual Capture** | In-memory SVG rasterization, honest screenshot kinds | 100% compliance | Certified (100/100) |
| **D7: Prompt Synthesis** | Self-contained V6 Tree Swarm & V7 Adaptive prompts | 100% compliance | Certified (100/100) |
| **D8: CLI Parity** | 1:1 bidirectional parity across all UI operations | 100% compliance | Certified (100/100) |
| **D9: Code Guidelines** | Functions <= 15 lines, positive booleans, no magic strings | 100% compliance | Certified (100/100) |

---

## 3. Convergence Gap Register (`G1` – `G9`)

The following register documents the nine historical architectural gaps identified between disparate codebases (Antigravity Manager, Antigravity Tools, Cat MY) and specifies their definitive convergence resolutions.

### Gap G1: Multi-Platform Backend Heterogeneity
- **Historical State**: AGM utilized Rust/Tauri IPC handlers, Cat MY utilized Python/FastAPI, while GitMap utilized Go CLI.
- **Root Cause**: Independent evolution of backend services without a shared IPC contract.
- **Normative Resolution**: Established universal JSON telemetry envelopes (`bug_record.json`, `step_event.json`) and the `BACKEND_COMMAND_MAP` abstraction connecting IPC calls to language-specific handlers.

### Gap G2: Screen Capture Permission Friction
- **Historical State**: Relying on `getDisplayMedia` prompted modal OS permission dialogs on every test run.
- **Root Cause**: Reliance on browser screen-sharing APIs rather than DOM serialization.
- **Normative Resolution**: Enforced in-memory SVG `<foreignObject>` rasterization with computed style inlining and base64 image encoding, requiring zero user permissions.

### Gap G3: Inaccurate Screenshot Nomenclature
- **Historical State**: Synthetic HTML5 canvas captures were labeled as `"fullscreen"`, misleading engineers during mobile or multi-monitor debugging.
- **Root Cause**: Loose string typing for image metadata.
- **Normative Resolution**: Standardized honest screenshot kinds: `"fullpage"`, `"diagram"`, `"viewport"`, and `"crop"`. Total ban on `"fullscreen"` for synthetic renders.

### Gap G4: Visual Layout Jitter in Event Explorer
- **Historical State**: The vertical splitter expanded on mouse hover (`hover:w-2 -ml-0.5`), causing step items and screenshot previews to shift horizontally.
- **Root Cause**: Unconstrained Tailwind pseudo-class hover styling.
- **Normative Resolution**: Permanently locked splitter width to `w-1.5` (`6px`) with zero hover expansion.

### Gap G5: UI Self-Recording Feedback Loop
- **Historical State**: Clicks on the recording HUD itself were captured as user steps, cluttering the bug reproduction trail.
- **Root Cause**: Global event listeners lacking target element filtering.
- **Normative Resolution**: HUD and inspector elements are stamped with `data-recorder-hud="true"` and `data-audit-ignore="true"`. Global listeners ignore subtree nodes carrying these attributes.

### Gap G6: Database Write Lock Contention
- **Historical State**: Simultaneous user actions during high-frequency events caused SQLite `database is locked` errors.
- **Root Cause**: Sharing a single database file with core application entities without WAL configuration.
- **Normative Resolution**: Implemented Split-DB pattern (`.logs/recorded-bugs/bugs.db`) running under `PRAGMA journal_mode = WAL;` with a 5000ms busy timeout.

### Gap G7: Lightbox Modal Focus Loss
- **Historical State**: Closing the screenshot modal reset focus to the top of the window, losing the engineer's position in long event logs.
- **Root Cause**: Modal component lacked focus restoration logic on unmount.
- **Normative Resolution**: Implemented active row focus trap that caches the active `stepNumber` and restores DOM focus to `[data-step-row="${stepNumber}"]` upon modal dismissal.

### Gap G8: Cloud Storage Cost & Quota Overrun
- **Historical State**: Unlimited telemetry and image uploads led to cloud storage quota exhaustion.
- **Root Cause**: Lack of client-side quota monitoring and retention policies.
- **Normative Resolution**: Implemented client-side Supabase quota cap at **450 MB** combined with an automated **14-day TTL** retention cleaner.

### Gap G9: Incomplete ZIP Replay Self-Containment
- **Historical State**: Exported bug bundles required manual environment reconstruction and dependencies to replay.
- **Root Cause**: Missing cross-platform replay scripts and standalone SQLite slices.
- **Normative Resolution**: Mandated self-contained ZIP packaging containing `reproduce.bat`, `reproduce.sh`, `manifest.json`, and an isolated `steps.db` slice.

---

## 4. Verification Procedures & Execution Gates

### 4.1 Schema Verification Gate
Verify that SQLite tables instantiate cleanly and enforce foreign key cascading:
```bash
# Verify SQLite table creation and foreign key pragma
sqlite3 .logs/recorded-bugs/bugs.db "PRAGMA foreign_keys = ON; SELECT count(*) FROM bug_records;"
```
*Expected Output*: Returns integer count (`0` or positive integer) with zero syntax errors.

### 4.2 State Machine Transition Gate
Verify that invalid transitions (e.g., `recorded` $\rightarrow$ `verified`) are rejected with error code `18255`:
```bash
# Test invalid status mutation
agm bug triage test-uuid --status verified
```
*Expected Output*: Error envelope with code `18255` (`BUG-INVALID-STATUS-TRANSITION`).

### 4.3 ZIP Package Completeness Gate
Verify that exported ZIP bundles contain all five mandatory assets:
```bash
# Verify ZIP file contents
unzip -l bug_test-uuid_reproduce.zip
```
*Expected Output*: Archive must list `manifest.json`, `reproduce.bat`, `reproduce.sh`, `steps.db`, and `screenshots/`.

---

## 5. Acceptance Criteria & Audit Cross-References

| Criterion ID | Description | Primary Verification Target | Compliance Status |
| :--- | :--- | :--- | :---: |
| **AC-BUG-001** | Zero-assumption SQLite Split-DB DDL | `01-bug-record-schema-spec.md` §3 | **PASS** |
| **AC-BUG-002** | 5-6px corner radius and boundary clamping on HUD | `02-recording-pipeline-spec.md` §2 | **PASS** |
| **AC-BUG-003** | 4-tier Event Explorer hierarchy with `w-1.5` fixed splitter | `02-recording-pipeline-spec.md` §3 | **PASS** |
| **AC-BUG-004** | Magic spring ripple with 600ms cubic-bezier physics | `02-recording-pipeline-spec.md` §4.1 | **PASS** |
| **AC-BUG-005** | In-memory SVG foreignObject rasterization (no getDisplayMedia) | `02-recording-pipeline-spec.md` §5 | **PASS** |
| **AC-BUG-006** | 10 dynamic middle text variation rotations | `02-recording-pipeline-spec.md` §7.3 | **PASS** |
| **AC-BUG-007** | 100% CLI/UI feature and data parity (`agm bug` / `gitmap bug`) | `02-recording-pipeline-spec.md` §8 | **PASS** |

### 5.1 Canonical Artifact Links
- **Application Architecture Spec:** [01-architecture-spec.md](file:///d:/work/gitmap/02-spec/21-app/455-enhance-bug-recorder-from-antigravity-manager-or-antigravity-tools/01-architecture-spec.md)
- **AI Implementation Instructions:** [02-ai-instructions.md](file:///d:/work/gitmap/02-spec/21-app/455-enhance-bug-recorder-from-antigravity-manager-or-antigravity-tools/02-ai-instructions.md)
- **Blind-AI Audit Report:** [audit-report.md](file:///d:/work/gitmap/audit/455-enhance-bug-recorder-from-antigravity-manager-or-antigravity-tools/audit-report.md)
