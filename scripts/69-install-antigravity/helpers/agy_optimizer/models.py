"""
Data models and terminal styling constants for AGY Optimizer.
"""

from __future__ import annotations

import os
import sys
from dataclasses import dataclass
from typing import Optional

# Cross-platform ANSI terminal color palette and safe UTF-8 output
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

if sys.platform == "win32":
    os.system("")  # Initialize Windows VT100 / ANSI escape sequence handler

RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
CYAN = "\033[96m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
MAGENTA = "\033[95m"
WHITE = "\033[97m"
BLUE = "\033[94m"
RED = "\033[91m"
GRAY = "\033[90m"


@dataclass
class ConversationInfo:
    conversation_id: str
    db_path: str
    file_size: int
    title: str
    preview: str
    workspace_uri: str
    project_slug: str
    step_count: int
    is_heavy: bool
    mtime: float = 0.0
    is_preserved: bool = False


@dataclass
class BrainCleanupItem:
    category: str
    path: str
    file_count: int
    total_bytes: int


def format_bytes(total_bytes: int) -> str:
    if total_bytes >= 1024 * 1024 * 1024:
        return f"{total_bytes / (1024 * 1024 * 1024):.2f} GB"

    if total_bytes >= 1024 * 1024:
        return f"{total_bytes / (1024 * 1024):.2f} MB"

    if total_bytes >= 1024:
        return f"{total_bytes / 1024:.2f} KB"

    return f"{total_bytes} B"
