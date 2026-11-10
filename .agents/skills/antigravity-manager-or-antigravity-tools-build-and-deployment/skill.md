---
name: antigravity-manager-or-antigravity-tools-build-and-deployment
description: >-
  Build, test, and deploy Antigravity Manager / Antigravity Tools natively and rapidly with smart CPU-respecting worker scaling (up to 20 cores when >=70% idle), cross-process build deduplication lock with skip notice, LLVM fast linking, and reusable top-level Python functions.
---

<!-- ========================================================================= -->
<!-- MANDATORY REPOSITORY RULE: DO NOT REMOVE OR DELETE THIS SKILL.             -->
<!-- THIS SKILL IS A PERMANENT REPOSITORY ASSET AND MUST REMAIN ACTIVE ALWAYS.  -->
<!-- ========================================================================= -->

# Antigravity Manager / Antigravity Tools Smart Build, Test & Deployment

> **Invocation:** `@[antigravity-manager-or-antigravity-tools-build-and-deployment](directory;.agents/skills/antigravity-manager-or-antigravity-tools-build-and-deployment)`

## 1. Overview & Core Architecture

This skill governs high-speed, processor-respecting builds, testing, and deployments for **Antigravity Manager** and **Antigravity Tools**. It replaces slow, unconstrained, or bottlenecked compilation flows with an intelligent orchestrator (`03-ai-scripts/58-smart-build-and-deploy.py`) that respects system resources and coordinates concurrent requests.

### Core Invariants

1. **Zero Duplicate Builds (Mutual Exclusion & Skip Guard)**:
   - Only **one** build may run on the same project/machine at any given time.
   - When a build is triggered, the orchestrator acquires `target/.agm-build.lock` recording PID, timestamp, caller, and start time.
   - If another build is already in progress, the orchestrator **immediately skips** with a friendly notice:
     ```
     ========================================================================
       [BUILD SKIP] Antigravity Manager / Tools is already building!
     ========================================================================
       Active Build PID : <pid>
       Running Duration : <duration>s
       Triggered By     : <caller>
       Message          : You're already building. You don't have to build.
                          If you have put the code, so relax, the code will come back.
     ========================================================================
     ```
   - Exits cleanly with status code `0` (`is_skipped=True`), so automated tools, agents, or watchers do not fail.
   - Stale lock detection: If the recorded PID is dead or crashed, the lock is automatically cleared.

2. **Processor Respect & Dynamic Worker Scaling**:
   - Compiling large Tauri applications can freeze the operating system or lag the IDE if all cores are saturated while the CPU is already under heavy load.
   - The orchestrator samples real-time system CPU idle rates via native OS APIs (`GetSystemTimes` on Windows, `/proc/stat` on Linux) with `<1ms` overhead:
     - **CPU Free >= 70% (Idle Machine)**: Saturates maximum logical cores (e.g. 20 workers on Intel Core Ultra 7 265KF) for ultra-fast throughput.
     - **CPU Free 40%–70% (Moderate Load)**: Allocates balanced workers (~50% of available cores, e.g. 10 workers) to maintain system and UI responsiveness.
     - **CPU Free < 40% (Heavy System Load)**: Throttles to conservative workers (4–5 workers) preventing thermal throttling or UI freezes.

3. **LLVM Fast Linker Injection (`lld-link`)**:
   - Default MSVC `link.exe` is single-threaded and takes 30–60s just to link release binaries.
   - The orchestrator detects `lld-link.exe` (LLVM) or `rust-lld.exe` (bundled with rustup toolchain) and injects `-C link-arg=-fuse-ld=lld`, reducing link duration by 3x–5x.

4. **Reusable Top-Level Python API**:
   - Exported functions in `03-ai-scripts/58-smart-build-and-deploy.py`:
     - `smart_build(profile="release", skip_frontend=False, jobs=None, force=False, wait=False) -> SmartBuildResult`
     - `smart_deploy(no_launch=False, force=False) -> SmartDeployResult`
     - `smart_test(test_args=None, force=False) -> SmartTestResult`
     - `get_dynamic_worker_count() -> int`
     - `acquire_build_lock(force=False, wait=False) -> Tuple[bool, Optional[dict]]`
   - Test suites, CI runners, and deployment scripts can import and call these functions directly.

---

## 2. Docker Evaluation: Why Native Host Builds are Mandatory

Docker is evaluated for this repository with the following conclusions:
- **Tauri v2 Windows Requirements**: Antigravity Manager produces native Windows binaries (`agm.exe`, `agm-ui.exe`) linked with WebView2, Windows SDK headers, and native C crates (`boring2`, `machine-uid`). Cross-compiling for Windows inside a Linux Docker container requires fragile `xwin` toolchains and Wine, which frequently break and lack official Tauri v2 support.
- **Filesystem I/O Penalty in Docker**: Docker on Windows runs inside WSL2. Mounting host source code into containers (`/mnt/d/...`) incurs severe Plan9/9P filesystem translation penalties (3x–5x slower for Rust's thousands of intermediate artifact writes and lock checks).
- **Host Binary Deployment**: Local deployment (`agm deploy current`) directly updates files in `%LOCALAPPDATA%\Programs\agm-alim` and restarts desktop UI processes. A Docker container cannot interact with host user directories or running host processes without elevated security bridges.
- **Conclusion**: Native host build with dynamic worker scaling and `lld-link` is drastically faster, more reliable, and fully integrated with host deployment.

---

## 3. Standard Operational Commands

Always use the smart orchestrator commands:

| Workflow | Command | Behavior |
| :--- | :--- | :--- |
| **Smart Fast Build** | `npm run build:smart` or `npm run build:fast` | Builds release binaries with dynamic CPU scaling and duplicate skip guard |
| **Smart Build & Deploy** | `npm run deploy:smart` or `npm run release:local` | Builds release binaries and immediately deploys to current host installation |
| **Deploy Existing Binaries** | `npm run deploy:current` | Deploys already compiled binaries without rebuilding |
| **Smart Testing** | `npm run test:smart` | Executes cargo tests with dynamic worker scaling and build lock protection |
| **Bypass Lock (Force)** | `python 03-ai-scripts/58-smart-build-and-deploy.py --force` | Overrides active build lock if explicitly needed |
| **Wait for In-Flight Build** | `python 03-ai-scripts/58-smart-build-and-deploy.py --wait` | Waits for running build to complete instead of skipping |

---

## 4. Integration Example for Testing and CI Scripts

Any test script or deployment runner can reuse the Python smart engine:

```python
import sys
from pathlib import Path

# Add 03-ai-scripts to Python module path
sys.path.insert(0, str(Path("03-ai-scripts").resolve()))
import importlib
smart_engine = importlib.import_module("58-smart-build-and-deploy")

# Run smart build respecting active builds and CPU load
result = smart_engine.smart_build(skip_frontend=True)
if result.is_skipped:
    print("Build already covered by running process. Proceeding...")
elif not result.is_success:
    raise RuntimeError(f"Build failed: {result.message}")

# Execute tests safely with dynamic workers
test_result = smart_engine.smart_test(test_args=["--lib"])
print(f"Test status: {test_result.message}")
```

<!-- END OF SKILL -->
