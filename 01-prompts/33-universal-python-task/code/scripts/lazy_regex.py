"""Lazy regular expression compilation with thread-safe caching."""

from __future__ import annotations

import re
from typing import ClassVar, Pattern


class LazyRegex:
    """Thread-safe lazy regular expression compiler (cached on demand)."""

    _cache: ClassVar[dict[str, Pattern[str]]] = {}

    @classmethod
    def get(cls, pattern: str, flags: int = 0) -> Pattern[str]:
        """Retrieve compiled pattern from cache or compile and store."""
        key = f"{pattern}::{flags}"
        if key not in cls._cache:
            cls._cache[key] = re.compile(pattern, flags)
        return cls._cache[key]

    @classmethod
    def clear(cls) -> None:
        """Clear cached patterns."""
        cls._cache.clear()
