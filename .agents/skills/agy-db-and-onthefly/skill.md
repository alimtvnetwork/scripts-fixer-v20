---
name: agy-db-and-onthefly
description: >-
  Inspect Antigravity conversation states, titles, step metrics, and step-type breakdowns, decode Protobuf raw summaries via 'gitmap agy proto', run safe read-only SQL queries on conversation databases using 'gitmap agy db' and 'gitmap agy steps', and run on-the-fly prompts against the Antigravity assistant directly without project context via 'gitmap agy on-the-fly'.
---

# AGY Database & On-The-Fly Prompting

## Overview
This skill governs native GitMap management of Antigravity's conversation databases (`conversation_summaries.db` and individual `<uuid>.db` files), Protobuf wire-format raw summary decoding, step metrics inspection, and on-the-fly prompt execution without project context.

## 1. AGY Database Inspection & Queries (`gitmap agy db`, `gitmap agy summaries`)
TOTAL BAN on running ad-hoc Python scripts like:
```python
# ❌ FORBIDDEN: Do not run ad-hoc python scripts to query conversation_summaries.db
import sqlite3
conn = sqlite3.connect(r'C:\Users\Administrator\.gemini\antigravity\conversation_summaries.db')
rows = conn.execute('SELECT conversation_id, title, workspace_uris, raw_summary IS NULL FROM conversation_summaries').fetchall()
for r in rows:
    print(r)
```

Instead, ALWAYS execute native GitMap commands or MCP tool `gitmap_agy_db`:

```bash
# List recent conversation summaries with Proto status, workspace, and timestamps
gitmap agy summaries
gitmap agy db 10

# Inspect in Wide format with full 36-char UUID and complete path
gitmap agy summaries -w

# Output in JSON format including hasRawSummary, rawSummaryBytes, and workspaceUris
gitmap agy summaries --json

# Output in multi-line YAML format
gitmap agy summaries --yaml

# Filter by Protobuf raw_summary presence or absence
gitmap agy summaries --proto
gitmap agy summaries --missing-proto

# Run direct read-only SQL query against conversation_summaries.db
gitmap agy db query "SELECT conversation_id, title, workspace_uris, raw_summary IS NULL FROM conversation_summaries LIMIT 5"
gitmap agy db query "SELECT * FROM conversation_summaries" --json

# List recent conversations with DB names and Proto badges
gitmap agy conv ls 5
```

## 2. Conversation Steps Query, Timing & Prompt Context (`gitmap agy steps`)
TOTAL BAN on running ad-hoc Python scripts like:
```python
# ❌ FORBIDDEN: Do not run ad-hoc python scripts to query steps
python -c "import sqlite3, glob, os ... SELECT count(*) FROM steps ... SELECT step_type, count(*) ..."
```

Instead, ALWAYS execute the native `gitmap agy steps` (or `gitmap agy conv steps`) command:

```bash
# Query all conversations: total steps count, titles, step types, and DB name
gitmap agy steps

# Limit scan to the last 20 conversations
gitmap agy steps --limit 20

# Query a specific conversation ID with full context and prompt history
gitmap agy steps 3355384c

# Output structured JSON with granular timing, last 2 prompts (<=100 words), and suggestions
gitmap agy steps --json

# Output multi-line YAML document with timing, context, and query suggestions
gitmap agy steps --yaml

# Short YAML alias for specific conversation
gitmap agy steps 3355384c -y

# Filter conversations by specific step_type (e.g. 15)
gitmap agy steps --step-type 15

# Include global aggregate statistics across all conversations
gitmap agy steps --summary

# Query steps from a direct database file path
gitmap agy steps --db "C:\path\to\conversation.db"
```

### Suggested AI Follow-up Queries
When investigating conversation internals, use these pre-formatted commands:
```bash
# Count total steps recorded in current session
gitmap agy db "SELECT count(*) FROM steps"

# Step-type frequency breakdown (1 = user input, 15 = assistant turn, etc.)
gitmap agy db "SELECT step_type, count(*) FROM steps GROUP BY step_type"

# Inspect the 10 most recent execution steps
gitmap agy db "SELECT idx, step_type, status FROM steps ORDER BY idx DESC LIMIT 10"

# List recent workspace conversations with prompt snippets
gitmap agy conv ls 5
```

## 3. Protobuf Raw Summary Wire Decoding (`gitmap agy proto`)
TOTAL BAN on running ad-hoc Python Protobuf decoders like:
```python
# ❌ FORBIDDEN: Do not run ad-hoc python scripts to parse raw_summary protobuf blobs
python -c "import sqlite3; from trajectory_metadata_patcher import parse_proto_fields; ... parse_proto_fields(raw) ..."
```

Instead, ALWAYS execute native `gitmap agy proto` (or `gitmap agy raw-summary`, `gitmap agy proto-fields`):

```bash
# Decode latest conversation's raw_summary Protobuf fields
gitmap agy proto

# Decode specific conversation by UUID or prefix
gitmap agy proto beb1b119-eb06-4555-9183-e38f6fd50240

# Filter for specific field tags (e.g. 1: Title, 4: ConversationID, 9: Workspace)
gitmap agy proto beb1b119 -f 1,4,9

# Recursively decode nested protobuf messages (Field 9 Workspace, Field 17 Metadata)
gitmap agy proto --nested

# Output structured JSON for automated AI ingestion
gitmap agy proto --json

# Output multi-line YAML document
gitmap agy proto --yaml

# List conversation summaries table with decoded protobuf fields
gitmap agy summaries --proto
```

### Known Antigravity Protobuf Field Semantics
| Tag | Wire Type | Type | Semantic Name | Description |
|:---:|:---:|:---|:---|:---|
| `1` | `2` | String | `Title` | Human-readable conversation title |
| `2` | `0` | Varint | `StepSequence` | Current step index / message sequence |
| `4` | `2` | String | `ConversationID` | Canonical UUID of the conversation |
| `7` | `2` | String | `ModelSource` | Underlying LLM model or client origin |
| `9` | `2` | Sub-message | `WorkspaceInfo` | Workspace file URI, path, and branch |
| `10`| `2` | String | `AppDataDir` | Application data folder path |
| `17`| `2` | Sub-message | `MetadataBlob` | Internal runtime trajectory metadata |

## 4. On-The-Fly Prompt Execution (`gitmap agy on-the-fly`)
Run prompts against the Antigravity assistant directly without requiring an active project directory:

```bash
# Run task prompt directly to terminal output
gitmap agy on-the-fly "Summarize recent Git commits across all projects"

# Short alias with custom instance and timeout
gitmap agy otf -i primary -t 2m "Explain the Split-DB architecture"
```

## 5. Native MCP Server Tools
- `gitmap_agy_db`: Execute read-only SQL queries or list conversations from `conversation_summaries.db`.
- `gitmap_agy_steps`: Query conversation step counts and step-type breakdowns across conversation databases.
- `gitmap_agy_proto`: Decode and inspect Protobuf `raw_summary` fields and nested sub-messages.
- `gitmap_agy_onthefly`: Execute on-the-fly prompts without project context.
