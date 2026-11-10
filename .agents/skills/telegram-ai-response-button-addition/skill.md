---
name: telegram-ai-response-button-addition
description: >-
  Add Telegram AI response inspection button, multi-machine fleet running project aggregator (up to 8 projects, >=100 words), fast telemetry caching, last-2 AI response extraction, and Telegram 4096-char multi-part message splitting.
---

# Telegram AI Response Button Addition

> **Invocation:** `@[telegram-ai-response-button-addition](directory;.agents/skills/telegram-ai-response-button-addition)`

## Core Protocol & Technical Architecture
1. **Button & Keyboard Addition**:
   - Register inline keyboard action `🤖 Check AI Response` with callback data `check_ai_response`.
   - Provide command alias `/ai_response` in Telegram bot dispatcher.
2. **Multi-Machine & Running Projects Aggregation**:
   - Aggregate open cluster machines via SSH / Supabase registry.
   - Enumerate all instances and active running projects (limit to 8 projects).
   - Display at least 100 words of the running prompt for each project.
3. **Caching Layer**:
   - Implement fast TTL cache for fleet status and response telemetry to guarantee sub-second repeat responses.
4. **Last-2 AI Responses Extraction**:
   - Reverse-scan un-truncated `transcript_full.jsonl` past telemetry/heartbeat records.
   - Extract the last 2 assistant responses (`thinking` and `content`).
5. **Multi-Part Message Splitting**:
   - Bounded splitting adhering to Telegram's 4096-character maximum limit per message (`[Part X/Y]`).
