"""
Cache purging and brain artifact backup-and-cleanup operations.
"""

from __future__ import annotations

import json
import os
import shutil
import tempfile
import time
from pathlib import Path
from typing import List, Tuple

from agy_optimizer.models import BrainCleanupItem


def clean_app_cache_items(items: List[BrainCleanupItem], is_apply: bool = False) -> Tuple[int, int]:
    freed_files = 0
    freed_bytes = 0

    if not is_apply:
        return sum(i.file_count for i in items), sum(i.total_bytes for i in items)

    for item in items:
        p = Path(item.path)
        if not p.is_dir():
            continue

        for root, _, files in os.walk(p):
            for f in files:
                fp = Path(root) / f
                try:
                    sz = fp.stat().st_size
                    fp.unlink()
                    freed_files += 1
                    freed_bytes += sz
                except (OSError, PermissionError):
                    pass

        try:
            for root, dirs, _ in os.walk(p, topdown=False):
                for d in dirs:
                    try:
                        (Path(root) / d).rmdir()
                    except OSError:
                        pass
        except OSError:
            pass

    return freed_files, freed_bytes


def backup_and_clean_brain_items(items: List[BrainCleanupItem], is_apply: bool = False) -> Tuple[int, str]:
    temp_dir = Path(tempfile.gettempdir()) / "antigravity-brain-backup"
    ts = time.strftime("%Y%m%d_%H%M%S")
    backup_bundle = temp_dir / ts
    backup_bundle.mkdir(parents=True, exist_ok=True)

    manifest: List[dict] = []
    freed_bytes = 0

    for item in items:
        src = Path(item.path)
        if not src.exists():
            continue

        clean_cat = item.category.replace(" ", "_").replace("(", "").replace(")", "").replace(":", "_")
        rel_dest = backup_bundle / clean_cat
        try:
            if src.is_dir():
                shutil.copytree(src, rel_dest, dirs_exist_ok=True)
                if is_apply:
                    shutil.rmtree(src)
            elif src.is_file():
                rel_dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, rel_dest)
                if is_apply:
                    src.unlink()

            manifest.append({"category": item.category, "original_path": item.path, "backup_path": str(rel_dest), "bytes": item.total_bytes})
            freed_bytes += item.total_bytes
        except Exception:
            pass

    with open(backup_bundle / "manifest.json", "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)

    return freed_bytes, str(backup_bundle)
