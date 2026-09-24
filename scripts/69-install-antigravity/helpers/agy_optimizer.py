#!/usr/bin/env python3
"""
Antigravity Optimizer & SQLite Conversation Pruner Engine.

Cross-platform utility (Windows, Linux, macOS) for analyzing, pruning,
and optimizing Antigravity conversation databases, Electron/GPU caches,
and Gemini brain directories.
Delegates to the modular agy_optimizer package.
"""

from __future__ import annotations

import sys
from pathlib import Path

# Ensure helper folder is in sys.path for direct script execution
helper_dir = Path(__file__).resolve().parent
if str(helper_dir) not in sys.path:
    sys.path.insert(0, str(helper_dir))

from agy_optimizer import (
    BrainCleanupItem,
    ConversationInfo,
    apply_optimization,
    discover_conversations,
    extract_project_slug,
    format_bytes,
    get_backup_db_path,
    get_cache_directories,
    get_dir_stats,
    get_gemini_base_dir,
    init_backup_database,
    list_backup_transactions,
    load_conversation_summaries,
    predict_optimization,
    prune_conversation,
    run_cli,
    scan_app_cache_items,
    scan_brain_cleanup_items,
    undo_transaction,
)

if __name__ == "__main__":
    sys.exit(run_cli(sys.argv[1:]))
