#!/usr/bin/env python3
"""
Purge GitHub Actions Storage (Artifacts & Caches) Script
Autonomously discovers and deletes stored GitHub Actions artifacts and caches via GitHub API.
"""

import argparse
import sys

from helpers._purge_artifacts import purge_repo_artifacts
from helpers._purge_caches import purge_repo_caches

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

TARGET_REPOS = [
    "alimtvnetwork/scripts-fixer-v20",
    "alimtvnetwork/Antigravity-Manager",
    "alimtvnetwork/coding-guidelines-v24",
    "alimtvnetwork/gitmap-v28",
    "alimtvnetwork/img-pdf-v2",
    "alimtvnetwork/macro-ahk-v55",
    "alimtvnetwork/movie-cli-v8",
    "alimtvnetwork/cat-my-v12",
]


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Purge GitHub Actions storage (artifacts & caches).")
    parser.add_argument("--repo", help="Target repository (owner/repo). If omitted, purges all defaults.")
    parser.add_argument("--workers", type=int, default=12, help="Number of concurrent deletion threads.")
    parser.add_argument("--artifacts-only", action="store_true", help="Purge only artifacts.")
    parser.add_argument("--caches-only", action="store_true", help="Purge only caches.")

    return parser


def execute_purge(repos: list[str], is_do_artifacts: bool, is_do_caches: bool, workers: int) -> None:
    for repo in repos:
        if is_do_artifacts:
            purge_repo_artifacts(repo, max_workers=workers)

        if is_do_caches:
            purge_repo_caches(repo, max_workers=max(4, workers // 2))


def main():
    parser = build_parser()
    args = parser.parse_args()

    repos = [args.repo] if args.repo else TARGET_REPOS
    is_do_artifacts = not args.caches_only
    is_do_caches = not args.artifacts_only

    execute_purge(repos, is_do_artifacts, is_do_caches, args.workers)


if __name__ == "__main__":
    main()
