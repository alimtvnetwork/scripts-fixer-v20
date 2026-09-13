import os
import sys
import argparse
import datetime
import subprocess
import json

from split_db import get_connection, init_startup_db

PRIMARY = "\033[1;32m"
SECONDARY = "\033[1;36m"
ACCENT = "\033[1;33m"
MUTED = "\033[0;37m"
ERROR = "\033[1;31m"
TEXT = "\033[0m"

def get_windows_startup_dir():
    appdata = os.environ.get("APPDATA")
    if appdata:
        p = os.path.join(appdata, "Microsoft", "Windows", "Start Menu", "Programs", "Startup")
        if os.path.exists(p):
            return p
    return None

def get_linux_autostart_dir():
    p = os.path.expanduser("~/.config/autostart")
    os.makedirs(p, exist_ok=True)
    return p

def normalize_frequency(freq):
    f = str(freq or "on-login").lower().strip().replace(" ", "-").replace("_", "-")
    if f in ("every-time", "everytime", "login", "on-login", "every-login"):
        return "on-login"
    if f in ("weekly", "once-a-week", "once-week", "1-week"):
        return "weekly"
    if f in ("daily", "once-a-day", "every-day"):
        return "daily"
    return f

def add_startup_item(name, target_path, arguments="", frequency="on-login"):
    init_startup_db()
    conn = get_connection("Startup.db")
    cursor = conn.cursor()
    item_id = name.lower().replace(" ", "-")
    now_str = datetime.datetime.now().isoformat()
    norm_freq = normalize_frequency(frequency)
    
    cursor.execute("""
        INSERT OR REPLACE INTO StartupItems
        (ItemId, Name, TargetType, TargetPath, Arguments, Frequency, IsEnabled, CreatedAt, UpdatedAt)
        VALUES (?, ?, ?, ?, ?, ?, 1, COALESCE((SELECT CreatedAt FROM StartupItems WHERE ItemId = ?), ?), ?)
    """, (item_id, name, detect_target_type(target_path), target_path, arguments, norm_freq, item_id, now_str, now_str))
    conn.commit()
    conn.close()

    # Configure OS integration
    apply_os_startup(item_id, name, target_path, arguments, norm_freq)
    print(f"  {PRIMARY}✔ Added startup item '{name}' [Frequency: {norm_freq}]{TEXT}")

def detect_target_type(target_path):
    lower = target_path.lower()
    if lower.startswith("macro:"):
        return "macro"
    if lower.endswith(".ps1"):
        return "powershell"
    if lower.endswith(".sh") or lower.endswith(".bash"):
        return "bash"
    if lower.endswith(".js"):
        return "javascript"
    if lower.endswith((".ico", ".icon", ".png")):
        return "icon"
    if lower.endswith(".lnk"):
        return "shortcut"
    return "binary"

def apply_os_startup(item_id, name, target_path, arguments, frequency):
    if sys.platform == "win32":
        startup_dir = get_windows_startup_dir()
        if startup_dir:
            cmd_path = os.path.join(startup_dir, f"scripts_fixer_{item_id}.cmd")
            with open(cmd_path, "w", encoding="utf-8") as f:
                f.write(f"@echo off\r\nREM scripts-fixer startup item: {name}\r\n")
                if target_path.lower().startswith("macro:"):
                    macro_name = target_path.split(":", 1)[1]
                    f.write(f"python \"{os.path.join(os.path.dirname(__file__), 'macro_manager.py')}\" run {macro_name}\r\n")
                elif target_path.endswith(".ps1"):
                    f.write(f"powershell -NoProfile -ExecutionPolicy Bypass -File \"{target_path}\" {arguments}\r\n")
                elif target_path.lower().endswith((".ico", ".icon", ".png", ".jpg")):
                    f.write(f"start \"\" \"{target_path}\"\r\n")
                else:
                    f.write(f"\"{target_path}\" {arguments}\r\n")
    else:
        autostart_dir = get_linux_autostart_dir()
        desktop_file = os.path.join(autostart_dir, f"scripts_fixer_{item_id}.desktop")
        exec_cmd = target_path
        if target_path.lower().startswith("macro:"):
            macro_name = target_path.split(":", 1)[1]
            exec_cmd = f"python3 {os.path.join(os.path.dirname(__file__), 'macro_manager.py')} run {macro_name}"
        elif target_path.endswith(".sh"):
            exec_cmd = f"bash {target_path} {arguments}"
        elif target_path.lower().endswith((".ico", ".icon", ".png", ".jpg")):
            exec_cmd = f"xdg-open \"{target_path}\""
        with open(desktop_file, "w", encoding="utf-8") as f:
            f.write(f"[Desktop Entry]\nType=Application\nName={name}\nExec={exec_cmd}\nHidden=false\nNoDisplay=false\nX-GNOME-Autostart-enabled=true\n")

