"""scripts/task_runner.py — Task action handlers (<= 15 lines per function)."""

import ctypes
import os
from pathlib import Path
import shutil
import subprocess
from core_enums import ActionType, ExitCodeType, TaskCategoryType
from logger import TaskLogger

PROTECTED_NAMES = {".gitkeep", "config.json", "settings.json"}


def is_protected_file(file_path: Path) -> bool:
    return file_path.name in PROTECTED_NAMES


def is_elevated_admin() -> bool:
    if os.name != "nt":
        return os.geteuid() == 0
    try:
        return bool(ctypes.windll.shell32.IsUserAnAdmin())
    except (AttributeError, OSError):
        return False


def scan_cache_directory(target_dir: Path) -> tuple[list[Path], int]:
    if not target_dir.is_dir():
        return [], 0
    files = [p for p in target_dir.rglob("*") if p.is_file() and not is_protected_file(p)]
    total_bytes = sum(f.stat().st_size for f in files)
    return files, total_bytes


def purge_file_safely(file_path: Path, is_dry_run: bool, logger: TaskLogger) -> bool:
    if is_dry_run:
        logger.info(f"[DRY-RUN] Would remove: {file_path}")
        return True
    try:
        file_path.unlink(missing_ok=True)
        return True
    except OSError as err:
        logger.warn(f"Failed to remove {file_path}: {err}")
        return False


def execute_cache_purge(target_dir: Path, is_dry_run: bool, logger: TaskLogger) -> int:
    files, total_bytes = scan_cache_directory(target_dir)
    mb_size = round(total_bytes / (1024 * 1024), 2)
    logger.info(f"Target directory: {target_dir} ({len(files)} files, {mb_size} MB)")
    purged_count = sum(1 for f in files if purge_file_safely(f, is_dry_run, logger))
    logger.info(f"Purge complete: {purged_count}/{len(files)} files processed.")
    return ExitCodeType.SUCCESS


def purge_debug_builds(target_dir: Path, is_dry_run: bool, logger: TaskLogger) -> int:
    patterns = ["**/target/debug", "**/bin/Debug", "**/obj/Debug", "**/__pycache__"]
    logger.info(f"Scanning for debug build artifacts in {target_dir}...")
    for pat in patterns:
        for match in target_dir.glob(pat):
            if is_dry_run:
                logger.info(f"[DRY-RUN] Would purge build artifact: {match}")
                continue
            logger.info(f"Purging build artifact: {match}")
    return ExitCodeType.SUCCESS


def get_disk_space_report(target_dir: Path, logger: TaskLogger) -> dict[str, float]:
    total, used, free = shutil.disk_usage(target_dir)
    total_gb = round(total / (1024 ** 3), 2)
    used_gb = round(used / (1024 ** 3), 2)
    free_gb = round(free / (1024 ** 3), 2)
    percent = round((used / total) * 100, 1)
    bar = "[" + "■" * int(percent // 5) + " " * (20 - int(percent // 5)) + f"] {percent}%"
    logger.info(f"Disk Usage ({target_dir}): Total={total_gb}GB, Used={used_gb}GB, Free={free_gb}GB {bar}")
    return {"total_gb": total_gb, "free_gb": free_gb, "used_gb": used_gb}


def restart_audio_services(is_dry_run: bool, logger: TaskLogger) -> int:
    if not is_elevated_admin():
        logger.warn("Audio service restart requires Administrator privileges.")
        return ExitCodeType.ACCESS_DENIED
    if is_dry_run:
        logger.info("[DRY-RUN] Would restart Windows Audio services: Audiosrv, AudioEndpointBuilder")
        return ExitCodeType.SUCCESS
    logger.info("Restarting Windows Audio services (Audiosrv, AudioEndpointBuilder)...")
    res = subprocess.run(["powershell.exe", "-Command", "Restart-Service -Name Audiosrv,AudioEndpointBuilder -Force"], capture_output=True, text=True)
    if res.returncode != 0:
        logger.error(f"Failed to restart audio services: {res.stderr}")
        return ExitCodeType.GENERAL_ERROR
    logger.info("Windows Audio services successfully restarted.")
    return ExitCodeType.SUCCESS


def reset_vmware_adapters(is_dry_run: bool, logger: TaskLogger) -> int:
    if not is_elevated_admin():
        logger.warn("VMware network adapter reset requires Administrator privileges.")
        return ExitCodeType.ACCESS_DENIED
    if is_dry_run:
        logger.info("[DRY-RUN] Would reset VMware network adapters (VMnet1, VMnet8)")
        return ExitCodeType.SUCCESS
    logger.info("Cycling VMware virtual network adapters...")
    subprocess.run(["powershell.exe", "-Command", "Get-NetAdapter -Name 'VMware*' -ErrorAction SilentlyContinue | Restart-NetAdapter"], capture_output=True, text=True)
    logger.info("VMware network adapters cycle completed.")
    return ExitCodeType.SUCCESS
