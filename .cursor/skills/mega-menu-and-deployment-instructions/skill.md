---
name: mega-menu-and-deployment-instructions
description: >-
  Autonomously implement a hover-triggered, non-modal mega menu without scrollbars, recorder start/stop controls, auto-shutdown prioritization, team sub-menu, cross-fleet binary deploy command (close UI, deploy, reopen), flat shaded combined machine & instance dropdown, 30s quota cache, and view executable button.
---

# Mega Menu and Deployment Instructions Specification & Workflow

> **Invocation:** `@[mega-menu-and-deployment-instructions](directory;.agents/skills/mega-menu-and-deployment-instructions)`

## Overview
This skill governs the end-to-end implementation of:
1. **Hover-Activated Mega Menu**: Seamless non-modal dropdown opening on hover without scrollbars, matching website navigation standards.
2. **Recorder Start/Stop Toggle & Auto-Shutdown Prioritization**: Direct toggle on the bug recorder pill and header; auto-shutdown prioritized at top level.
3. **Team Sub-Menu**: Hierarchical sub-menu displayed cleanly upon clicking/hovering without layout disruptions.
4. **Local & Multi-Node Fleet Deployment Engine**:
   - `agm deploy current`: Gracefully terminates running AGM UI, builds/updates latest binary, executes post-install hooks, and relaunches the UI.
   - `agm deploy all`: Extends verified local deployment to all cluster nodes over SSH.
5. **Combined Flat-Shaded Node & Instance Selector**:
   - Merges machine ("Current") and instance dropdowns into a single contiguous flat-shaded pill capsule.
   - Eliminates nested circular borders and disjoint spacing.
6. **30-Second Polled Quota & Prompt Cache**:
   - Reduces query spam; caches remote node quota and running prompt telemetry for 30s.
7. **View Executable Button**:
   - Adds a direct "View Executable" inspection button in the instance section to focus/reveal target binaries.
