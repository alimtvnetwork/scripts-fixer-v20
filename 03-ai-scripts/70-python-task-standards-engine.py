"""Reusable Python task standards engine: monadic errors, enums, constants, and logging.

Enforces zero magic strings, strongly-typed enums ending in Type, and monadic Result[T].
"""

from __future__ import annotations

import json
import re
import sqlite3
import sys
from contextlib import contextmanager
from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum, IntEnum
from pathlib import Path
from typing import Any, Generic, Iterator, Protocol, TypeVar

T = TypeVar("T")
E = TypeVar("E", bound="BaseParsableEnum")


@dataclass(frozen=True)
class AppError:
    """Structured enterprise application error container."""

    code: str
    message: str
    operation: str = ""
    details: dict[str, Any] = field(default_factory=dict)
    cause_message: str | None = None

    def to_dict(self) -> dict[str, Any]:
        """Convert error to dictionary representation."""
        return {
            "code": self.code,
            "message": self.message,
            "operation": self.operation,
            "details": self.details,
            "cause_message": self.cause_message,
        }

    def __str__(self) -> str:
        """Format error as a readable string."""
        if self.operation:
            return f"[{self.code}] {self.operation}: {self.message}"

        return f"[{self.code}] {self.message}"


class Result(Generic[T]):
    """Monadic container holding either a successful value or an AppError."""

    def __init__(self, value: T | None, error: AppError | None, is_safe: bool) -> None:
        self._value = value
        self._error = error
        self._is_safe = is_safe

    @classmethod
    def ok(cls, value: T) -> Result[T]:
        """Create a successful result container."""
        return cls(value=value, error=None, is_safe=True)

    @classmethod
    def fail(cls, error: AppError) -> Result[T]:
        """Create a failed result container wrapping an AppError."""
        return cls(value=None, error=error, is_safe=False)

    @property
    def is_safe(self) -> bool:
        """Return True if operation succeeded with no errors."""
        return self._is_safe

    @property
    def has_error(self) -> bool:
        """Return True if operation resulted in an error."""
        return not self._is_safe

    @property
    def value(self) -> T:
        """Unwrap value or raise RuntimeError if in failed state."""
        if self.has_error:
            raise RuntimeError(f"Attempted to unwrap failed result: {self._error}")

        return self._value  # type: ignore[return-value]

    @property
    def error(self) -> AppError:
        """Access AppError or raise RuntimeError if in safe state."""
        if self.is_safe:
            raise RuntimeError("Attempted to access error on successful result")

        return self._error  # type: ignore[return-value]


class BaseParsableEnum(str, Enum):
    """Base parsable string enum with monadic parsing."""

    @classmethod
    def all_values(cls) -> list[str]:
        """Return list of all registered enum string values."""
        return [item.value for item in cls]

    @classmethod
    def is_valid(cls, raw_value: str) -> bool:
        """Return True if string matches a registered enum value."""
        return raw_value.strip().lower() in cls.all_values()

    @classmethod
    def parse(cls: type[E], raw_value: str) -> Result[E]:
        """Monadically parse string into enum member."""
        normalized = raw_value.strip().lower()
        for item in cls:
            if item.value == normalized:
                return Result.ok(item)

        err = AppError("VALIDATION_ERROR", f"Invalid {cls.__name__}: '{raw_value}'. Allowed: {cls.all_values()}", "parse")
        return Result.fail(err)


class AppErrorCodeType(str, Enum):
    """Domain-specific error code classifications."""

    SYSTEM_ERROR = "SYSTEM_ERROR"
    IO_ERROR = "IO_ERROR"
    VALIDATION_ERROR = "VALIDATION_ERROR"
    PERMISSION_ERROR = "PERMISSION_ERROR"
    TIMEOUT_ERROR = "TIMEOUT_ERROR"
    NOT_FOUND_ERROR = "NOT_FOUND_ERROR"
    COMMAND_ERROR = "COMMAND_ERROR"
    DATABASE_ERROR = "DATABASE_ERROR"


