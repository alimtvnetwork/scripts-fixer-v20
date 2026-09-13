#!/usr/bin/env python3
"""
Python SQLite Bridge for Windows Nginx Domain Manager
Provides zero-dependency, reliable SQLite execution and queries on Windows.
Handles UTF-8 with or without BOM automatically across PowerShell versions.
"""
import sys
import sqlite3

def read_sql_from_stdin():
    raw = sys.stdin.buffer.read()
    return raw.decode("utf-8-sig", errors="replace").strip()

def cmd_exec(db_path):
    sql = read_sql_from_stdin()
    try:
        conn = sqlite3.connect(db_path)
        cur = conn.cursor()
        cur.executescript(sql)
        conn.commit()
        conn.close()
    except Exception as e:
        sys.stderr.write(f"SQLite Bridge Error: {e}\n")
        sys.exit(1)

def cmd_query(db_path):
    sql = read_sql_from_stdin()
    try:
        conn = sqlite3.connect(db_path)
        cur = conn.cursor()
        for row in cur.execute(sql):
            print("|".join("" if col is None else str(col) for col in row))
        conn.close()
    except Exception as e:
        sys.stderr.write(f"SQLite Bridge Query Error: {e}\n")
        sys.exit(1)

def main():
    if len(sys.argv) < 2:
        sys.stderr.write("Usage: sqlite-bridge.py <exec|query|ping> [db_path]\n")
        sys.exit(1)

    cmd = sys.argv[1].lower()
    if cmd == "ping":
        sys.exit(0)

    if len(sys.argv) < 3:
        sys.stderr.write("Error: db_path is required for exec or query\n")
        sys.exit(1)

    db_path = sys.argv[2]
    if cmd == "exec":
        cmd_exec(db_path)
    elif cmd == "query":
        cmd_query(db_path)
    else:
        sys.stderr.write(f"Unknown command: {cmd}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
