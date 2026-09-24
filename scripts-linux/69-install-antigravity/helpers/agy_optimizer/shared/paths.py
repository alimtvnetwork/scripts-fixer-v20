"""
Filesystem path resolution and slug extraction for Antigravity engine.
"""

from __future__ import annotations

import os
import urllib.parse
from pathlib import Path
from typing import List


def get_gemini_base_dir() -> Path:
    return Path.home() / ".gemini" / "antigravity"


def get_backup_db_path() -> Path:
    backup_dir = Path.home() / ".scripts-fixer"
    backup_dir.mkdir(parents=True, exist_ok=True)

    return backup_dir / "antigravity-backup.db"


def extract_project_slug(workspace_uri: str) -> str:
    if not workspace_uri:
        return "unknown"

    try:
        parsed = urllib.parse.unquote(workspace_uri)
        clean = parsed.rstrip("/").split("/")[-1]
        clean = clean.replace("file://", "").strip(":").strip('"]').strip('["').strip('"').strip("'")

        return clean or "unknown"
    except Exception:
        return "unknown"


def _get_platform_subdirs() -> List[str]:
    return [
        "Cache",
        "Code Cache",
        "GPUCache",
        "DawnGraphiteCache",
        "DawnWebGPUCache",
        "blob_storage",
        "Session Storage",
        "Shared Dictionary",
        "Crashpad",
    ]


def get_cache_directories() -> List[Path]:
    dirs: List[Path] = []
    appdata = os.environ.get("APPDATA")
    localappdata = os.environ.get("LOCALAPPDATA")
    home = Path.home()
    sub_dirs = _get_platform_subdirs()

    if appdata:
        roaming = Path(appdata) / "Antigravity"
        for sub in sub_dirs:
            dirs.append(roaming / sub)

    if localappdata:
        dirs.append(Path(localappdata) / "Antigravity" / "Cache")
        dirs.append(Path(localappdata) / "Antigravity" / "Crashpad")
        dirs.append(Path(localappdata) / "antigravity-updater")

    for sub in sub_dirs:
        dirs.append(home / ".config" / "Antigravity" / sub)
        dirs.append(home / ".config" / "antigravity" / sub)

    dirs.append(home / ".cache" / "antigravity")
    dirs.append(home / ".local" / "share" / "antigravity-updater")

    mac_app_support = home / "Library" / "Application Support" / "Antigravity"
    for sub in sub_dirs:
        dirs.append(mac_app_support / sub)

    dirs.append(home / "Library" / "Caches" / "Antigravity")
    dirs.append(home / "Library" / "Caches" / "com.google.antigravity")

    return dirs
