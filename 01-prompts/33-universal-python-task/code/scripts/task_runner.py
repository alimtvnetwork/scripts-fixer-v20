"""Modular task execution handlers for universal Python automation."""

from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path

from app_errors import AppError, Result
from core_constants import OsPathConstants, ProtectedNameConstants
from core_enums import AppErrorCodeType
from subprocess_guard import execute_command
from task_logger import TaskLogger


def is_protected_path(path: Path) -> bool:
    """Return True if path matches any protected file or directory pattern."""
    if path.name in (ProtectedNameConstants.GITKEEP, ProtectedNameConstants.CONFIG_JSON):
        return True

    if path.name in (ProtectedNameConstants.SETTINGS_JSON, ProtectedNameConstants.ENV_FILE):
        return True

    return any(part.startswith(".") for part in path.parts)


def scan_target_directory(target_path: Path) -> Result[tuple[list[Path], int]]:
    """Scan directory and return list of purgeable files and total bytes."""
    if not target_path.exists():
        err = AppError(AppErrorCodeType.NOT_FOUND_ERROR.value, f"Directory not found: {target_path}", "scan")
        return Result.fail(err)

    files_to_purge: list[Path] = []
    total_bytes = 0
    for root, _, files in os.walk(target_path):
        for name in files:
            file_path = Path(root) / name
            if not is_protected_path(file_path):
                files_to_purge.append(file_path)
                total_bytes += file_path.stat().st_size

    return Result.ok((files_to_purge, total_bytes))


def purge_file_safely(file_path: Path, is_dry_run: bool, logger: TaskLogger) -> Result[bool]:
    """Safely delete a single file respecting dry-run simulation mode."""
    if is_protected_path(file_path):
        logger.skip(f"Protected path skipped: {file_path}")
        return Result.ok(False)

    if is_dry_run:
        logger.info(f"[DRY-RUN] Would remove: {file_path}")
        return Result.ok(True)

    try:
        file_path.unlink(missing_ok=True)
        logger.ok(f"Purged: {file_path}")
        return Result.ok(True)
    except OSError as ex:
        err = AppError(AppErrorCodeType.IO_ERROR.value, f"Failed to delete {file_path}: {ex}", "purge")
        return Result.fail(err)


def execute_cache_purge(target_path: Path, is_dry_run: bool, logger: TaskLogger) -> Result[int]:
    """Scan and purge eligible cache files in target directory."""
    scan_res = scan_target_directory(target_path)
    if scan_res.has_error:
        return Result.fail(scan_res.error)

    files, total_bytes = scan_res.value
    size_mb = total_bytes / (1024 * 1024)
    logger.info(f"Target {target_path}: found {len(files)} purgeable files ({size_mb:.2f} MB)")
    purged_count = 0
    for item in files:
        res = purge_file_safely(item, is_dry_run, logger)
        if res.is_safe and res.value:
            purged_count += 1

    return Result.ok(purged_count)


def calculate_disk_gauge(free_gb: float, total_gb: float, bar_width: int = 20) -> str:
    """Render an ASCII progress bar gauge representing free disk space percentage."""
    if total_gb <= 0:
        return "[" + " " * bar_width + "] 0.0%"

    free_ratio = max(0.0, min(1.0, free_gb / total_gb))
    filled_chars = int(free_ratio * bar_width)
    empty_chars = bar_width - filled_chars
    percent = free_ratio * 100.0
    return f"[{'#' * filled_chars}{'-' * empty_chars}] {percent:.1f}% free"


def check_disk_space_threshold(target_path: Path, threshold_gb: float, logger: TaskLogger) -> Result[bool]:
    """Check if free disk space is below threshold GB and render gauge."""
    try:
        usage = shutil.disk_usage(target_path if target_path.exists() else Path.cwd())
        free_gb = usage.free / (1024**3)
        total_gb = usage.total / (1024**3)
        gauge = calculate_disk_gauge(free_gb, total_gb)
        logger.info(f"Disk check: {free_gb:.2f} GB free of {total_gb:.2f} GB {gauge}")
        is_below = free_gb < threshold_gb
        return Result.ok(is_below)
    except OSError as ex:
        err = AppError(AppErrorCodeType.IO_ERROR.value, f"Disk check failed: {ex}", "disk_usage")
        return Result.fail(err)


def restart_windows_audio(is_dry_run: bool, logger: TaskLogger) -> Result[int]:
    """Restart Windows Audio service (AudioSrv)."""
    if is_dry_run:
        logger.info("[DRY-RUN] Would execute: net stop AudioSrv && net start AudioSrv")
        return Result.ok(0)

    stop_res = execute_command(["net", "stop", "AudioSrv", "/y"], timeout_sec=15)
    start_res = execute_command(["net", "start", "AudioSrv"], timeout_sec=15)
    if stop_res.has_error or start_res.has_error:
        return Result.fail(AppError(AppErrorCodeType.COMMAND_ERROR.value, "Service command failed"))

    logger.ok("Restarted Windows Audio service successfully")
    return Result.ok(0)


def reset_vmware_network(is_dry_run: bool, logger: TaskLogger) -> Result[int]:
    """Reset VMware virtual network adapter routing and flush DNS."""
    if is_dry_run:
        logger.info("[DRY-RUN] Would execute: ipconfig /flushdns")
        return Result.ok(0)

    res = execute_command(["ipconfig", "/flushdns"], timeout_sec=10)
    if res.has_error:
        return Result.fail(res.error)

    if not res.value.is_success:
        err = AppError(AppErrorCodeType.COMMAND_ERROR.value, res.value.error_message, "reset_network")
        return Result.fail(err)

    logger.ok("Flushed DNS and reset network adapter routing")
    return Result.ok(0)


def clean_temp_caches(is_dry_run: bool, logger: TaskLogger) -> Result[int]:
    """Clean standard user temporary files directory."""
    temp_dir = Path(tempfile.gettempdir())
    logger.info(f"Targeting system temp directory: {temp_dir}")
    if not temp_dir.exists():
        logger.warn(f"Temp directory does not exist: {temp_dir}")
        return Result.ok(0)

    return execute_cache_purge(temp_dir, is_dry_run, logger)


def clean_app_cache(app_name: str, cache_dir: Path, is_dry_run: bool, logger: TaskLogger) -> Result[int]:
    """Clean specific desktop application cache directory."""
    logger.info(f"Initiating cache cleanup for application: {app_name}")
    if not cache_dir.exists():
        logger.warn(f"Cache directory does not exist: {cache_dir}")
        return Result.ok(0)

    return execute_cache_purge(cache_dir, is_dry_run, logger)


def clean_whatsapp_cache(is_dry_run: bool, logger: TaskLogger) -> Result[int]:
    """Clean WhatsApp desktop application temporary cache directory."""
    app_data = os.environ.get("LOCALAPPDATA", "")
    if not app_data:
        return Result.ok(0)

    wa_cache = Path(app_data) / "Packages"
    logger.info(f"Checking WhatsApp cache directory: {wa_cache}")
    if not wa_cache.exists():
        return Result.ok(0)

    return clean_app_cache("WhatsApp", wa_cache, is_dry_run, logger)
