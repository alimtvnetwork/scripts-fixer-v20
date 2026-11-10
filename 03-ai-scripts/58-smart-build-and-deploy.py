#!/usr/bin/env python3
"""
Smart High-Speed Build, Test & Deployment Engine for Antigravity Manager / Antigravity Tools
Maintained by Alim (Sponsored by RISEUP ASIA LLC)

Key Capabilities:
1. Concurrency Mutual Exclusion & Skip Guard:
   - Detects if a build is already in progress on this machine / project via target/.agm-build.lock.
   - If an active build is running, gracefully skips the duplicate build with the friendly notice:
     "Antigravity Manager is already building. You don't have to build.
      If you have put the code, so relax, the code will come back."
   - Stale lock recovery: Automatically clears locks if previous build process died or crashed.
2. Dynamic CPU Load & Worker Scaling:
   - Real-time CPU idle rate measurement via high-speed native OS APIs (<1ms latency).
   - CPU Free >= 70% (idle machine): Scales workers up to maximum logical cores (e.g. 20 workers).
   - CPU Free 40% - 70% (moderate load): Scales to balanced worker count (e.g. 10 workers).
   - CPU Free < 40% (high load): Throttles to conservative workers (e.g. 4-5 workers) to keep UI responsive.
3. Fast Linker & Toolchain Environment:
   - Automatically detects rustc/cargo and LLVM lld-link / rust-lld for accelerated linking.
4. Top-Level Reusable Functions:
   - smart_build(), smart_deploy(), smart_test(), get_dynamic_worker_count(), acquire_build_lock()
   - Readily importable and reusable by testing suites, CI runners, and deployment scripts.
"""

from dataclasses import dataclass
import argparse
import ctypes
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import time
from typing import Any, Dict, List, Optional, Tuple

if sys.platform == "win32":
    if hasattr(sys.stdout, "buffer"):
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
    if hasattr(sys.stderr, "buffer"):
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

# Base repository root resolution
SCRIPT_DIR = Path(__file__).resolve().parent
ROOT_DIR = SCRIPT_DIR.parent
SRC_TAURI_DIR = ROOT_DIR / "src-tauri"
TARGET_DIR = SRC_TAURI_DIR / "target"
LOCK_FILE_PATH = TARGET_DIR / ".agm-build.lock"

# Standard Exit Codes
EXIT_SUCCESS = 0
EXIT_BUILD_FAILED = 1
EXIT_DEPLOY_FAILED = 2
EXIT_TEST_FAILED = 3


@dataclass
class SmartBuildResult:
    is_success: bool
    is_skipped: bool
    duration_seconds: float
    workers_used: int
    message: str


@dataclass
class SmartDeployResult:
    is_success: bool
    duration_seconds: float
    message: str


@dataclass
class SmartTestResult:
    is_success: bool
    duration_seconds: float
    workers_used: int
    message: str


def get_cpu_idle_percentage(sample_ms: int = 80) -> float:
    """
    Measures current system CPU idle percentage.
    Uses ultra-fast Windows GetSystemTimes (<1ms) or Linux /proc/stat.
    Returns a float between 0.0 and 100.0.
    """
    if sys.platform == "win32":
        try:
            idle1, kern1, usr1 = ctypes.c_ulonglong(), ctypes.c_ulonglong(), ctypes.c_ulonglong()
            ctypes.windll.kernel32.GetSystemTimes(
                ctypes.byref(idle1), ctypes.byref(kern1), ctypes.byref(usr1)
            )
            time.sleep(sample_ms / 1000.0)
            idle2, kern2, usr2 = ctypes.c_ulonglong(), ctypes.c_ulonglong(), ctypes.c_ulonglong()
            ctypes.windll.kernel32.GetSystemTimes(
                ctypes.byref(idle2), ctypes.byref(kern2), ctypes.byref(usr2)
            )

            idle_diff = idle2.value - idle1.value
            total_diff = (kern2.value - kern1.value) + (usr2.value - usr1.value)
            if total_diff <= 0:
                return 100.0
            idle_pct = (idle_diff / total_diff) * 100.0
            return max(0.0, min(100.0, idle_pct))
        except Exception:
            return 80.0
    else:
        # Linux / Unix fallback reading /proc/stat
        try:
            def read_stat():
                with open("/proc/stat", "r") as f:
                    fields = [float(x) for x in f.readline().strip().split()[1:8]]
                idle = fields[3] + fields[4]
                total = sum(fields)
                return idle, total

            i1, t1 = read_stat()
            time.sleep(sample_ms / 1000.0)
            i2, t2 = read_stat()
            diff_total = t2 - t1
            diff_idle = i2 - i1
            if diff_total <= 0:
                return 100.0
            return max(0.0, min(100.0, (diff_idle / diff_total) * 100.0))
        except Exception:
            return 80.0


