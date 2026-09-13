import os
import sys
import sqlite3
import datetime

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

def get_db_root_dir():
    base_dir = os.path.expanduser("~/.scripts-fixer")
    os.makedirs(base_dir, exist_ok=True)
    os.makedirs(os.path.join(base_dir, "schedules"), exist_ok=True)
    return base_dir

def get_connection(db_name):
    base_dir = get_db_root_dir()
    db_path = os.path.join(base_dir, db_name)
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn

def init_root_db():
    conn = get_connection("Root.db")
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS RegisteredDatabases (
            DatabaseId TEXT PRIMARY KEY,
            DatabaseName TEXT NOT NULL,
            FilePath TEXT NOT NULL,
            Description TEXT,
            CreatedAt TEXT NOT NULL,
            UpdatedAt TEXT NOT NULL
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS SystemMetadata (
            Key TEXT PRIMARY KEY,
            Value TEXT,
            UpdatedAt TEXT NOT NULL
        )
    """)
    conn.commit()
    conn.close()

def register_database(db_id, db_name, file_path, description):
    init_root_db()
    conn = get_connection("Root.db")
    cursor = conn.cursor()
    now_str = datetime.datetime.now().isoformat()
    cursor.execute("""
        INSERT OR REPLACE INTO RegisteredDatabases
        (DatabaseId, DatabaseName, FilePath, Description, CreatedAt, UpdatedAt)
        VALUES (?, ?, ?, ?, COALESCE((SELECT CreatedAt FROM RegisteredDatabases WHERE DatabaseId = ?), ?), ?)
    """, (db_id, db_name, file_path, description, db_id, now_str, now_str))
    conn.commit()
    conn.close()

def init_startup_db():
    conn = get_connection("Startup.db")
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS StartupItems (
            ItemId TEXT PRIMARY KEY,
            Name TEXT NOT NULL,
            TargetType TEXT NOT NULL,
            TargetPath TEXT NOT NULL,
            Arguments TEXT,
            Frequency TEXT NOT NULL,
            IsEnabled INTEGER NOT NULL DEFAULT 1,
            CreatedAt TEXT NOT NULL,
            UpdatedAt TEXT NOT NULL
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS StartupExecutions (
            ExecutionId INTEGER PRIMARY KEY AUTOINCREMENT,
            ItemId TEXT NOT NULL,
            ExecutedAt TEXT NOT NULL,
            Status TEXT NOT NULL,
            ExitCode INTEGER,
            OutputSummary TEXT,
            FOREIGN KEY (ItemId) REFERENCES StartupItems(ItemId)
        )
    """)
    conn.commit()
    conn.close()
    register_database("Startup", "Startup.db", os.path.join(get_db_root_dir(), "Startup.db"), "Startup actions & boot tasks")

def init_schedule_db():
    conn = get_connection("Schedule.db")
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ScheduleItems (
            ScheduleId TEXT PRIMARY KEY,
            Name TEXT NOT NULL,
            ScriptType TEXT NOT NULL,
            TargetPath TEXT NOT NULL,
            Arguments TEXT,
            CronExpression TEXT NOT NULL,
            FrequencyDesc TEXT,
            IsEnabled INTEGER NOT NULL DEFAULT 1,
            CreatedAt TEXT NOT NULL,
            UpdatedAt TEXT NOT NULL
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ScheduleDefinitions (
            DefinitionId INTEGER PRIMARY KEY AUTOINCREMENT,
            ScheduleId TEXT NOT NULL,
            ParamName TEXT NOT NULL,
            ParamValue TEXT,
            FOREIGN KEY (ScheduleId) REFERENCES ScheduleItems(ScheduleId)
        )
    """)
    conn.commit()
    conn.close()
    register_database("Schedule", "Schedule.db", os.path.join(get_db_root_dir(), "Schedule.db"), "Cron schedules & periodic jobs")

def init_macro_db():
    conn = get_connection("Macro.db")
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS MacroDefinitions (
            MacroId TEXT PRIMARY KEY,
            Name TEXT NOT NULL UNIQUE,
            Description TEXT,
            IsInteractive INTEGER NOT NULL DEFAULT 1,
            CreatedAt TEXT NOT NULL,
            UpdatedAt TEXT NOT NULL
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS MacroSteps (
            StepId INTEGER PRIMARY KEY AUTOINCREMENT,
            MacroId TEXT NOT NULL,
            StepOrder INTEGER NOT NULL,
            CommandType TEXT NOT NULL,
            CommandText TEXT NOT NULL,
            Arguments TEXT,
            FOREIGN KEY (MacroId) REFERENCES MacroDefinitions(MacroId)
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS MacroExecutions (
            ExecutionId INTEGER PRIMARY KEY AUTOINCREMENT,
            MacroId TEXT NOT NULL,
            ExecutedAt TEXT NOT NULL,
            Status TEXT NOT NULL,
            ExitCode INTEGER,
            DurationSeconds REAL,
            FOREIGN KEY (MacroId) REFERENCES MacroDefinitions(MacroId)
        )
    """)
    conn.commit()
    conn.close()
    register_database("Macro", "Macro.db", os.path.join(get_db_root_dir(), "Macro.db"), "Interactive macros & workflow sequences")

def get_schedule_log_db(schedule_id):
    base_dir = get_db_root_dir()
    sched_dir = os.path.join(base_dir, "schedules")
    clean_id = "".join(c for c in schedule_id if c.isalnum() or c in ("-", "_"))
    db_path = os.path.join(sched_dir, f"{clean_id}.db")
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ExecutionLogs (
            LogId INTEGER PRIMARY KEY AUTOINCREMENT,
            ScheduleId TEXT NOT NULL,
            ExecutedAt TEXT NOT NULL,
            Status TEXT NOT NULL,
            ExitCode INTEGER,
            StdoutText TEXT,
            StderrText TEXT,
            DurationMs INTEGER
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS RunHistory (
            RunId INTEGER PRIMARY KEY AUTOINCREMENT,
            ScheduledFor TEXT,
            TriggeredAt TEXT NOT NULL,
            Status TEXT NOT NULL
        )
    """)
    conn.commit()
    register_database(f"Schedule_{clean_id}", f"schedules/{clean_id}.db", db_path, f"Execution logs for schedule {schedule_id}")
    return conn

def init_all_databases():
    init_root_db()
    init_startup_db()
    init_schedule_db()
    init_macro_db()

if __name__ == "__main__":
    init_all_databases()
    print("Initialized all Split Databases successfully.")
