# Specification 27.02: Universal UI/UX & Interaction Design for Bug Reporting

## 1. Visual Anatomy & Industrial Design Language

The Bug Reporting UI adheres to the **Tokyo Night Dark Glassmorphic Theme** (`#0c101a` deep navy canvas, `#151c2e` elevated card containers, `rgba(255,255,255,0.08)` borders, and cyan/emerald status accents).

### Component 1: Floating Recorder HUD (5–6px Radius, Draggable, Collapsible)
A compact, 32px height floating status bar with 5–6px corner radius (`rounded-md` / `rounded-[6px]`):

```
+--------------------------------------------------------------------------------------------------+
| [06-bug] 02:02 | [Step #1 · 1 snaps] | [📸 Snap | 💬 Note | ⏸ Pause | ⏹ Stop | 🚀 IDE v] | [^] [X] |
+--------------------------------------------------------------------------------------------------+
```
- **Corner Radius Invariant**: Strictly 5px to 6px (`rounded-md` / `rounded-[6px]`); large `rounded-full` pill shapes are prohibited.
- **Free-Form Viewport Dragging**: Supports pointer dragging with viewport boundary clamping so the HUD can be positioned anywhere across screen coordinates without escaping bounds.
- **Collapsible Minimization**:
  - Clicking the `^` chevron collapses the HUD into a compact 28px height badge:
    `[06-bug] 02:02 [Expand ^]` with `rounded-[6px]`.
  - Clicking `Expand` or dragging restores the full action toolbar.
- **Unclipped Dropdown Capsule**:
  - Segmented button capsules MUST NOT use `overflow-hidden` on the container div, as this clips child absolute dropdown menus (`z-[10100]`).
  - Border rounding is applied strictly to outer button edges (`rounded-l-md` / `rounded-r-md`).
- **Self-Trace Exclusion Invariant**:
  - Every HUD element and modal is marked with `data-recorder-hud="true"` and `data-recorder-ui="true"` to prevent self-recursive recording.

---

## 2. Event Explorer Modal: 4-Tier Hierarchy & Fixed Column Resizing

The Event Explorer provides detailed forensic inspection of recorded user interactions, DOM telemetry, and backend code execution.

```
+--------------------------------------------------------------------------------------------------+
|  Recorded Telemetry Stream              [ Active Session #1 (3 steps) v ]       [Replay] [IDE v] [X]  |
+--------------------------------------------------------------------------------------------------+
|  [All | Interaction | Snap | Note | Error]                                                       |
|-------------------------------------+ |----------------------------------------------------------|
| Step #1: Clicked "Focus IDE"        | | TIER 1: BACKEND EXECUTION CONTEXT                        |
| 10:08:30 PM · Route: /instances     | | Backend Fn: focus_resolved_conversation                  |
| Target: button#btn-focus-ide        | | Source File: src-tauri/src/modules/instance/focus.rs:71  |
| [📋 Copy Step Prompt & CLI]         | | Invocation:  invoke.focus_or_launch_instance             |
|                                     | | Status:      E7001 (Failed to activate conversation)     |
| Step #2: Input in Prompt Box        | |----------------------------------------------------------|
| 10:08:45 PM · Route: /instances     | | TIER 2: FULL-PAGE SNAPSHOT PREVIEW                       |
| Target: textarea#prompt-input       | | [ Viewport Image with Animated Red Locator Ring ]        |
| [📋 Copy Step Prompt & CLI]         | | [< Prev Image]                         [Next Image >]    |
|                                     | |----------------------------------------------------------|
| Step #3: Clicked "Send Prompt"      | | TIER 3: TARGET ELEMENT & DOM CONTEXT                     |
| 10:09:02 PM · Route: /instances     | | Label: Focus IDE (Default) · Tag: button                 |
| Target: button#btn-send-now         | | XPath: /div[1]/nav[1]/div[1]/button#btn-focus-ide        |
| [📋 Copy Step Prompt & CLI]         | |----------------------------------------------------------|
|                                     | | TIER 4: RAW FORMATTED JSON SEGMENT                       |
|                                     | | { "id": "evt-01", "type": "click", "stepNumber": 1 ... } |
|                                     | | [📋 Copy Formatted JSON]                                 |
+-------------------------------------+------------------------------------------------------------+
```

### Key Interaction Rules:
1. **Constant-Width Resize Handle**: The vertical resize divider between the event list and details inspector maintains a strictly constant width (`w-1.5`). Dynamic width expansions (`hover:w-2 -ml-0.5`) are strictly prohibited to prevent layout jitter.
2. **Zero-Padded Human Bug IDs**: Bug session identifiers are presented as zero-padded numbers (`#01`, `#02`, `#06`), and event step IDs follow the composite format `01|05` or `06|02` for immediate human recognizability in SQLite and CLI workflows.
3. **Dual-Mode Visual Snapshot Preview (Tier 2)**: Full-page screen snapshots support dual before/after verification via a segmented `[Before | After]` toggle capsule. `Before` shows the instantaneous cursor interaction with an animated red locator ring; `After` captures the settled post-action DOM transition (180ms delay).
4. **Z-Index Layer Coordination**: Event Explorer and Previous Bugs modals operate at elevated `z-[100100]` / `z-[100200]`. Underlying modals (such as `PromptTreeViewModal` at `z-[99999]`) dynamically drop to `z-[99980]` with `pointer-events-none opacity-40` when recorder modals are active to eliminate visual occlusion.
5. **Fast Deployment Tooltips**: Native HTML `title` attributes with browser latency are replaced by instant `<Tooltip delayMs={0}>` dark-glass wrappers across action buttons.
6. **Clean Header Title**: Prohibits redundant count capsules (`3 Steps · 3 Snaps`) in the title; displays friendly session sequence names (`Active Session #1`) instead of raw UUID strings (`rec-...`).
7. **Lightbox Return Invariant**: Dismissing the full-screen screenshot preview returns the user directly to the snapshot event table with the active step preserved.
8. **Per-Step Copy Action**:
   - Each event card features a 1-click copy action generating:
     1. A targeted prompt to diagnose and fix that specific step failure.
     2. The exact CLI inspection command: `agm bug event <session-id> <step-no>`.
     3. 2–3 step blast radius context (previous step, current step, next step).

---

## 3. Bug Tracker: Previous Bugs Modal with Unclipped Dropdowns

```
+--------------------------------------------------------------------------------------------------+
|  HISTORICAL BUG SESSIONS & TELEMETRY ARCHIVE                                             [X Close]|
+--------------------------------------------------------------------------------------------------+
|  Search: [ Filter by title, route, machine... ]              Showing 24 Sessions      [🔄 Refresh]|
|                                                                                                  |
|  +--------------------------------------------------------------------------------------------+  |
|  | 06-bug: Focus Conversation Timeout (3 steps · 1 snaps)                15-Nov-26 10:08:30    |  |
|  | Route: /instances → /instances · Duration: 00:32 · Backend Error: E7001                     |  |
|  | [▶ Replay] [Activity Events] [🚀 IDE v] [📄 MD]                                             |  |
|  +--------------------------------------------------------------------------------------------+  |
+--------------------------------------------------------------------------------------------------+
```
- **Unclipped Dropdowns**: The right-hand actions segmented capsule (`[▶ Replay] [Activity Events] [🚀 IDE v] [📄 MD]`) uses `overflow-visible` so the export dropdown renders cleanly above or below without container clipping.