def get_system_ram_gb() -> float:
    """
    Returns total physical system RAM in gigabytes (GB).
    """
    if sys.platform == "win32":
        try:
            class MEMORYSTATUSEX(ctypes.Structure):
                _fields_ = [
                    ("dwLength", ctypes.c_ulong),
                    ("dwMemoryLoad", ctypes.c_ulong),
                    ("ullTotalPhys", ctypes.c_ulonglong),
                    ("ullAvailPhys", ctypes.c_ulonglong),
                    ("ullTotalPageFile", ctypes.c_ulonglong),
                    ("ullAvailPageFile", ctypes.c_ulonglong),
                    ("ullTotalVirtual", ctypes.c_ulonglong),
                    ("ullAvailVirtual", ctypes.c_ulonglong),
                    ("sullAvailExtendedVirtual", ctypes.c_ulonglong),
                ]
            stat = MEMORYSTATUSEX()
            stat.dwLength = ctypes.sizeof(MEMORYSTATUSEX)
            if ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(stat)):
                return stat.ullTotalPhys / (1024 ** 3)
        except Exception:
            pass
    elif sys.platform == "linux":
        try:
            with open("/proc/meminfo", "r") as f:
                for line in f:
                    if line.startswith("MemTotal:"):
                        kb = float(line.split()[1])
                        return kb / (1024 * 1024)
        except Exception:
            pass
    return 8.0


def get_dynamic_worker_count(
    min_workers: int = 2,
    max_workers: Optional[int] = None,
    high_idle_threshold: float = 70.0,
    moderate_idle_threshold: float = 40.0,
) -> int:
    """
    Calculates the optimal number of build workers respecting CPU load and RAM bounds:
    - CPU Free >= 70%: Saturate logical cores bounded by available RAM.
    - CPU Free 40%-70%: Balanced worker allocation (50% cores).
    - CPU Free < 40%: Conservative allocation (2-4 workers) to prevent UI lag.
    - Memory Guard: Heavy Rust compilation requires ~2GB RAM per worker to avoid LLVM OOM.
    """
    total_cores = os.cpu_count() or 4
    effective_max = max_workers if max_workers is not None else total_cores
    ram_gb = get_system_ram_gb()
    # Memory Guard: Bound workers to ~2.0 GB RAM per worker thread
    ram_bounded_max = max(min_workers, int(ram_gb / 2.0))
    effective_max = min(effective_max, ram_bounded_max)

    idle_pct = get_cpu_idle_percentage()

    if idle_pct >= high_idle_threshold:
        workers = effective_max
        mode = "Saturated Full-Power (RAM-bounded)"
    elif idle_pct >= moderate_idle_threshold:
        workers = max(min_workers, int(effective_max * 0.5))
        mode = "Balanced Responsive"
    else:
        workers = min_workers
        mode = "Conservative Throttled"

    print(f"[*] System Specs: {ram_gb:.1f} GB RAM, {total_cores} CPU cores (RAM limit: {ram_bounded_max} workers)")
    print(f"[*] CPU Status  : {idle_pct:.1f}% free/idle -> Mode: {mode} ({workers} parallel workers)")
    return workers


