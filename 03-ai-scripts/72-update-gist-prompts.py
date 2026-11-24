#!/usr/bin/env python3
"""
72-update-gist-prompts.py — Automated Gist Synchronization Engine via GitHub CLI (gh).
Synchronizes canonical master prompts to public GitHub Gists, preserving raw, unwrapped URLs.
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from enum import Enum
from pathlib import Path
from typing import ClassVar, Final, NamedTuple, Pattern


class GistActionType(str, Enum):
    """Supported gist synchronization actions."""
    SYNC = "sync"
    STATUS = "status"


class EncodingConstants:
    """Standard character encoding format constants."""
    UTF8: Final[str] = "utf-8"
    ASCII: Final[str] = "ascii"
    UTF16: Final[str] = "utf-16"


class GistConstants:
    """Canonical Gist identifiers and filenames."""
    GIST_COMMON_FOUNDATION_ID: Final[str] = "9fe8c6fb25ab0e409a22e9c2624915da"
    GIST_COMMON_FOUNDATION_FILENAME: Final[str] = "00-universal-common-foundation-prompt.md"
    GIST_PYTHON_ID: Final[str] = "fd0953a5f2bfbbc91ae6e3666c5f7c37"
    GIST_PYTHON_FILENAME: Final[str] = "python-any-task-prompt.md"
    GIST_WP_ID: Final[str] = "11900295ef222d921bd646923fbcff3d"
    GIST_WP_FILENAME: Final[str] = "universal-wp-modernizing-master-prompt.md"
    GIST_ELEMENTOR_ID: Final[str] = "9ee32e9568d0afc4ee4c49c86bedb9e8"
    GIST_ELEMENTOR_FILENAME: Final[str] = "elementor-modify-pixel-perfect-loop.md"
    GIST_AI_MEMORY_ID: Final[str] = "faa0881913e4029b36951828418f5316"
    GIST_AI_MEMORY_FILENAME: Final[str] = "07-universal-ai-memory-folder-structure-prompt.md"


class LazyRegex:
    """Thread-safe lazy regular expression compiler (cached on demand)."""
    _cache: ClassVar[dict[str, Pattern[str]]] = {}

    @classmethod
    def get(cls, pattern: str, flags: int = 0) -> Pattern[str]:
        """Retrieve compiled pattern from cache or compile and store."""
        key = f"{pattern}::{flags}"
        if key not in cls._cache:
            cls._cache[key] = re.compile(pattern, flags)
        return cls._cache[key]

    @classmethod
    def clear(cls) -> None:
        """Clear cached patterns."""
        cls._cache.clear()


class GistTarget(NamedTuple):
    gist_id: str
    remote_filename: str
    local_path: Path
    description: str


class SyncResult(NamedTuple):
    is_success: bool
    gist_id: str
    filename: str
    message: str


TARGET_GISTS = (
    GistTarget(
        gist_id=GistConstants.GIST_COMMON_FOUNDATION_ID,
        remote_filename=GistConstants.GIST_COMMON_FOUNDATION_FILENAME,
        local_path=Path("01-prompts/35-universal-single-file-prompts/00-universal-common-foundation-prompt.md"),
        description="Universal Common Foundation Master Prompt",
    ),
    GistTarget(
        gist_id=GistConstants.GIST_PYTHON_ID,
        remote_filename=GistConstants.GIST_PYTHON_FILENAME,
        local_path=Path("01-prompts/35-universal-single-file-prompts/01-universal-python-task-automation-prompt.md"),
        description="Python Any Task Master Prompt",
    ),
    GistTarget(
        gist_id=GistConstants.GIST_WP_ID,
        remote_filename=GistConstants.GIST_WP_FILENAME,
        local_path=Path("01-prompts/35-universal-single-file-prompts/02-universal-wordpress-elementor-modification-prompt.md"),
        description="WordPress Modernization Master Prompt",
    ),
    GistTarget(
        gist_id=GistConstants.GIST_ELEMENTOR_ID,
        remote_filename=GistConstants.GIST_ELEMENTOR_FILENAME,
        local_path=Path("01-prompts/35-universal-single-file-prompts/elementor-modify-pixel-perfect-loop.md"),
        description="Elementor Pixel-Perfect Loop Prompt",
    ),
    GistTarget(
        gist_id=GistConstants.GIST_AI_MEMORY_ID,
        remote_filename=GistConstants.GIST_AI_MEMORY_FILENAME,
        local_path=Path("01-prompts/35-universal-single-file-prompts/07-universal-ai-memory-folder-structure-prompt.md"),
        description="Universal AI Memory Folder Structure Prompt",
    ),
)


def verify_gh_cli() -> bool:
    """Verify GitHub CLI is installed and authenticated with gist scope."""
    res = subprocess.run(["gh", "auth", "status"], capture_output=True, text=True)
    has_token = res.returncode == 0
    gist_pattern = LazyRegex.get(r"\bgist\b", re.IGNORECASE)
    has_gist_scope = bool(gist_pattern.search(res.stdout) or gist_pattern.search(res.stderr))
    return has_token and has_gist_scope


def sync_single_gist(target: GistTarget, is_dry_run: bool) -> SyncResult:
    """Synchronize single local prompt file to remote GitHub Gist."""
    if not target.local_path.exists():
        msg = f"Local file not found: {target.local_path}"
        return SyncResult(False, target.gist_id, target.remote_filename, msg)

    if is_dry_run:
        msg = f"[DRY-RUN] Would push {target.local_path} -> Gist {target.gist_id}:{target.remote_filename}"
        return SyncResult(True, target.gist_id, target.remote_filename, msg)

    cmd = [
        "gh", "gist", "edit", target.gist_id,
        "--filename", target.remote_filename,
        str(target.local_path)
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        err_msg = res.stderr.strip() or res.stdout.strip() or "Unknown gh error"
        return SyncResult(False, target.gist_id, target.remote_filename, f"Sync failed: {err_msg}")

    url = f"https://gist.github.com/{target.gist_id}"
    return SyncResult(True, target.gist_id, target.remote_filename, f"Successfully synced to {url}")


def run_sync(is_dry_run: bool) -> int:
    """Execute synchronization across all configured gists."""
    if not verify_gh_cli():
        print("[FAIL] GitHub CLI (gh) is not authenticated or missing 'gist' scope.")
        return 1

    print(f"🚀 Starting Gist Synchronization (dry_run={is_dry_run})...\n")
    all_success = True
    for target in TARGET_GISTS:
        res = sync_single_gist(target, is_dry_run)
        status_tag = "OK" if res.is_success else "FAIL"
        print(f"[{status_tag}] {target.description} ({target.remote_filename})")
        print(f"     -> {res.message}\n")
        if not res.is_success:
            all_success = False

    return 0 if all_success else 2


def main() -> None:
    """CLI entry point for gist synchronization."""
    parser = argparse.ArgumentParser(description="Synchronize master prompts to public GitHub Gists")
    parser.add_argument("--dry-run", action="store_true", help="Simulate sync without uploading")
    parser.add_argument("--status", action="store_true", help="Check gh authentication and targets only")
    args = parser.parse_args()

    if args.status:
        is_ok = verify_gh_cli()
        print(f"GitHub CLI Gist Scope Active : {is_ok}")
        for t in TARGET_GISTS:
            exists = t.local_path.exists()
            size = t.local_path.stat().st_size if exists else 0
            print(f"  • {t.description}: {t.local_path} (exists={exists}, {size} bytes)")
        sys.exit(0 if is_ok else 1)

    code = run_sync(is_dry_run=args.dry_run)
    sys.exit(code)


if __name__ == "__main__":
    main()
