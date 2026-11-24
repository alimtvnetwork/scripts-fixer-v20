"""Unit tests for Git multi-format repository synchronizer runner."""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

scripts_path = Path(__file__).resolve().parent.parent / "scripts"
if str(scripts_path) not in sys.path:
    sys.path.insert(0, str(scripts_path))

from core_enums import GitSyncFormatType
from git_sync_runner import (
    RepoSyncEntry,
    extract_repo_name,
    parse_sync_manifest,
    sync_single_repo,
    url_to_ssh,
)
from task_logger import TaskLogger


class TestGitSyncRunner(unittest.TestCase):
    """Test suite for Git multi-format synchronizer runner."""

    def test_url_to_ssh(self) -> None:
        """Verify HTTPS URL to SSH conversion."""
        https_url = "https://github.com/alimtvnetwork/gitmap"
        ssh_url = url_to_ssh(https_url)
        self.assertEqual(ssh_url, "git@github.com:alimtvnetwork/gitmap.git")

    def test_extract_repo_name(self) -> None:
        """Verify slug name extraction."""
        self.assertEqual(extract_repo_name("https://github.com/alimtvnetwork/my-repo.git"), "my-repo")
        self.assertEqual(extract_repo_name("git@github.com:alimtvnetwork/second-repo.git"), "second-repo")

    def test_parse_text_lines(self) -> None:
        """Verify parsing raw text manifest lines."""
        content = "https://github.com/org/repo-a\n# Comment\nhttps://github.com/org/repo-b"
        res = parse_sync_manifest(content, GitSyncFormatType.TEXT)
        self.assertTrue(res.is_safe)
        self.assertEqual(len(res.value), 2)
        self.assertEqual(res.value[0].repo_name, "repo-a")
        self.assertEqual(res.value[1].repo_name, "repo-b")

    def test_parse_json_manifest(self) -> None:
        """Verify parsing JSON array manifest."""
        content = '[{"title": "Repo One", "url": "https://github.com/org/one"}]'
        res = parse_sync_manifest(content, GitSyncFormatType.JSON)
        self.assertTrue(res.is_safe)
        self.assertEqual(len(res.value), 1)
        self.assertEqual(res.value[0].title, "Repo One")
        self.assertEqual(res.value[0].repo_name, "one")

    def test_parse_markdown_links(self) -> None:
        """Verify parsing Markdown link entries."""
        content = "## Repos\n- [Tool](https://github.com/org/tool)\n- [CLI](https://github.com/org/cli)"
        res = parse_sync_manifest(content, GitSyncFormatType.MARKDOWN)
        self.assertTrue(res.is_safe)
        self.assertEqual(len(res.value), 2)
        self.assertEqual(res.value[0].title, "Tool")
        self.assertEqual(res.value[1].title, "CLI")

    def test_sync_single_repo_dry_run(self) -> None:
        """Verify dry-run simulation mode."""
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            logger = TaskLogger(temp_path / "test.log")
            entry = RepoSyncEntry("test-repo", "https://github.com/org/test-repo", "git@github.com:org/test-repo.git", "test-repo")
            res = sync_single_repo(entry, temp_path, is_dry_run=True, logger=logger)
            self.assertTrue(res.is_safe)
            self.assertEqual(res.value, "CLONE")


if __name__ == "__main__":
    unittest.main()
