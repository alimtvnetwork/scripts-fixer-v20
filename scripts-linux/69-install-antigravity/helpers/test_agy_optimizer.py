#!/usr/bin/env python3
"""
Master test runner for the modularized AGY Optimizer package.
Runs all component unit test suites.
"""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

helper_dir = Path(__file__).resolve().parent
if str(helper_dir) not in sys.path:
    sys.path.insert(0, str(helper_dir))

from test_agy_cli import TestAgyOptimizerCLI
from test_agy_db import TestAgyOptimizerPathsAndDb
from test_agy_models import TestAgyOptimizerModels


def suite() -> unittest.TestSuite:
    loader = unittest.TestLoader()
    combined_suite = unittest.TestSuite()
    combined_suite.addTests(loader.loadTestsFromTestCase(TestAgyOptimizerModels))
    combined_suite.addTests(loader.loadTestsFromTestCase(TestAgyOptimizerPathsAndDb))
    combined_suite.addTests(loader.loadTestsFromTestCase(TestAgyOptimizerCLI))

    return combined_suite


if __name__ == "__main__":
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite())
    sys.exit(0 if result.wasSuccessful() else 1)