class ActionType(BaseParsableEnum):
    """Universal CLI execution actions."""

    STATUS = "status"
    SCAN = "scan"
    PURGE = "purge"
    RESTART = "restart"
    REPORT = "report"
    HISTORY = "history"


class TaskCategoryType(BaseParsableEnum):
    """Task category classifications."""

    OS_OPTIMIZATION = "os-optimization"
    WINDOWS_TROUBLESHOOTING = "windows-troubleshooting"
    VMWARE_MANAGEMENT = "vmware-management"
    APP_CACHE = "app-cache"
    SYSTEM_CLEANUP = "system-cleanup"


class ExitCodeType(IntEnum):
    """Standardized POSIX and Windows CLI exit codes."""

    SUCCESS = 0
    GENERAL_ERROR = 1
    USAGE_ERROR = 2
    CONFIG_ERROR = 3
    PERMISSION_ERROR = 4
    RUNTIME_ERROR = 5


class LogBadgeConstants:
    """Standardized ANSI badges for console telemetry."""

    OK = "[  OK  ]"
    FAIL = "[ FAIL ]"
    WARN = "[ WARN ]"
    INFO = "[ INFO ]"
    SKIP = "[ SKIP ]"


class EncodingConstants:
    """Standard character encoding format constants."""

    UTF8 = "utf-8"
    ASCII = "ascii"
    UTF16 = "utf-16"


class ProtectedNameConstants:
    """Files strictly protected from deletion or modification."""

    GITKEEP = ".gitkeep"
    CONFIG_JSON = "config.json"
    SETTINGS_JSON = "settings.json"
    ENV_FILE = ".env"


class TaskSqlType(str, Enum):
    """SQL statements for task execution repository."""

    PRAGMA_BUSY_TIMEOUT = "PRAGMA busy_timeout = 5000"
    CREATE_TABLE = (
        "CREATE TABLE IF NOT EXISTS TaskExecutions ("
        "task_id TEXT PRIMARY KEY, action TEXT NOT NULL, category TEXT NOT NULL, "
        "status TEXT NOT NULL, target_path TEXT NOT NULL, items_affected INTEGER NOT NULL, "
        "duration_sec REAL NOT NULL, executed_at TEXT NOT NULL)"
    )
    INSERT = "INSERT INTO TaskExecutions VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))"
    SELECT_LATEST = "SELECT * FROM TaskExecutions ORDER BY executed_at DESC LIMIT ?"


@dataclass(frozen=True)
class TaskExecutionRecord:
    """Immutable audit record representing an automated task execution."""

    task_id: str
    action: str
    category: str
    status: str
    target_path: str
    items_affected: int
    duration_sec: float
    executed_at: str = ""


class ITaskRepository(Protocol):
    """Interface isolating SQL execution behind a repository contract."""

    def record_task(self, record: TaskExecutionRecord) -> Result[bool]: ...
    def list_latest(self, limit: int = 10) -> Result[tuple[TaskExecutionRecord, ...]]: ...


