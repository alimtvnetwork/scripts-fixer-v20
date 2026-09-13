import os
import sys
import time
import argparse
import datetime
import subprocess
import json

from split_db import get_connection, init_schedule_db, get_schedule_log_db

PRIMARY = "\033[1;32m"
SECONDARY = "\033[1;36m"
ACCENT = "\033[1;33m"
MUTED = "\033[0;37m"
ERROR = "\033[1;31m"
TEXT = "\033[0m"

VALID_TYPES = ["ps", "powershell", "bash", "sh", "js", "javascript", "macro"]

def normalize_type(stype):
    s = stype.lower()
    if s in ("ps", "powershell"): return "powershell"
    if s in ("bash", "sh"): return "bash"
    if s in ("js", "javascript"): return "javascript"
    if s == "macro": return "macro"
    return "binary"

def add_schedule(schedule_id, name, script_type, target_path, timing, arguments=""):
    init_schedule_db()
    conn = get_connection("Schedule.db")
    cursor = conn.cursor()
    now_str = datetime.datetime.now().isoformat()
    norm_type = normalize_type(script_type)

    cursor.execute("""
        INSERT OR REPLACE INTO ScheduleItems
        (ScheduleId, Name, ScriptType, TargetPath, Arguments, CronExpression, FrequencyDesc, IsEnabled, CreatedAt, UpdatedAt)
        VALUES (?, ?, ?, ?, ?, ?, ?, 1, COALESCE((SELECT CreatedAt FROM ScheduleItems WHERE ScheduleId = ?), ?), ?)
    """, (schedule_id, name, norm_type, target_path, arguments, timing, timing, schedule_id, now_str, now_str))
    conn.commit()
    conn.close()

    # Pre-initialize child schedule execution DB
    log_conn = get_schedule_log_db(schedule_id)
    log_conn.close()

    print(f"  {PRIMARY}✔ Scheduled task '{schedule_id}' registered successfully [{norm_type} | {timing}].{TEXT}")
    print(f"  {MUTED}  Child database: ~/.scripts-fixer/schedules/{schedule_id}.db{TEXT}")

def list_schedules(as_json=False):
    init_schedule_db()
    conn = get_connection("Schedule.db")
    cursor = conn.cursor()
    cursor.execute("SELECT ScheduleId, Name, ScriptType, TargetPath, CronExpression, IsEnabled, CreatedAt FROM ScheduleItems ORDER BY CreatedAt DESC")
    rows = cursor.fetchall()
    conn.close()

    if as_json:
        items = [dict(r) for r in rows]
        print(json.dumps(items, indent=2))
        return

    if not rows:
        print(f"  {MUTED}No scheduled tasks found. Add one using 'schedule add <type> <path> <timing>'.{TEXT}")
        return

    print(f"\n  {PRIMARY}Scheduled Tasks & Crontab Registry ({len(rows)} entries):{TEXT}")
    print(f"  {MUTED}{'-'*76}{TEXT}")
    print(f"  {MUTED}{'ID'.ljust(18)} {'Name'.ljust(22)} {'Type'.ljust(12)} {'Timing'.ljust(16)} {'Status'}{TEXT}")
    print(f"  {MUTED}{'-'*76}{TEXT}")
    for r in rows:
        status_txt = f"{PRIMARY}Enabled{TEXT}" if r["IsEnabled"] else f"{MUTED}Disabled{TEXT}"
        print(f"  {SECONDARY}{r['ScheduleId'].ljust(18)}{TEXT} {r['Name'].ljust(22)} {MUTED}{r['ScriptType'].ljust(12)}{TEXT} {ACCENT}{r['CronExpression'].ljust(16)}{TEXT} {status_txt}")
        print(f"    {MUTED}└── Target: {r['TargetPath']}{TEXT}")
    print(f"  {MUTED}{'-'*76}\n")

def remove_schedule(schedule_id):
    init_schedule_db()
    conn = get_connection("Schedule.db")
    cursor = conn.cursor()
    cursor.execute("SELECT ScheduleId FROM ScheduleItems WHERE ScheduleId = ?", (schedule_id,))
    if not cursor.fetchone():
        print(f"  {ERROR}Schedule '{schedule_id}' not found.{TEXT}")
        conn.close()
        return False
    cursor.execute("DELETE FROM ScheduleItems WHERE ScheduleId = ?", (schedule_id,))
    cursor.execute("DELETE FROM ScheduleDefinitions WHERE ScheduleId = ?", (schedule_id,))
    conn.commit()
    conn.close()
    print(f"  {PRIMARY}✔ Schedule '{schedule_id}' removed.{TEXT}")
    return True