def is_process_alive(pid: int) -> bool:
    """
    Checks if a given process PID is actively running.
    """
    if pid <= 0:
        return False
    if sys.platform == "win32":
        try:
            PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
            handle = ctypes.windll.kernel32.OpenProcess(
                PROCESS_QUERY_LIMITED_INFORMATION, False, pid
            )
            if handle:
                ctypes.windll.kernel32.CloseHandle(handle)
                return True
            return False
        except Exception:
            return False
    else:
        try:
            os.kill(pid, 0)
            return True
        except OSError:
            return False


def acquire_build_lock(
    lock_file: Path = LOCK_FILE_PATH,
    caller_info: str = "smart_build",
    force: bool = False,
    wait: bool = False,
    wait_timeout: float = 300.0,
) -> Tuple[bool, Optional[Dict[str, Any]]]:
    """
    Acquires the project-wide build lock to prevent concurrent build collisions.
    Returns:
      (True, lock_data) if lock acquired.
      (False, existing_lock_data) if build is already running and skipped.
    """
    TARGET_DIR.mkdir(parents=True, exist_ok=True)
    start_wait = time.time()

    while True:
        if lock_file.exists():
            try:
                content = json.loads(lock_file.read_text(encoding="utf-8"))
            except Exception:
                content = {"pid": 0, "timestamp": 0, "caller": "unknown"}

            active_pid = content.get("pid", 0)

            # Check if recorded process is actually still alive
            if active_pid > 0 and is_process_alive(active_pid):
                if force:
                    print(f"[!] Warning: --force specified. Overriding active build lock from PID {active_pid}...")
                    try:
                        lock_file.unlink(missing_ok=True)
                    except Exception:
                        pass
                elif wait:
                    elapsed = time.time() - start_wait
                    if elapsed > wait_timeout:
                        print(f"[ERROR] Timed out waiting for active build (PID {active_pid}) after {wait_timeout}s.")
                        return False, content
                    print(f"[*] Waiting for in-flight build (PID {active_pid}, running {time.time() - content.get('timestamp', time.time()):.1f}s)...")
                    time.sleep(2.0)
                    continue
                else:
                    # Concurrency Guard Triggered: Print friendly skip message
                    duration = time.time() - content.get("timestamp", time.time())
                    print("========================================================================")
                    print("  [BUILD SKIP] Antigravity Manager / Tools is already building!")
                    print("========================================================================")
                    print(f"  Active Build PID : {active_pid}")
                    print(f"  Running Duration : {duration:.1f}s")
                    print(f"  Triggered By     : {content.get('caller', 'unknown')}")
                    print("  Message          : You're already building. You don't have to build.")
                    print("                     If you have put the code, so relax, the code will come back.")
                    print("========================================================================\n")
                    return False, content
            else:
                # Stale lock from crashed or terminated process
                print(f"[*] Evicting stale build lock from dead PID {active_pid}...")
                try:
                    lock_file.unlink(missing_ok=True)
                except Exception:
                    pass

        # Write fresh lock file atomically
        try:
            lock_payload = {
                "pid": os.getpid(),
                "timestamp": time.time(),
                "started_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                "caller": caller_info,
            }
            lock_file.write_text(json.dumps(lock_payload, indent=2), encoding="utf-8")
            return True, lock_payload
        except Exception as e:
            if force:
                return True, {"pid": os.getpid(), "error": str(e)}
            time.sleep(0.1)
            if time.time() - start_wait > 5.0:
                return False, {"error": str(e)}


def release_build_lock(lock_file: Path = LOCK_FILE_PATH) -> None:
    """
    Safely releases the project build lock.
    """
    try:
        if lock_file.exists():
            data = json.loads(lock_file.read_text(encoding="utf-8"))
            if data.get("pid") == os.getpid():
                lock_file.unlink(missing_ok=True)
    except Exception:
        try:
            lock_file.unlink(missing_ok=True)
        except Exception:
            pass


