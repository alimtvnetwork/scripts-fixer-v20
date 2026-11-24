"""Structured error handling and monadic Result[T] container."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Generic, TypeVar

T = TypeVar("T")


@dataclass(frozen=True)
class AppError:
    """Strongly-typed error container with code and diagnostic message."""
    code: str
    message: str
    details: dict[str, Any] | None = None

    def __str__(self) -> str:
        if self.details:
            return f"[{self.code}] {self.message} (details: {self.details})"

        return f"[{self.code}] {self.message}"


class Result(Generic[T]):
    """Monadic container holding either a success value or an AppError."""

    def __init__(self, is_success: bool, value: T | None, error: AppError | None) -> None:
        self._is_success = is_success
        self._value = value
        self._error = error

    @property
    def is_success(self) -> bool:
        return self._is_success

    @property
    def is_failure(self) -> bool:
        return not self._is_success

    @property
    def value(self) -> T:
        if not self._is_success or self._value is None:
            raise ValueError(f"Cannot unwrap value from failed Result: {self._error}")

        return self._value

    @property
    def error(self) -> AppError:
        if self._is_success or self._error is None:
            raise ValueError("Cannot access error on successful Result")

        return self._error

    @classmethod
    def ok(cls, value: T) -> Result[T]:
        return cls(is_success=True, value=value, error=None)

    @classmethod
    def fail(cls, error: AppError) -> Result[T]:
        return cls(is_success=False, value=None, error=error)
