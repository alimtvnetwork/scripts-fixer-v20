"""FileSystemCache and PipelineWrapper for WordPress transformation stacks."""
from __future__ import annotations

import hashlib
import importlib
import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from scripts.app_errors import AppError, Result
from scripts.core_constants import EncodingConstants
from scripts.transform_protocol import ITransformStep, TransformContext, TransformRegistry


@dataclass(frozen=True)
class CacheEntry:
    content: str
    mtime_ns: int
    sha256_hash: str


class FileSystemCache:
    """Thread-safe caching wrapper with mtime and SHA-256 freshness tracking."""

    def __init__(self) -> None:
        self._store: dict[str, CacheEntry] = {}

    def _calculate_sha256(self, raw_bytes: bytes) -> str:
        return hashlib.sha256(raw_bytes).hexdigest()

    def get_or_load(self, path: Path | str) -> Result[str]:
        p = Path(path).resolve()
        if not p.exists():
            return Result.fail(AppError("FILE_NOT_FOUND", f"File does not exist: {p}"))

        mtime = p.stat().st_mtime_ns
        key = str(p)
        cached = self._store.get(key)
        if cached is not None and cached.mtime_ns == mtime:
            return Result.ok(cached.content)

        try:
            raw = p.read_bytes()
            content = raw.decode(EncodingConstants.UTF8)
            digest = self._calculate_sha256(raw)
            self._store[key] = CacheEntry(content=content, mtime_ns=mtime, sha256_hash=digest)
            return Result.ok(content)
        except Exception as err:
            return Result.fail(AppError("FILE_READ_ERROR", str(err)))

    def get_json(self, path: Path | str) -> Result[dict[str, Any]]:
        load_res = self.get_or_load(path)
        if load_res.is_failure:
            return Result.fail(load_res.error)

        try:
            parsed = json.loads(load_res.value)
            return Result.ok(parsed)
        except json.JSONDecodeError as err:
            return Result.fail(AppError("JSON_DECODE_ERROR", str(err)))

    def invalidate(self, path: Path | str) -> None:
        key = str(Path(path).resolve())
        self._store.pop(key, None)

    def clear(self) -> None:
        self._store.clear()


class PipelineWrapper:
    """Pluggable execution pipeline that sequences transformation steps."""

    def __init__(self, name: str = "default_pipeline") -> None:
        self.name = name
        self.steps: list[ITransformStep] = []

    def add_step(self, step: ITransformStep) -> None:
        self.steps.append(step)

    @classmethod
    def from_json(cls, config_path: Path | str, cache: FileSystemCache) -> Result[PipelineWrapper]:
        json_res = cache.get_json(config_path)
        if json_res.is_failure:
            return Result.fail(json_res.error)

        raw_doc = json_res.value
        data_section = raw_doc.get("data", raw_doc)
        cfg = data_section.get("attributes", data_section) if isinstance(data_section, dict) else raw_doc
        pipeline = cls(name=cfg.get("pipelineName") or cfg.get("pipeline_name", "unnamed_pipeline"))
        step_items = cfg.get("steps", [])
        for item in step_items:
            step_res = cls._load_single_step(item)
            if step_res.is_failure:
                return Result.fail(step_res.error)
            if step_res.value is not None:
                pipeline.add_step(step_res.value)

        return Result.ok(pipeline)

    @classmethod
    def _load_single_step(cls, item: dict[str, Any]) -> Result[ITransformStep | None]:
        attrs = item.get("attributes", item) if isinstance(item.get("attributes"), dict) else item
        is_enabled = bool(attrs.get("isEnabled") if "isEnabled" in attrs else attrs.get("enabled", True))
        if not is_enabled:
            return Result.ok(None)

        class_name = attrs.get("className") or attrs.get("class_name", "")
        module_name = attrs.get("modulePath") or attrs.get("module", "")
        reg_step = TransformRegistry.get(class_name)
        if reg_step is not None:
            return Result.ok(reg_step())

        return cls._instantiate_from_module(module_name, class_name)

    @classmethod
    def _instantiate_from_module(cls, module_name: str, class_name: str) -> Result[ITransformStep | None]:
        if not module_name or not class_name:
            return Result.fail(AppError("INVALID_STEP_CONFIG", "Missing module or class_name"))

        try:
            mod = importlib.import_module(module_name)
            cls_type = getattr(mod, class_name)
            return Result.ok(cls_type())
        except Exception as err:
            return Result.fail(AppError("STEP_IMPORT_ERROR", f"Failed importing {module_name}.{class_name}: {err}"))

    def execute(
        self,
        context: TransformContext,
        initial_ast: dict[str, Any],
        initial_css: str = "",
    ) -> Result[dict[str, Any]]:
        current_ast = initial_ast
        current_css = initial_css

        for step in self.steps:
            comp_res = step.compile(context)
            if comp_res.is_failure:
                return Result.fail(comp_res.error)

            ast_res = step.modify_ast(current_ast, context)
            if ast_res.is_failure:
                return Result.fail(ast_res.error)
            current_ast = ast_res.value

            css_res = step.modify_css(current_css, context)
            if css_res.is_failure:
                return Result.fail(css_res.error)
            current_css = css_res.value

            val_res = step.validate(current_ast)
            if val_res.is_failure:
                return Result.fail(val_res.error)

        return Result.ok({"ast": current_ast, "css": current_css, "step_count": len(self.steps)})
