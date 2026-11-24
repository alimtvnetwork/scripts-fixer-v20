"""Monadic error architecture for universal Python tasks."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Generic, TypeVar

T = TypeVar("T")


@dataclass(frozen=True)
class AppError:
    """Structured enterprise application error container."""

    code: str
    message: str
    operation: str = ""
    details: dict[str, Any] = field(default_factory=dict)
    cause_message: str | None = None

    def to_dict(self) -> dict[str, Any]:
        """Convert error to dictionary representation."""
        return {
            "code": self.code,
            "message": self.message,
            "operation": self.operation,
            "details": self.details,
            "cause_message": self.cause_message,
        }

    def __str__(self) -> str:
        """Format error as a readable string."""
        if self.operation:
            return f"[{self.code}] {self.operation}: {self.message}"

        return f"[{self.code}] {self.message}"


class Result(Generic[T]):
    """Monadic container holding either a successful value or an AppError."""

    def __init__(self, value: T | None, error: AppError | None, is_safe: bool) -> None:
        self._value = value
        self._error = error
        self._is_safe = is_safe

    @classmethod
    def ok(cls, value: T) -> Result[T]:
        """Create a successful result container."""
        return cls(value=value, error=None, is_safe=True)

    @classmethod
    def fail(cls, error: AppError) -> Result[T]:
        """Create a failed result container wrapping an AppError."""
        return cls(value=None, error=error, is_safe=False)

    @property
    def is_safe(self) -> bool:
        """Return True if operation succeeded with no errors."""
        return self._is_safe

    @property
    def has_error(self) -> bool:
        """Return True if operation resulted in an error."""
        return not self._is_safe

    @property
    def is_defined(self) -> bool:
        """Return True if result is safe and value is not None."""
        return self._is_safe and self._value is not None

    @property
    def is_empty(self) -> bool:
        """Return True if result is safe and value is None."""
        return self._is_safe and self._value is None

    @property
    def value(self) -> T:
        """Unwrap value or raise RuntimeError if in failed state."""
        if self.has_error:
            raise RuntimeError(f"Attempted to unwrap failed result: {self._error}")

        return self._value  # type: ignore[return-value]

    @property
    def error(self) -> AppError:
        """Access AppError or raise RuntimeError if in safe state."""
        if self.is_safe:
            raise RuntimeError("Attempted to access error on successful result")

        return self._error  # type: ignore[return-value]

    def __repr__(self) -> str:
        """Return debug representation of result."""
        if self._is_safe:
            return f"Result.ok({self._value!r})"

        return f"Result.fail({self._error!r})"
