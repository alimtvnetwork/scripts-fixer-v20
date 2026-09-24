"""
SQLite database initialization and summary loading.
"""

from __future__ import annotations

import sqlite3
from pathlib import Path
from typing import Any, Dict


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
