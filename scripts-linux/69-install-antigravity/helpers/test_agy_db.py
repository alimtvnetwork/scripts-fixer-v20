#!/usr/bin/env python3
"""
Unit tests for AGY Optimizer database, paths, and scanner.
"""

from __future__ import annotations

import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path

helper_dir = Path(__file__).resolve().parent
if str(helper_dir) not in sys.path:
    sys.path.insert(0, str(helper_dir))

from agy_optimizer.scanner import get_dir_stats
from agy_optimizer.shared.database import init_backup_database
from agy_optimizer.shared.paths import extract_project_slug, get_gemini_base_dir


class TestAgyOptimizerPathsAndDb(unittest.TestCase):
    def test_extract_project_slug(self):
        self.assertEqual(extract_project_slug(""), "unknown")
        self.assertEqual(extract_project_slug("file:///d:/work/scripts-fixer"), "scripts-fixer")
        self.assertEqual(extract_project_slug("file:///home/user/my-app/"), "my-app")
        self.assertEqual(extract_project_slug('["file:///d:/projects/alpha"]'), "alpha")

    def test_gemini_base_dir(self):
        base_dir = get_gemini_base_dir()
        self.assertIn(".gemini", str(base_dir))

    def test_init_backup_database(self):
        with tempfile.TemporaryDirectory() as tmp_dir:
            db_path = Path(tmp_dir) / "test-backup.db"
            init_backup_database(db_path)
            self.assertTrue(db_path.is_file())

            conn = sqlite3.connect(str(db_path))
            cur = conn.cursor()
            cur.execute("SELECT name FROM sqlite_master WHERE type='table'")
            tables = {row[0] for row in cur.fetchall()}
            conn.close()

            self.assertIn("prune_transactions", tables)
            self.assertIn("pruned_steps", tables)

    def test_get_dir_stats(self):
        with tempfile.TemporaryDirectory() as tmp_dir:
            p = Path(tmp_dir)
            (p / "file1.txt").write_text("hello", encoding="utf-8")
            (p / "file2.txt").write_text("world!", encoding="utf-8")

            cnt, sz = get_dir_stats(p)
            self.assertEqual(cnt, 2)
            self.assertGreater(sz, 0)


if __name__ == "__main__":
    unittest.main()