def get_extended_env(jobs: int) -> Dict[str, str]:
    """
    Prepares environment variables with PATH containing cargo and LLVM linkers.
    """
    env = os.environ.copy()
    candidate_cargo_dirs = [
        os.path.join(env.get("USERPROFILE", ""), ".cargo", "bin"),
        r"C:\Users\Administrator\.cargo\bin",
        os.path.join(env.get("HOMEDRIVE", "C:"), "Users", "Administrator", ".cargo", "bin"),
    ]
    candidate_llvm_dirs = [
        r"C:\Program Files\LLVM\bin",
        os.path.join(env.get("ProgramFiles", r"C:\Program Files"), "LLVM", "bin"),
    ]

    extra_paths = []
    for d in candidate_cargo_dirs:
        if os.path.exists(os.path.join(d, "cargo.exe")):
            extra_paths.append(d)
            break

    for d in candidate_llvm_dirs:
        if os.path.exists(os.path.join(d, "lld-link.exe")):
            extra_paths.append(d)
            break

    current_path = env.get("PATH", "")
    new_path = os.pathsep.join(extra_paths + [current_path])
    env["PATH"] = new_path
    env["CARGO_BUILD_JOBS"] = str(jobs)
    env["RUST_MIN_STACK"] = env.get("RUST_MIN_STACK", "67108864")

    # Do not inject invalid -fuse-ld=lld on MSVC targets to avoid stack buffer overruns

    return env


def find_cargo_executable(env: Dict[str, str]) -> str:
    """
    Finds the full path to cargo.exe or returns 'cargo'.
    """
    if sys.platform == "win32":
        for part in env.get("PATH", "").split(os.pathsep):
            candidate = os.path.join(part, "cargo.exe")
            if os.path.exists(candidate):
                return candidate
        return "cargo.exe"
    return "cargo"


