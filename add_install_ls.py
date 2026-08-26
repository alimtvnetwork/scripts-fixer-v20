import os

list_code = """import sys
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
        
        print(f"  \033[0;35mInstallation History ({len(rows)} items):\033[0m")
        print("  \033[1;30m--------------------------------------------------\033[0m")
        for row in rows:
            print(f"    \033[0;36m✔\033[0m {row[0].ljust(30)} \033[1;30m(Last run: {row[1][:16].replace('T', ' ')})\033[0m")
        print("  \033[1;30m--------------------------------------------------\033[0m")
    except sqlite3.OperationalError:
        print("  Installation database is empty or corrupted.")
    finally:
        conn.close()

if __name__ == "__main__":
    list_installs()
"""

with open("scripts/shared/list_installs.py", "w", encoding="utf-8", newline='\n') as f:
    f.write(list_code)

with open("scripts/run.sh", "r", encoding="utf-8") as f:
    run_sh = f.read()

# Add `install ls` and `install list` handling
new_help = """        elif [[ "$ARGS" == *"help"* || "$ARGS" == *"-h"* || "$ARGS" == *"--help"* || "$ARGS" == *"-help"* ]]; then
            show_install_help
            show_footer
            exit 0
        elif [[ "$ARGS" == "ls" || "$ARGS" == "list" ]]; then
            python3 scripts/shared/list_installs.py
            show_footer
            exit 0
        fi"""

run_sh = run_sh.replace("""        elif [[ "$ARGS" == *"help"* || "$ARGS" == *"-h"* || "$ARGS" == *"--help"* || "$ARGS" == *"-help"* ]]; then
            show_install_help
            show_footer
            exit 0
        fi""", new_help)

with open("scripts/run.sh", "w", encoding="utf-8", newline='\n') as f:
    f.write(run_sh)

import subprocess
subprocess.run(["git", "add", "."], check=True)
subprocess.run(["git", "commit", "-m", "feat: add 'install ls' to view installation history from sqlite"], check=True)
subprocess.run(["git", "push"], check=True)
print("Added install ls capability.")
