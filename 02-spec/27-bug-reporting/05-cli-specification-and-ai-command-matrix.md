# Specification 27.05: CLI Specification & AI Diagnostic Command Matrix

## 1. CLI Design Objectives for Blind AI Agents

When an AI coding assistant is tasked with diagnosing and fixing a bug, it cannot look at a browser screen interactively unless the CLI gives it structured, granular commands.

This specification defines the universal CLI tool contract (`errors-cli` / `bug-cli`):
1. **Recent Bugs Discovery**: `errors-cli --recent-bugs` shows the newest bug reports, their session IDs, reporter, machine name, and step counts.
2. **Step Inspection**: `errors-cli --step <N>` (or `--inspect-event <N>`) outputs the exact frontend code location (`data-tsd-source`), backend route (`BE/routes/...`), screenshot file link, and human action phrase for Step N.
3. **Drill-Down Stack Trace**: `errors-cli --drill-down <SESSION_ID> --step <N> [--depth full|code|stack]` fetches the stack trace or snippet.
4. **Suggested Follow-up Commands**: Every CLI output appends a `Suggested AI Commands` block giving the AI the exact next shell commands to execute.
5. **Portable Import / Export**: `errors-cli --import-zip <FILE>` and `errors-cli --export-bundle <SESSION_ID>`.

---

## 2. Universal Command Syntax & Options

| Command / Flag | Purpose | Example Usage |
| :--- | :--- | :--- |
| `--recent-bugs [--limit N]` | Lists newest bug sessions with machine, user, and step counts | `python bin/errors-cli.py --recent-bugs` |
| `--step <N>` / `-s <N>` | Inspects Step N of the most recent (or targeted) bug session | `python bin/errors-cli.py --step 7` |
| `--session <ID>` | Targets a specific bug session ID | `python bin/errors-cli.py --session rec-1234 --step 8` |
| `--drill-down <ID> --step <N>` | Retrieves deep stack trace and code snippets | `python bin/errors-cli.py --drill-down rec-1234 --step 7` |
| `--import-zip <PATH>` | Imports a `.bug.zip` archive into SQLite and local directories | `python bin/errors-cli.py --import-zip ./defect.bug.zip` |
| `--export-bundle <ID> [--out F]` | Exports full session and project into a portable ZIP | `python bin/errors-cli.py --export-bundle rec-1234` |
| `--json` | Emits output formatted in Universal Response Envelope JSON | `python bin/errors-cli.py --step 7 --json` |

---

## 3. Sample CLI Terminal Output: `errors-cli --step 7`

```
================================================================================
INSPECTING STEP #07 (Session: rec-20261103-134210-9281)
================================================================================
Timestamp:    +41200ms (13:42:51 UTC)
Screen:       Workpiece Analysis (Route: /projects/demo)
Action:       Clicked 'Analyze Inspection' on canvas control bar
XPath:        //*[@data-ui-id='ui-workspace-run']

CODE LEVEL TRACEABILITY:
  Frontend Source:   src/components/vision/workpiece/WorkpieceAnalyzeWorkspace.tsx:1865:12
  React Component:   WorkpieceAnalyzeWorkspace
  Backend Endpoint:  POST /score
  Backend Handler:   BE/routes/score.py::evaluate_score

VISUAL EVIDENCE:
  Full Viewport:     .logs/recorded-bugs/rec-20261103-134210-9281/screenshots/snap-07-full.png
  Workpiece Canvas:  .logs/recorded-bugs/rec-20261103-134210-9281/screenshots/snap-07-canvas.png

HOST & REPORTER:
  Machine Host:      LAB-WORKSTATION-02
  Operating System:  Windows 11 Pro (10.0.26100)
  Reported By:       alim

--------------------------------------------------------------------------------
💡 SUGGESTED AI COMMANDS FOR NEXT INVESTIGATION STEPS:
  1. Inspect Previous Step:   python bin/errors-cli.py --step 6
  2. Inspect Following Step:  python bin/errors-cli.py --step 8
  3. View Full Stack Trace:   python bin/errors-cli.py --drill-down rec-20261103-134210-9281 --step 7
  4. Inspect Source File:     gitmap cat src/components/vision/workpiece/WorkpieceAnalyzeWorkspace.tsx -L 1850:1880
  5. Inspect Backend Route:   gitmap cat BE/routes/score.py -L 80:120
================================================================================
```

---

## 4. Machine-Readable JSON Output (`--json`)

```json
{
  "Status": "success",
  "Code": "OK_STEP_INSPECTED",
  "SessionId": "rec-20261103-134210-9281",
  "Step": {
    "sequenceNumber": 7,
    "elapsedMs": 41200,
    "screenName": "Workpiece Analysis",
    "route": "/projects/demo",
    "actionPhrase": "Clicked 'Analyze Inspection'",
    "xpath": "//*[@data-ui-id='ui-workspace-run']",
    "source": {
      "filePath": "src/components/vision/workpiece/WorkpieceAnalyzeWorkspace.tsx",
      "line": 1865,
      "column": 12,
      "component": "WorkpieceAnalyzeWorkspace"
    },
    "backend": {
      "endpoint": "/score",
      "method": "POST",
      "file": "BE/routes/score.py",
      "fn": "evaluate_score"
    },
    "evidence": {
      "viewportScreenshot": ".logs/recorded-bugs/rec-20261103-134210-9281/screenshots/snap-07-full.png",
      "canvasScreenshot": ".logs/recorded-bugs/rec-20261103-134210-9281/screenshots/snap-07-canvas.png"
    }
  },
  "Machine": {
    "hostname": "LAB-WORKSTATION-02",
    "os": "Windows 11 Pro",
    "username": "alim"
  },
  "SuggestedAiCommands": [
    "python bin/errors-cli.py --step 6",
    "python bin/errors-cli.py --step 8",
    "python bin/errors-cli.py --drill-down rec-20261103-134210-9281 --step 7"
  ]
}
```
