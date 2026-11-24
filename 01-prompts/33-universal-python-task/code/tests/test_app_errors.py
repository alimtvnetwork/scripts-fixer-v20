"""Unit tests for monadic AppError and Result[T] containers."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

scripts_path = Path(__file__).resolve().parent.parent / "scripts"
if str(scripts_path) not in sys.path:
    sys.path.insert(0, str(scripts_path))

from app_errors import AppError, Result


class TestAppErrors(unittest.TestCase):
    """Test suite for AppError structured error dataclass."""

    def test_app_error_creation(self) -> None:
        """Verify AppError fields and formatting."""
        err = AppError("TEST_CODE", "Test message", "test_op", {"key": "val"})
        self.assertEqual(err.code, "TEST_CODE")
        self.assertEqual(err.message, "Test message")
        self.assertEqual(err.operation, "test_op")
        self.assertEqual(err.details["key"], "val")
        self.assertIn("[TEST_CODE] test_op: Test message", str(err))

    def test_app_error_immutability(self) -> None:
        """Verify AppError is frozen and cannot be mutated."""
        err = AppError("CODE", "Msg")
        with self.assertRaises(Exception):
            err.code = "NEW_CODE"  # type: ignore[misc]

    def test_app_error_to_dict(self) -> None:
        """Verify AppError dictionary serialization."""
        err = AppError("CODE", "Msg", "op", {"count": 1})
        data = err.to_dict()
        self.assertEqual(data["code"], "CODE")
        self.assertEqual(data["message"], "Msg")
        self.assertEqual(data["operation"], "op")
        self.assertEqual(data["details"]["count"], 1)

    def test_result_ok(self) -> None:
        """Verify Result.ok succeeds and unwraps value."""
        res: Result[int] = Result.ok(42)
        self.assertTrue(res.is_safe)
        self.assertFalse(res.has_error)
        self.assertEqual(res.value, 42)
        with self.assertRaises(RuntimeError):
            _ = res.error

    def test_result_fail(self) -> None:
        """Verify Result.fail wraps AppError and prevents value unwrapping."""
        err = AppError("FAIL", "Failure occurred")
        res: Result[int] = Result.fail(err)
        self.assertFalse(res.is_safe)
        self.assertTrue(res.has_error)
        self.assertEqual(res.error.code, "FAIL")
        with self.assertRaises(RuntimeError):
            _ = res.value


if __name__ == "__main__":
    unittest.main()
