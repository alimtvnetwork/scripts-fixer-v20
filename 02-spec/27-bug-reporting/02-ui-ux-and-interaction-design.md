# Specification 27.02: Universal UI/UX & Interaction Design for Bug Reporting

## 1. Visual Anatomy & Industrial Design Language

The Bug Reporting UI adheres to the **Tokyo Night Dark Glassmorphic Theme** (`#0c101a` deep navy canvas, `#151c2e` elevated card containers, `rgba(255,255,255,0.08)` borders, and cyan/emerald status accents).

### Component 1: Floating Recorder HUD Pill
A compact, 32px height floating status pill docked at the top center of the viewport:

```
+-----------------------------------------------------------------------------------------+
| [🔴 REC 00:44] | [Step #7] | [Snap #6] | [📸 Note] | [💬 Chat] | [⏸ Pause] | [⏹ Stop] | [⚙] |
+-----------------------------------------------------------------------------------------+
```
- **State Indicators**:
  - Recording Active: Glowing red pulsating badge (`#f43f5e`, `animate-pulse`).
  - Paused: Warm amber badge (`#f59e0b`).
  - Loading / Hydrating: Compact spinning `Loader2` skeleton (`data-testid="recorder-launcher-skeleton"`, `aria-busy="true"`).
- **Controls**:
  - `Snap Note`: Takes an instant high-resolution screenshot and prompts for a human annotation.
  - `Step Counter`: Interactive button displaying current step count; clicking opens the **Event Explorer Modal**.
  - `Stop Button`: Finalizes session and immediately launches the **Bug Summary & Export Modal**.

---

## 2. Bug Summary & Export Modal (Responsive Layout)

```
+---------------------------------------------------------------------------------------+
|  REPORT DEFECT / RECORDED BUG                                                [X Close]|
+---------------------------------------------------------------------------------------+
|  Title:           [ IC Pin 1 False Defect on Pockets 2 and 4                        ]  |
|  Category:        [ (v) Inspection Defect | Crash/Error | Performance | Other        ]  |
|                                                                                       |
|  Expected Behavior:                                                                   |
|  [ Pin 1 detector should recognize 24px circular fiducial with >85% confidence.     ]  |
|                                                                                       |
|  Actual Behavior:                                                                     |
|  [ Returns 0.00 score and flags FALSE_DEFECT due to contrast thresholding at 170.    ]  |
|                                                                                       |
|  MACHINE ENVIRONMENT (Auto-Captured):                                                 |
|  +---------------------------------------------------------------------------------+  |
|  | Host: LAB-INSPECT-04 | OS: Windows 11 (10.0.26100) | Reporter: eng-operator-01  |  |
|  | Arch: x86_64 | Python: 3.13.0 | Screen: 1920x1080 (DPR: 1.25) [Edit Info]       |  |
|  +---------------------------------------------------------------------------------+  |
|                                                                                       |
|  PROJECT BUNDLE ATTACHMENT:                                                           |
|  [x] Include full project configuration, rulesets, tolerances & reference images       |
|                                                                                       |
|  [📥 Export ZIP]  [📋 Copy V6 Prompt]  [📋 Copy V7 Prompt]  [✉ Email]  [☁ Cloud Sync] |
+---------------------------------------------------------------------------------------+
```

---

## 3. Bug Tracker: Previous Bugs Modal with Import / Export Section

```
+---------------------------------------------------------------------------------------+
|  HISTORICAL BUG SESSIONS & TELEMETRY ARCHIVE                                  [X Close]|
+---------------------------------------------------------------------------------------+
|  IMPORT / EXPORT BUNDLE DOCK:                                                         |
|  +---------------------------------------------------------------------------------+  |
|  |  📥 DRAG & DROP .BUG.ZIP HERE  OR  [ Browse Files ]                             |  |
|  |  Directly import and restore recorded sessions, steps, screenshots & full project|  |
|  +---------------------------------------------------------------------------------+  |
|                                                                                       |
|  Search: [ Filter by title, route, machine... ]    Category: [ All Categories (v) ]   |
|  Showing 24 Recorded Sessions                                            [🔄 Refresh]  |
|                                                                                       |
|  +---------------------------------------------------------------------------------+  |
|  | 🔴 T102 Laser Marking Misalignment (Step #14 · 42s)       03-Nov-26 13:42:10   |  |
|  | Host: LAB-WORKSTATION-02 · User: alim · OS: Windows 11 · Category: Inspection   |  |
|  | Steps: 14 | Snaps: 12 | Errors: 1 | Project: SMT Demo Carrier Strip (3 Rules)    |  |
|  | [📦 Export Full Bundle] [🔍 View Steps] [📋 Copy V7 Prompt] [✉ Resend Email]   |  |
|  +---------------------------------------------------------------------------------+  |
|  | 🟡 Runner Script Port Conflict on Restart (Step #4 · 12s)   03-Nov-26 12:15:02   |  |
|  | Host: CI-RUNNER-NODE-01 · User: runner · OS: Ubuntu 24.04 · Category: Crash    |  |
|  | Steps: 4 | Snaps: 2 | Errors: 2 | Project: N/A (CLI Run Engine)                 |  |
|  | [📦 Export Full Bundle] [🔍 View Steps] [📋 Copy V7 Prompt] [✉ Resend Email]   |  |
|  +---------------------------------------------------------------------------------+  |
+---------------------------------------------------------------------------------------+
```

---

## 4. Responsive Breakpoint Standards

- **Desktop ($\ge 1280px$)**: Dual-column modal showing session metadata list on left and instant event timeline / screenshot preview on right.
- **Laptop / Tablet ($768px - 1279px$)**: Stacked layout with collapsible import dropzone and full-width session cards.
- **Mobile / Compact ($\le 767px$)**: Single-column vertical scroll, sticky top search/filter header, compact button icons.
