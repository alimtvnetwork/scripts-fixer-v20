"""Dual-channel logging: ANSI formatted stdout and structured JSON files."""
from __future__ import annotations

import json
from datetime import datetime
from pathlib import Path

from scripts.core_constants import EncodingConstants


class TaskLogger:
    def __init__(self, log_path: Path | None = None) -> None:
        self.log_path = log_path
        self.events: list[dict[str, str]] = []

    def info(self, msg: str) -> None:
        print(f"\033[36m[ INFO ]\033[0m {msg}")
        self._record("INFO", msg)

    def success(self, msg: str) -> None:
        print(f"\033[32m[  OK  ]\033[0m {msg}")
        self._record("SUCCESS", msg)

    def warn(self, msg: str) -> None:
        print(f"\033[33m[ WARN ]\033[0m {msg}")
        self._record("WARN", msg)

    def error(self, msg: str) -> None:
        print(f"\033[31m[ FAIL ]\033[0m {msg}")
        self._record("ERROR", msg)

    def _record(self, level: str, msg: str) -> None:
        timestamp = datetime.utcnow().isoformat() + "Z"
        entry = {"timestamp": timestamp, "level": level, "message": msg}
        self.events.append(entry)
        if self.log_path:
            self.log_path.parent.mkdir(parents=True, exist_ok=True)
            with open(self.log_path, "a", encoding=EncodingConstants.UTF8) as f:
                f.write(json.dumps(entry) + "\n")
