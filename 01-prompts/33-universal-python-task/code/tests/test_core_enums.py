"""Unit tests for strongly-typed enums and monadic parsers."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

scripts_path = Path(__file__).resolve().parent.parent / "scripts"
if str(scripts_path) not in sys.path:
    sys.path.insert(0, str(scripts_path))

from core_enums import (
    ActionType,
    ExitCodeType,
    LogLevelType,
    OsCacheType,
    TaskCategoryType,
    WindowsServiceType,
)


class TestCoreEnums(unittest.TestCase):
    """Test suite for BaseParsableEnum and concrete domain enums."""

    def test_all_values(self) -> None:
        """Verify all_values returns registered strings."""
        values = ActionType.all_values()
        self.assertIn("status", values)
        self.assertIn("scan", values)
        self.assertIn("purge", values)
        self.assertIn("test", values)

    def test_is_valid(self) -> None:
        """Verify is_valid accurately validates inputs case-insensitively."""
        self.assertTrue(ActionType.is_valid("status"))
        self.assertTrue(ActionType.is_valid("STATUS"))
        self.assertTrue(ActionType.is_valid("  scan  "))
        self.assertFalse(ActionType.is_valid("non_existent_action"))

    def test_parse_success(self) -> None:
        """Verify parse successfully returns enum member in Result container."""
        res = ActionType.parse("status")
        self.assertTrue(res.is_safe)
        self.assertEqual(res.value, ActionType.STATUS)

    def test_parse_failure(self) -> None:
        """Verify parse returns AppError for invalid input."""
        res = ActionType.parse("invalid_value")
        self.assertTrue(res.has_error)
        self.assertEqual(res.error.code, "VALIDATION_ERROR")

    def test_action_labels(self) -> None:
        """Verify action labels return expected human-readable strings."""
        self.assertEqual(ActionType.STATUS.label(), "Check Status")
        self.assertEqual(ActionType.SCAN.label(), "Scan Targets")
        self.assertEqual(ActionType.TEST.label(), "Run Test Suite")

    def test_exit_codes(self) -> None:
        """Verify ExitCodeType integer values match POSIX conventions."""
        self.assertEqual(int(ExitCodeType.SUCCESS), 0)
        self.assertEqual(int(ExitCodeType.GENERAL_ERROR), 1)
        self.assertEqual(int(ExitCodeType.USAGE_ERROR), 2)
        self.assertEqual(int(ExitCodeType.TIMEOUT_ERROR), 124)

    def test_os_cache_and_service_enums(self) -> None:
        """Verify OsCacheType and WindowsServiceType registrations."""
        self.assertIn("user-temp", OsCacheType.all_values())
        self.assertIn("audio", WindowsServiceType.all_values())


if __name__ == "__main__":
    unittest.main()
