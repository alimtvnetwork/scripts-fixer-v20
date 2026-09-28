# 22-deep-uninstaller-suite — Data Contracts & Command Signatures

> **Spec Reference:** [01-overview.md](./01-overview.md)  
> **Status:** active

---

## 1. Project & Conversation State Backup JSON Schema

Before executing the deep purge (`agy-all`), the uninstaller extracts existing conversation summaries and associated workspace project directories. The saved JSON file is written to:
`~/.scripts-fixer/antigravity-projects-backup.json` (and mirrored to `antigravity-projects-backup.json` if run from within a scripts-fixer workspace).

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "saved_at": "2026-09-28T09:30:00Z",
  "total_conversations": 1,
  "projects": [
    {
      "project_name": "scripts-fixer",
      "project_path": "d:/work/scripts-fixer",
      "conversations": [
        {
          "conversation_id": "e82d9254-4786-4dc4-82c7-437162402c61",
          "conversation_name": "Project Conversation Name / Title",
          "last_modified": "2026-09-28T09:15:00Z"
        }
      ]
    }
  ],
  "items": [
    {
      "conversation_id": "e82d9254-4786-4dc4-82c7-437162402c61",
      "conversation_name": "Project Conversation Name / Title",
      "project_name": "scripts-fixer",
      "workspace_uri": "file:///d:/work/scripts-fixer"
    }
  ]
}
```

---

## 2. CLI Command Syntax Matrix

| CLI Invocation | Target Component | Mode | State Backup? | Total Brain Wipe? |
|---|---|---|---|---|
| `cli uninstall agy` / `.\run.ps1 uninstall agy` | Antigravity IDE & CLI | Standard | No | No (keeps brain/cache) |
| `cli uninstall agy-all` / `.\run.ps1 uninstall agy-all` | Antigravity IDE & CLI | Deep Wipe | **Yes (`.json`)** | **Yes (`.gemini`, `brain`, `cache`)** |
| `.\run.ps1 agy uninstall` | Antigravity IDE & CLI | Standard | No | No |
| `.\run.ps1 agy uninstall-all` / `.\run.ps1 agy uninstall --all` | Antigravity IDE & CLI | Deep Wipe | **Yes (`.json`)** | **Yes** |
| `cli uninstall agm` / `.\run.ps1 uninstall agm` | Anti-Gravity Manager | Standard | N/A | No |
| `cli uninstall agm-all` / `.\run.ps1 uninstall agm-all` | Anti-Gravity Manager | Deep Wipe | N/A | Yes (all configs & data) |
| `cli uninstall copilot` / `.\run.ps1 uninstall copilot` | Windows Copilot | Deep Removal | N/A | Yes (AppX & Registry) |
| `cli uninstall edge` / `.\run.ps1 uninstall edge` | Microsoft Edge | Chris Titus WinUtil | N/A | Yes (Browser & Updates) |
| `cli clean-dev` / `.\run.ps1 clean-dev` | Developer Caches | Enhanced Dev-Clean | N/A | Yes (Build/AI Caches) |

---

## 3. Targeted Processes for Termination

| Component | Target Processes |
|---|---|
| Antigravity | `Antigravity`, `antigravity`, `agy`, `antigravity-updater`, language servers (`gopls`, `vtsls`, `python`) spawned under `.gemini` or `antigravity` |
| Anti-Gravity Manager | `antigravity-manager`, `Antigravity Manager`, `agm` |
| Windows Copilot | `Copilot`, `Microsoft.Windows.Ai.Copilot.Provider` |
| Microsoft Edge | `msedge`, `msedgewebview2`, `MicrosoftEdgeUpdate` |

---

## 4. Protected Paths Invariant

The uninstaller suite strictly enforces an immutable protected paths blacklist:
- `D:\work\*` and `d:\work\*` (and current repo root) are NEVER touched.
- User documents, downloads, and non-tool system files are NEVER touched.
- Exit code on safety check violation: `87` (Invalid parameter / safety barrier tripped).
