"""Structured dual-channel logging system for universal Python tasks."""

from __future__ import annotations

import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from core_constants import AnsiColorConstants, EncodingConstants, LogBadgeConstants


class TaskLogger:
    """Dual console and file logger supporting ANSI badges and JSON telemetry."""

    def __init__(
        self,
        log_path: Path | str | None = None,
        is_verbose: bool = False,
        enable_ansi: bool | None = None,
    ) -> None:
        self.is_verbose = is_verbose
        self.enable_ansi = sys.stdout.isatty() if enable_ansi is None else enable_ansi
        self.log_path = Path(log_path) if log_path else Path("logs/task.log")
        self._start_time = datetime.now(timezone.utc)
        self._events: list[dict[str, Any]] = []
        self._error_count = 0
        self._warn_count = 0
        self._ensure_log_directory()

    def _ensure_log_directory(self) -> None:
        """Ensure parent directory of log file exists."""
        if not self.log_path.parent.exists():
            self.log_path.parent.mkdir(parents=True, exist_ok=True)

    def _strip_ansi(self, text: str) -> str:
        """Strip ANSI escape sequences from text for file storage."""
        return re.sub(r"\033\[[0-9;]*m", "", text)

    def _format_badge(self, badge: str, color: str) -> str:
        """Format badge with ANSI color or plain text."""
        if not self.enable_ansi:
            return badge

        return f"{color}{AnsiColorConstants.BOLD}{badge}{AnsiColorConstants.RESET}"

    def _write_file(self, line: str) -> None:
        """Write line to file with LF line ending."""
        try:
            with open(self.log_path, "a", encoding=EncodingConstants.UTF8, newline="\n") as handle:
                handle.write(self._strip_ansi(line) + "\n")
        except OSError:
            pass

    def log_entry(self, badge: str, color: str, message: str, details: dict[str, Any] | None = None) -> None:
        """Output entry to console and record structured entry to log file."""
        now = datetime.now(timezone.utc)
        formatted_badge = self._format_badge(badge, color)
        console_line = f"{formatted_badge} {message}"
        file_line = f"[{now.strftime('%Y-%m-%d %H:%M:%S')}] {badge} {message}"
        print(console_line)
        self._write_file(file_line)
        self._record_event(badge, message, details, now)
        if details and self.is_verbose:
            self._write_file(f"[{now.strftime('%Y-%m-%d %H:%M:%S')}] DETAILS: {json.dumps(details, default=str)}")

    def _record_event(self, badge: str, message: str, details: dict[str, Any] | None, now: datetime) -> None:
        """Append event to internal buffer and increment level tallies."""
        if badge == LogBadgeConstants.FAIL:
            self._error_count += 1
        if badge == LogBadgeConstants.WARN:
            self._warn_count += 1
        self._events.append({"timestamp": now.isoformat(), "badge": badge, "message": message, "details": details or {}})

    def ok(self, message: str, details: dict[str, Any] | None = None) -> None:
        """Log success message with green OK badge."""
        self.log_entry(LogBadgeConstants.OK, AnsiColorConstants.GREEN, message, details)

    def fail(self, message: str, details: dict[str, Any] | None = None) -> None:
        """Log failure message with red FAIL badge."""
        self.log_entry(LogBadgeConstants.FAIL, AnsiColorConstants.RED, message, details)

    def warn(self, message: str, details: dict[str, Any] | None = None) -> None:
        """Log warning message with yellow WARN badge."""
        self.log_entry(LogBadgeConstants.WARN, AnsiColorConstants.YELLOW, message, details)

    def info(self, message: str, details: dict[str, Any] | None = None) -> None:
        """Log info message with blue INFO badge."""
        self.log_entry(LogBadgeConstants.INFO, AnsiColorConstants.BLUE, message, details)

    def skip(self, message: str, details: dict[str, Any] | None = None) -> None:
        """Log skipped operation with cyan SKIP badge."""
        self.log_entry(LogBadgeConstants.SKIP, AnsiColorConstants.CYAN, message, details)

    def audit(self, operation: str, status: str, details: dict[str, Any] | None = None) -> None:
        """Record structured JSON audit event."""
        payload = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "operation": operation,
            "status": status,
            "details": details or {},
        }
        json_line = f"JSON_AUDIT: {json.dumps(payload)}"
        self._write_file(json_line)

    def _build_summary(self, status: str, end_time: datetime) -> dict[str, Any]:
        """Construct JSON execution summary dictionary following GitMap data and attributes pattern."""
        duration = round((end_time - self._start_time).total_seconds(), 3)
        formatted_id = f"taskSummary-{self._start_time.strftime('%Y%m%dT%H%M%SZ')}"
        return {
            "data": {
                "id": formatted_id,
                "type": "taskSummary",
                "attributes": {
                    "status": status,
                    "startTime": self._start_time.isoformat(),
                    "endTime": end_time.isoformat(),
                    "durationSec": duration,
                    "eventCount": len(self._events),
                    "errorCount": self._error_count,
                    "warnCount": self._warn_count,
                    "events": self._events,
                },
            }
        }

    def save_summary_log(self, status: str = "ok") -> Path:
        """Persist structured JSON execution summary to logs directory."""
        end_time = datetime.now(timezone.utc)
        payload = self._build_summary(status, end_time)
        summary_path = self.log_path.parent / "taskSummary.json"
        with open(summary_path, "w", encoding=EncodingConstants.UTF8, newline="\n") as handle:
            json.dump(payload, handle, indent=2)
        self._write_error_summary_if_needed(payload, status)
        return summary_path

    def _write_error_summary_if_needed(self, payload: dict[str, Any], status: str) -> None:
        """Write error summary file if status is not ok or errors exist."""
        if status == "ok" and self._error_count == 0:
            return

        err_path = self.log_path.parent / "taskSummaryError.json"
        with open(err_path, "w", encoding=EncodingConstants.UTF8, newline="\n") as err_handle:
            json.dump(payload, err_handle, indent=2)
