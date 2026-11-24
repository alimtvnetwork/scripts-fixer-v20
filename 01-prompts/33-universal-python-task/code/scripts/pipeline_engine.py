"""Configurable pipeline runner executing modular steps from config/pipeline.json."""

from __future__ import annotations

import importlib
import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from app_errors import AppError, Result
from core_constants import EncodingConstants
from env_config import interpolate_env_vars
from step_protocol import IPipelineStep, StepContext, StepOutput
from task_logger import TaskLogger


@dataclass
class PipelineStepConfig:
    """Configuration record for an individual pipeline step."""

    step_id: str
    module_path: str
    class_name: str
    is_enabled: bool = True
    description: str = ""
    params: dict[str, Any] = field(default_factory=dict)


@dataclass
class PipelineConfig:
    """Top-level pipeline configuration container."""

    pipeline_name: str
    version: str
    steps: list[PipelineStepConfig] = field(default_factory=list)


def parse_step_config(raw: dict[str, Any]) -> PipelineStepConfig:
    """Convert raw dictionary into strongly-typed PipelineStepConfig supporting GitMap attributes envelope."""
    attrs = raw.get("attributes", raw) if isinstance(raw.get("attributes"), dict) else raw
    raw_params = attrs.get("params", {})
    interp_params = {
        k: interpolate_env_vars(v) if isinstance(v, str) else v
        for k, v in raw_params.items()
    }
    step_id = str(attrs.get("stepId") or raw.get("id") or attrs.get("step_id") or "")
    module_path = str(attrs.get("modulePath") or attrs.get("module", ""))
    class_name = str(attrs.get("className") or attrs.get("class_name", ""))
    is_enabled_val = attrs.get("isEnabled") if "isEnabled" in attrs else attrs.get("enabled", True)
    return PipelineStepConfig(
        step_id=step_id,
        module_path=module_path,
        class_name=class_name,
        is_enabled=bool(is_enabled_val),
        description=str(attrs.get("description", "")),
        params=interp_params,
    )


def load_pipeline_config(config_path: Path | str) -> Result[PipelineConfig]:
    """Parse JSON pipeline specification supporting GitMap data and attributes pattern."""
    p = Path(config_path).resolve()
    if not p.is_file():
        return Result.fail(AppError("NOT_FOUND_ERROR", f"Missing pipeline file: {p}"))

    try:
        raw_doc = json.loads(p.read_text(encoding=EncodingConstants.UTF8))
        data_section = raw_doc.get("data", raw_doc)
        source = data_section.get("attributes", data_section) if isinstance(data_section, dict) else raw_doc
        pipeline_name = str(source.get("pipelineName") or source.get("pipeline_name", "Default Pipeline"))
        version = str(source.get("version", "1.0.0"))
        steps = [parse_step_config(item) for item in source.get("steps", [])]
        return Result.ok(PipelineConfig(
            pipeline_name=pipeline_name,
            version=version,
            steps=steps,
        ))
    except Exception as exc:
        return Result.fail(AppError("IO_ERROR", f"Failed parsing pipeline JSON: {exc}"))


def instantiate_step(cfg: PipelineStepConfig) -> Result[IPipelineStep]:
    """Dynamically import and instantiate an IPipelineStep class."""
    try:
        mod = importlib.import_module(cfg.module_path)
        cls = getattr(mod, cfg.class_name)
        instance = cls()
        return Result.ok(instance)
    except Exception as exc:
        err = AppError("SYSTEM_ERROR", f"Failed instantiating {cfg.class_name}: {exc}")
        return Result.fail(err)


class PipelineRunner:
    """Sequentially executes enabled pipeline steps with telemetry and error checking."""

    def __init__(self, config: PipelineConfig, logger: TaskLogger) -> None:
        self._config = config
        self._logger = logger

    def _run_single_step(
        self, step_cfg: PipelineStepConfig, context: StepContext
    ) -> Result[StepOutput]:
        """Load and execute an individual step."""
        self._logger.info(f"Pipeline step: {step_cfg.step_id} ({step_cfg.description})")
        inst_res = instantiate_step(step_cfg)
        if inst_res.has_error:
            return Result.fail(inst_res.error)

        step = inst_res.value
        return step.execute(context, step_cfg.params)

    def run(self, context: StepContext) -> Result[list[StepOutput]]:
        """Run all enabled steps sequentially, collecting StepOutput records."""
        outputs: list[StepOutput] = []
        for step_cfg in self._config.steps:
            if not step_cfg.is_enabled:
                self._logger.info(f"Skipping disabled step: {step_cfg.step_id}")
                continue

            step_res = self._run_single_step(step_cfg, context)
            if step_res.has_error:
                return Result.fail(step_res.error)

            outputs.append(step_res.value)

        return Result.ok(outputs)
