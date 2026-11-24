"""Unit tests for resilient subprocess execution guard."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

scripts_path = Path(__file__).resolve().parent.parent / "scripts"
if str(scripts_path) not in sys.path:
    sys.path.insert(0, str(scripts_path))

from subprocess_guard import execute_command


class TestSubprocessGuard(unittest.TestCase):
    """Test suite for SubprocessResult and execute_command."""

    def test_execute_success(self) -> None:
        """Verify executing valid command returns success result."""
        res = execute_command([sys.executable, "-c", "print('hello_guard')"])
        self.assertTrue(res.is_safe)
        self.assertTrue(res.value.is_success)
        self.assertIn("hello_guard", res.value.stdout)

    def test_execute_empty_command(self) -> None:
        """Verify empty command args returns failure Result."""
        res = execute_command([])
        self.assertTrue(res.has_error)
        self.assertEqual(res.error.code, "COMMAND_EMPTY")

    def test_execute_timeout(self) -> None:
        """Verify command exceeding timeout triggers timeout envelope."""
        cmd = [sys.executable, "-c", "import time; time.sleep(3)"]
        res = execute_command(cmd, timeout_sec=1)
        self.assertTrue(res.is_safe)
        self.assertTrue(res.value.is_timeout)
        self.assertFalse(res.value.is_success)

    def test_execute_nonzero_exit(self) -> None:
        """Verify non-zero process exit returns is_success=False."""
        cmd = [sys.executable, "-c", "import sys; sys.exit(4)"]
        res = execute_command(cmd)
        self.assertTrue(res.is_safe)
        self.assertEqual(res.value.returncode, 4)
        self.assertFalse(res.value.is_success)


if __name__ == "__main__":
    unittest.main()
