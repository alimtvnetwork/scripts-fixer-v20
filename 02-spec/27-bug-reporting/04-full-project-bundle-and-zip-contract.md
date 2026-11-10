# Specification 27.04: Full Project Bundle & Portable ZIP Contract

## 1. Portable Bundle Structure (`.bug.zip`)

When a bug report is exported, it packages both the **session flight-recorder data** and the **entire project workspace configuration** into an atomic, self-contained `.bug.zip` archive.

```
<session_id>.bug.zip
├── manifest.json              # Bundle envelope, version, checksums, and machine info
├── session.json               # Full normalized bug session metadata
├── steps.json                 # Sequential interaction telemetry events
├── prompt-v6.md               # Standard AI reproduction prompt (Letterly V6)
├── prompt-v7.md               # Enhanced AI reproduction prompt with code locations (V7)
├── project/
│   ├── project.json           # Full project configuration, rulesets, tolerances
│   ├── camera-settings.json   # Exposure, gain, frame rate, sensor calibration
│   └── light-settings.json    # Strobes, illumination levels, channels
├── screenshots/
│   ├── snap-01-full.png       # Viewport context snapshot
│   ├── snap-01-canvas.png     # Workpiece canvas snapshot
│   └── snap-02-full.png
└── images/
    ├── inspection-frame.png   # Exact image under inspection when defect occurred
    └── sample-boards/         # Golden reference images (Pocket 1, Pocket 2, etc.)
        ├── pocket-1-filled.png
        └── pocket-2-empty.png
```

---

## 2. Manifest Schema (`manifest.json`)

```json
{
  "$schema": "https://specs.industrial-vision.org/schemas/bug-bundle-v1.json",
  "bundleVersion": "1.0.0",
  "sessionId": "rec-20261103-134210-9281",
  "exportedAt": "2026-11-03T13:42:15.120Z",
  "generator": {
    "name": "CAT iVision Flight Recorder",
    "version": "4.122.0"
  },
  "machine": {
    "hostname": "LAB-WORKSTATION-02",
    "operatingSystem": "Windows 11 Pro (10.0.26100)",
    "architecture": "x86_64",
    "cpuCount": 16,
    "totalMemoryGb": 32.0,
    "reportedBy": "alim",
    "runtimeEnvironment": "desktop-client",
    "nodeVersion": "v22.11.0",
    "pythonVersion": "3.13.0"
  },
  "sessionSummary": {
    "title": "T102 Laser Marking Misalignment on Pocket 4",
    "category": "InspectionDefect",
    "stepCount": 14,
    "screenshotCount": 12,
    "errorCount": 1,
    "durationMs": 42150
  },
  "projectAttached": {
    "hasProject": true,
    "projectId": "proj-demoset-smt",
    "projectName": "SMT Tape Strip Inspection",
    "rulesetCount": 2,
    "ruleCount": 6,
    "hasInspectionImage": true,
    "inspectionImageFile": "images/inspection-frame.png"
  }
}
```

---

## 3. Import / Export Lifecycle & Parity Contract

### Export Pipeline:
1. Export Engine extracts records from SQLite `bug_sessions`, `bug_step_events`, `bug_screenshots`, and `bug_project_bundles`.
2. Gathers physical screenshots from disk directory `.logs/recorded-bugs/<session_id>/`.
3. Gathers active project state from `useProjectStore` / `rules.py` including inspection image data URLs / binary buffers.
4. Generates `manifest.json`, `prompt-v6.md`, and `prompt-v7.md`.
5. Compresses into `<session_id>.bug.zip`.

### Import Pipeline:
1. User drops `.bug.zip` onto the UI dropzone or executes `errors-cli --import-zip <file.zip>`.
2. System decompresses into a temporary buffer, validates `manifest.json` against schema.
3. Automatically parses and registers:
   - Machine environment metadata (Host, OS, Reporter).
   - Normalized session rows into SQLite `bug_sessions` and `bug_step_events`.
   - Screenshots into `.logs/recorded-bugs/<session_id>/screenshots/`.
   - Complete project into project database (`projects.db` / `task.db`).
4. UI displays toast notification: *"Successfully imported bug report rec-20261103-... from LAB-WORKSTATION-02"*.
5. Operator can immediately click **"Load Project & Re-Run Inspection"** to inspect the exact defect in 1 click!
