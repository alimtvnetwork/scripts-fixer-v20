---
name: bug-fixes-and-deployment-instructions
description: Autonomously diagnose and fix Focus button conversation targeting, eliminate delayed focus ping, implement deploy fleet terminal modal with real-time progress, fix cross-instance prompt rerun and delegation, enhance universal copy button, and optimize image deduplication.
---

# Bug Fixes and Deployment Instructions — Master Architecture & Execution Guide

> **Invocation:** `@[bug-fixes-and-deployment-instructions](directory;.agents/skills/bug-fixes-and-deployment-instructions)`

## Overview & Scope
This skill governs the systematic remediation of critical instance lifecycle, fleet deployment, and cross-instance prompt rerun capabilities in Antigravity Manager:
1. **Deploy Fleet Real-Time Terminal & Progress Modal**: Replace silent or non-functional fleet deployment with an interactive modal displaying live terminal stdout/stderr streaming, per-machine progress bars, and aggregate execution summaries.
2. **Focus Button Running Conversation Targeting**: Ensure the instance card Focus button immediately identifies the exact running conversation window (via DevTools CDP / PID / Window Title) and brings it into focus, instead of just focusing the base IDE project window.
3. **Elimination of Delayed Focus Ping / Repush**: Completely eradicate delayed `setTimeout` / interval timers that attempt to re-focus or ping the IDE window 5–10 seconds after initial interaction in both history and focus flows.
4. **Instant Cross-Instance Rerun & Delegation**: Fix cross-instance prompt rerun dispatching, ensuring prompt content, system flags, and target instances cleanly transfer and enqueue without stalls or dropped payloads.
5. **Universal Copy Button Enhancement**: Ensure the prompt copy button copies comprehensive content (including prompt text, file links, and metadata) suitable for direct clipboard pasting anywhere.
6. **Strict Image Deduplication**: Eliminate duplicated or wrapped image payloads during prompt formatting, rerun transfers, and active queue ingestion.