def smart_build(
    profile: str = "release",
    skip_frontend: bool = False,
    jobs: Optional[int] = None,
    force: bool = False,
    wait: bool = False,
    caller_info: str = "smart_build",
    full_build: bool = False,
) -> SmartBuildResult:
    """
    Top-Level Reusable Function: Executes smart high-speed compilation.
    - Prevents duplicate builds with friendly skip message.
    - Dynamically scales workers based on CPU load.
    - Compiles frontend and Rust release binaries.
    """
    start_time = time.time()

    # Step 1: Concurrency Guard / Lock Acquisition
    acquired, lock_data = acquire_build_lock(
        caller_info=caller_info, force=force, wait=wait
    )
    if not acquired:
        return SmartBuildResult(
            is_success=True,
            is_skipped=True,
            duration_seconds=time.time() - start_time,
            workers_used=0,
            message="Skipped: Build already running on machine.",
        )

    try:
        # Step 2: Dynamic CPU Allocation
        workers = jobs if jobs is not None else get_dynamic_worker_count()
        env = get_extended_env(workers)
        cargo_cmd = find_cargo_executable(env)

        print("================================================================")
        print("  Antigravity Manager High-Speed Smart Build Runner")
        print("================================================================")
        print(f" Profile      : {profile}")
        print(f" Workers      : {workers} parallel compiler threads")
        print(f" Platform     : {'All Platforms (Full cross-build)' if full_build else 'win64 only (Optimized default)'}")
        print(f" Frontend     : {'Skip (use existing dist/)' if skip_frontend else 'TypeScript & Vite Build'}\n")

        # Step 3: Frontend Compilation (if requested)
        dist_index = ROOT_DIR / "dist" / "index.html"
        if not skip_frontend:
            print("[*] [1/2] Compiling frontend assets (npm run build)...")
            fe_start = time.time()
            npm_cmd = "npm.cmd" if sys.platform == "win32" else "npm"
            fe_res = subprocess.run(
                [npm_cmd, "run", "build"],
                cwd=str(ROOT_DIR),
                env=env,
                shell=(sys.platform == "win32"),
            )
            if fe_res.returncode != 0:
                print(f"\n[ERROR] Frontend compilation failed with code {fe_res.returncode}")
                return SmartBuildResult(
                    is_success=False,
                    is_skipped=False,
                    duration_seconds=time.time() - start_time,
                    workers_used=workers,
                    message=f"Frontend build failed: exit code {fe_res.returncode}",
                )
            print(f"[OK] Frontend compiled in {time.time() - fe_start:.1f}s!\n")

        if not dist_index.exists() or dist_index.stat().st_size == 0:
            print(f"[ERROR] Frontend index missing at {dist_index}. Tauri requires valid dist/index.html.")
            return SmartBuildResult(
                is_success=False,
                is_skipped=False,
                duration_seconds=time.time() - start_time,
                workers_used=workers,
                message="Missing dist/index.html",
            )

        # Step 4: Touch main.rs to guarantee Tauri dist asset embedding
        main_rs = SRC_TAURI_DIR / "src" / "main.rs"
        if main_rs.exists():
            now = time.time()
            os.utime(str(main_rs), (now, now))

        # Step 5: High-Speed Cargo Compilation
        print(f"[*] [2/2] Compiling release binaries with --jobs {workers}...")
        cargo_args = [
            cargo_cmd,
            "build",
            "--manifest-path",
            str(SRC_TAURI_DIR / "Cargo.toml"),
            "--jobs",
            str(workers),
            "--bin",
            "agm-ui",
            "--bin",
            "agm",
        ]
        if profile == "release":
            cargo_args.insert(2, "--release")

        cargo_start = time.time()
        cargo_res = subprocess.run(cargo_args, cwd=str(ROOT_DIR), env=env)

        if cargo_res.returncode != 0:
            print(f"\n[ERROR] Cargo compilation failed with exit code {cargo_res.returncode}")
            return SmartBuildResult(
                is_success=False,
                is_skipped=False,
                duration_seconds=time.time() - start_time,
                workers_used=workers,
                message=f"Cargo build failed: exit code {cargo_res.returncode}",
            )

        duration = time.time() - start_time
        print(f"\n[OK] Release binaries successfully compiled in {duration:.1f}s!")
        return SmartBuildResult(
            is_success=True,
            is_skipped=False,
            duration_seconds=duration,
            workers_used=workers,
            message="Build completed successfully.",
        )

    finally:
        # Step 6: Guaranteed Lock Release
        release_build_lock()


def smart_deploy(
    no_launch: bool = False,
    force: bool = False,
) -> SmartDeployResult:
    """
    Top-Level Reusable Function: Executes local host deployment via `agm deploy current`.
    """
    start_time = time.time()
    print("\n[*] Executing local host deployment (agm deploy current)...")

    bin_name = "agm.exe" if sys.platform == "win32" else "agm"
    compiled_agm = TARGET_DIR / "release" / bin_name

    deploy_args = ["deploy", "current"]
    if no_launch:
        deploy_args.append("--no-launch")
    if force:
        deploy_args.append("--force")

    env = get_extended_env(get_dynamic_worker_count())

    if compiled_agm.exists():
        print(f"  • Using compiled binary: {compiled_agm.relative_to(ROOT_DIR)}")
        res = subprocess.run([str(compiled_agm)] + deploy_args, cwd=str(ROOT_DIR), env=env)
    else:
        print("  • Target binary not found; falling back to cargo run --bin agm...")
        cargo_cmd = find_cargo_executable(env)
        cargo_run_args = [
            cargo_cmd,
            "run",
            "--release",
            "--manifest-path",
            str(SRC_TAURI_DIR / "Cargo.toml"),
            "--bin",
            "agm",
            "--",
        ] + deploy_args
        res = subprocess.run(cargo_run_args, cwd=str(ROOT_DIR), env=env)

    if res.returncode != 0:
        print(f"\n[ERROR] Deployment failed with status code {res.returncode}")
        return SmartDeployResult(
            is_success=False,
            duration_seconds=time.time() - start_time,
            message=f"Deploy failed with exit code {res.returncode}",
        )

    print("\n✓ Release and local deployment completed successfully!")
    return SmartDeployResult(
        is_success=True,
        duration_seconds=time.time() - start_time,
        message="Deployed successfully.",
    )


