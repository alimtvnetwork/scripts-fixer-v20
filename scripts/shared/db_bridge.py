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

    # Relative repository database path (ignored by .gitignore)
    repo_root = Path(__file__).resolve().parent.parent.parent
    data_dir = repo_root / ".data"
    try:
        data_dir.mkdir(parents=True, exist_ok=True)
        db_path = data_dir / "scripts-fixer.db"

        if not db_path.exists():
            legacy_path = Path(os.path.expanduser("~")) / ".local" / "share" / "scripts-fixer" / "scripts-fixer.db"
            if legacy_path.exists():
                import shutil
                try:
                    shutil.copy2(str(legacy_path), str(db_path))
                except Exception:
                    pass

        return str(db_path)
    except Exception:
        fallback = Path(os.getcwd()) / ".data"
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
        init_cluster_tables(conn)
    conn.close()


def init_cluster_tables(conn: sqlite3.Connection):
    conn.execute("""
        CREATE TABLE IF NOT EXISTS cluster_nodes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            node_name TEXT UNIQUE NOT NULL,
            role TEXT NOT NULL,
            ip_address TEXT NOT NULL,
            port INTEGER DEFAULT 22,
            ssh_user TEXT DEFAULT 'root',
            ssh_key_path TEXT DEFAULT '',
            is_active INTEGER DEFAULT 1,
            created_at TEXT,
            updated_at TEXT
        );
    """)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS cluster_cmd_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            target TEXT NOT NULL,
            command TEXT NOT NULL,
            exit_code INTEGER,
            stdout_preview TEXT,
            stderr_preview TEXT,
            executed_at TEXT
        );
    """)
    conn.execute("INSERT OR IGNORE INTO schema_migrations (version, applied_at) VALUES (2, datetime('now'));")


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


def add_cluster_node(node_name: str, role: str, ip_address: str, port: int = 22, ssh_user: str = "root", ssh_key_path: str = ""):
    init_db()
    conn = get_connection()
    now = datetime.datetime.now().isoformat()

    with conn:
        conn.execute("""
            INSERT OR REPLACE INTO cluster_nodes
            (node_name, role, ip_address, port, ssh_user, ssh_key_path, is_active, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, 1, COALESCE((SELECT created_at FROM cluster_nodes WHERE node_name=?), ?), ?)
        """, (node_name, role, ip_address, port, ssh_user, ssh_key_path, node_name, now, now))

    conn.close()


def remove_cluster_node(node_name: str) -> bool:
    init_db()
    conn = get_connection()

    with conn:
        cur = conn.execute("DELETE FROM cluster_nodes WHERE node_name=?", (node_name,))
        has_deleted = bool(cur.rowcount > 0)

    conn.close()

    return has_deleted


def get_cluster_node(node_name: str) -> dict:
    init_db()
    conn = get_connection()
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute("SELECT * FROM cluster_nodes WHERE node_name=? AND is_active=1", (node_name,))
    row = cur.fetchone()
    conn.close()

    if not row:
        return {}

    return dict(row)


def list_cluster_nodes(role: str = "") -> list:
    init_db()
    conn = get_connection()
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    if role:
        cur.execute("SELECT * FROM cluster_nodes WHERE role=? AND is_active=1 ORDER BY node_name", (role,))
    else:
        cur.execute("SELECT * FROM cluster_nodes WHERE is_active=1 ORDER BY role, node_name")

    rows = cur.fetchall()
    conn.close()

    return [dict(r) for r in rows]


def log_cluster_cmd(target: str, command: str, exit_code: int, stdout_preview: str = "", stderr_preview: str = ""):
    init_db()
    conn = get_connection()
    now = datetime.datetime.now().isoformat()

    with conn:
        conn.execute("""
            INSERT INTO cluster_cmd_logs (target, command, exit_code, stdout_preview, stderr_preview, executed_at)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (target, command, exit_code, stdout_preview[:500], stderr_preview[:500], now))

    conn.close()


def list_cluster_cmd_logs(limit: int = 20) -> list:
    init_db()
    conn = get_connection()
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute("SELECT * FROM cluster_cmd_logs ORDER BY id DESC LIMIT ?", (limit,))
    rows = cur.fetchall()
    conn.close()

    return [dict(r) for r in rows]


