import os
import sys
import time
import argparse
import datetime
import subprocess
import json

from split_db import get_connection, register_database, get_db_root_dir

PRIMARY = "\033[1;32m"
SECONDARY = "\033[1;36m"
ACCENT = "\033[1;33m"
MUTED = "\033[0;37m"
ERROR = "\033[1;31m"
TEXT = "\033[0m"

def init_async_db():
    conn = get_connection("Async.db")
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS AsyncTasks (
            TaskId INTEGER PRIMARY KEY AUTOINCREMENT,
            CommandText TEXT NOT NULL,
            IntervalSeconds INTEGER NOT NULL,
            Status TEXT NOT NULL,
            StartedAt TEXT NOT NULL,
            LastRunAt TEXT
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS AsyncLogs (
            LogId INTEGER PRIMARY KEY AUTOINCREMENT,
            TaskId INTEGER NOT NULL,
            ExecutedAt TEXT NOT NULL,
            ExitCode INTEGER,
            OutputSummary TEXT,
            FOREIGN KEY (TaskId) REFERENCES AsyncTasks(TaskId)
        )
    """)
    conn.commit()
    conn.close()
    register_database("Async", "Async.db", os.path.join(get_db_root_dir(), "Async.db"), "Async operations & periodic monitor tasks")

def run_async_loop(command_text, interval_seconds, max_count=None):
    init_async_db()
    conn = get_connection("Async.db")
    cursor = conn.cursor()
    now_str = datetime.datetime.now().isoformat()
    cursor.execute("""
        INSERT INTO AsyncTasks (CommandText, IntervalSeconds, Status, StartedAt, LastRunAt)
        VALUES (?, ?, 'running', ?, ?)
    """, (command_text, interval_seconds, now_str, now_str))
    task_id = cursor.lastrowid
    conn.commit()
    conn.close()

    print(f"\n  {PRIMARY}=== Async Monitor Started [Task #{task_id}] ==={TEXT}")
    print(f"  {SECONDARY}Command:{TEXT} {command_text}")
    print(f"  {MUTED}Interval:{TEXT} Every {interval_seconds}s (Press Ctrl+C to stop)")
    print(f"  {MUTED}{'-'*60}{TEXT}\n")

    iteration = 0
    try:
        while True:
            iteration += 1
            ts = datetime.datetime.now().strftime("%H:%M:%S")
            print(f"  {MUTED}[{ts}] Run #{iteration}:{TEXT}", flush=True)
            t0 = time.time()
            p = subprocess.run(command_text, shell=True, capture_output=True, text=True)
            dur = round((time.time() - t0) * 1000)
            out_snippet = (p.stdout or p.stderr or "Completed").strip().replace("\n", " ")[:120]

            if p.returncode == 0:
                print(f"    {PRIMARY}✔ ({dur}ms){TEXT} {out_snippet}")
            else:
                print(f"    {ERROR}✘ ({dur}ms, exit {p.returncode}){TEXT} {out_snippet}")

            # Log to DB
            conn = get_connection("Async.db")
            cur = conn.cursor()
            cur.execute("""
                INSERT INTO AsyncLogs (TaskId, ExecutedAt, ExitCode, OutputSummary)
                VALUES (?, ?, ?, ?)
            """, (task_id, datetime.datetime.now().isoformat(), p.returncode, out_snippet))
            cur.execute("UPDATE AsyncTasks SET LastRunAt = ? WHERE TaskId = ?", (datetime.datetime.now().isoformat(), task_id))
            conn.commit()
            conn.close()

            if max_count and iteration >= max_count:
                break
            time.sleep(interval_seconds)
    except KeyboardInterrupt:
        print(f"\n  {ACCENT}Async task #{task_id} stopped by user.{TEXT}")
    finally:
        conn = get_connection("Async.db")
        cur = conn.cursor()
        cur.execute("UPDATE AsyncTasks SET Status = 'stopped' WHERE TaskId = ?", (task_id,))
        conn.commit()
        conn.close()

def list_async_tasks():
    init_async_db()
    conn = get_connection("Async.db")
    cur = conn.cursor()
    cur.execute("SELECT TaskId, CommandText, IntervalSeconds, Status, StartedAt, LastRunAt FROM AsyncTasks ORDER BY TaskId DESC")
    rows = cur.fetchall()
    conn.close()

    if not rows:
        print(f"  {MUTED}No async tasks found in Async.db.{TEXT}")
        return

    print(f"\n  {PRIMARY}=== Async Tasks Logged ({len(rows)}) ==={TEXT}")
    print(f"  {MUTED}{'-'*70}{TEXT}")
    print(f"  {SECONDARY}{'ID':<4} {'Status':<10} {'Interval':<10} {'Command':<30} {'Last Run':<16}{TEXT}")
    print(f"  {MUTED}{'-'*70}{TEXT}")
    for r in rows:
        tid, cmd, interval, status, started, last_run = r
        last_str = last_run[:16].replace("T", " ") if last_run else "-"
        status_col = PRIMARY if status == "running" else MUTED
        print(f"  #{tid:<3} {status_col}{status:<10}{TEXT} {str(interval)+'s':<10} {cmd[:28]:<30} {last_str:<16}")
    print(f"  {MUTED}{'-'*70}{TEXT}\n")

def main():
    if len(sys.argv) > 1 and sys.argv[1].lower() in ("ls", "list", "status"):
        list_async_tasks()
        return

    parser = argparse.ArgumentParser(description="Async Task Runner & Monitoring CLI (scripts-fixer)")
    parser.add_argument("command", help="Command or service action to run periodically")
    parser.add_argument("-t", "--interval", type=int, default=5, help="Interval in seconds (default: 5)")
    parser.add_argument("--count", "-c", type=int, default=None, help="Stop after N iterations (optional)")
    args = parser.parse_args()

    if args.command.lower() in ("ls", "list", "status"):
        list_async_tasks()
    else:
        run_async_loop(args.command, args.interval, args.count)

if __name__ == "__main__":
    main()

