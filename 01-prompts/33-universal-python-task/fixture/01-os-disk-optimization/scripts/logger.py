"""scripts/logger.py — Structured console and file logging."""

from datetime import datetime
from pathlib import Path


class TaskLogger:
    def __init__(self, log_path: Path):
        self.log_path = log_path
        self.log_path.parent.mkdir(parents=True, exist_ok=True)

    def log_message(self, level: str, message: str) -> None:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        formatted = f"[{timestamp}] [{level.upper()}] {message}"
        print(formatted)
        with open(self.log_path, "a", encoding="utf-8") as f:
            f.write(formatted + "\n")

    def info(self, message: str) -> None:
        self.log_message("info", message)

    def warn(self, message: str) -> None:
        self.log_message("warn", message)

    def error(self, message: str) -> None:
        self.log_message("error", message)
