import os
import sys
import shutil
import sqlite3
import argparse
import json

from split_db import get_db_root_dir

PRIMARY = "\033[1;32m"
SECONDARY = "\033[1;36m"
ACCENT = "\033[1;33m"
MUTED = "\033[0;37m"
ERROR = "\033[1;31m"
TEXT = "\033[0m"

def format_bytes(size):
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size < 1024.0:
            return f"{size:.2f} {unit}"
        size /= 1024.0
    return f"{size:.2f} PB"

def list_databases():
    base_dir = get_db_root_dir()
    dbs = []
    for root, _, files in os.walk(base_dir):
        for f in files:
            if f.endswith(".db"):
                full_path = os.path.join(root, f)
                size = os.path.getsize(full_path)
                rel_path = os.path.relpath(full_path, base_dir)
                table_count = 0
                try:
                    conn = sqlite3.connect(full_path)
                    cur = conn.cursor()
                    cur.execute("SELECT count(*) FROM sqlite_master WHERE type='table'")
                    table_count = cur.fetchone()[0]
                    conn.close()
                except Exception:
                    pass
                dbs.append({
                    "name": rel_path,
                    "path": full_path,
                    "size_bytes": size,
                    "size_fmt": format_bytes(size),
                    "tables": table_count
                })
    return dbs

def get_windows_fs_info(drive_path):
    try:
        import ctypes
        vol_name = ctypes.create_unicode_buffer(1024)
        fs_name = ctypes.create_unicode_buffer(1024)
        res = ctypes.windll.kernel32.GetVolumeInformationW(
            ctypes.c_wchar_p(drive_path),
            vol_name, len(vol_name),
            None, None, None,
            fs_name, len(fs_name)
        )
        if res:
            return fs_name.value or "NTFS", vol_name.value or ""
    except Exception:
        pass
    return "NTFS", ""

def get_linux_mount_info():
    mount_map = {}
    try:
        if os.path.exists("/proc/mounts"):
            with open("/proc/mounts", "r") as f:
                for line in f:
                    parts = line.strip().split()
                    if len(parts) >= 3:
                        mount_map[parts[1]] = parts[2]
    except Exception:
        pass
    return mount_map

def get_drive_info():
    drives = []
    current_cwd = os.getcwd()
    current_drive_letter = os.path.splitdrive(current_cwd)[0].upper() if sys.platform == "win32" else None

    if sys.platform == "win32":
        import string
        for letter in string.ascii_uppercase:
            drive_path = f"{letter}:\\"
            if os.path.exists(drive_path):
                try:
                    usage = shutil.disk_usage(drive_path)
                    percent = round((usage.used / usage.total) * 100, 1)
                    fs_type, vol_label = get_windows_fs_info(drive_path)
                    is_current = (f"{letter}:" == current_drive_letter)
                    drives.append({
                        "drive": f"{letter}:",
                        "mount": drive_path,
                        "format": fs_type,
                        "label": vol_label,
                        "total": format_bytes(usage.total),
                        "used": format_bytes(usage.used),
                        "free": format_bytes(usage.free),
                        "percent": f"{percent}%",
                        "is_current": is_current
                    })
                except Exception:
                    pass
    else:
        linux_mounts = get_linux_mount_info()
        candidate_mounts = ["/", "/home", "/var", "/tmp"]
        for mnt in list(linux_mounts.keys()):
            if mnt.startswith("/media") or mnt.startswith("/mnt") or mnt in candidate_mounts:
                if mnt not in candidate_mounts: candidate_mounts.append(mnt)

        for mount in candidate_mounts:
            if os.path.exists(mount):
                try:
                    usage = shutil.disk_usage(mount)
                    percent = round((usage.used / usage.total) * 100, 1)
                    fs_type = linux_mounts.get(mount, "ext4")
                    is_current = (current_cwd == mount or (mount != "/" and current_cwd.startswith(mount)))
                    drives.append({
                        "drive": mount,
                        "mount": mount,
                        "format": fs_type,
                        "label": "",
                        "total": format_bytes(usage.total),
                        "used": format_bytes(usage.used),
                        "free": format_bytes(usage.free),
                        "percent": f"{percent}%",
                        "is_current": is_current
                    })
                except Exception:
                    pass
    return drives

