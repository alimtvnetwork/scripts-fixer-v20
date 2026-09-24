"""
Conversation step pruner and SQLite transaction archiver.
"""

from __future__ import annotations

import sqlite3
import time
from pathlib import Path
from typing import Any, Dict, Optional

from agy_optimizer.models import ConversationInfo
from agy_optimizer.shared.database import init_backup_database
from agy_optimizer.shared.paths import get_backup_db_path


def _fetch_prune_rows(c_target: sqlite3.Cursor, cutoff_idx: int) -> list:
    try:
        c_target.execute(
            """
            SELECT idx, step_type, status, step_payload, metadata, gen_metadata_data, gen_metadata_size
            FROM steps WHERE idx < ?
            """,
            (cutoff_idx,),
        )
        return c_target.fetchall()
    except Exception:
        c_target.execute(
            """
            SELECT idx, step_type, status, step_payload, metadata, NULL, 0
            FROM steps WHERE idx < ?
            """,
            (cutoff_idx,),
        )
        return c_target.fetchall()


def _archive_rows(backup_db: Path, tx_id: str, cid: str, rows: list) -> None:
    conn_backup = sqlite3.connect(str(backup_db))
    c_backup = conn_backup.cursor()

    for row in rows:
        idx, stype, stat, payload, meta, gm_data, gm_size = row
        c_backup.execute(
            """
            INSERT OR REPLACE INTO pruned_steps
            (transaction_id, conversation_id, idx, step_type, status, step_payload, metadata, gen_metadata_data, gen_metadata_size)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (tx_id, cid, idx, stype, stat, payload, meta, gm_data, gm_size),
        )

    conn_backup.commit()
    conn_backup.close()


def _record_transaction(backup_db: Path, tx_id: str, ts: str, c_info: ConversationInfo, new_sz: int, count: int) -> None:
    conn_backup = sqlite3.connect(str(backup_db))
    c_backup = conn_backup.cursor()

    c_backup.execute(
        """
        INSERT INTO prune_transactions
        (transaction_id, timestamp, conversation_id, workspace_uri, project_slug, original_size, pruned_size, steps_archived, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (tx_id, ts, c_info.conversation_id, c_info.workspace_uri, c_info.project_slug, c_info.file_size, new_sz, count, "applied"),
    )
    conn_backup.commit()
    conn_backup.close()


def prune_conversation(c_info: ConversationInfo, keep_turns: int = 2) -> Optional[Dict[str, Any]]:
    db_path = Path(c_info.db_path)
    if not db_path.is_file():
        return None

    backup_db = get_backup_db_path()
    init_backup_database(backup_db)
    tx_id = f"tx_{int(time.time())}_{c_info.conversation_id[:8]}"
    timestamp = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

    conn_target = sqlite3.connect(str(db_path))
    c_target = conn_target.cursor()
    c_target.execute("SELECT MAX(idx) FROM steps")
    max_idx_row = c_target.fetchone()
    max_idx = max_idx_row[0] if max_idx_row and max_idx_row[0] is not None else 0

    cutoff_idx = max(0, max_idx - keep_turns)
    if cutoff_idx <= 0:
        conn_target.close()
        return None

    prune_rows = _fetch_prune_rows(c_target, cutoff_idx)
    if not prune_rows:
        conn_target.close()
        return None

    _archive_rows(backup_db, tx_id, c_info.conversation_id, prune_rows)
    c_target.execute("DELETE FROM steps WHERE idx < ?", (cutoff_idx,))
    conn_target.commit()

    try:
        c_target.execute("VACUUM")
    except Exception:
        pass

    conn_target.close()
    new_sz = db_path.stat().st_size
    _record_transaction(backup_db, tx_id, timestamp, c_info, new_sz, len(prune_rows))

    return {
        "transaction_id": tx_id,
        "conversation_id": c_info.conversation_id,
        "original_size": c_info.file_size,
        "pruned_size": new_sz,
        "steps_archived": len(prune_rows),
    }
