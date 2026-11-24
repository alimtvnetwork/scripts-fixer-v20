"""Unit tests for SQL repository pattern and TaskSqlType enums."""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

scripts_path = Path(__file__).resolve().parent.parent / "scripts"
if str(scripts_path) not in sys.path:
    sys.path.insert(0, str(scripts_path))

from sql_types import TaskSqlType
from task_repository import SqliteTaskRepository, TaskExecutionRecord


class TestTaskRepository(unittest.TestCase):
    """Test suite for SqliteTaskRepository and TaskSqlType."""

    def setUp(self) -> None:
        """Create isolated temporary database directory."""
        self.temp_dir = tempfile.TemporaryDirectory()
        self.db_path = Path(self.temp_dir.name) / "tasks.db"
        self.repo = SqliteTaskRepository(db_path=self.db_path)

    def tearDown(self) -> None:
        """Clean up temporary database directory."""
        self.temp_dir.cleanup()

    def test_sql_types(self) -> None:
        """Verify TaskSqlType members and parse method."""
        self.assertTrue(TaskSqlType.is_valid(TaskSqlType.PRAGMA_BUSY_TIMEOUT.value))
        parse_res = TaskSqlType.parse("PRAGMA_BUSY_TIMEOUT")
        self.assertTrue(parse_res.is_safe)
        self.assertEqual(parse_res.value, TaskSqlType.PRAGMA_BUSY_TIMEOUT)

    def test_record_and_list_tasks(self) -> None:
        """Verify recording and querying task records via repository."""
        rec = TaskExecutionRecord("task-01", "scan", "os-optimization", "active", "C:/temp", 10, 0.42)
        save_res = self.repo.record_task(rec)
        self.assertTrue(save_res.is_safe)

        list_res = self.repo.list_latest(limit=5)
        self.assertTrue(list_res.is_safe)
        records = list_res.value
        self.assertEqual(len(records), 1)
        self.assertEqual(records[0].task_id, "task-01")
        self.assertEqual(records[0].items_affected, 10)

    def test_list_by_category(self) -> None:
        """Verify filtering task records by category."""
        rec1 = TaskExecutionRecord("t1", "scan", "os-optimization", "ok", ".", 5, 0.1)
        rec2 = TaskExecutionRecord("t2", "restart", "windows-troubleshooting", "ok", ".", 1, 0.2)
        self.repo.record_task(rec1)
        self.repo.record_task(rec2)

        cat_res = self.repo.list_by_category("os-optimization")
        self.assertTrue(cat_res.is_safe)
        self.assertEqual(len(cat_res.value), 1)
        self.assertEqual(cat_res.value[0].task_id, "t1")


if __name__ == "__main__":
    unittest.main()
