---
name: agy-db-and-onthefly
description: >-
  Inspect Antigravity conversation states, titles, and idle status or run safe read-only SQL queries on conversation_summaries.db using 'gitmap agy db', and run on-the-fly prompts against the Antigravity assistant directly without project context via 'gitmap agy on-the-fly'.
---

# AGY Database & On-The-Fly Prompting

## Overview
This skill governs native GitMap management of Antigravity's conversation database (`conversation_summaries.db`) and on-the-fly prompt execution without project context.

## 1. AGY Database Inspection & Queries (`gitmap agy db`)
Avoid ad-hoc Python scripts to query `conversation_summaries.db`. Use native GitMap commands:

```bash
# List recent conversation summaries
gitmap agy db

# Show 20 active / running conversations
gitmap agy db 20 --active

# Run direct read-only SQL query
gitmap agy db query "SELECT conversation_id, title FROM conversation_summaries LIMIT 5"

# Output query results in structured JSON format
gitmap agy db query "SELECT * FROM conversation_summaries" --json
```

## 2. On-The-Fly Prompt Execution (`gitmap agy on-the-fly`)
Run prompts against the Antigravity assistant directly without requiring an active project directory:

```bash
# Run task prompt directly to terminal output
gitmap agy on-the-fly "Summarize recent Git commits across all projects"

# Short alias with custom instance and timeout
gitmap agy otf -i primary -t 2m "Explain the Split-DB architecture"
```

## 3. Native MCP Server Tools
- `gitmap_agy_db`: Execute read-only SQL queries or list conversations from `conversation_summaries.db`.
- `gitmap_agy_onthefly`: Execute on-the-fly prompts without project context.
