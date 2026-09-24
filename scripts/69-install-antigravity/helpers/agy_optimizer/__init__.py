"""
Antigravity Optimizer package — Modular conversation pruner and cache engine.
"""

from __future__ import annotations

from agy_optimizer.applier import apply_optimization
from agy_optimizer.cache_cleaner import backup_and_clean_brain_items, clean_app_cache_items
from agy_optimizer.cli import run_cli
from agy_optimizer.conversations import discover_conversations
from agy_optimizer.models import BrainCleanupItem, ConversationInfo, format_bytes
from agy_optimizer.predictor import predict_optimization
from agy_optimizer.pruner import prune_conversation
from agy_optimizer.rollback import undo_transaction
from agy_optimizer.scanner import get_dir_stats, scan_app_cache_items, scan_brain_cleanup_items

from agy_optimizer.shared.database import init_backup_database, load_conversation_summaries
from agy_optimizer.shared.list_backups import list_backup_transactions
from agy_optimizer.shared.paths import extract_project_slug, get_backup_db_path, get_cache_directories, get_gemini_base_dir



__all__ = [
    "ConversationInfo",
    "BrainCleanupItem",
    "format_bytes",
    "get_gemini_base_dir",
    "get_backup_db_path",
    "get_cache_directories",
    "extract_project_slug",
    "init_backup_database",
    "load_conversation_summaries",
    "list_backup_transactions",
    "get_dir_stats",
    "scan_app_cache_items",
    "scan_brain_cleanup_items",
    "discover_conversations",
    "clean_app_cache_items",
    "backup_and_clean_brain_items",
    "prune_conversation",
    "predict_optimization",
    "apply_optimization",
    "undo_transaction",
    "run_cli",
]
