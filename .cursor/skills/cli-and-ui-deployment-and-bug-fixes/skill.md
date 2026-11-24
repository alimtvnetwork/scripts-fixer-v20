---
name: cli-and-ui-deployment-and-bug-fixes
description: >-
  Autonomously orchestrate CLI and UI deployment of Antigravity Manager (AGM) and GitMap across cluster nodes, build a professional dark-glass Update UI with CSS3 hover animations, fix instance card prompt badges, enforce credit-safe clone account selection, shield IDE auto-switching with try-catch logging, reorder prompt preview buttons to Copy-Send-Next, preserve image attachments on send/rerun, and ensure direct local execution for the current machine.
---

# CLI and UI Deployment and Bug Fixes

> **Invocation:** `@[cli-and-ui-deployment-and-bug-fixes](directory;.agents/skills/cli-and-ui-deployment-and-bug-fixes)`

## Overview
This skill governs the end-to-end implementation and verification of:
1. **Fleet CLI & UI Deployment Pipeline**:
   - `agm deploy` / `gitmap deploy-bin` for AGM and GitMap binaries across fleet nodes (`w1`, `w2`, etc.).
   - Professional dark-glass Update UI in Settings with CSS3 hover transitions.
   - Graceful app closure prior to in-place binary replacement.
   - GitMap deployment audit trail with installer hash ID, sender, receiver, and speed DB records.
2. **Instance & Header UI Bug Fixes**:
   - Removal of redundant `● Prompt` badge on instance cards.
   - Credit-safe clone account selection (>=18% weekly quota, PRO tier priority).
   - Defensive try-catch error routing for IDE switching to eliminate silent crashes.
   - Header button reordering: `[Copy ⌵] [Send N ⌵] [Next 20 ⌵]`.
   - Lossless image attachment preservation in prompt send and rerun flows.
   - Direct local execution bypass when target node is the current machine (`w2`).
