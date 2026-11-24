"""Universal CLI argument dispatcher and interactive suggestions engine."""

from __future__ import annotations

import argparse
import sys
import unittest
from pathlib import Path

from app_errors import AppError, Result
from core_constants import EncodingConstants
from core_enums import ActionType, ExitCodeType, TaskCategoryType
from task_logger import TaskLogger
from task_runner import (
    check_disk_space_threshold,
    clean_app_cache,
    clean_temp_caches,
    execute_cache_purge,
    reset_vmware_network,
    restart_windows_audio,
    scan_target_directory,
)


def build_parser() -> argparse.ArgumentParser:
    """Construct CLI argument parser schema."""
    parser = argparse.ArgumentParser(description="Universal Python Task Automation Runner")
    parser.add_argument("action", nargs="?", default=ActionType.STATUS.value, choices=ActionType.all_values())
    parser.add_argument("--category", default=TaskCategoryType.OS_OPTIMIZATION.value, choices=TaskCategoryType.all_values())
    parser.add_argument("--target", default=".", help="Target directory or item path")
    parser.add_argument("--threshold-gb", type=float, default=10.0, help="Disk threshold in GB")
    parser.add_argument("--dry-run", action="store_true", help="Simulate execution without mutations")
    parser.add_argument("--json", action="store_true", help="Output telemetry in JSON format")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose debug logging")
    return parser


def print_suggestions(action: ActionType, category: TaskCategoryType, logger: TaskLogger) -> None:
    """Print helpful next-step suggestions based on selected action and category."""
    if action == ActionType.STATUS:
        logger.info(f"Suggestion: Run 'scan --category {category.value}' to inspect target files")
        return

    if action == ActionType.SCAN:
        logger.info(f"Suggestion: Run 'purge --category {category.value} --dry-run' to simulate cleanup")
        return

    if action == ActionType.PURGE:
        logger.info(f"Suggestion: Run 'status --category {category.value}' to verify freed storage")
        return

    logger.info("Suggestion: Check 'logs/taskSummary.json' for structured execution audit")


def _run_test_suite(logger: TaskLogger) -> Result[int]:
    """Execute unit tests under tests directory and report result."""
    tests_dir = Path(__file__).resolve().parent.parent / "tests"
    if not tests_dir.exists():
        return Result.fail(AppError("NOT_FOUND_ERROR", f"Tests dir not found: {tests_dir}", "test"))

    suite = unittest.defaultTestLoader.discover(str(tests_dir))
    runner = unittest.TextTestRunner(verbosity=2)
    test_result = runner.run(suite)
    if not test_result.wasSuccessful():
        err_msg = f"Unit tests failed: {len(test_result.failures)} failures, {len(test_result.errors)} errors"
        return Result.fail(AppError("TEST_FAILURE", err_msg, "test"))

    logger.ok(f"Unit tests passed: {test_result.testsRun} tests executed successfully")
    return Result.ok(test_result.testsRun)


def _handle_git_sync(manifest_path: Path, is_dry_run: bool, logger: TaskLogger) -> Result[int]:
    """Parse manifest and sync Git repositories."""
    if not manifest_path.exists():
        return Result.fail(AppError("NOT_FOUND_ERROR", f"Manifest not found: {manifest_path}"))

    from git_sync_runner import parse_sync_manifest, sync_single_repo
    from core_enums import GitSyncFormatType
    content = manifest_path.read_text(encoding=EncodingConstants.UTF8)
    is_json = manifest_path.suffix == ".json"
    is_md = manifest_path.suffix == ".md"
    fmt = GitSyncFormatType.JSON if is_json else (GitSyncFormatType.MARKDOWN if is_md else GitSyncFormatType.TEXT)
    parsed_res = parse_sync_manifest(content, fmt)
    if parsed_res.has_error:
        return Result.fail(parsed_res.error)

    for entry in parsed_res.value:
        sync_single_repo(entry, manifest_path.parent, is_dry_run, logger)

    return Result.ok(len(parsed_res.value))


def dispatch_action(action: ActionType, cat: TaskCategoryType, args: argparse.Namespace, logger: TaskLogger) -> Result[int]:
    """Route validated action and category to modular runner handlers."""
    target_path = Path(args.target)
    if action == ActionType.TEST:
        return _run_test_suite(logger)

    if action == ActionType.GIT_SYNC:
        return _handle_git_sync(target_path, args.dry_run, logger)

    if action == ActionType.CLEAN_TEMP:
        return clean_temp_caches(args.dry_run, logger)

    if action == ActionType.RESET_NET or (action == ActionType.RESTART and cat == TaskCategoryType.VMWARE_MANAGEMENT):
        return reset_vmware_network(args.dry_run, logger)

    if action == ActionType.STATUS:
        res = check_disk_space_threshold(target_path, args.threshold_gb, logger)
        return Result.ok(0) if res.is_safe else Result.fail(res.error)

    if action == ActionType.SCAN:
        scan_res = scan_target_directory(target_path)
        return Result.ok(len(scan_res.value[0])) if scan_res.is_safe else Result.fail(scan_res.error)

    if action == ActionType.PURGE:
        return execute_cache_purge(target_path, args.dry_run, logger)

    if action == ActionType.RESTART and cat == TaskCategoryType.WINDOWS_TROUBLESHOOTING:
        return restart_windows_audio(args.dry_run, logger)

    return clean_app_cache(cat.value, target_path, args.dry_run, logger)


def _validate_inputs(args: argparse.Namespace, logger: TaskLogger) -> Result[tuple[ActionType, TaskCategoryType]]:
    """Validate action and category strings against registered enums."""
    act_res = ActionType.parse(args.action)
    cat_res = TaskCategoryType.parse(args.category)
    if act_res.has_error:
        return Result.fail(act_res.error)
    if cat_res.has_error:
        return Result.fail(cat_res.error)

    return Result.ok((act_res.value, cat_res.value))


def run_dispatch(args: argparse.Namespace) -> ExitCodeType:
    """Execute command dispatch, handle logging, and return strongly-typed exit code."""
    logger = TaskLogger(is_verbose=args.verbose)
    val_res = _validate_inputs(args, logger)
    if val_res.has_error:
        logger.fail(f"Validation failure: {val_res.error}")
        logger.save_summary_log(status="fail")
        return ExitCodeType.USAGE_ERROR

    action, category = val_res.value
    logger.info(f"Executing '{action.label()}' for '{category.label()}' (dry-run: {args.dry_run})")
    result = dispatch_action(action, category, args, logger)
    if result.has_error:
        logger.fail(f"Execution failed: {result.error}")
        logger.save_summary_log(status="fail")
        return ExitCodeType.RUNTIME_ERROR

    logger.ok(f"Completed '{action.label()}' successfully")
    print_suggestions(action, category, logger)
    logger.audit(action.value, "SUCCESS", {"category": category.value, "dry_run": args.dry_run})
    logger.save_summary_log(status="ok")
    return ExitCodeType.SUCCESS


def main() -> int:
    """Top-level CLI entrypoint."""
    parser = build_parser()
    args = parser.parse_args()
    exit_code = run_dispatch(args)
    return int(exit_code)


if __name__ == "__main__":
    sys.exit(main())
