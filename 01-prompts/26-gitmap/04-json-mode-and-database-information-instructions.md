# AI Execution Instruction: JSON Mode, YAML View & Database Information Instructions

> [!IMPORTANT]
> **Prompt Sequence:** `448`
> **Slug:** `json-mode-and-database-information-instructions`
> **Target Command:** `gitmap agy steps [id] [--json|--yaml|-y|--wide|--summary]`
> **Repository:** `github.com/alimtvnetwork/gitmap-v28`

---

## 1. Context & AI Problem Statement

When autonomous AI assistants or developer tooling query Google Antigravity conversation states, they need rich, structured telemetry without running brittle, ad-hoc Python SQLite scripts.

The AI assistant must be able to query `gitmap agy steps` to receive:
1. **Gemini Root & DB Information**:
   - `geminiRootFolder`: `~/.gemini/antigravity`
   - `conversationsFolder`: `~/.gemini/antigravity/conversations`
   - Concise database names (`<convID>.db`).
2. **Conversation Context**:
   - Up to two recent user prompts truncated to $\le 100$ words with trailing `...`.
3. **Execution & Metric Timing**:
   - Scan duration (`elapsedMs`, `scanDuration`, `queryDurationMs`).
   - Timestamps: `startedAt`, `finishedAt`, `lastModified`, `lastUserInputTime`, `relativeAge`.
4. **Actionable Query Suggestions**:
   - Pre-formatted `gitmap agy db` SQL commands so any tool or AI immediately knows how to inspect deeper into the SQLite tables.
5. **Multi-Format Ingestion**:
   - Beautiful cyan terminal table.
   - Structured JSON envelope (`--json`).
   - Human-readable YAML envelope (`--yaml` / `-y`).

---

## 2. Command Reference for AI Agents

```bash
# 1. Query recent conversations with timing and context in JSON
gitmap agy steps --json --limit 5

# 2. Query recent conversations formatted as YAML
gitmap agy steps --yaml --limit 5

# 3. Inspect a specific conversation with full context and prompt history
gitmap agy steps 3355384c

# 4. Global aggregate step distribution with suggestions
gitmap agy steps --summary --json

# 5. Execute suggested SQL query against conversation database
gitmap agy db "SELECT count(*) FROM steps"
gitmap agy db "SELECT step_type, count(*) FROM steps GROUP BY step_type"
gitmap agy db "SELECT idx, step_type, status FROM steps ORDER BY idx DESC LIMIT 10"
```

---

## 3. Structural Contracts

### JSON Output Contract
```json
{
  "databaseInfo": {
    "geminiRootFolder": "C:\\Users\\Administrator\\.antigravity_tools\\instances\\v3-125\\home\\.gemini\\antigravity",
    "geminiRootRelative": "~/.gemini/antigravity",
    "conversationsFolder": "C:\\Users\\Administrator\\.antigravity_tools\\instances\\v3-125\\home\\.gemini\\antigravity\\conversations",
    "conversationsRelative": "~/.gemini/antigravity/conversations",
    "summariesDatabasePath": "C:\\Users\\Administrator\\.antigravity_tools\\instances\\v3-125\\home\\.gemini\\antigravity\\conversation_summaries.db"
  },
  "timing": {
    "startedAt": "2026-11-16T08:30:00Z",
    "finishedAt": "2026-11-16T08:30:00Z",
    "elapsedMs": 48.5,
    "scanDuration": "48ms"
  },
  "totalConversations": 1,
  "totalSteps": 2778,
  "globalTypeCounts": [
    { "stepType": 14, "count": 17 },
    { "stepType": 15, "count": 1363 }
  ],
  "suggestions": [
    "gitmap agy db \"SELECT count(*) FROM steps\"",
    "gitmap agy db \"SELECT step_type, count(*) FROM steps GROUP BY step_type\"",
    "gitmap agy steps 3355384c --yaml"
  ],
  "conversations": [
    {
      "conversationId": "3355384c-4ea3-4189-8cfd-5f3284297e05",
      "title": "Fix Build And Deploy Script",
      "totalSteps": 2778,
      "stepTypes": [...],
      "workspace": "d:\\work\\gitmap",
      "databaseName": "3355384c-4ea3-4189-8cfd-5f3284297e05.db",
      "databasePath": "...",
      "databaseRelativePath": "~/.gemini/antigravity/conversations/3355384c-4ea3-4189-8cfd-5f3284297e05.db",
      "timing": {
        "lastModified": "2026-11-16T07:46:35Z",
        "lastUserInputTime": "2026-11-16T07:44:00Z",
        "queryDurationMs": 1.2,
        "relativeAge": "45m ago"
      },
      "context": {
        "lastPrompts": [
          "with conversation try to have db folder informed in the top...",
          "lease have an AGY query where you could perform this type of query..."
        ],
        "preview": "with conversation try to have db folder informed in the top..."
      },
      "suggestions": [
        "gitmap agy steps 3355384c --yaml",
        "gitmap agy db \"SELECT * FROM steps WHERE step_type = 1 LIMIT 5\""
      ]
    }
  ]
}
```
