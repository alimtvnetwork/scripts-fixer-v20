"""Unit tests for modular task runner handlers."""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

scripts_path = Path(__file__).resolve().parent.parent / "scripts"
if str(scripts_path) not in sys.path:
    sys.path.insert(0, str(scripts_path))

from task_logger import TaskLogger
from task_runner import (
    calculate_disk_gauge,
    check_disk_space_threshold,
    clean_whatsapp_cache,
    is_protected_path,
    purge_file_safely,
    scan_target_directory,
)


class TestTaskRunner(unittest.TestCase):
    """Test suite for task runner modular functions."""

    def setUp(self) -> None:
        """Create isolated workspace directory with sample files."""
        self.temp_dir = tempfile.TemporaryDirectory()
        self.work_path = Path(self.temp_dir.name)
        self.log_file = self.work_path / "test.log"
        self.logger = TaskLogger(log_path=self.log_file)

    def tearDown(self) -> None:
        """Clean up isolated workspace."""
        self.temp_dir.cleanup()

    def test_is_protected_path(self) -> None:
        """Verify protected path detection logic."""
        self.assertTrue(is_protected_path(Path(".gitkeep")))
        self.assertTrue(is_protected_path(Path("config.json")))
        self.assertTrue(is_protected_path(Path(".env")))
        self.assertTrue(is_protected_path(Path(".git/HEAD")))
        self.assertFalse(is_protected_path(Path("cache_file.tmp")))

    def test_scan_and_purge_dry_run(self) -> None:
        """Verify scan discovers files and dry-run purge simulates safely."""
        target_file = self.work_path / "purgeable.tmp"
        target_file.write_text("sample content", encoding="utf-8")
        protected_file = self.work_path / ".gitkeep"
        protected_file.write_text("", encoding="utf-8")

        scan_res = scan_target_directory(self.work_path)
        self.assertTrue(scan_res.is_safe)
        files, total_bytes = scan_res.value
        self.assertEqual(len(files), 1)
        self.assertEqual(files[0], target_file)

        purge_res = purge_file_safely(target_file, is_dry_run=True, logger=self.logger)
        self.assertTrue(purge_res.is_safe)
        self.assertTrue(target_file.exists())

    def test_calculate_disk_gauge(self) -> None:
        """Verify disk gauge progress bar rendering."""
        gauge_empty = calculate_disk_gauge(0, 100, bar_width=10)
        self.assertIn("0.0%", gauge_empty)
        gauge_half = calculate_disk_gauge(50, 100, bar_width=10)
        self.assertIn("50.0%", gauge_half)
        self.assertIn("#####", gauge_half)

    def test_clean_whatsapp_cache_dry_run(self) -> None:
        """Verify WhatsApp cache clean handler safely executes."""
        res = clean_whatsapp_cache(is_dry_run=True, logger=self.logger)
        self.assertTrue(res.is_safe)
        self.assertIsInstance(res.value, int)


if __name__ == "__main__":
    unittest.main()
