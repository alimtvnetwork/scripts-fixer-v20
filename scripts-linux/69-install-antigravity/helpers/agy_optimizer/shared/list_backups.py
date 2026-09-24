"""
Backup transaction listing and terminal display.
"""

from __future__ import annotations

import sqlite3
from pathlib import Path

from agy_optimizer.shared.paths import get_backup_db_path


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
