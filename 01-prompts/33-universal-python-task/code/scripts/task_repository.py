"""SQL Repository Pattern implementation for task execution telemetry."""

from __future__ import annotations

import sqlite3
from contextlib import contextmanager
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator, Protocol

from app_errors import AppError, Result
from core_enums import AppErrorCodeType
from sql_types import TaskSqlType


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
    """Protocol interface isolating all task execution database operations."""

    def record_task(self, record: TaskExecutionRecord) -> Result[bool]: ...
    def list_latest(self, limit: int = 10) -> Result[tuple[TaskExecutionRecord, ...]]: ...
    def list_by_category(self, category: str) -> Result[tuple[TaskExecutionRecord, ...]]: ...


class SqliteTaskRepository:
    """SQLite implementation of ITaskRepository adhering to SQL Repository Pattern."""

    def __init__(self, db_path: Path | str = "logs/tasks.db") -> None:
        self._db_path = Path(db_path)
        self._ensure_db_dir()
        self._init_db()

    def _ensure_db_dir(self) -> None:
        """Ensure parent directory of SQLite database exists."""
        if not self._db_path.parent.exists():
            self._db_path.parent.mkdir(parents=True, exist_ok=True)

    @contextmanager
    def _open_conn(self) -> Iterator[sqlite3.Connection]:
        """Open SQLite connection with busy timeout pragmas and ensure closure."""
        conn = sqlite3.connect(str(self._db_path), timeout=5.0)
        conn.row_factory = sqlite3.Row
        conn.execute(TaskSqlType.PRAGMA_BUSY_TIMEOUT.value)
        try:
            yield conn
            conn.commit()
        finally:
            conn.close()

    def _init_db(self) -> Result[bool]:
        """Initialize database schema using encapsulated SQL statement."""
        try:
            with self._open_conn() as conn:
                conn.execute(TaskSqlType.CREATE_TASKS_TABLE.value)
                return Result.ok(True)
        except sqlite3.Error as err:
            error = AppError(AppErrorCodeType.DATABASE_ERROR.value, f"Schema init failed: {err}", "init_db")
            return Result.fail(error)

    def record_task(self, record: TaskExecutionRecord) -> Result[bool]:
        """Record task execution into SQLite database."""
        try:
            params = (
                record.task_id, record.action, record.category, record.status,
                record.target_path, record.items_affected, record.duration_sec,
            )
            with self._open_conn() as conn:
                conn.execute(TaskSqlType.INSERT_TASK.value, params)
                return Result.ok(True)
        except sqlite3.Error as err:
            error = AppError(AppErrorCodeType.DATABASE_ERROR.value, f"Record task failed: {err}", "record_task")
            return Result.fail(error)

    def list_latest(self, limit: int = 10) -> Result[tuple[TaskExecutionRecord, ...]]:
        """List latest task execution records."""
        try:
            with self._open_conn() as conn:
                rows = conn.execute(TaskSqlType.SELECT_LATEST.value, (limit,)).fetchall()
                records = tuple(self._row_to_record(row) for row in rows)
                return Result.ok(records)
        except sqlite3.Error as err:
            error = AppError(AppErrorCodeType.DATABASE_ERROR.value, f"Query failed: {err}", "list_latest")
            return Result.fail(error)

    def list_by_category(self, category: str) -> Result[tuple[TaskExecutionRecord, ...]]:
        """List task execution records filtered by category."""
        try:
            with self._open_conn() as conn:
                rows = conn.execute(TaskSqlType.SELECT_BY_CATEGORY.value, (category,)).fetchall()
                records = tuple(self._row_to_record(row) for row in rows)
                return Result.ok(records)
        except sqlite3.Error as err:
            error = AppError(AppErrorCodeType.DATABASE_ERROR.value, f"Query by category failed: {err}", "list_by_category")
            return Result.fail(error)

    def _row_to_record(self, row: sqlite3.Row) -> TaskExecutionRecord:
        """Convert SQLite row to TaskExecutionRecord domain object."""
        return TaskExecutionRecord(
            task_id=row["task_id"],
            action=row["action"],
            category=row["category"],
            status=row["status"],
            target_path=row["target_path"],
            items_affected=row["items_affected"],
            duration_sec=row["duration_sec"],
            executed_at=row["executed_at"],
        )
