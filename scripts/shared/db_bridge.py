#!/usr/bin/env python3
"""
db_bridge.py — Zero-dependency SQLite engine for scripts-fixer.
Manages schema bootstrapping, migration, package/profile tracking, and audit logging.
"""

import os
import sys
import sqlite3
import datetime
from pathlib import Path


def get_db_path() -> str:
    env_path = os.environ.get("SCRIPTS_FIXER_DB")
    if env_path:
        return env_path

    home = os.path.expanduser("~")
    local_share = Path(home) / ".local" / "share" / "scripts-fixer"
    try:
        local_share.mkdir(parents=True, exist_ok=True)
        return str(local_share / "scripts-fixer.db")
    except Exception:
        fallback = Path(__file__).resolve().parent.parent.parent / ".data"
        fallback.mkdir(parents=True, exist_ok=True)
        return str(fallback / "scripts-fixer.db")


def get_connection() -> sqlite3.Connection:
    db_file = get_db_path()
    conn = sqlite3.connect(db_file)
    conn.execute("PRAGMA journal_mode=WAL;")
    return conn


def init_db():
    conn = get_connection()
    with conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS schema_migrations (
                version INTEGER PRIMARY KEY,
                applied_at TEXT
            );
        """)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS packages (
                name TEXT PRIMARY KEY,
                version TEXT,
                status TEXT,
                installed_at TEXT,
                updated_at TEXT,
                details TEXT
            );
        """)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS profiles (
                name TEXT PRIMARY KEY,
                status TEXT,
                installed_at TEXT,
                updated_at TEXT
            );
        """)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS install_logs (
                id TEXT PRIMARY KEY,
                target_type TEXT,
                target_name TEXT,
                action TEXT,
                status TEXT,
                exit_code INTEGER,
                error_message TEXT,
                log_path TEXT,
                started_at TEXT,
                ended_at TEXT
            );
        """)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS error_logs (
                id TEXT PRIMARY KEY,
                target_name TEXT,
                error_stage TEXT,
                error_message TEXT,
                stacktrace TEXT,
                created_at TEXT
            );
        """)
        conn.execute("INSERT OR IGNORE INTO schema_migrations (version, applied_at) VALUES (1, datetime('now'));")
    conn.close()


def record_start(target_type: str, target_name: str, action: str = "install") -> str:
    init_db()
    conn = get_connection()
    log_id = f"{target_name}-{int(datetime.datetime.now().timestamp())}"
    now = datetime.datetime.now().isoformat()
    with conn:
        conn.execute("""
            INSERT OR REPLACE INTO install_logs 
            (id, target_type, target_name, action, status, started_at)
            VALUES (?, ?, ?, ?, 'running', ?)
        """, (log_id, target_type, target_name, action, now))
    conn.close()
    return log_id


def record_success(target_type: str, target_name: str, version: str = "", details: str = ""):
    init_db()
    conn = get_connection()
    now = datetime.datetime.now().isoformat()
    with conn:
        if target_type == "profile":
            conn.execute("""
                INSERT OR REPLACE INTO profiles (name, status, installed_at, updated_at)
                VALUES (?, 'installed', COALESCE((SELECT installed_at FROM profiles WHERE name=?), ?), ?)
            """, (target_name, target_name, now, now))
        else:
            conn.execute("""
                INSERT OR REPLACE INTO packages (name, version, status, installed_at, updated_at, details)
                VALUES (?, ?, 'installed', COALESCE((SELECT installed_at FROM packages WHERE name=?), ?), ?, ?)
            """, (target_name, version, target_name, now, now, details))

        conn.execute("""
            UPDATE install_logs 
            SET status='success', exit_code=0, ended_at=?
            WHERE target_name=? AND status='running'
        """, (now, target_name))
    conn.close()


def record_failure(target_type: str, target_name: str, exit_code: int, error_msg: str, stacktrace: str = ""):
    init_db()
    conn = get_connection()
    now = datetime.datetime.now().isoformat()
    err_id = f"err-{target_name}-{int(datetime.datetime.now().timestamp())}"
    with conn:
        if target_type == "profile":
            conn.execute("INSERT OR REPLACE INTO profiles (name, status, updated_at) VALUES (?, 'failed', ?)", (target_name, now))
        else:
            conn.execute("INSERT OR REPLACE INTO packages (name, status, updated_at) VALUES (?, 'failed', ?)", (target_name, now))

        conn.execute("""
            UPDATE install_logs 
            SET status='failed', exit_code=?, error_message=?, ended_at=?
            WHERE target_name=? AND status='running'
        """, (exit_code, error_msg, now, target_name))

        conn.execute("""
            INSERT INTO error_logs (id, target_name, error_stage, error_message, stacktrace, created_at)
            VALUES (?, ?, 'execution', ?, ?, ?)
        """, (err_id, target_name, error_msg, stacktrace, now))
    conn.close()


def record_skipped(target_type: str, target_name: str, reason: str = "already installed"):
    init_db()
    conn = get_connection()
    now = datetime.datetime.now().isoformat()
    log_id = f"{target_name}-skip-{int(datetime.datetime.now().timestamp())}"
    with conn:
        conn.execute("""
            INSERT OR REPLACE INTO install_logs 
            (id, target_type, target_name, action, status, exit_code, error_message, started_at, ended_at)
            VALUES (?, ?, ?, 'check', 'skipped', 0, ?, ?, ?)
        """, (log_id, target_type, target_name, reason, now, now))
    conn.close()


def is_installed(target_type: str, target_name: str) -> bool:
    init_db()
    conn = get_connection()
    cur = conn.cursor()
    if target_type == "profile":
        cur.execute("SELECT status FROM profiles WHERE name=?", (target_name,))
    else:
        cur.execute("SELECT status FROM packages WHERE name=?", (target_name,))
    row = cur.fetchone()
    conn.close()
    return bool(row and row[0] == "installed")


def get_status(target_type: str, target_name: str) -> str:
    init_db()
    conn = get_connection()
    cur = conn.cursor()
    if target_type == "profile":
        cur.execute("SELECT status FROM profiles WHERE name=?", (target_name,))
    else:
        cur.execute("SELECT status FROM packages WHERE name=?", (target_name,))
    row = cur.fetchone()
    conn.close()
    return row[0] if row else "not_installed"


def main():
    if len(sys.argv) < 2:
        print(f"db_path: {get_db_path()}")
        sys.exit(0)

    cmd = sys.argv[1]
    if cmd == "init":
        init_db()
        print(f"Initialized SQLite database at: {get_db_path()}")
        sys.exit(0)

    if cmd == "path":
        print(get_db_path())
        sys.exit(0)

    if cmd == "is-installed":
        ttype = sys.argv[2] if len(sys.argv) > 2 else "package"
        tname = sys.argv[3] if len(sys.argv) > 3 else ""
        sys.exit(0 if is_installed(ttype, tname) else 1)

    if cmd == "get-status":
        ttype = sys.argv[2] if len(sys.argv) > 2 else "package"
        tname = sys.argv[3] if len(sys.argv) > 3 else ""
        print(get_status(ttype, tname))
        sys.exit(0)

    if cmd == "record-start":
        ttype = sys.argv[2] if len(sys.argv) > 2 else "package"
        tname = sys.argv[3] if len(sys.argv) > 3 else ""
        action = sys.argv[4] if len(sys.argv) > 4 else "install"
        log_id = record_start(ttype, tname, action)
        print(log_id)
        sys.exit(0)

    if cmd == "record-success":
        ttype = sys.argv[2] if len(sys.argv) > 2 else "package"
        tname = sys.argv[3] if len(sys.argv) > 3 else ""
        ver = sys.argv[4] if len(sys.argv) > 4 else ""
        details = sys.argv[5] if len(sys.argv) > 5 else ""
        record_success(ttype, tname, ver, details)
        sys.exit(0)

    if cmd == "record-failure":
        ttype = sys.argv[2] if len(sys.argv) > 2 else "package"
        tname = sys.argv[3] if len(sys.argv) > 3 else ""
        code = int(sys.argv[4]) if len(sys.argv) > 4 and sys.argv[4].isdigit() else 1
        msg = sys.argv[5] if len(sys.argv) > 5 else "unknown error"
        record_failure(ttype, tname, code, msg)
        sys.exit(0)

    if cmd == "record-skipped":
        ttype = sys.argv[2] if len(sys.argv) > 2 else "package"
        tname = sys.argv[3] if len(sys.argv) > 3 else ""
        reason = sys.argv[4] if len(sys.argv) > 4 else "already installed"
        record_skipped(ttype, tname, reason)
        sys.exit(0)

    print(f"Unknown command: {cmd}", file=sys.stderr)
    sys.exit(2)


if __name__ == "__main__":
    main()
