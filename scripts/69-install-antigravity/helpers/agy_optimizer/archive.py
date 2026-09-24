"""
Database archiving functions for pruned conversation steps.
"""

from __future__ import annotations

import sqlite3
from pathlib import Path

from agy_optimizer.models import ConversationInfo


def archive_pruned_rows(backup_db: Path, tx_id: str, cid: str, rows: list) -> None:
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


def record_prune_transaction(backup_db: Path, tx_id: str, ts: str, c_info: ConversationInfo, new_sz: int, count: int) -> None:
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
