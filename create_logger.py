import os

logger_code = """import sys
import json
import sqlite3
import datetime
import os

def log_transaction(item):
    log_dir = os.path.expanduser("~/.scripts-fixer")
    os.makedirs(log_dir, exist_ok=True)
    
    json_file = os.path.join(log_dir, "install_log.json")
    db_file = os.path.join(log_dir, "install_log.db")
    
    timestamp = datetime.datetime.now().isoformat()
    record = {"timestamp": timestamp, "item": item, "status": "success"}
    
    # JSON Append
    logs = []
    if os.path.exists(json_file):
        try:
            with open(json_file, "r", encoding="utf-8") as f:
                logs = json.load(f)
        except:
            pass
    logs.append(record)
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(logs, f, indent=2)
        
    # SQLite Append
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()
    cursor.execute('''CREATE TABLE IF NOT EXISTS installs (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        timestamp TEXT,
                        item TEXT,
                        status TEXT
                      )''')
    cursor.execute("INSERT INTO installs (timestamp, item, status) VALUES (?, ?, ?)", (timestamp, item, "success"))
    conn.commit()
    conn.close()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        log_transaction(sys.argv[1])
"""

os.makedirs("scripts/shared", exist_ok=True)
with open("scripts/shared/logger.py", "w", encoding="utf-8", newline='\n') as f:
    f.write(logger_code)

print("Created scripts/shared/logger.py")
