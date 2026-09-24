"""
SQLite database initialization, summary loading, and transaction queries.
"""

from __future__ import annotations

import sqlite3
from pathlib import Path
from typing import Any, Dict

from agy_optimizer.shared.paths import get_backup_db_path


def init_backup_database(db_path: Path) -> None:
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()

    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS prune_transactions (
            transaction_id TEXT PRIMARY KEY,
            timestamp TEXT,
            conversation_id TEXT,
            workspace_uri TEXT,
            project_slug TEXT,
            original_size INTEGER,
            pruned_size INTEGER,
            steps_archived INTEGER,
            status TEXT
        )
        """
    )
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS pruned_steps (
            transaction_id TEXT,
            conversation_id TEXT,
            idx INTEGER,
            step_type INTEGER,
            status INTEGER,
            step_payload BLOB,
            metadata BLOB,
            gen_metadata_data BLOB,
            gen_metadata_size INTEGER,
            PRIMARY KEY (transaction_id, conversation_id, idx)
        )
        """
    )
    conn.commit()
    conn.close()


def load_conversation_summaries(gemini_dir: Path) -> Dict[str, Dict[str, Any]]:
    summaries_db = gemini_dir / "conversation_summaries.db"
    if not summaries_db.is_file():
        return {}

    results: Dict[str, Dict[str, Any]] = {}
    try:
        conn = sqlite3.connect(f"file:{summaries_db}?mode=ro", uri=True)
        cur = conn.cursor()
        query = "SELECT conversation_id, title, preview, step_count, workspace_uris, last_modified_time FROM conversation_summaries"

        for row in cur.execute(query).fetchall():
            cid, title, prev, sc, w_uris, last_mod = row
            results[cid] = {
                "title": title or "",
                "preview": prev or "",
                "step_count": sc or 0,
                "workspace_uris": w_uris or "",
                "last_modified_time": last_mod or "",
            }

        conn.close()
    except Exception:
        pass

    return results


def list_backup_transactions() -> int:
    backup_db = get_backup_db_path()
    if not backup_db.is_file():
        print("No backup database found.")
        return 0

    conn = sqlite3.connect(str(backup_db))
    cur = conn.cursor()
    print(f"{'TX ID':<26} {'TIMESTAMP':<22} {'CONVERSATION ID':<38} {'SLUG':<16} {'STATUS':<10}")
    print("-" * 115)

    for r in cur.execute("SELECT transaction_id, timestamp, conversation_id, project_slug, status FROM prune_transactions"):
        print(f"{r[0]:<26} {r[1]:<22} {r[2]:<38} {r[3][:15]:<16} {r[4]:<10}")

    conn.close()
    return 0
