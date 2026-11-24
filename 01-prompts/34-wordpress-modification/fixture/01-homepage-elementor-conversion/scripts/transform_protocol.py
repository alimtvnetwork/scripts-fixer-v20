"""Pluggable transformation step protocol, context, and registry."""
from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Callable, Protocol, TypeVar

from scripts.app_errors import AppError, Result


class TransformActionType(str, Enum):
    """Supported transformation actions."""
    MODIFY_AST = "modify_ast"
    MODIFY_CSS = "modify_css"
    INJECT_WIDGET = "inject_widget"
    REPLACE_TOKENS = "replace_tokens"
    CUSTOM = "custom"


@dataclass
class TransformContext:
    """Execution context passed through all pipeline transformation steps."""
    site_url: str
    page_id: int
    cache: Any
    params: dict[str, Any] = field(default_factory=dict)
    metadata: dict[str, Any] = field(default_factory=dict)
    has_cache: bool = True
    is_dry_run: bool = False


class ITransformStep(Protocol):
    """Contract for modular, stackable WordPress transformation steps."""
    step_id: str
    description: str
    user_request: str

    def compile(self, context: TransformContext) -> Result[bool]:
        """Pre-flight check verifying step preconditions and parameters."""
        ...

    def modify_ast(self, ast: dict[str, Any], context: TransformContext) -> Result[dict[str, Any]]:
        """Applies AST tree transformations and returns updated AST."""
        ...

    def modify_css(self, existing_css: str, context: TransformContext) -> Result[str]:
        """Applies scoped CSS modifications and returns updated CSS string."""
        ...

    def validate(self, ast: dict[str, Any]) -> Result[bool]:
        """Validates transformed AST against schema rules."""
        ...


TStep = TypeVar("TStep", bound=type)


class TransformRegistry:
    """Registry maintaining available transformation step implementations."""
    _registry: dict[str, type] = {}

    @classmethod
    def register(cls, name: str, step_class: type) -> None:
        cls._registry[name] = step_class

    @classmethod
    def get(cls, name: str) -> type | None:
        return cls._registry.get(name)

    @classmethod
    def list_registered(cls) -> list[str]:
        return sorted(list(cls._registry.keys()))


def register_transform(name: str) -> Callable[[TStep], TStep]:
    """Decorator registering an ITransformStep class under a unique name."""
    def decorator(cls: TStep) -> TStep:
        TransformRegistry.register(name, cls)
        return cls

    return decorator
