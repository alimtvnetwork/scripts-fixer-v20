"""
Command-line interface and argument parsing dispatch for AGY Optimizer.
"""

from __future__ import annotations

import argparse
import sys
from typing import List, Optional

from agy_optimizer.applier import apply_optimization
from agy_optimizer.predictor import predict_optimization
from agy_optimizer.rollback import undo_transaction
from agy_optimizer.shared.list_backups import list_backup_transactions



def build_argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Antigravity Optimizer & Conversation Pruning Engine")
    parser.add_argument("--predict", action="store_true", help="Predict optimization savings without modifying files")
    parser.add_argument("--dry-run", action="store_true", help="Alias for --predict")
    parser.add_argument("--yes", "-y", action="store_true", help="Apply optimization changes")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")
    parser.add_argument("--threshold", type=int, default=200, help="Conversation size threshold in KB (default: 200)")
    parser.add_argument("--keep", "-k", type=int, default=0, help="Number of latest conversations to keep intact")
    parser.add_argument("count", nargs="?", type=int, default=None, help="Optional positional conversation retention count")
    parser.add_argument("--keep-turns", type=int, default=2, help="Number of latest conversation turns to preserve")
    parser.add_argument("--min-steps", type=int, default=0, help="Filter conversations with at least N steps")
    parser.add_argument("--filter-slug", type=str, default="", help="Filter conversations by project slug substring")
    parser.add_argument("--undo", nargs="?", const="latest", type=str, help="Undo a specific transaction ID or 'latest'")
    parser.add_argument("--list-backups", action="store_true", help="List all backup transactions")

    return parser


def run_cli(argv: Optional[List[str]] = None) -> int:
    parser = build_argument_parser()
    args = parser.parse_args(argv)
    threshold_bytes = args.threshold * 1024

    keep_count = args.keep
    if keep_count == 0 and args.count is not None:
        keep_count = args.count

    if args.undo is not None:
        is_undone = undo_transaction(args.undo)
        return 0 if is_undone else 1

    if args.list_backups:
        return list_backup_transactions()

    if args.yes:
        return apply_optimization(
            threshold_bytes=threshold_bytes,
            keep_count=keep_count,
            keep_turns=args.keep_turns,
            min_steps=args.min_steps,
            filter_slug=args.filter_slug,
        )

    return predict_optimization(
        threshold_bytes=threshold_bytes,
        keep_count=keep_count,
        min_steps=args.min_steps,
        filter_slug=args.filter_slug,
        as_json=args.json,
    )


def main() -> int:
    return run_cli(sys.argv[1:])


if __name__ == "__main__":
    sys.exit(main())