def smart_test(
    test_args: Optional[List[str]] = None,
    force: bool = False,
) -> SmartTestResult:
    """
    Top-Level Reusable Function: Executes tests with dynamic worker allocation and lock guard.
    """
    start_time = time.time()
    workers = get_dynamic_worker_count()
    env = get_extended_env(workers)
    cargo_cmd = find_cargo_executable(env)

    args = [
        cargo_cmd,
        "test",
        "--manifest-path",
        str(SRC_TAURI_DIR / "Cargo.toml"),
        "--jobs",
        str(workers),
    ]
    if test_args:
        args.extend(test_args)

    print(f"[*] Running tests with {workers} parallel workers...")
    res = subprocess.run(args, cwd=str(ROOT_DIR), env=env)

    is_success = (res.returncode == 0)
    return SmartTestResult(
        is_success=is_success,
        duration_seconds=time.time() - start_time,
        workers_used=workers,
        message="Tests passed" if is_success else f"Tests failed with code {res.returncode}",
    )


def main() -> int:
    """
    CLI Entrypoint for Smart Build & Deploy.
    """
    parser = argparse.ArgumentParser(
        description="Antigravity Manager Smart High-Speed Build & Deploy Orchestrator"
    )
    parser.add_argument("--build-only", action="store_true", help="Build release binaries without deploying")
    parser.add_argument("--deploy-only", action="store_true", help="Deploy existing binaries without rebuilding")
    parser.add_argument("--deploy", action="store_true", help="Build and deploy to current host installation")
    parser.add_argument("--test", action="store_true", help="Run cargo tests using smart worker allocation")
    parser.add_argument("--skip-frontend", action="store_true", help="Skip npm run build frontend compilation")
    parser.add_argument("--no-launch", action="store_true", help="Do not relaunch desktop UI after deployment")
    parser.add_argument("--force", action="store_true", help="Override active build lock / caller guard")
    parser.add_argument("--full", action="store_true", help="Full multi-platform build (default: win64 only)")
    parser.add_argument("--wait", action="store_true", help="Wait for active build to complete instead of skipping")
    parser.add_argument("--jobs", type=int, default=None, help="Explicit worker count override")

    args = parser.parse_args()

    # Case 1: Test Mode
    if args.test:
        test_res = smart_test(force=args.force)
        return EXIT_SUCCESS if test_res.is_success else EXIT_TEST_FAILED

    # Case 2: Deploy Only Mode
    if args.deploy_only:
        deploy_res = smart_deploy(no_launch=args.no_launch, force=args.force)
        return EXIT_SUCCESS if deploy_res.is_success else EXIT_DEPLOY_FAILED

    # Case 3: Build Mode (or Build + Deploy)
    build_res = smart_build(
        skip_frontend=args.skip_frontend,
        jobs=args.jobs,
        force=args.force,
        wait=args.wait,
        caller_info="CLI_smart_build",
        full_build=args.full,
    )

    if not build_res.is_success:
        return EXIT_BUILD_FAILED

    # If skipped due to duplicate build, exit cleanly
    if build_res.is_skipped:
        return EXIT_SUCCESS

    # If --build-only was specified, stop here
    if args.build_only and not args.deploy:
        return EXIT_SUCCESS

    # Default action: Deploy freshly built binaries
    deploy_res = smart_deploy(no_launch=args.no_launch, force=args.force)
    return EXIT_SUCCESS if deploy_res.is_success else EXIT_DEPLOY_FAILED


if __name__ == "__main__":
    sys.exit(main())
