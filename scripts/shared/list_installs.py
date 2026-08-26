import sys
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except:
        pass

import sqlite3
import os

def list_installs():
    db_file = os.path.expanduser("~/.scripts-fixer/install_log.db")
    if not os.path.exists(db_file):
        print("  \033[0;37mNo installation history found.\033[0m")
        return

    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT item, MAX(timestamp) FROM installs WHERE status='success' GROUP BY item ORDER BY MAX(timestamp) DESC")
        rows = cursor.fetchall()
        if not rows:
            print("  \033[0;37mNo installation history found.\033[0m")
            return
        
        print(f"\n  \033[1;32mInstallation History ({len(rows)} items):\033[0m")
        print("  \033[0;37m------------------------------------------------------------\033[0m")
        for row in rows:
            item_name = row[0].ljust(32)
            timestamp_str = row[1][:16].replace('T', ' ')
            print(f"    \033[1;36m✔\033[0m \033[1;37m{item_name}\033[0m \033[0;37m(Last run: {timestamp_str})\033[0m")
        print("  \033[0;37m------------------------------------------------------------\033[0m\n")
    except sqlite3.OperationalError:
        print("  \033[1;31mInstallation database is empty or corrupted.\033[0m")
    finally:
        conn.close()

if __name__ == "__main__":
    list_installs()