class SqliteTaskRepository:
    """SQLite implementation of ITaskRepository."""

    def __init__(self, db_path: Path | str = "logs/tasks.db") -> None:
        self._db_path = Path(db_path)
        if not self._db_path.parent.exists():
            self._db_path.parent.mkdir(parents=True, exist_ok=True)
        self._init_db()

    @contextmanager
    def _open_conn(self) -> Iterator[sqlite3.Connection]:
        """Open SQLite connection and ensure clean closure."""
        conn = sqlite3.connect(str(self._db_path), timeout=5.0)
        conn.row_factory = sqlite3.Row
        conn.execute(TaskSqlType.PRAGMA_BUSY_TIMEOUT.value)
        try:
            yield conn
            conn.commit()
        finally:
            conn.close()

    def _init_db(self) -> Result[bool]:
        """Initialize database schema."""
        try:
            with self._open_conn() as conn:
                conn.execute(TaskSqlType.CREATE_TABLE.value)
                return Result.ok(True)
        except sqlite3.Error as err:
            return Result.fail(AppError(AppErrorCodeType.DATABASE_ERROR.value, str(err), "init_db"))

    def record_task(self, r: TaskExecutionRecord) -> Result[bool]:
        """Record task execution into SQLite database."""
        try:
            params = (r.task_id, r.action, r.category, r.status, r.target_path, r.items_affected, r.duration_sec)
            with self._open_conn() as conn:
                conn.execute(TaskSqlType.INSERT.value, params)
                return Result.ok(True)
        except sqlite3.Error as err:
            return Result.fail(AppError(AppErrorCodeType.DATABASE_ERROR.value, str(err), "record_task"))

    def list_latest(self, limit: int = 10) -> Result[tuple[TaskExecutionRecord, ...]]:
        """List latest task records."""
        try:
            with self._open_conn() as conn:
                rows = conn.execute(TaskSqlType.SELECT_LATEST.value, (limit,)).fetchall()
                records = tuple(TaskExecutionRecord(r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7]) for r in rows)
                return Result.ok(records)
        except sqlite3.Error as err:
            return Result.fail(AppError(AppErrorCodeType.DATABASE_ERROR.value, str(err), "list_latest"))


class TaskLogger:
    """Console and file logger supporting ANSI badges and JSON telemetry."""

    def __init__(self, log_path: Path | None = None, is_verbose: bool = False) -> None:
        self.is_verbose = is_verbose
        self.log_path = log_path or Path("logs/task.log")
        self.enable_ansi = sys.stdout.isatty()
        if not self.log_path.parent.exists():
            self.log_path.parent.mkdir(parents=True, exist_ok=True)

    def _write_file(self, line: str) -> None:
        """Write line to file with LF line ending."""
        try:
            clean_line = re.sub(r"\033\[[0-9;]*m", "", line)
            with open(self.log_path, "a", encoding=EncodingConstants.UTF8, newline="\n") as handle:
                handle.write(clean_line + "\n")
        except OSError:
            pass

    def log(self, badge: str, message: str) -> None:
        """Log entry to console and file."""
        now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
        print(f"{badge} {message}")
        self._write_file(f"[{now}] {badge} {message}")

    def ok(self, message: str) -> None:
        """Log success message."""
        self.log(LogBadgeConstants.OK, message)

    def fail(self, message: str) -> None:
        """Log failure message."""
        self.log(LogBadgeConstants.FAIL, message)

    def info(self, message: str) -> None:
        """Log info message."""
        self.log(LogBadgeConstants.INFO, message)


def calculate_disk_gauge(free_gb: float, total_gb: float, bar_width: int = 20) -> str:
    """Render an ASCII progress bar gauge representing free disk space percentage."""
    if total_gb <= 0:
        return "[" + " " * bar_width + "] 0.0%"

    free_ratio = max(0.0, min(1.0, free_gb / total_gb))
    filled_chars = int(free_ratio * bar_width)
    empty_chars = bar_width - filled_chars
    percent = free_ratio * 100.0
    return f"[{'#' * filled_chars}{'-' * empty_chars}] {percent:.1f}% free"


def is_elevated_admin() -> bool:
    """Return True if running process possesses administrator privileges."""
    try:
        import ctypes

        return bool(ctypes.windll.shell32.IsUserAnAdmin())
    except Exception:
        import os

        return hasattr(os, "getuid") and os.getuid() == 0


def main() -> int:
    """Self-test and verification entrypoint."""
    logger = TaskLogger()
    logger.ok("Task standards engine loaded successfully")
    gauge = calculate_disk_gauge(15.5, 100.0)
    logger.info(f"Sample disk gauge: {gauge}")
    is_admin = is_elevated_admin()
    logger.info(f"Process elevation: is_admin={is_admin}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
