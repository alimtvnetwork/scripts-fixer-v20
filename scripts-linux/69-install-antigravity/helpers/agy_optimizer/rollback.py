"""
Transaction rollback and undo engine for Antigravity conversations.
"""

from __future__ import annotations

import sqlite3
from typing import Optional

from agy_optimizer.restore import restore_steps_to_db
from agy_optimizer.shared.paths import get_backup_db_path


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

    is_success = restore_steps_to_db(cid, archived_steps, target_tx, conn_backup)
    conn_backup.close()

    return is_success
