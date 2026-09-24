#!/usr/bin/env python3
"""
Unit tests for AGY Optimizer CLI argument parser.
"""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

helper_dir = Path(__file__).resolve().parent
if str(helper_dir) not in sys.path:
    sys.path.insert(0, str(helper_dir))

from agy_optimizer.cli import build_argument_parser


class TestAgyOptimizerCLI(unittest.TestCase):
    def test_build_argument_parser(self):
        parser = build_argument_parser()
        args = parser.parse_args(["--predict", "--threshold", "300", "--keep", "5"])
        self.assertTrue(args.predict)
        self.assertEqual(args.threshold, 300)
        self.assertEqual(args.keep, 5)


if __name__ == "__main__":
    unittest.main()
