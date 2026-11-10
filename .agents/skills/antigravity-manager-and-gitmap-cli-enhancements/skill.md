---
name: antigravity-manager-and-gitmap-cli-enhancements
description: >-
  Inspect, parse, browse, and backup system-generated Antigravity conversation transcripts (transcript.jsonl / transcript_full.jsonl) across projects and instances via fluent CLI commands and visual UI dropdowns in Antigravity Manager and GitMap, backed by project-level SQLite databases.
---

# Antigravity Manager and GitMap CLI Enhancements

> **Invocation:** `@[antigravity-manager-and-gitmap-cli-enhancements](directory;.agents/skills/antigravity-manager-and-gitmap-cli-enhancements)`

## Overview
This skill provides comprehensive CLI commands, UI components, and SQLite caching pipelines to inspect, browse, feed, and back up Antigravity system-generated conversation transcripts (`transcript.jsonl` and `transcript_full.jsonl`).

## Key Capabilities
1. **System Transcript Discovery**: Automatically locates brain conversation folders across Antigravity instances (`.gemini/antigravity/brain/<conversation-id>/.system_generated/logs/`).
2. **Project & Conversation Resolution**: Resolves human-readable conversation names/titles from initial user prompts or metadata instead of bare UUIDs, while tracking the underlying UUID.
3. **Fluent CLI Commands (`agm transcripts` & `gitmap agy transcript`)**:
   - `list`: Browse available projects, instances, and conversations by human name and ID.
   - `inspect`: Read conversation transcripts with reverse scanning and step filtering.
   - `backup`: Incrementally sync and back up transcript steps into project-scoped SQLite database (`transcripts.db`).
   - `export`: Export clean Markdown or JSON digests for feeding directly into LLMs/AI contexts.
4. **Visual UI Integration**:
   - Instance section JSON view dropdown allowing project-by-project and conversation browsing.
   - GitMap AGY UI integration for visual exploration.
5. **Project-Scoped SQLite Archival**:
   - Split-DB schema organizing steps, tool calls, and model thoughts for zero-latency queries.
