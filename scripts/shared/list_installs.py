import sys
import sqlite3
import os

def list_installs():
    db_file = os.path.expanduser("~/.scripts-fixer/install_log.db")
    if not os.path.exists(db_file):
        print("  No installation history found.")
        return

    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT item, MAX(timestamp) FROM installs WHERE status='success' GROUP BY item ORDER BY MAX(timestamp) DESC")
        rows = cursor.fetchall()
        if not rows:
            print("  No installation history found.")
            return
        
        print(f"  [0;35mInstallation History ({len(rows)} items):[0m")
        print("  [1;30m--------------------------------------------------[0m")
        for row in rows:
            print(f"    [0;36m✔[0m {row[0].ljust(30)} [1;30m(Last run: {row[1][:16].replace('T', ' ')})[0m")
        print("  [1;30m--------------------------------------------------[0m")
    except sqlite3.OperationalError:
        print("  Installation database is empty or corrupted.")
    finally:
        conn.close()

if __name__ == "__main__":
    list_installs()
