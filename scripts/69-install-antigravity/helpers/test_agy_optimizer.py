#!/usr/bin/env python3
"""
Unit verification tests for the modularized AGY Optimizer package.
"""

from __future__ import annotations

import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path

# Add helpers dir to sys.path
helper_dir = Path(__file__).resolve().parent
if str(helper_dir) not in sys.path:
    sys.path.insert(0, str(helper_dir))

from agy_optimizer.cli import build_argument_parser
from agy_optimizer.models import (
    BrainCleanupItem,
    ConversationInfo,
    format_bytes,
)
from agy_optimizer.scanner import get_dir_stats
from agy_optimizer.shared.database import init_backup_database
from agy_optimizer.shared.paths import extract_project_slug, get_gemini_base_dir


class TestAgyOptimizerModels(unittest.TestCase):
    def test_format_bytes(self):
        self.assertEqual(format_bytes(500), "500 B")
        self.assertEqual(format_bytes(2048), "2.00 KB")
        self.assertEqual(format_bytes(5 * 1024 * 1024), "5.00 MB")
        self.assertEqual(format_bytes(3 * 1024 * 1024 * 1024), "3.00 GB")

    def test_conversation_info_instantiation(self):
        conv = ConversationInfo(
            conversation_id="conv-123",
            db_path="/tmp/conv.db",
            file_size=10240,
            title="Test Chat",
            preview="Hello world",
            workspace_uri="file:///d:/work/test-proj",
            project_slug="test-proj",
            step_count=12,
            is_heavy=False,
        )
        self.assertEqual(conv.conversation_id, "conv-123")
        self.assertEqual(conv.project_slug, "test-proj")
        self.assertFalse(conv.is_heavy)


class TestAgyOptimizerPaths(unittest.TestCase):
    def test_extract_project_slug(self):
        self.assertEqual(extract_project_slug(""), "unknown")
        self.assertEqual(extract_project_slug("file:///d:/work/scripts-fixer"), "scripts-fixer")
        self.assertEqual(extract_project_slug("file:///home/user/my-app/"), "my-app")
        self.assertEqual(extract_project_slug('["file:///d:/projects/alpha"]'), "alpha")

    def test_gemini_base_dir(self):
        base_dir = get_gemini_base_dir()
        self.assertIn(".gemini", str(base_dir))


class TestAgyOptimizerDatabase(unittest.TestCase):
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


class TestAgyOptimizerScanner(unittest.TestCase):
    def test_get_dir_stats(self):
        with tempfile.TemporaryDirectory() as tmp_dir:
            p = Path(tmp_dir)
            (p / "file1.txt").write_text("hello", encoding="utf-8")
            (p / "file2.txt").write_text("world!", encoding="utf-8")

            cnt, sz = get_dir_stats(p)
            self.assertEqual(cnt, 2)
            self.assertGreater(sz, 0)


class TestAgyOptimizerCLI(unittest.TestCase):
    def test_build_argument_parser(self):
        parser = build_argument_parser()
        args = parser.parse_args(["--predict", "--threshold", "300", "--keep", "5"])
        self.assertTrue(args.predict)
        self.assertEqual(args.threshold, 300)
        self.assertEqual(args.keep, 5)


if __name__ == "__main__":
    unittest.main()
