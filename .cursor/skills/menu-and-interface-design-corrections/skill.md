---
name: menu-and-interface-design-corrections
description: >-
  Autonomously execute flat non-grouped mega menu redesign, real-time fleet ping/connectivity accuracy, bug recorder naming, theme & accent color application fixes across the whole system, settings page modernization (border-less cards & polished dropdowns), mega menu global search, header dropdown hover fix, instance card new-instance button removal, and Telegram prompt truncation (50-100 words with expand/copy/rerun).
---

# Menu and Interface Design Corrections

> **Invocation:** `@[menu-and-interface-design-corrections](directory;.agents/skills/menu-and-interface-design-corrections)`

## Invocations & Shortcuts
- **Task Identifier:** `264-menu-and-interface-design-corrections`
- **Specification:** [`02-spec/21-app/264-menu-and-interface-design-corrections/01-architecture-spec.md`](02-spec/21-app/264-menu-and-interface-design-corrections/01-architecture-spec.md)
- **Completed Plan:** [`.ai-memory/plans/completed/264-menu-and-interface-design-corrections.md`](.ai-memory/plans/completed/264-menu-and-interface-design-corrections.md)
- **Invocation:** `@[menu-and-interface-design-corrections](file;.agents/skills/menu-and-interface-design-corrections)`

## Core Directives
1. **Flat Design Mega Menu**: Eliminate artificial bordered column grouping; blend sections seamlessly with soft background tinting and unified header alignment.
2. **Real-time Fleet Status Probe**: Query live node reachability via SSH ping / health check cache instead of assuming all nodes are online.
3. **Bug Recorder & Bug Reporting**: Rename "RECORDERS" / "Start Recording" to "BUG RECORDER" and "Bug Reporting".
4. **Theme & Accent Color Reactivity**: Fix CSS variable / Tailwind theme accent updates so selecting any color palette immediately applies across the UI.
5. **Settings Page Modernization**: Remove harsh multi-layered borders, eliminate paper design look, style dropdowns with smooth hover states and dark-glass elegance.
6. **Mega Menu Unified Search**: Top search bar searching across mega menu actions, settings tabs, and dropdown menus.
7. **Header Hover Deconfliction**: Ensure hovering the mega menu does not conflict with or blur other dropdowns.
8. **Remove New Instance Button**: Eliminate unused "New Instance" button from the instances view.
9. **Telegram Prompt Compactness**: Truncate prompts to 50-100 words with expandable inline view, copy, and rerun actions.
10. **Deployment & Release**: Verify all features locally, deploy to current machine (`agm deploy current`), and perform release ceremony.
