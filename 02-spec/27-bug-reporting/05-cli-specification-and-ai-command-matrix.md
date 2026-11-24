# Specification 27.05: CLI Specification & AI Diagnostic Command Matrix

## 1. CLI Design Objectives for Blind AI Agents

When an AI coding assistant is tasked with diagnosing and fixing a bug, it cannot look at a browser screen interactively unless the CLI gives it structured, granular commands.

This specification defines the universal CLI tool contract implemented across `agm bug` (Rust/Tauri) and `errors-cli` (Python/Node):
1. **Recent Bugs Discovery**: `agm bug list` (or `errors-cli --recent-bugs`) shows newest bug reports, session IDs, bug sequence (`06-bug`), duration, and step counts.
2. **Session Inspection**: `agm bug show <id|latest>` shows complete session metadata, initial/final routes, duration, step counts, and backend trace summary.
3. **Step Inspection with Blast Radius**: `agm bug event <id> <step> [--blast-radius 2]` outputs the exact frontend code location (`data-tsd-source`), backend route/handler, screenshot file link, human action phrase, and adjacent 2–3 step blast radius for Step N.
4. **Suggested Follow-up Commands**: Every CLI output appends a `Suggested AI Commands` block giving the AI the exact next shell commands to execute.
5. **Portable Import / Export**: `agm bug export <id>` and `errors-cli --import-zip <PATH>`.

---

## 2. Universal Command Syntax & Options (`agm bug`)

| Command / Flag | Purpose | Example Usage |
| :--- | :--- | :--- |
| `agm bug list [--limit N] [--json]` | Lists newest bug sessions with sequence, duration, and step counts | `agm bug list --limit 10` |
| `agm bug show <id\|latest> [--json]` | Displays high-level summary and step list for a session | `agm bug show latest` |
| `agm bug event <id> <step> [--blast-radius N]` | Inspects specific event with 2–3 step blast radius & backend code (supports `agm bug event 07 2`, `07\|02`, and `07:02`) | `agm bug event 06-bug 1 --blast-radius 2` |
| `agm bug latest` | Quick shortcut for `agm bug show latest` | `agm bug latest` |
| `--json` | Emits output formatted in Universal Response Envelope JSON | `agm bug event latest 1 --json` |

---

## 3. Sample CLI Terminal Output: `agm bug event 06-bug 1`

```
================================================================================
INSPECTING STEP #01 (Session: 06-bug · rec-mwhwqqp7-w8yv7)
================================================================================
Timestamp:    +2100ms (10:08:30 UTC)
Route:        /instances
Action:       Clicked 'Focus IDE (Default)' on InstanceCardProjects
XPath:        //*[@id='btn-focus-ide']

BACKEND CODE TRACEABILITY (TOP TIER):
  Backend Function:  focus_resolved_conversation
  Source File:       src-tauri/src/modules/instance/focus_activation.rs:71
  IPC Command:       invoke.focus_or_launch_instance
  Execution Status:  E7001 (Failed to activate conversation: CDP session returned false)
  Stack Trace:       src-tauri/src/modules/instance/focus_activation.rs:94

FRONTEND DOM & SOURCE CONTEXT:
  Frontend Source:   src/pages/instances/InstanceCardProjects.tsx:294:15
  Target Element:    button#btn-focus-ide.rounded-md
  Target Label:      Focus IDE (Default) on d:\work\Antigravity-Manager

VISUAL EVIDENCE:
  Step Snapshot:     .logs/recorded-bugs/06-bug/screenshots/step-01.png
  Locator Ring:      Red animated ring at coordinates (x: 412, y: 185)

--------------------------------------------------------------------------------
BLAST RADIUS CONTEXT (Adjacent Steps):
  [Step #0] (Initial State) Navigation to /instances
  [Step #1] (Current Step) Clicked 'Focus IDE (Default)' -> Backend Error E7001
  [Step #2] Clicked 'Prompt Input Box' -> Focused textarea#prompt-input

--------------------------------------------------------------------------------
💡 SUGGESTED AI COMMANDS FOR NEXT INVESTIGATION STEPS:
  1. Inspect Previous Step:   agm bug event 06-bug 0
  2. Inspect Following Step:  agm bug event 06-bug 2
  3. Inspect Backend Source:  gitmap cat src-tauri/src/modules/instance/focus_activation.rs -L 70:110
  4. Inspect SafeIo Wrapper:  gitmap cat src/utils/safeIo.ts -L 30:70
================================================================================
```

---

## 4. Machine-Readable JSON Output (`--json`)

```json
{
  "Status": "success",
  "Code": "OK_STEP_INSPECTED",
  "SessionId": "rec-mwhwqqp7-w8yv7",
  "BugSeq": "06-bug",
  "Step": {
    "stepNumber": 1,
    "timestamp": 1794751710000,
    "route": "/instances",
    "action": "Clicked 'Focus IDE (Default)'",
    "backend": {
      "functionName": "focus_resolved_conversation",
      "fileName": "src-tauri/src/modules/instance/focus_activation.rs",
      "lineNumber": 71,
      "commandName": "invoke.focus_or_launch_instance",
      "status": "E7001",
      "stackTrace": "src-tauri/src/modules/instance/focus_activation.rs:94"
    },
    "frontend": {
      "file": "src/pages/instances/InstanceCardProjects.tsx",
      "line": 294,
      "targetTag": "button",
      "targetId": "btn-focus-ide",
      "xpath": "//*[@id='btn-focus-ide']"
    },
    "screenshotPath": ".logs/recorded-bugs/06-bug/screenshots/step-01.png",
    "blastRadius": [
      { "stepNumber": 0, "action": "Navigation to /instances" },
      { "stepNumber": 1, "action": "Clicked 'Focus IDE (Default)'", "error": "E7001" },
      { "stepNumber": 2, "action": "Clicked 'Prompt Input Box'" }
    ]
  }
}
```