def run_schedule(schedule_id):
    init_schedule_db()
    conn = get_connection("Schedule.db")
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM ScheduleItems WHERE ScheduleId = ?", (schedule_id,))
    row = cursor.fetchone()
    conn.close()
    
    if not row:
        print(f"  {ERROR}Schedule '{schedule_id}' not found.{TEXT}")
        return False

    stype = row["ScriptType"]
    target = row["TargetPath"]
    args = row["Arguments"] or ""
    
    print(f"  {SECONDARY}Executing schedule [{schedule_id}]:{TEXT} {target}")
    start_ts = datetime.datetime.now().isoformat()
    t0 = time.time()
    stdout_text = ""
    stderr_text = ""
    exit_code = 0
    
    try:
        if stype == "macro":
            macro_name = target.replace("macro:", "")
            cmd = [sys.executable, os.path.join(os.path.dirname(__file__), "macro_manager.py"), "run", macro_name]
            p = subprocess.run(cmd, capture_output=True, text=True)
            exit_code = p.returncode
            stdout_text = p.stdout
            stderr_text = p.stderr
        elif stype == "powershell":
            cmd = f"powershell -NoProfile -ExecutionPolicy Bypass -File \"{target}\" {args}"
            p = subprocess.run(cmd, capture_output=True, text=True, shell=True)
            exit_code = p.returncode
            stdout_text = p.stdout
            stderr_text = p.stderr
        elif stype == "bash":
            cmd = ["bash", target] + (args.split() if args else [])
            p = subprocess.run(cmd, capture_output=True, text=True)
            exit_code = p.returncode
            stdout_text = p.stdout
            stderr_text = p.stderr
        elif stype == "javascript":
            cmd = ["node", target] + (args.split() if args else [])
            p = subprocess.run(cmd, capture_output=True, text=True)
            exit_code = p.returncode
            stdout_text = p.stdout
            stderr_text = p.stderr
        else:
            cmd = f"\"{target}\" {args}".strip()
            p = subprocess.run(cmd, capture_output=True, text=True, shell=True)
            exit_code = p.returncode
            stdout_text = p.stdout
            stderr_text = p.stderr
    except Exception as ex:
        exit_code = 1
        stderr_text = str(ex)

    duration_ms = int((time.time() - t0) * 1000)
    status_str = "success" if exit_code == 0 else "failure"

    # Save to child log DB
    log_conn = get_schedule_log_db(schedule_id)
    log_cursor = log_conn.cursor()
    log_cursor.execute("""
        INSERT INTO ExecutionLogs (ScheduleId, ExecutedAt, Status, ExitCode, StdoutText, StderrText, DurationMs)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (schedule_id, start_ts, status_str, exit_code, stdout_text, stderr_text, duration_ms))
    log_cursor.execute("""
        INSERT INTO RunHistory (ScheduledFor, TriggeredAt, Status)
        VALUES (?, ?, ?)
    """, (row["CronExpression"], start_ts, status_str))
    log_conn.commit()
    log_conn.close()

    if exit_code == 0:
        print(f"  {PRIMARY}✔ Schedule '{schedule_id}' finished successfully ({duration_ms} ms).{TEXT}")
    else:
        print(f"  {ERROR}✘ Schedule '{schedule_id}' failed with exit code {exit_code}. Run 'schedule debug {schedule_id}' for details.{TEXT}")
    return exit_code == 0

def debug_schedule(schedule_id):
    log_conn = get_schedule_log_db(schedule_id)
    cursor = log_conn.cursor()
    cursor.execute("SELECT * FROM ExecutionLogs ORDER BY ExecutedAt DESC LIMIT 10")
    rows = cursor.fetchall()
    log_conn.close()
    
    if not rows:
        print(f"  {MUTED}No execution logs found for schedule '{schedule_id}'.{TEXT}")
        return

    print(f"\n  {PRIMARY}Execution Logs for Schedule '{schedule_id}' (Child DB):{TEXT}")
    print(f"  {MUTED}{'-'*76}{TEXT}")
    for r in rows:
        c_status = PRIMARY if r["Status"] == "success" else ERROR
        print(f"  {c_status}[{r['Status'].upper()}]{TEXT} Time: {r['ExecutedAt']} | Duration: {r['DurationMs']} ms | ExitCode: {r['ExitCode']}")
        if r["StdoutText"]:
            print(f"    {MUTED}Stdout:{TEXT} {r['StdoutText'].strip()[:200]}")
        if r["StderrText"]:
            print(f"    {ERROR}Stderr:{TEXT} {r['StderrText'].strip()[:200]}")
        print(f"  {MUTED}{'-'*76}{TEXT}")
    print("")

def show_schedule_help():
    print(f"\n  {PRIMARY}=== Schedule & Crontab Command Reference (Schedule.db) ==={TEXT}")
    print(f"  {MUTED}Manage recurring tasks with multi-runtime script execution and per-schedule dynamic log DBs.{TEXT}\n")
    print(f"  {SECONDARY}Commands:{TEXT}")
    print(f"    schedule ls                             {MUTED}# List all scheduled jobs{TEXT}")
    print(f"    schedule add <type> <path> <timing>     {MUTED}# Register scheduled task{TEXT}")
    print(f"    schedule run <id>                       {MUTED}# Trigger execution immediately{TEXT}")
    print(f"    schedule debug <id>                     {MUTED}# Inspect execution logs in ~/.scripts-fixer/schedules/<id>.db{TEXT}")
    print(f"    schedule remove <id>                    {MUTED}# Unregister scheduled task{TEXT}")
    print(f"    schedule help                           {MUTED}# Show this help screen{TEXT}\n")
    print(f"  {SECONDARY}Supported Script Types & Examples:{TEXT}")
    print(f"    {ACCENT}ps{TEXT}     (PowerShell) : schedule add ps \".\\scripts\\health.ps1\" \"0 * * * *\"")
    print(f"    {ACCENT}bash{TEXT}   (Bash script): schedule add bash \"/home/user/clean.sh\" \"@daily\"")
    print(f"    {ACCENT}sh{TEXT}     (POSIX Shell): schedule add sh \"/usr/local/bin/sync.sh\" \"*/15 * * * *\"")
    print(f"    {ACCENT}js{TEXT}     (JavaScript) : schedule add js \"./worker.js\" \"0 2 * * *\"")
    print(f"    {ACCENT}macro{TEXT}  (Macro Flow) : schedule add macro \"deploy-flow\" \"@weekly\"")
    print(f"\n  {MUTED}Note: 'crontab' and 'cron' are recognized as aliases for 'schedule'.{TEXT}\n")

def main():
    if len(sys.argv) > 1 and sys.argv[1].lower() in ("help", "-h", "--help"):
        show_schedule_help()
        return

    parser = argparse.ArgumentParser(description="Scheduled Tasks & Crontab Manager (scripts-fixer)", add_help=False)
    subparsers = parser.add_subparsers(dest="subcommand")

    # ls / list
    subparsers.add_parser("ls")
    subparsers.add_parser("list")

    # add <type> <target> <timing>
    p_add = subparsers.add_parser("add")
    p_add.add_argument("type", choices=VALID_TYPES, help="Script type: ps, bash, sh, js, macro")
    p_add.add_argument("target", help="Path to script or macro name")
    p_add.add_argument("timing", help="Timing interval (e.g. daily, hourly, '0 0 * * *')")
    p_add.add_argument("--id", default=None, help="Custom identifier for schedule")
    p_add.add_argument("--name", default=None, help="Display name")
    p_add.add_argument("--args", default="", help="Command line arguments")

    # remove / rm
    p_rm = subparsers.add_parser("remove")
    p_rm.add_argument("id", help="Schedule ID to remove")
    p_rm2 = subparsers.add_parser("rm")
    p_rm2.add_argument("id", help="Schedule ID to remove")

    # run
    p_run = subparsers.add_parser("run")
    p_run.add_argument("id", help="Schedule ID to execute immediately")

    # debug
    p_dbg = subparsers.add_parser("debug")
    p_dbg.add_argument("id", help="Schedule ID to view execution logs")

    parser.add_argument("--json", action="store_true", help="Output in JSON format")

    args, unknown = parser.parse_known_args()
    sub = (args.subcommand or "list").lower()

    if sub in ("ls", "list"):
        list_schedules(as_json=args.json)
    elif sub == "add":
        clean_target = os.path.basename(args.target).split(".")[0]
        sched_id = args.id or f"sched-{clean_target.lower()}"
        name = args.name or f"Job {clean_target}"
        add_schedule(sched_id, name, args.type, args.target, args.timing, args.args)
    elif sub in ("remove", "rm"):
        remove_schedule(args.id)
    elif sub == "run":
        run_schedule(args.id)
    elif sub == "debug":
        debug_schedule(args.id)
    elif sub == "help":
        show_schedule_help()

if __name__ == "__main__":
    main()
