"""Reference troubleshooting and fix step implementing IPipelineStep."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from app_errors import Result
from step_protocol import IPipelineStep, StepContext, StepOutput


class SampleFixStep(IPipelineStep):
    """Purges stale files and logs step output."""

    @property
    def step_id(self) -> str:
        """Step identifier."""
        return "sample_fix_step"

    def _purge_file(self, file_path: Path, is_dry_run: bool) -> tuple[int, bool]:
        """Safely delete single file and return size in bytes."""
        try:
            size = file_path.stat().st_size
            if not is_dry_run:
                file_path.unlink(missing_ok=True)
            return size, True
        except Exception:
            return 0, False

    def _scan_and_clean(
        self, target_dir: Path, is_dry_run: bool
    ) -> tuple[int, int]:
        """Scan directory and purge stale log files."""
        total_freed = 0
        cleaned_count = 0
        for entry in target_dir.glob("*.stale"):
            freed, is_ok = self._purge_file(entry, is_dry_run)
            if is_ok:
                total_freed += freed
                cleaned_count += 1
        return total_freed, cleaned_count

    def execute(self, context: StepContext, params: dict[str, Any]) -> Result[StepOutput]:
        """Execute cleanup step logic adhering to <= 15 line limit."""
        target_path = Path(params.get("target_path", str(context.work_dir)))
        if not target_path.exists():
            return Result.ok(StepOutput(self.step_id, True, "Target path does not exist", 0, 0))

        freed, count = self._scan_and_clean(target_path, context.is_dry_run)
        summary = f"Cleaned {count} items, freed {freed} bytes (dry_run={context.is_dry_run})"
        context.logger.info(f"[{self.step_id}] {summary}")
        return Result.ok(StepOutput(self.step_id, True, summary, freed, count))