def remove_startup_item(item_id_or_name):
    init_startup_db()
    conn = get_connection("Startup.db")
    cursor = conn.cursor()
    cursor.execute("SELECT ItemId, Name FROM StartupItems WHERE ItemId = ? OR Name = ?", (item_id_or_name, item_id_or_name))
    row = cursor.fetchone()
    if not row:
        print(f"  {ERROR}Startup item '{item_id_or_name}' not found.{TEXT}")
        conn.close()
        return False
    item_id = row["ItemId"]
    cursor.execute("DELETE FROM StartupItems WHERE ItemId = ?", (item_id,))
    cursor.execute("DELETE FROM StartupExecutions WHERE ItemId = ?", (item_id,))
    conn.commit()
    conn.close()

    # Remove OS integration
    if sys.platform == "win32":
        startup_dir = get_windows_startup_dir()
        if startup_dir:
            cmd_path = os.path.join(startup_dir, f"scripts_fixer_{item_id}.cmd")
            if os.path.exists(cmd_path):
                try: os.remove(cmd_path)
                except Exception: pass
    else:
        autostart_dir = get_linux_autostart_dir()
        desktop_file = os.path.join(autostart_dir, f"scripts_fixer_{item_id}.desktop")
        if os.path.exists(desktop_file):
            try: os.remove(desktop_file)
            except Exception: pass
            
    print(f"  {PRIMARY}✔ Removed startup item '{item_id}'.{TEXT}")
    return True

def list_startup_items(as_json=False):
    init_startup_db()
    conn = get_connection("Startup.db")
    cursor = conn.cursor()
    cursor.execute("SELECT ItemId, Name, TargetType, TargetPath, Frequency, IsEnabled, CreatedAt FROM StartupItems ORDER BY CreatedAt DESC")
    rows = cursor.fetchall()
    conn.close()
    
    if as_json:
        items = [dict(r) for r in rows]
        print(json.dumps(items, indent=2))
        return

    if not rows:
        print(f"  {MUTED}No startup items registered. Add one using 'startup add <path>'.{TEXT}")
        return

    print(f"\n  {PRIMARY}Registered Startup Items ({len(rows)} entries):{TEXT}")
    print(f"  {MUTED}{'-'*72}{TEXT}")
    print(f"  {MUTED}{'ID'.ljust(18)} {'Name'.ljust(22)} {'Type'.ljust(12)} {'Frequency'.ljust(14)} {'Status'}{TEXT}")
    print(f"  {MUTED}{'-'*72}{TEXT}")
    for r in rows:
        status_txt = f"{PRIMARY}Enabled{TEXT}" if r["IsEnabled"] else f"{MUTED}Disabled{TEXT}"
        print(f"  {SECONDARY}{r['ItemId'].ljust(18)}{TEXT} {r['Name'].ljust(22)} {MUTED}{r['TargetType'].ljust(12)}{TEXT} {ACCENT}{r['Frequency'].ljust(14)}{TEXT} {status_txt}")
        print(f"    {MUTED}└── Target: {r['TargetPath']}{TEXT}")
    print(f"  {MUTED}{'-'*72}{TEXT}\n")

def run_startup_items(item_id=None):
    init_startup_db()
    conn = get_connection("Startup.db")
    cursor = conn.cursor()
    query = "SELECT * FROM StartupItems WHERE IsEnabled = 1"
    params = ()
    if item_id:
        query += " AND (ItemId = ? OR Name = ?)"
        params = (item_id, item_id)
    cursor.execute(query, params)
    rows = cursor.fetchall()
    
    for r in rows:
        target = r["TargetPath"]
        args = r["Arguments"] or ""
        print(f"  {SECONDARY}Executing startup item:{TEXT} {r['Name']} ({target})")
        start_time = datetime.datetime.now()
        exit_code = 0
        output_summary = ""
        try:
            if target.startswith("macro:"):
                macro_name = target.split(":", 1)[1]
                p = subprocess.run([sys.executable, os.path.join(os.path.dirname(__file__), "macro_manager.py"), "run", macro_name])
                exit_code = p.returncode
            elif target.endswith(".ps1"):
                cmd = f"powershell -NoProfile -ExecutionPolicy Bypass -File \"{target}\" {args}"
                p = subprocess.run(cmd, shell=True)
                exit_code = p.returncode
            elif target.endswith(".sh"):
                p = subprocess.run(["bash", target] + (args.split() if args else []))
                exit_code = p.returncode
            else:
                cmd = f"\"{target}\" {args}".strip()
                p = subprocess.run(cmd, shell=True)
                exit_code = p.returncode
            output_summary = "Executed successfully" if exit_code == 0 else f"Failed with exit code {exit_code}"
        except Exception as e:
            exit_code = 1
            output_summary = str(e)
            
        cursor.execute("""
            INSERT INTO StartupExecutions (ItemId, ExecutedAt, Status, ExitCode, OutputSummary)
            VALUES (?, ?, ?, ?, ?)
        """, (r["ItemId"], start_time.isoformat(), "success" if exit_code == 0 else "failure", exit_code, output_summary))
        conn.commit()
    conn.close()

