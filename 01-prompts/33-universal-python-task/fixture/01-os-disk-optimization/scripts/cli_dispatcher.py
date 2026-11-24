"""scripts/cli_dispatcher.py — CLI entrypoint with formatted help and suggestions."""

import argparse
from pathlib import Path
import sys
from core_enums import ActionType, ExitCodeType, TaskCategoryType
from logger import TaskLogger
from task_runner import (
    execute_cache_purge,
    get_disk_space_report,
    purge_debug_builds,
    reset_vmware_adapters,
    restart_audio_services,
)


def create_argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Autonomous Task CLI Runner — executes modular system automation tasks."
    )
    parser.add_argument("action", choices=[a.value for a in ActionType], help="Action to execute")
    parser.add_argument("--category", choices=[c.value for c in TaskCategoryType], default=TaskCategoryType.OS_CACHE.value)
    parser.add_argument("--target", type=str, default=".", help="Target path for operation")
    parser.add_argument("--all", action="store_true", help="Execute across all supported categories")
    parser.add_argument("--dry-run", action="store_true", help="Simulate execution without modifying state")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")
    return parser


def print_suggestions(action: str) -> None:
    print("\n💡 Suggested Next Actions:")
    if action == ActionType.SCAN.value:
        print("  1. Review scanned targets above.")
        print("  2. Run simulation:  ./run.ps1 purge --dry-run")
        print("  3. Run live purge:  ./run.ps1 purge")
    elif action == ActionType.PURGE.value:
        print("  1. Verify freed disk space: ./run.ps1 status")
        print("  2. Check detailed audit: cat logs/task.log")
    elif action == ActionType.RESTART.value:
        print("  1. Verify service health in Task Manager or Services console.")
        print("  2. Check diagnostic log: cat logs/task.log")


def dispatch_action(args: argparse.Namespace, target_path: Path, logger: TaskLogger) -> int:
    is_dry_run = args.dry_run
    if args.action == ActionType.STATUS.value:
        get_disk_space_report(target_path, logger)
        return ExitCodeType.SUCCESS
    if args.category == TaskCategoryType.AUDIO_DEVICE.value or (args.all and args.action == ActionType.RESTART.value):
        return restart_audio_services(is_dry_run, logger)
    if args.category == TaskCategoryType.VMWARE_NETWORK.value or (args.all and args.action == ActionType.RESTART.value):
        return reset_vmware_adapters(is_dry_run, logger)
    if args.all or args.category == TaskCategoryType.OS_CACHE.value:
        execute_cache_purge(target_path, is_dry_run, logger)
    if args.all or args.category == TaskCategoryType.DEBUG_BUILDS.value:
        purge_debug_builds(target_path, is_dry_run, logger)
    return ExitCodeType.SUCCESS


def main() -> int:
    parser = create_argument_parser()
    args = parser.parse_args()
    log_dir = Path(__file__).resolve().parent.parent / "logs"
    logger = TaskLogger(log_dir / "task.log")
    logger.info(f"CLI Dispatcher initiated: action={args.action}, target={args.target}, dry_run={args.dry_run}")

    target_path = Path(args.target).resolve()
    exit_code = dispatch_action(args, target_path, logger)

    print_suggestions(args.action)
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
