> [!IMPORTANT]
> Prompt Version: 6.2.0
> Runtime: Google Antigravity 2.0 (IDE and CLI) & Cursor IDE
> Category: 26-gitmap
> Invoke: /gitmap agy-steps
>
> **Top-Instruction Priority Mandate (Above Precedence):**
> Whatever instructions, constraints, domain rules, or user prompts are given ABOVE this prompt (or passed as leading task input) are HIGHEST PRIORITY and MUST BE FOLLOWED as strictly NON-NEGOTIABLE.
> This prompt provides the autonomous execution engine; top instructions provide the mission authority.

# GitMap Antigravity Conversation Steps Query & Aggregation — Canonical Specification (must follow)

> **Antigravity Slash Command Compatibility:**
> Use `[/goal](slashCommand;goal)` to run long-running execution without stopping until verified.
> Use `[/learn](slashCommand;learn)` to persist learned architectural conventions and rules.

You are pair programming with **GitMap**, the ultra-fast developer companion and autonomous CLI engine designed for AI coding agents and software engineers.

---

## 1. Rule Mandate: TOTAL BAN on Ad-Hoc Python Conversation Queries

All autonomous agents, subagents, and scripts interacting with Antigravity SQLite conversation databases MUST strictly adhere to:

```text
TOTAL BAN on:
  python -c "import sqlite3, glob, os ... SELECT count(*) FROM steps ... SELECT step_type ..."
```

Instead, ALWAYS execute the native GitMap command:
```bash
gitmap agy steps [conversation-id] [flags]
# or
gitmap agy conv steps [conversation-id] [flags]
```

---

## 2. Command Catalog & Usage Matrix

| CLI Invocation | Description | Machine-Readable Flag |
| :--- | :--- | :--- |
| `gitmap agy steps` | Scan all Antigravity conversation databases and display step counts & step-type breakdown | `--json` |
| `gitmap agy steps <id>` | Inspect step breakdown for a specific conversation ID or prefix | `--json` |
| `gitmap agy steps --limit <n>` | Limit scan to the $N$ most recently modified conversations (default 50, 0 = all) | `-l <n>` |
| `gitmap agy steps --step-type <type>` | Filter results to conversations containing a specific `step_type` (e.g. 15, 132) | `-t <type>` |
| `gitmap agy steps --summary` | Include global aggregate summary of total steps and step-type frequency distribution | `--summary` |
| `gitmap agy steps --db <path>` | Target a specific conversation SQLite database directly by file path | `--db <path>` |

---

## 3. JSON Output Format (`--json`)

When invoked with `--json`, `gitmap agy steps` outputs a structured JSON array for direct AI consumption:

```json
[
  {
    "conversationId": "13519667-1c44-45d3-9760-be48bec8ea49",
    "totalSteps": 63,
    "stepTypes": [
      {"stepType": 15, "count": 31},
      {"stepType": 90, "count": 1},
      {"stepType": 101, "count": 1},
      {"stepType": 132, "count": 30}
    ],
    "workspace": "d:/work/gitmap",
    "databasePath": "C:\\Users\\Administrator\\.gemini\\antigravity\\conversations\\13519667-1c44-45d3-9760-be48bec8ea49.db",
    "lastModified": "2026-11-16T03:48:00Z"
  }
]
```

---

## 4. Architectural Invariants
1. **Concurrency Safe**: Reads SQLite databases using read-only locks without interrupting active conversation writes.
2. **Instance Fallback**: Discovers databases across `~/.gemini/antigravity/conversations/` and instance directories (`~/.antigravity_tools/instances/*/home/.gemini/antigravity/conversations/`).
3. **Workspace Correlation**: Automatically correlates conversation UUIDs with their workspace root paths from `trajectory_metadata_blob`.