def show_storage_overview(as_json=False):
    dbs = list_databases()
    drives = get_drive_info()

    if as_json:
        print(json.dumps({"databases": dbs, "drives": drives}, indent=2))
        return

    print(f"\n  {PRIMARY}=== System Storage Calculation & Split DB Footprint ==={TEXT}")
    print(f"\n  {SECONDARY}Disk Drives & Partitions:{TEXT}")
    print(f"  {MUTED}{'-'*78}{TEXT}")
    print(f"  {MUTED}{'Drive'.ljust(16)} {'Mount'.ljust(12)} {'Format'.ljust(10)} {'Total'.ljust(11)} {'Used'.ljust(11)} {'Free'.ljust(11)} {'Usage'}{TEXT}")
    print(f"  {MUTED}{'-'*78}{TEXT}")
    for d in drives:
        drive_disp = f"{d['drive']} *" if d.get("is_current") else d['drive']
        padded_drive = drive_disp.ljust(16)
        col_drive = f"{PRIMARY}{padded_drive}{TEXT}" if d.get("is_current") else f"{ACCENT}{padded_drive}{TEXT}"
        print(f"  {col_drive} {d['mount'].ljust(12)} {d['format'].ljust(10)} {d['total'].ljust(11)} {d['used'].ljust(11)} {PRIMARY}{d['free'].ljust(11)}{TEXT} {d['percent']}")

    print(f"  {MUTED}{'-'*78}{TEXT}")
    print(f"  {MUTED}(* = Current Working Drive: {os.getcwd()}){TEXT}")

    print(f"\n  {SECONDARY}Split SQLite Databases (~/.scripts-fixer):{TEXT}")
    print(f"  {MUTED}{'-'*78}{TEXT}")
    print(f"  {MUTED}{'Database Name'.ljust(38)} {'Size'.ljust(16)} {'Tables'.ljust(10)}{TEXT}")
    print(f"  {MUTED}{'-'*78}{TEXT}")
    total_db_size = sum(x["size_bytes"] for x in dbs)
    for db in dbs:
        print(f"  {SECONDARY}{db['name'].ljust(38)}{TEXT} {db['size_fmt'].ljust(16)} {ACCENT}{str(db['tables']).ljust(10)}{TEXT}")
    print(f"  {MUTED}{'-'*78}{TEXT}")
    print(f"  {MUTED}Total Split DB Size: {PRIMARY}{format_bytes(total_db_size)}{TEXT}\n")

def show_partition_guidance(subaction=None, swap_size="4G"):
    print(f"\n  {PRIMARY}=== Storage Partitioning Best Practices & Operations ==={TEXT}")
    if subaction == "gui":
        if sys.platform == "win32":
            print(f"  {SECONDARY}Launching Windows Disk Management GUI (diskmgmt.msc)...{TEXT}")
            os.system("start diskmgmt.msc")
        else:
            print(f"  {SECONDARY}Launching GParted GUI...{TEXT}")
            os.system("gparted &")
        return

    if subaction == "swap" or sys.platform != "win32":
        print(f"""
  {SECONDARY}Ubuntu / Linux Partitioning & Swap Management:{TEXT}
  1. Inspect Swap:
     {ACCENT}swapon --show{TEXT} or {ACCENT}free -h{TEXT}
  2. Increase / Recreate Swapfile ({swap_size}) (Zero-Downtime Best Practice):
     {MUTED}sudo swapoff -a
     sudo fallocate -l {swap_size} /swapfile
     sudo chmod 600 /swapfile
     sudo mkswap /swapfile
     sudo swapon /swapfile{TEXT}
  3. LVM Volume Extension (e.g. increase root partition by 10G):
     {MUTED}sudo vgs
     sudo lvextend -L +10G /dev/mapper/ubuntu--vg-ubuntu--lv
     sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv{TEXT}
        """)
        if subaction == "swap":
            return

    if sys.platform == "win32":
        print(f"""
  {SECONDARY}Windows Storage Partitioning Options:{TEXT}
  1. Launch Windows Disk Management GUI:
     {ACCENT}storage partition gui{TEXT} or {ACCENT}diskmgmt.msc{TEXT}
  2. Inspect Volumes via PowerShell:
     {ACCENT}Get-Volume | Format-Table DriveLetter, FileSystemLabel, SizeRemaining, Size{TEXT}
  3. Diskpart Interactive Helper:
     {MUTED}diskpart -> list disk -> list volume -> select volume <N> -> extend{TEXT}
        """)

def show_storage_help():
    print(f"\n  {PRIMARY}=== Storage & Split DB Inspector (scripts-fixer) ==={TEXT}")
    print(f"  {MUTED}Inspect disk drives, calculate usage, audit split SQLite DBs, and manage partitions.{TEXT}\n")
    print(f"  {SECONDARY}Commands:{TEXT}")
    print(f"    storage ls                              {MUTED}# Show disk partitions, formats, free space & DB footprint{TEXT}")
    print(f"    storage info                            {MUTED}# Detailed storage breakdown{TEXT}")
    print(f"    storage partition                       {MUTED}# Display partition & swap management guidance{TEXT}")
    print(f"    storage partition swap [--size <size>]  {MUTED}# Swap expansion guide/commands for Ubuntu{TEXT}")
    print(f"    storage partition gui                   {MUTED}# Open OS Disk Management GUI{TEXT}")
    print(f"    storage help                            {MUTED}# Show this help screen{TEXT}\n")

def main():
    if len(sys.argv) > 1 and sys.argv[1].lower() in ("help", "-h", "--help"):
        show_storage_help()
        return

    sub = sys.argv[1].lower() if len(sys.argv) > 1 else "ls"
    as_json = "--json" in sys.argv

    if sub in ("ls", "list", "info"):
        show_storage_overview(as_json=as_json)
    elif sub == "partition":
        subaction = sys.argv[2].lower() if len(sys.argv) > 2 else None
        swap_size = "4G"
        if "--size" in sys.argv:
            s_idx = sys.argv.index("--size")
            if s_idx + 1 < len(sys.argv): swap_size = sys.argv[s_idx + 1]
        show_partition_guidance(subaction, swap_size)
    elif sub == "help":
        show_storage_help()
    else:
        show_storage_overview(as_json=as_json)

if __name__ == "__main__":
    main()

