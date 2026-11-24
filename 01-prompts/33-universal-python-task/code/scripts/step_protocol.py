"""Pluggable step protocol and context definitions for task pipelines."""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from app_errors import Result
from task_logger import TaskLogger


@dataclass
class StepContext:
    """Execution context passed through all pipeline steps."""

    task_name: str
    work_dir: Path
    logger: TaskLogger
    is_dry_run: bool = False
    state: dict[str, Any] = field(default_factory=dict)

    def set_value(self, key: str, val: Any) -> None:
        """Store key-value pair in context state."""
        self.state[key] = val

    def get_value(self, key: str, default: Any = None) -> Any:
        """Retrieve key-value pair from context state."""
        return self.state.get(key, default)


@dataclass
class StepOutput:
    """Standardized output envelope returned by every pipeline step."""

    step_id: str
    is_success: bool
    summary: str
    freed_bytes: int = 0
    items_modified: int = 0
    details: dict[str, Any] = field(default_factory=dict)


class IPipelineStep(ABC):
    """Abstract interface for all configurable pipeline steps."""

    @property
    @abstractmethod
    def step_id(self) -> str:
        """Return unique slug identifier for the step."""
        ...

    @abstractmethod
    def execute(self, context: StepContext, params: dict[str, Any]) -> Result[StepOutput]:
        """Execute step logic with single-responsibility helpers <= 15 lines."""
        ...
