"""
Transaction rollback and undo engine for Antigravity conversations.
"""

from __future__ import annotations

import sqlite3
from typing import Optional

from agy_optimizer.shared.paths import get_backup_db_path, get_gemini_base_dir


def _resolve_target_transaction(cur: sqlite3.Cursor, tx_arg: Optional[str]) -> Optional[str]:
    if tx_arg and tx_arg.strip().lower() not in ("latest", "last"):
        return tx_arg

    cur.execute(
        "SELECT transaction_id FROM prune_transactions WHERE status != 'reverted' ORDER BY timestamp DESC LIMIT 1"
    )
    row = cur.fetchone()
    if not row:
        print("  [WARN] No active (non-reverted) prune transactions found to undo.")
        return None

    print(f"  [INFO] Resolved 'latest' to transaction: {row[0]}")
    return row[0]


def _restore_steps_to_db(cid: str, archived_steps: list, target_tx: str, conn_backup: sqlite3.Connection) -> bool:
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


def undo_transaction(transaction_id: Optional[str]) -> bool:
    backup_db = get_backup_db_path()
    if not backup_db.is_file():
        print(f"Backup database not found: {backup_db}")
        return False

    conn_backup = sqlite3.connect(str(backup_db))
    cur = conn_backup.cursor()
    target_tx = _resolve_target_transaction(cur, transaction_id)
    if not target_tx:
        conn_backup.close()
        return False

    cur.execute("SELECT conversation_id, status FROM prune_transactions WHERE transaction_id = ?", (target_tx,))
    tx_record = cur.fetchone()
    if not tx_record:
        print(f"  [XX] Transaction not found: {target_tx}")
        conn_backup.close()
        return False

    cid, status = tx_record
    if status == "reverted":
        print(f"  [INFO] Transaction {target_tx} was already reverted.")
        conn_backup.close()
        return True

    cur.execute("SELECT idx, step_type, status, step_payload, metadata FROM pruned_steps WHERE transaction_id = ?", (target_tx,))
    archived_steps = cur.fetchall()

    is_success = _restore_steps_to_db(cid, archived_steps, target_tx, conn_backup)
    conn_backup.close()

    return is_success
