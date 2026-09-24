"""
Scanning and inventory discovery for caches and Gemini brain artifacts.
"""

from __future__ import annotations

import os
from pathlib import Path
from typing import List, Optional, Set, Tuple

from agy_optimizer.models import BrainCleanupItem
from agy_optimizer.shared.paths import get_cache_directories, get_gemini_base_dir


def get_dir_stats(target_path: Path) -> Tuple[int, int]:
    file_count = 0
    total_size = 0

    try:
        for root, _, files in os.walk(target_path):
            for file_name in files:
                file_path = Path(root) / file_name
                try:
                    total_size += file_path.stat().st_size
                    file_count += 1
                except OSError:
                    pass
    except OSError:
        pass

    return file_count, total_size


def scan_app_cache_items() -> List[BrainCleanupItem]:
    cache_dirs = get_cache_directories()
    items: List[BrainCleanupItem] = []
    seen: Set[str] = set()

    for cache_dir in cache_dirs:
        resolved_str = str(cache_dir.resolve()) if cache_dir.exists() else str(cache_dir)
        if resolved_str in seen or not cache_dir.is_dir():
            continue

        seen.add(resolved_str)
        cnt, bsz = get_dir_stats(cache_dir)
        if cnt > 0:
            parent_name = cache_dir.parent.name
            tag = f"AppCache ({parent_name}/{cache_dir.name})" if parent_name in ("Antigravity", "antigravity") else f"AppCache ({cache_dir.name})"
            items.append(BrainCleanupItem(category=tag, path=str(cache_dir), file_count=cnt, total_bytes=bsz))

    return items


def scan_brain_cleanup_items(
    protected_cids: Optional[Set[str]] = None,
    cid_to_slug: Optional[dict[str, str]] = None,
) -> List[BrainCleanupItem]:
    gemini_dir = get_gemini_base_dir()
    items: List[BrainCleanupItem] = []
    protected = protected_cids or set()
    slug_map = cid_to_slug or {}

    static_targets = [
        ("Crashes", gemini_dir / "crashes"),
        ("Logs", gemini_dir / "log"),
        ("TempMedia", gemini_dir / "brain" / "tempmediaStorage"),
        ("BrainCache", gemini_dir / "brain" / "cache"),
    ]
    for cat, p in static_targets:
        if p.is_dir():
            cnt, bsz = get_dir_stats(p)
            if cnt > 0:
                items.append(BrainCleanupItem(category=cat, path=str(p), file_count=cnt, total_bytes=bsz))

    brain_dir = gemini_dir / "brain"
    if not brain_dir.is_dir():
        return items

    for cdir in brain_dir.iterdir():
        if not cdir.is_dir() or cdir.name == "tempmediaStorage" or cdir.name in protected:
            continue

        suffix = f" ({cdir.name[:8]}: {slug_map.get(cdir.name, '')[:16]})" if slug_map.get(cdir.name) else f" ({cdir.name[:8]})"
        for sub_cat, folder in (("Scratch", cdir / "scratch"), ("TaskLogs", cdir / ".system_generated" / "tasks")):
            if folder.is_dir():
                cnt, bsz = get_dir_stats(folder)
                if cnt > 0:
                    items.append(BrainCleanupItem(category=f"{sub_cat}{suffix}", path=str(folder), file_count=cnt, total_bytes=bsz))

    return items
