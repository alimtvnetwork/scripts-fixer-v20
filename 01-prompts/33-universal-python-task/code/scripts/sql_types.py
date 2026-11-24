"""SQL queries and statement definitions encapsulated in strongly-typed enums."""

from __future__ import annotations

from enum import Enum
from typing import TypeVar

from app_errors import AppError, Result

T = TypeVar("T", bound="TaskSqlType")


class TaskSqlType(str, Enum):
    """Encapsulated SQL statements for task execution audit database."""

    PRAGMA_BUSY_TIMEOUT = "PRAGMA busy_timeout = 5000"
    CREATE_TASKS_TABLE = (
        "CREATE TABLE IF NOT EXISTS TaskExecutions ("
        "task_id TEXT PRIMARY KEY, "
        "action TEXT NOT NULL, "
        "category TEXT NOT NULL, "
        "status TEXT NOT NULL, "
        "target_path TEXT NOT NULL, "
        "items_affected INTEGER NOT NULL, "
        "duration_sec REAL NOT NULL, "
        "executed_at TEXT NOT NULL"
        ")"
    )
    INSERT_TASK = (
        "INSERT INTO TaskExecutions ("
        "task_id, action, category, status, target_path, items_affected, duration_sec, executed_at"
        ") VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))"
    )
    SELECT_LATEST = (
        "SELECT task_id, action, category, status, target_path, items_affected, duration_sec, executed_at "
        "FROM TaskExecutions ORDER BY executed_at DESC LIMIT ?"
    )
    SELECT_BY_CATEGORY = (
        "SELECT task_id, action, category, status, target_path, items_affected, duration_sec, executed_at "
        "FROM TaskExecutions WHERE category = ? ORDER BY executed_at DESC"
    )

    def label(self) -> str:
        """Human-readable display label."""
        return self.name

    @classmethod
    def all_values(cls) -> tuple[str, ...]:
        """Return tuple of all registered SQL statements."""
        return tuple(m.value for m in cls)

    @classmethod
    def is_valid(cls, raw_value: str) -> bool:
        """Return True if statement matches registered SQL string."""
        return raw_value in cls.all_values()

    @classmethod
    def parse(cls: type[T], raw_value: str) -> Result[T]:
        """Monadically parse string into TaskSqlType member."""
        for member in cls:
            if member.value == raw_value or member.name == raw_value:
                return Result.ok(member)

        error = AppError("VALIDATION_ERROR", f"Unknown TaskSqlType: '{raw_value}'", "parse")
        return Result.fail(error)
