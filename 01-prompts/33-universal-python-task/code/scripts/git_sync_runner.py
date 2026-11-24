"""Git repository multi-format synchronization runner with monadic envelopes."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence

from app_errors import AppError, Result
from core_constants import GitSyncConstants
from core_enums import AppErrorCodeType, GitSyncFormatType
from subprocess_guard import execute_command
from task_logger import TaskLogger


@dataclass(frozen=True)
class RepoSyncEntry:
    """Immutable parsed Git repository target."""

    title: str
    original_url: str
    ssh_url: str
    repo_name: str


def url_to_ssh(raw_url: str) -> str:
    """Convert HTTPS GitHub URL to SSH format."""
    trimmed = raw_url.strip()
    if trimmed.startswith(GitSyncConstants.HTTPS_PREFIX):
        sub = trimmed[len(GitSyncConstants.HTTPS_PREFIX) :]
        clean_sub = sub if sub.endswith(".git") else f"{sub}.git"
        return f"{GitSyncConstants.SSH_PREFIX}{clean_sub}"

    return trimmed if trimmed.endswith(".git") else f"{trimmed}.git"


def extract_repo_name(url: str) -> str:
    """Extract repository slug name from URL."""
    clean = url.rstrip("/").rstrip(".git")
    parts = clean.split("/")
    return parts[-1] if parts else "unknown-repo"


def _parse_text_lines(text: str) -> list[RepoSyncEntry]:
    entries: list[RepoSyncEntry] = []
    for line in text.splitlines():
        trimmed = line.strip()
        if trimmed and not trimmed.startswith("#"):
            ssh = url_to_ssh(trimmed)
            name = extract_repo_name(trimmed)
            entries.append(RepoSyncEntry(name, trimmed, ssh, name))
    return entries


def _parse_json_manifest(text: str) -> Result[list[RepoSyncEntry]]:
    try:
        data = json.loads(text)
        if not isinstance(data, list):
            return Result.fail(AppError(AppErrorCodeType.VALIDATION_ERROR.value, "JSON must be array"))
        entries = [
            RepoSyncEntry(
                item.get("title", extract_repo_name(item.get("url", ""))),
                item.get("url", ""),
                url_to_ssh(item.get("url", "")),
                extract_repo_name(item.get("url", "")),
            )
            for item in data
            if isinstance(item, dict) and item.get("url")
        ]
        return Result.ok(entries)
    except json.JSONDecodeError as err:
        return Result.fail(AppError(AppErrorCodeType.VALIDATION_ERROR.value, f"JSON parse error: {err}"))


def _parse_markdown_links(text: str) -> list[RepoSyncEntry]:
    pattern = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
    matches = pattern.findall(text)
    entries: list[RepoSyncEntry] = []
    for title, url in matches:
        ssh = url_to_ssh(url)
        name = extract_repo_name(url)
        entries.append(RepoSyncEntry(title.strip(), url.strip(), ssh, name))
    return entries


def parse_sync_manifest(
    content: str,
    format_type: GitSyncFormatType,
) -> Result[tuple[RepoSyncEntry, ...]]:
    """Parse raw manifest content according to target format enum."""
    if format_type == GitSyncFormatType.JSON:
        res = _parse_json_manifest(content)
        return Result.ok(tuple(res.value)) if res.is_safe else Result.fail(res.error)

    if format_type == GitSyncFormatType.MARKDOWN:
        return Result.ok(tuple(_parse_markdown_links(content)))

    return Result.ok(tuple(_parse_text_lines(content)))


def sync_single_repo(
    entry: RepoSyncEntry,
    target_dir: Path,
    is_dry_run: bool,
    logger: TaskLogger,
) -> Result[str]:
    """Clone repository or pull updates if directory already exists."""
    dest = target_dir / entry.repo_name
    if is_dry_run:
        action = "PULL" if dest.exists() else "CLONE"
        logger.info(f"[DRY-RUN] Would execute {action} for {entry.title} at {dest}")
        return Result.ok(action)

    if dest.exists():
        pull_res = execute_command(["git", "-C", str(dest), "pull"], timeout_sec=30)
        status = "PULLED" if (pull_res.is_safe and pull_res.value.is_success) else "PULL_FAILED"
        logger.ok(f"Synced {entry.repo_name}: {status}")
        return Result.ok(status)

    clone_res = execute_command(["git", "clone", entry.ssh_url, str(dest)], timeout_sec=60)
    status = "CLONED" if (clone_res.is_safe and clone_res.value.is_success) else "CLONE_FAILED"
    logger.ok(f"Cloned {entry.repo_name}: {status}")
    return Result.ok(status)
