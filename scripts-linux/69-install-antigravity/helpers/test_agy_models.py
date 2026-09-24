#!/usr/bin/env python3
"""
Unit tests for AGY Optimizer models and formatting functions.
"""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

helper_dir = Path(__file__).resolve().parent
if str(helper_dir) not in sys.path:
    sys.path.insert(0, str(helper_dir))

from agy_optimizer.models import (
    BrainCleanupItem,
    ConversationInfo,
    format_bytes,
)


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


if __name__ == "__main__":
    unittest.main()
