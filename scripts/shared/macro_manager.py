import os
import sys
import time
import argparse
import datetime
import subprocess
import json

from split_db import get_connection, init_macro_db
import startup_manager
import schedule_manager

PRIMARY = "\033[1;32m"
SECONDARY = "\033[1;36m"
ACCENT = "\033[1;33m"
MUTED = "\033[0;37m"
ERROR = "\033[1;31m"
TEXT = "\033[0m"

def add_macro(name, steps, description=""):
    init_macro_db()
    conn = get_connection("Macro.db")
    cursor = conn.cursor()
    macro_id = name.lower().replace(" ", "-")
    now_str = datetime.datetime.now().isoformat()
    desc = description or f"Macro sequence ({len(steps)} steps)"

    cursor.execute("""
        INSERT OR REPLACE INTO MacroDefinitions
        (MacroId, Name, Description, IsInteractive, CreatedAt, UpdatedAt)
        VALUES (?, ?, ?, 1, COALESCE((SELECT CreatedAt FROM MacroDefinitions WHERE MacroId = ?), ?), ?)
    """, (macro_id, name, desc, macro_id, now_str, now_str))

    cursor.execute("DELETE FROM MacroSteps WHERE MacroId = ?", (macro_id,))
    for idx, step_cmd in enumerate(steps):
        cursor.execute("""
            INSERT INTO MacroSteps (MacroId, StepOrder, CommandType, CommandText, Arguments)
            VALUES (?, ?, 'shell', ?, '')
        """, (macro_id, idx + 1, step_cmd))
    conn.commit()
    conn.close()
    print(f"  {PRIMARY}✔ Created interactive macro '{name}' with {len(steps)} steps.{TEXT}")

def list_macros(as_json=False):
    init_macro_db()
    conn = get_connection("Macro.db")
    cursor = conn.cursor()
    cursor.execute("""
        SELECT m.MacroId, m.Name, m.Description, COUNT(s.StepId) as StepCount, m.CreatedAt
        FROM MacroDefinitions m
        LEFT JOIN MacroSteps s ON m.MacroId = s.MacroId
        GROUP BY m.MacroId
        ORDER BY m.CreatedAt DESC
    """)
    rows = cursor.fetchall()
    conn.close()

    if as_json:
        items = [dict(r) for r in rows]
        print(json.dumps(items, indent=2))
        return

    if not rows:
        print(f"  {MUTED}No macros found. Define one using 'macro add <name> <step1> <step2>...'.{TEXT}")
        return

    print(f"\n  {PRIMARY}Registered Interactive Macros ({len(rows)} entries):{TEXT}")
    print(f"  {MUTED}{'-'*76}{TEXT}")
    print(f"  {MUTED}{'Macro Name'.ljust(24)} {'Steps'.ljust(10)} {'Description'.ljust(40)}{TEXT}")
    print(f"  {MUTED}{'-'*76}{TEXT}")
    for r in rows:
        print(f"  {SECONDARY}{r['Name'].ljust(24)}{TEXT} {ACCENT}{str(r['StepCount']).ljust(10)}{TEXT} {MUTED}{r['Description'][:40]}{TEXT}")
    print(f"  {MUTED}{'-'*76}\n")

def remove_macro(name):
    init_macro_db()
    conn = get_connection("Macro.db")
    cursor = conn.cursor()
    cursor.execute("SELECT MacroId FROM MacroDefinitions WHERE MacroId = ? OR Name = ?", (name, name))
    row = cursor.fetchone()
    if not row:
        print(f"  {ERROR}Macro '{name}' not found.{TEXT}")
        conn.close()
        return False
    m_id = row["MacroId"]
    cursor.execute("DELETE FROM MacroDefinitions WHERE MacroId = ?", (m_id,))
    cursor.execute("DELETE FROM MacroSteps WHERE MacroId = ?", (m_id,))
    cursor.execute("DELETE FROM MacroExecutions WHERE MacroId = ?", (m_id,))
    conn.commit()
    conn.close()
    print(f"  {PRIMARY}✔ Removed macro '{name}'.{TEXT}")
    return True