def import_cluster_nodes_from_json(json_path: str) -> int:
    import json
    init_db()
    path_obj = Path(json_path)

    if not path_obj.exists():
        return 0

    with open(path_obj, "r", encoding="utf-8") as f:
        data = json.load(f)

    user = data.get("user", {}).get("name", "root")
    count = 0

    master_ip = data.get("control", {}).get("master")
    if master_ip:
        add_cluster_node("control", "control", master_ip, 22, user)
        count += 1

    nodes = data.get("nodes", {})
    for node_name, node_ip in nodes.items():
        add_cluster_node(node_name, "worker", node_ip, 22, user)
        count += 1

    return count


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

    if cmd == "cluster-add-node":
        name = sys.argv[2] if len(sys.argv) > 2 else ""
        role = sys.argv[3] if len(sys.argv) > 3 else "worker"
        ip = sys.argv[4] if len(sys.argv) > 4 else ""
        port = int(sys.argv[5]) if len(sys.argv) > 5 and sys.argv[5].isdigit() else 22
        user = sys.argv[6] if len(sys.argv) > 6 else "root"
        key_path = sys.argv[7] if len(sys.argv) > 7 else ""
        if not name or not ip:
            print("Usage: cluster-add-node <name> <role> <ip> [port] [user] [key_path]", file=sys.stderr)
            sys.exit(1)
        add_cluster_node(name, role, ip, port, user, key_path)
        print(f"Node '{name}' registered ({role} @ {ip}:{port} user={user}).")
        sys.exit(0)

    if cmd == "cluster-remove-node":
        name = sys.argv[2] if len(sys.argv) > 2 else ""
        has_removed = remove_cluster_node(name)
        if has_removed:
            print(f"Node '{name}' removed successfully.")
            sys.exit(0)
        print(f"Node '{name}' not found.", file=sys.stderr)
        sys.exit(1)

    if cmd == "cluster-get-node":
        import json
        name = sys.argv[2] if len(sys.argv) > 2 else ""
        node = get_cluster_node(name)
        if not node:
            print(f"Node '{name}' not found.", file=sys.stderr)
            sys.exit(1)
        print(json.dumps(node))
        sys.exit(0)

    if cmd == "cluster-list-nodes":
        import json
        role = sys.argv[2] if len(sys.argv) > 2 and not sys.argv[2].startswith("-") else ""
        nodes = list_cluster_nodes(role)
        is_json = any(arg == "--json" for arg in sys.argv[2:])
        if is_json:
            print(json.dumps(nodes))
        else:
            if not nodes:
                print("No cluster nodes registered in database.")
            else:
                for n in nodes:
                    key_str = f" [key: {n['ssh_key_path']}]" if n['ssh_key_path'] else ""
                    print(f"  {n['node_name']:<12} {n['role']:<8} {n['ssh_user']}@{n['ip_address']}:{n['port']}{key_str}")
        sys.exit(0)

    if cmd == "cluster-log-cmd":
        target = sys.argv[2] if len(sys.argv) > 2 else "unknown"
        command = sys.argv[3] if len(sys.argv) > 3 else ""
        exit_code = int(sys.argv[4]) if len(sys.argv) > 4 and sys.argv[4].isdigit() else 0
        stdout_preview = sys.argv[5] if len(sys.argv) > 5 else ""
        stderr_preview = sys.argv[6] if len(sys.argv) > 6 else ""
        log_cluster_cmd(target, command, exit_code, stdout_preview, stderr_preview)
        sys.exit(0)

    if cmd == "cluster-list-logs":
        limit = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2].isdigit() else 10
        logs = list_cluster_cmd_logs(limit)
        if not logs:
            print("No cluster command logs found.")
        else:
            for l in logs:
                status_symbol = "✔" if l['exit_code'] == 0 else "✖"
                print(f"  {status_symbol} [{l['executed_at']}] target={l['target']} code={l['exit_code']} cmd=\"{l['command']}\"")
        sys.exit(0)

    if cmd == "cluster-import-json":
        json_path = sys.argv[2] if len(sys.argv) > 2 else "kubernetes/config.json"
        count = import_cluster_nodes_from_json(json_path)
        print(f"Imported {count} node(s) from {json_path}.")
        sys.exit(0)

    print(f"Unknown command: {cmd}", file=sys.stderr)
    sys.exit(2)


if __name__ == "__main__":
    main()
