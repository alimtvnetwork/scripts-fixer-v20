# Specification 27.06: Step-by-Step Build Guide for Any Blind AI

## 1. Scope & Objective

This document is written for a "blind AI" or software engineer with **zero prior knowledge** of this specific project. By following these 6 sequential phases, you can construct a complete, production-grade bug reporting and flight-recorder engine in any tech stack.

---

## 2. Phase 1: Client-Side Interaction & Event Interceptor

1. **Window Event Listener Hook**:
   - Attach global capture-phase listeners on `window` for `click`, `input`, `change`, `keydown`, and `popstate` / `hashchange`.
   - Prevent recursive capture loops: check if the event originated inside the bug recorder modal or HUD by verifying `!target.closest("[data-bug-recorder]")`.
2. **Deterministic Label & Component Extraction**:
   - Check `target.getAttribute("data-automation-name")` or `aria-label`.
   - Fall back to visible inner text (up to 40 characters) or tag name.
   - Compute unique XPath from root: `/html/body/div[1]/main/button[2]`.
3. **Source Code Location Resolution**:
   - In development mode, check `target.closest("[data-tsd-source]")`.
   - Extract string `filePath:line:col` (e.g. `src/components/MyButton.tsx:24:5`).
   - Read backend data tags: `data-backend-endpoint`, `data-backend-file`, `data-backend-fn`.
4. **Visual Snapshot Capture**:
   - Use HTML5 Canvas `drawImage` or screen capture API to capture the canvas view and viewport.
   - Save image as PNG buffer and assign sequence number `snap-NN`.

---

## 3. Phase 2: Host Environment & Machine Identity Harvester

Whenever a session is recorded or exported, automatically harvest:
- **Operating System**: `platform.platform()` (Python) / `process.platform + os.release()` (Node) / `runtime.GOOS` (Go).
- **Hostname**: `socket.gethostname()` (Python) / `os.hostname()` (Node).
- **Username**: `os.getlogin()` / `getpass.getuser()` (Python) / `os.userInfo().username` (Node).
- **Hardware Architecture**: `platform.machine()` (`x86_64`, `arm64`).
- **Display Resolution & DPR**: `window.screen.width * window.devicePixelRatio`.
- Store these in session metadata with an editable UI override field.

---

## 4. Phase 3: Normalized 3NF SQLite Persistence

1. Initialize SQLite database `bug_records.db` using the schema in [`03-normalized-sqlite-schema.md`](03-normalized-sqlite-schema.md).
2. Never store giant unindexed JSON blobs. When a session ends:
   - Insert one record into `bug_sessions`.
   - Loop over recorded steps and insert one row per step into `bug_step_events`.
   - Insert screenshot paths into `bug_screenshots`.
   - If a project is open, serialize its settings into `bug_project_bundles`.
3. Create indexes on `session_id`, `created_at DESC`, `source_file`, and `category`.

---

## 5. Phase 4: ZIP Packaging & Project Bundling

1. Create ZIP archive `<session_id>.bug.zip`:
   - Write `manifest.json` with machine info, generator version, and checksums.
   - Write `session.json` and `steps.json`.
   - Write `prompt-v6.md` and `prompt-v7.md` (AI instructions).
   - Write `project/project.json` containing active rules, tolerances, and camera settings.
   - Copy all screenshot PNG files into `screenshots/`.
   - Copy workpiece inspection frames into `images/`.
2. Implement symmetric `import-zip` parser:
   - Extract ZIP to temporary folder.
   - Read `manifest.json` and validate schema.
   - Insert rows into SQLite database.
   - Move images to user storage directory.

---

## 6. Phase 5: CLI Diagnostic & AI Navigation Engine

1. Implement CLI executable (`bin/errors-cli.py` or `bug-cli`):
   - Command `errors-cli --recent-bugs`: Query `bug_sessions` ordered by `created_at DESC`.
   - Command `errors-cli --step <N>`: Query `bug_step_events` joined with `bug_screenshots` for step $N$.
   - Display:
     - Step sequence and elapsed time.
     - Screen name and user action phrase.
     - Exact frontend file path and line number.
     - Exact backend route file, endpoint, and function.
     - Path to local screenshot image.
     - Machine name and reporter username.
   - Append `Suggested AI Commands` block giving the AI the next CLI commands to execute.
2. Provide `--json` flag to return structured envelopes for autonomous programmatic consumption.

---

## 7. Phase 6: Embedded UI Bug Tracker with Import / Export Dock

1. Construct modal component (`PreviousBugsModal`):
   - Top banner: Responsive Drag & Drop zone accepting `.bug.zip`.
   - Filter bar: Search input + category dropdown.
   - List cards: Display session title, elapsed duration, step count, and machine identity badge (`Host: ... · User: ...`).
   - Action buttons: "Export Full Bundle", "Inspect Steps", "Copy V7 Prompt", "Resend Email".
