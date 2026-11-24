"""Resilient subprocess execution module with monadic Result envelopes.

Guarantees Unicode-safe text decoding and timeout protection without hanging.
"""

from __future__ import annotations

import subprocess
from dataclasses import dataclass
from typing import List

from app_errors import AppError, Result
from core_enums import ExitCodeType


@dataclass(frozen=True)
class SubprocessResult:
    """Immutable result envelope for external process execution."""

    returncode: int
    stdout: str
    stderr: str
    is_success: bool
    is_timeout: bool = False
    error_message: str = ""


def _build_timeout_result(timeout_sec: int) -> SubprocessResult:
    return SubprocessResult(
        returncode=ExitCodeType.GENERAL_ERROR.value,
        stdout="",
        stderr=f"Process timed out after {timeout_sec}s",
        is_success=False,
        is_timeout=True,
        error_message=f"Timeout after {timeout_sec}s",
    )


def _build_success_result(completed: subprocess.CompletedProcess[str]) -> SubprocessResult:
    is_success = completed.returncode == ExitCodeType.SUCCESS.value
    err_msg = "" if is_success else f"Exited with code {completed.returncode}"
    return SubprocessResult(
        returncode=completed.returncode,
        stdout=completed.stdout,
        stderr=completed.stderr,
        is_success=is_success,
        is_timeout=False,
        error_message=err_msg,
    )


def execute_command(
    command_args: List[str],
    timeout_sec: int = 30,
) -> Result[SubprocessResult]:
    """Execute command safely with Unicode error replacement and timeout guard."""
    if not command_args:
        return Result.fail(AppError("COMMAND_EMPTY", "Command arguments cannot be empty"))

    try:
        completed = subprocess.run(
            command_args,
            capture_output=True,
            text=True,
            timeout=timeout_sec,
            check=False,
            errors="replace",
        )
        return Result.ok(_build_success_result(completed))
    except subprocess.TimeoutExpired:
        return Result.ok(_build_timeout_result(timeout_sec))
    except OSError as err:
        return Result.fail(AppError("OS_EXEC_FAILED", f"OS execution failed: {err}"))
