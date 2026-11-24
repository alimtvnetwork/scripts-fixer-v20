---
name: cluster-fleet-and-ui-improvements
description: >-
  Cluster fleet deployment error surfacing, active node prioritization, theme builder & visualizer performance, iconified action buttons, theme picker custom dropdown, and drag resize UI fixes.
---

# Cluster Fleet and UI Improvements

> **Invocation:** `@[cluster-fleet-and-ui-improvements](directory;.agents/skills/cluster-fleet-and-ui-improvements)`

## Objectives
1. **Cluster Fleet Deploy All & Active Node Prioritization**:
   - In Mega Menu and Deployment Orchestrator (`DeployProgressModal.tsx`, `fleetUpdateService.ts`), sort active/online nodes to top and off/unreachable nodes to bottom.
   - Visually gray out (lower opacity, muted borders) switch-off/offline machines.
   - Smart "Deploy All Fleet" selects active machines and automatically unchecks/skips switched-off machines.
2. **Surface Deployment Errors & Unswallowed Terminal Output**:
   - When deploying to fleet nodes (e.g., `w1`), capture real error details (SCP write failure, SSH handshake, timeout) and spill out exact failure details to the terminal modal and logs. Never swallow errors or hang indefinitely.
3. **Bug Report Deep Navigation Confirmation**:
   - Confirm that the system can read and navigate any bug report step-by-step by slug, extracting frontend/backend file locations, code snippets, and telemetry.
4. **Start Button & Conversation Focus Invariant**:
   - Ensure the instance Start button automatically navigates/moves to the active conversation inside the Antigravity IDE after startup.
   - "Start All" displays a spinner while starting and disables itself once all instances are running; periodically checks PIDs every 30 minutes to re-enable "Start All" if any instance stops.
5. **Theme Builder & Data Visualizer Latency Resolution**:
   - Diagnose why `http://127.0.0.1:19527/builder` hangs or loads slowly; ensure local visualizer server starts properly and renders instantly without freeze.
6. **Card UI Iconification & Turns Count Simplification**:
   - Convert `Focus`, `Date`, `IDE`, and `Transcripts` text buttons into compact, sleek icon buttons (`<Monitor />`, `<Calendar />`, `<Cpu />`, `<FileText />`).
   - Shorten `"156 turns"` to just `"156"` with hover tooltip `"156 turns"`.
7. **Explore Ideas Button Removal**:
   - Remove redundant `Explore Ideas` button next to the `Next` button.
8. **Mega Menu Theme Picker Enhancement**:
   - Render color combination preview dots in theme picker.
   - Convert to a custom dark-glass dropdown with an `Edit` button that opens the theme builder in browser.
9. **Prompt Tree View Drag Resizer Hover Glitch**:
   - Prevent the resize splitter from expanding width/height on hover; style hover state with background color change only.
