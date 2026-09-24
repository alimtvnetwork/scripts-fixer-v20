"""
Step restoration logic for rollback transactions.
"""

from __future__ import annotations

import sqlite3
from typing import List

from agy_optimizer.shared.paths import get_gemini_base_dir


def restore_steps_to_db(cid: str, archived_steps: List, target_tx: str, conn_backup: sqlite3.Connection) -> bool:
    target_db = get_gemini_base_dir() / "conversations" / f"{cid}.db"
    if not target_db.is_file():
        print(f"  [XX] Target conversation database missing: {target_db}")
        return False

    conn_target = sqlite3.connect(str(target_db))
    cur_target = conn_target.cursor()

    for s in archived_steps:
        idx, stype, stat, payload, meta = s
        cur_target.execute(
            """
            INSERT OR REPLACE INTO steps (idx, step_type, status, step_payload, metadata)
            VALUES (?, ?, ?, ?, ?)
            """,
            (idx, stype, stat, payload, meta),
        )

    conn_target.commit()
    cur_target.execute("VACUUM")
    conn_target.close()

    conn_backup.execute(
        "UPDATE prune_transactions SET status = 'reverted' WHERE transaction_id = ?",
        (target_tx,),
    )
    conn_backup.commit()
    print(f"  [OK] Successfully reverted transaction {target_tx} ({len(archived_steps)} steps restored).")
    return True
