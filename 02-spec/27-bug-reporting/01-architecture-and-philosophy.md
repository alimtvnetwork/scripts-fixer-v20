# Specification 27.01: Universal Bug Reporting Architecture & Philosophy

## 1. Executive Summary & Blind-AI Contract

This specification establishes a **language-agnostic, zero-context blueprint** for building a production-grade, autonomous bug reporting and session telemetry engine in any software ecosystem (TypeScript, Python, Go, Rust, C#, Java, PHP).

A "blind AI" with zero knowledge of prior systems can read this directory and construct a fully compliant bug reporting system from scratch.

### Core Philosophy: The Deterministic Reproduction Invariant
A bug report is **NOT** a vague text ticket. It is an **executable, deterministic flight-recorder package** containing:
1. **Physical Environment Context**: Host machine name, operating system, architecture, kernel, CPU, GPU, memory, username, and timestamp.
2. **Sequential Step-by-Step Telemetry**: Exactly what the human or agent did at $T + \Delta t$ milliseconds (clicks, inputs, drags, zooms, keyboard navigation, routes).
3. **Dual Visual Evidence**: Both full-window context screenshots and focused component/canvas snapshots for every interaction step.
4. **Code-Level Traceability**: Exact frontend file path, line, column, React/component name, AND backend route endpoint, handler file, and function name.
5. **State Snapshot / Project Bundle**: The complete project state (rulesets, cameras, lights, calibration parameters, and sample images) enabling 1-click reproduction.
6. **Automated AI Diagnostic Prompts (V6 / V7 Letterly Format)**: Ready-to-execute prompts allowing coding assistants to isolate the root cause immediately without manual back-and-forth.

---

## 2. High-Level Subsystem Topology

```
+-----------------------------------------------------------------------------------+
| USER INTERACTION LAYER (Frontend Web / Desktop / Mobile)                          |
| - Event Interceptor (Clicks, Inputs, Drags, Route Changes)                        |
| - Dual Snapshot Capture (Offscreen Canvas / HTML2Canvas / Native API)             |
| - Source Map Resolver (Vite/Webpack JSX source tag extraction: file:line:col)     |
| - Backend Route Tagging (data-backend-* DOM annotations)                          |
+-----------------------------------------------------------------------------------+
                                        │
                                        ▼ (HTTP POST / IPC Stream)
+-----------------------------------------------------------------------------------+
| CORE FLIGHT RECORDER & NORMALIZATION DAEMON (Local Backend Server)                |
| - Machine Metadata Harvester (Platform, Hostname, Username, CPU)                  |
| - Normalization Engine (Decomposes sessions, steps, screenshots, project data)    |
| - SQLite Split-DB Persistence (3NF Relational Tables with Foreign Keys)           |
| - ZIP Bundle Archiver (Creates .bug.zip with JSON manifests, images, prompts)     |
| - Delivery Pipelines (Local Disk, Supabase Cloud Storage, SMTP Email)             |
+-----------------------------------------------------------------------------------+
                                        │
                    ┌───────────────────┴───────────────────┐
                    ▼                                       ▼
+---------------------------------------+   +---------------------------------------+
| DEVELOPER & AI CLI FACADE             |   | EMBEDDED BUG TRACKER UI               |
| - `errors-cli --recent-bugs`          |   | - Previous Bugs Filter Modal          |
| - `errors-cli --step <N>`             |   | - ZIP Drag & Drop Import / Export     |
| - `errors-cli --drill-down <ID>`      |   | - Machine Info & Source Badges        |
| - `errors-cli --import-zip <PATH>`    |   | - 1-Click Copy V6/V7 Prompts          |
| - `errors-cli --export-bundle <ID>`   |   | - Re-Run / Full Project Restore       |
+---------------------------------------+   +---------------------------------------+
```

---

## 3. Data Flow Lifecycle

1. **Recording Initiation**:
   - Operator clicks "REC" or calls CLI `start-recording`.
   - The system records `recording_start_timestamp`, initializes memory buffer, and harvests machine environment metadata.
2. **Telemetry Capture**:
   - Each interaction triggers `captureEvent(type, target, details)`.
   - Evaluates XPath, component hierarchy, and `data-tsd-source` attributes.
   - Saves dual snapshot (`snap-NN-canvas.png` and `snap-NN-full.png`).
3. **Session Finalization**:
   - Operator clicks "STOP" or triggers error exit.
   - Prompts for Title, Category, Expected Behavior, and Actual Behavior.
   - Decomposes session into 3NF normalized SQLite tables.
   - Packages `.bug.zip` containing `session.json`, `project.json`, `prompt-v6.md`, `prompt-v7.md`, and all captured screenshots and workpiece images.
4. **AI Consumption & Diagnostics**:
   - AI agent queries CLI: `errors-cli --recent-bugs` or `errors-cli --step 7`.
   - CLI outputs code locations, screenshots, and suggested follow-up commands (`--drill-down`, `--inspect-event`).