def run_macro_interactive(name):
    init_macro_db()
    conn = get_connection("Macro.db")
    cursor = conn.cursor()
    cursor.execute("SELECT MacroId, Name, Description FROM MacroDefinitions WHERE MacroId = ? OR Name = ?", (name, name))
    macro = cursor.fetchone()
    if not macro:
        print(f"  {ERROR}Macro '{name}' not found.{TEXT}")
        conn.close()
        return False

    macro_id = macro["MacroId"]
    cursor.execute("SELECT StepOrder, CommandText FROM MacroSteps WHERE MacroId = ? ORDER BY StepOrder ASC", (macro_id,))
    steps = cursor.fetchall()
    
    print(f"\n  {PRIMARY}=== Running Interactive Macro: {macro['Name']} ({len(steps)} steps) ==={TEXT}")
    t0 = time.time()
    overall_exit = 0

    for s in steps:
        step_num = s["StepOrder"]
        cmd_text = s["CommandText"]
        print(f"\n  {SECONDARY}▶ [Step {step_num}/{len(steps)}]{TEXT} {ACCENT}{cmd_text}{TEXT}")
        
        # Stream live output interactively
        p = subprocess.Popen(cmd_text, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
        for line in iter(p.stdout.readline, ''):
            sys.stdout.write(line)
            sys.stdout.flush()
        p.stdout.close()
        p.wait()

        if p.returncode != 0:
            overall_exit = p.returncode
            print(f"  {ERROR}✘ Step {step_num} failed with exit code {p.returncode}. Aborting macro.{TEXT}")
            break

    dur = round(time.time() - t0, 2)
    status_str = "success" if overall_exit == 0 else "failure"

    cursor.execute("""
        INSERT INTO MacroExecutions (MacroId, ExecutedAt, Status, ExitCode, DurationSeconds)
        VALUES (?, ?, ?, ?, ?)
    """, (macro_id, datetime.datetime.now().isoformat(), status_str, overall_exit, dur))
    conn.commit()
    conn.close()

    if overall_exit == 0:
        print(f"\n  {PRIMARY}✔ Macro '{macro['Name']}' completed successfully in {dur}s.{TEXT}\n")
    return overall_exit == 0

def show_macro_help():
    print(f"\n  {PRIMARY}=== Interactive Macro Engine (Macro.db) ==={TEXT}")
    print(f"  {MUTED}Compose, manage, and execute multi-step interactive workflows with real-time terminal streaming.{TEXT}\n")
    print(f"  {SECONDARY}Commands:{TEXT}")
    print(f"    macro ls                                      {MUTED}# List all registered macros{TEXT}")
    print(f"    macro add <name> <step1> <step2> ...          {MUTED}# Create a multi-step macro pipeline{TEXT}")
    print(f"    macro run <name>                              {MUTED}# Execute macro with real-time streaming{TEXT}")
    print(f"    macro remove <name>                           {MUTED}# Delete a macro{TEXT}")
    print(f"    macro startup [ls|add|remove|help]            {MUTED}# Manage macro startup hooks or add items{TEXT}")
    print(f"    macro schedule [ls|add|remove|help]           {MUTED}# Manage macro recurring schedules{TEXT}")
    print(f"    macro help                                    {MUTED}# Show this help screen{TEXT}\n")
    print(f"  {SECONDARY}Startup & Schedule Integration Examples:{TEXT}")
    print(f"    {ACCENT}macro startup add <macro_name>{TEXT}          : Hook macro to execute on user login")
    print(f"    {ACCENT}macro startup add \"C:\\path\\app.ps1\"{TEXT}    : Register any script to startup via macro")
    print(f"    {ACCENT}macro schedule add <macro_name> \"@daily\"{TEXT}: Schedule macro to run daily")
    print(f"    {ACCENT}macro schedule add ps \".\\test.ps1\" \"0 * * * *\"{TEXT}: Schedule PowerShell script via macro\n")

def main():
    if len(sys.argv) > 1 and sys.argv[1].lower() in ("help", "-h", "--help"):
        show_macro_help()
        return

    # Handle macro startup subactions directly
    if len(sys.argv) > 1 and sys.argv[1].lower() == "startup":
        sub_args = sys.argv[2:]
        if not sub_args or sub_args[0].lower() in ("ls", "list"):
            startup_manager.list_startup_items()
            return
        if sub_args[0].lower() in ("help", "-h", "--help"):
            startup_manager.show_startup_help()
            return
        if sub_args[0].lower() == "add" and len(sub_args) > 1:
            target = sub_args[1]
            freq = "on-login"
            if "--freq" in sub_args:
                f_idx = sub_args.index("--freq")
                if f_idx + 1 < len(sub_args): freq = sub_args[f_idx + 1]
            # Check if it's a known macro
            conn = get_connection("Macro.db")
            cur = conn.cursor()
            cur.execute("SELECT Name FROM MacroDefinitions WHERE MacroId = ? OR Name = ?", (target, target))
            is_macro = cur.fetchone() is not None
            conn.close()
            if is_macro:
                startup_manager.add_startup_item(f"macro-{target}", f"macro:{target}", frequency=freq)
            else:
                name = os.path.splitext(os.path.basename(target))[0] or target
                startup_manager.add_startup_item(name, target, frequency=freq)
            return
        if sub_args[0].lower() in ("remove", "rm") and len(sub_args) > 1:
            startup_manager.remove_startup_item(sub_args[1])
            startup_manager.remove_startup_item(f"macro-{sub_args[1]}")
            return
        # If bare macro startup <path>
        startup_manager.main()
        return

    # Handle macro schedule subactions directly
    if len(sys.argv) > 1 and sys.argv[1].lower() in ("schedule", "crontab", "cron"):
        sub_args = sys.argv[2:]
        if not sub_args or sub_args[0].lower() in ("ls", "list"):
            schedule_manager.list_schedules()
            return
        if sub_args[0].lower() in ("help", "-h", "--help"):
            schedule_manager.show_schedule_help()
            return
        if sub_args[0].lower() == "add" and len(sub_args) > 1:
            if sub_args[1].lower() in schedule_manager.VALID_TYPES and len(sub_args) >= 4:
                # macro schedule add <type> <path> <timing>
                stype = sub_args[1]
                target = sub_args[2]
                timing = sub_args[3]
                clean = os.path.splitext(os.path.basename(target))[0]
                schedule_manager.add_schedule(f"sched-{clean.lower()}", f"Job {clean}", stype, target, timing)
                return
            elif len(sub_args) >= 3:
                # macro schedule add <macro_name> <timing>
                m_name = sub_args[1]
                timing = sub_args[2]
                schedule_manager.add_schedule(f"macro-{m_name.lower()}", f"Macro {m_name}", "macro", f"macro:{m_name}", timing)
                return
        if sub_args[0].lower() in ("remove", "rm") and len(sub_args) > 1:
            schedule_manager.remove_schedule(sub_args[1])
            schedule_manager.remove_schedule(f"macro-{sub_args[1]}")
            return
        schedule_manager.main()
        return

    parser = argparse.ArgumentParser(description="Interactive Macro Manager (scripts-fixer)", add_help=False)
    subparsers = parser.add_subparsers(dest="subcommand")

    # ls / list
    subparsers.add_parser("ls")
    subparsers.add_parser("list")

    # add <name> <steps...>
    p_add = subparsers.add_parser("add")
    p_add.add_argument("name", help="Macro identifier / name")
    p_add.add_argument("steps", nargs="+", help="Shell commands to execute in sequence")
    p_add.add_argument("--desc", default="", help="Description")

    # remove / rm
    p_rm = subparsers.add_parser("remove")
    p_rm.add_argument("name", help="Macro name to delete")
    p_rm2 = subparsers.add_parser("rm")
    p_rm2.add_argument("name", help="Macro name to delete")

    # run <name>
    p_run = subparsers.add_parser("run")
    p_run.add_argument("name", help="Macro name to execute interactively")

    parser.add_argument("--json", action="store_true", help="Output in JSON format")

    args, unknown = parser.parse_known_args()
    sub = (args.subcommand or "list").lower()

    if sub in ("ls", "list"):
        list_macros(as_json=args.json)
    elif sub == "add":
        add_macro(args.name, args.steps, description=args.desc)
    elif sub in ("remove", "rm"):
        remove_macro(args.name)
    elif sub == "run":
        run_macro_interactive(args.name)
    elif sub == "help":
        show_macro_help()

if __name__ == "__main__":
    main()