def show_startup_help():
    print(f"\n  {PRIMARY}=== Startup Automation Reference (Startup.db) ==={TEXT}")
    print(f"  {MUTED}Manage scripts, commands, desktop icons, and macros configured to execute at OS boot / user login.{TEXT}\n")
    print(f"  {SECONDARY}Commands:{TEXT}")
    print(f"    startup ls                              {MUTED}# List all registered startup items{TEXT}")
    print(f"    startup <path> [--freq <frequency>]     {MUTED}# Quick-add any script/app/icon to startup{TEXT}")
    print(f"    startup add <path> [--freq <frequency>] {MUTED}# Register startup item explicitly{TEXT}")
    print(f"    startup run [<id>]                      {MUTED}# Run startup items immediately and record logs{TEXT}")
    print(f"    startup remove <id>                     {MUTED}# Unregister item and clean OS autostart files{TEXT}")
    print(f"    startup help                            {MUTED}# Show this help screen{TEXT}\n")
    print(f"  {SECONDARY}Supported Targets & Examples:{TEXT}")
    print(f"    {ACCENT}PowerShell{TEXT} (.ps1) : startup \"C:\\scripts\\init.ps1\" --freq on-login")
    print(f"    {ACCENT}Bash Script{TEXT}(.sh)  : startup \"/home/user/clean.sh\" --freq weekly")
    print(f"    {ACCENT}Desktop Icon{TEXT}(.ico): startup \"C:\\tools\\launcher.ico\"")
    print(f"    {ACCENT}Macro Flow{TEXT} (macro): startup add macro:deploy-flow --freq on-login")
    print(f"\n  {SECONDARY}Frequency Options:{TEXT}")
    print(f"    {MUTED}'on-login' (default, runs every time user logs in), 'weekly' (runs once a week), 'daily'{TEXT}\n")

def main():
    if len(sys.argv) > 1 and sys.argv[1].lower() in ("help", "-h", "--help"):
        show_startup_help()
        return

    # Direct target path shortcut: startup <path> [--freq <freq>]
    if len(sys.argv) > 1 and sys.argv[1].lower() not in ("ls", "list", "add", "remove", "rm", "run") and not sys.argv[1].startswith("-"):
        target_arg = sys.argv[1]
        freq_val = "on-login"
        args_val = ""
        name_val = None
        idx = 2
        while idx < len(sys.argv):
            opt = sys.argv[idx].lower()
            if opt in ("--freq", "--frequency", "-f") and idx + 1 < len(sys.argv):
                freq_val = sys.argv[idx + 1]
                idx += 2
            elif opt in ("--args", "-a") and idx + 1 < len(sys.argv):
                args_val = sys.argv[idx + 1]
                idx += 2
            elif opt in ("--name", "-n") and idx + 1 < len(sys.argv):
                name_val = sys.argv[idx + 1]
                idx += 2
            else:
                idx += 1
        name = name_val or os.path.splitext(os.path.basename(target_arg))[0] or target_arg
        add_startup_item(name, target_arg, args_val, freq_val)
        return

    parser = argparse.ArgumentParser(description="Startup items manager (scripts-fixer)", add_help=False)
    subparsers = parser.add_subparsers(dest="subcommand")
    
    # ls / list
    subparsers.add_parser("ls")
    subparsers.add_parser("list")
    
    # add
    p_add = subparsers.add_parser("add")
    p_add.add_argument("target", help="Path to script/binary or macro:<name>")
    p_add.add_argument("--name", "-n", default=None, help="Display name for item")
    p_add.add_argument("--args", "-a", default="", help="Optional arguments")
    p_add.add_argument("--frequency", "--freq", "-f", default="on-login")
    
    # remove / rm
    p_rm = subparsers.add_parser("remove")
    p_rm.add_argument("id", help="Item ID or name to remove")
    p_rm2 = subparsers.add_parser("rm")
    p_rm2.add_argument("id", help="Item ID or name to remove")

    # run
    p_run = subparsers.add_parser("run")
    p_run.add_argument("id", nargs="?", default=None, help="Optional item ID to run")
    
    parser.add_argument("--json", action="store_true", help="Output in JSON format")

    args, unknown = parser.parse_known_args()
    sub = (args.subcommand or "list").lower()

    if sub in ("ls", "list"):
        list_startup_items(as_json=args.json)
    elif sub == "add":
        name = args.name or os.path.splitext(os.path.basename(args.target))[0]
        add_startup_item(name, args.target, args.args, args.frequency)
    elif sub in ("remove", "rm"):
        remove_startup_item(args.id)
    elif sub == "run":
        run_startup_items(args.id)
    elif sub == "help":
        show_startup_help()

if __name__ == "__main__":
    main()

