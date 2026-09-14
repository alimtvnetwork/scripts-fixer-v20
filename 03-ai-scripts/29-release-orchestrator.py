#!/usr/bin/env python3
"""
Release Orchestrator & Branch Lifecycle Manager.
Automates semantic version bumping, branch management, and git tagging.
"""

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import subprocess
import sys


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Automated semantic release orchestrator and git lifecycle manager."
    )
    parser.add_argument(
        "--tier",
        choices=["minor", "patch", "major", "none"],
        default="minor",
        help="Semantic release increment tier (default: minor). Use 'none' to re-tag current version.",
    )
    parser.add_argument(
        "--scope",
        default="",
        help="Brief scope summary for the release commit and tag message.",
    )
    parser.add_argument(
        "--no-push",
        action="store_true",
        help="Skip pushing release branch and tag to remote origin.",
    )
    return parser.parse_args()


def run_git_command(git_args: list[str], has_check: bool = True) -> subprocess.CompletedProcess:
    repo_root = Path(__file__).resolve().parent.parent
    proc = subprocess.run(
        ["git"] + git_args,
        cwd=str(repo_root),
        capture_output=True,
        text=True,
    )
    if has_check and proc.returncode != 0:
        print(f"Git command failed: git {' '.join(git_args)}\nError: {proc.stderr.strip()}")
        raise subprocess.CalledProcessError(proc.returncode, ["git"] + git_args, output=proc.stdout, stderr=proc.stderr)
    return proc


def get_current_git_branch() -> str:
    result = run_git_command(["rev-parse", "--abbrev-ref", "HEAD"])
    return result.stdout.strip()


def read_canonical_version(repo_root: Path) -> str:
    version_file = repo_root / "version.json"
    if not version_file.exists():
        version_file = repo_root / "scripts" / "version.json"
    with open(version_file, "r", encoding="utf-8") as file_handle:
        version_content = json.load(file_handle)
    return str(version_content.get("version", "1.0.0"))


def calculate_next_version(current_ver: str, tier: str) -> str:
    if tier == "none":
        return current_ver.strip().lstrip("v")

    parts = current_ver.strip().lstrip("v").split(".")
    major_num = int(parts[0]) if len(parts) > 0 else 1
    minor_num = int(parts[1]) if len(parts) > 1 else 0
    patch_num = int(parts[2]) if len(parts) > 2 else 0

    if tier == "major":
        return f"{major_num + 1}.0.0"
    if tier == "patch":
        return f"{major_num}.{minor_num}.{patch_num + 1}"
    return f"{major_num}.{minor_num + 1}.0"


def update_json_version(file_path: Path, next_version: str, release_date: str) -> bool:
    if not file_path.exists():
        return False
    with open(file_path, "r", encoding="utf-8") as file_handle:
        payload = json.load(file_handle)
    if "Version" in payload:
        del payload["Version"]
    payload["version"] = next_version
    if "releaseDate" in payload or file_path.name == "version.json":
        payload["releaseDate"] = release_date
    if "updated" in payload:
        payload["updated"] = release_date
    with open(file_path, "w", encoding="utf-8", newline="\n") as file_handle:
        json.dump(payload, file_handle, indent=2)
        file_handle.write("\n")
    return True


def update_readme_version(readme_path: Path, next_version: str) -> bool:
    if not readme_path.exists():
        return False
    with open(readme_path, "r", encoding="utf-8") as file_handle:
        readme_text = file_handle.read()
    replaced_text = re.sub(
        r"Version-v\d+\.\d+\.\d+",
        f"Version-v{next_version}",
        readme_text,
    )
    with open(readme_path, "w", encoding="utf-8", newline="\n") as file_handle:
        file_handle.write(replaced_text)
    return True


def update_changelog_release(changelog_path: Path, next_version: str, release_date: str, scope: str) -> bool:
    if not changelog_path.exists():
        return False
    with open(changelog_path, "r", encoding="utf-8") as file_handle:
        changelog_text = file_handle.read()

    version_header = f"## [v{next_version}]"
    if version_header in changelog_text:
        return True

    clean_scope = scope if scope else "Automated orchestrated system release."
    new_entry = (
        f"## [v{next_version}] - {release_date}\n\n"
        f"### Added\n"
        f"- {clean_scope}\n\n"
    )
    updated_text = changelog_text.replace("# Changelog\n", f"# Changelog\n\n{new_entry}", 1)
    with open(changelog_path, "w", encoding="utf-8", newline="\n") as file_handle:
        file_handle.write(updated_text)
    return True


def update_gitmap_release(repo_root: Path, next_version: str, release_date: str, scope: str) -> None:
    release_dir = repo_root / ".gitmap" / "release"
    release_dir.mkdir(parents=True, exist_ok=True)

    latest_file = release_dir / "latest.json"
    latest_payload = {
        "version": next_version,
        "tag": f"v{next_version}",
        "branch": f"release/v{next_version}",
    }
    with open(latest_file, "w", encoding="utf-8", newline="\n") as file_handle:
        json.dump(latest_payload, file_handle, indent=2)
        file_handle.write("\n")

    version_release_file = release_dir / f"v{next_version}.json"
    clean_scope = scope if scope else f"Release v{next_version}"
    version_payload = {
        "version": next_version,
        "branch": f"release/v{next_version}",
        "sourceBranch": "main",
        "commit": "",
        "tag": f"v{next_version}",
        "assets": [],
        "changelog": [clean_scope],
        "isDraft": False,
        "isPreRelease": False,
        "createdAt": f"{release_date}T00:00:00Z",
        "isLatest": True,
    }
    with open(version_release_file, "w", encoding="utf-8", newline="\n") as file_handle:
        json.dump(version_payload, file_handle, indent=2)
        file_handle.write("\n")


def run_pre_release_generators(repo_root: Path) -> None:
    generators = [
        ["node", str(repo_root / "tools" / "registry-sync.cjs")],
        ["node", str(repo_root / "scripts" / "_internal" / "generate-registry-summary.cjs")],
        ["node", str(repo_root / "tools" / "docs-generate.cjs")],
        ["node", str(repo_root / "tools" / "manifest-aliases.cjs")],
        ["node", str(repo_root / "tools" / "gen-completions.cjs")],
    ]
    for cmd in generators:
        try:
            subprocess.run(cmd, cwd=str(repo_root), check=False, capture_output=True)
        except Exception:
            pass


def stage_release_files(repo_root: Path, next_version: str = "") -> list[str]:
    candidate_files = [
        "version.json",
        "scripts/version.json",
        "package.json",
        "changelog.md",
        "readme.md",
        "spec/script-registry-summary.md",
        "docs/parity-matrix.md",
        "scripts/readme.md",
        "scripts-linux/readme.md",
        "scripts/aliases.generated.json",
        "scripts-linux/aliases.generated.json",
        "scripts/registry.json",
        "scripts-linux/registry.json",
        "completions/run.ps1",
        "completions/run.bash",
        "completions/run.zsh",
        ".gitmap/release/latest.json",
    ]
    if next_version:
        candidate_files.append(f".gitmap/release/v{next_version}.json")

    staged_list = []
    for rel_path in candidate_files:
        full_path = repo_root / rel_path
        if full_path.exists():
            run_git_command(["add", rel_path])
            staged_list.append(rel_path)
    return staged_list


def create_release_commit(next_version: str, scope: str) -> str:
    commit_scope = f" {scope}" if scope else ""
    commit_message = f"release: v{next_version}{commit_scope}"
    run_git_command(["commit", "-m", commit_message])
    commit_hash = run_git_command(["rev-parse", "--short", "HEAD"]).stdout.strip()
    return commit_hash


def create_release_branch_and_tag(next_version: str, scope: str) -> tuple[str, str]:
    branch_name = f"release/v{next_version}"
    tag_name = f"v{next_version}"
    tag_message = f"Release {tag_name}: {scope}" if scope else f"Release {tag_name}"

    # Force branch pointer to HEAD if exists or create fresh
    run_git_command(["branch", "-f", branch_name, "HEAD"])
    # Create or update annotated tag
    run_git_command(["tag", "-a", "-f", tag_name, "-m", tag_message])
    return branch_name, tag_name


def push_release_artifacts(original_branch: str, release_branch: str, tag_name: str) -> None:
    print(f"  -> Pushing {original_branch} to origin...")
    run_git_command(["push", "origin", original_branch])
    print(f"  -> Pushing {release_branch} to origin...")
    run_git_command(["push", "--force", "origin", release_branch])
    print(f"  -> Pushing tag {tag_name} to origin...")
    run_git_command(["push", "--force", "origin", tag_name])


def ensure_active_branch_restored(original_branch: str) -> None:
    current_active = get_current_git_branch()
    if current_active != original_branch:
        run_git_command(["checkout", original_branch])


def execute_release_orchestration(tier: str, scope: str, has_push: bool) -> dict:
    repo_root = Path(__file__).resolve().parent.parent
    original_branch = get_current_git_branch()
    current_version = read_canonical_version(repo_root)
    next_version = calculate_next_version(current_version, tier)
    release_date = datetime.now(timezone.utc).strftime("%Y-%m-%d")

    print("\n=======================================================")
    print("  Automated Release Orchestrator & Branch Lifecycle")
    print("=======================================================")
    print(f"  Starting Branch  : {original_branch}")
    print(f"  Current Version  : {current_version}")
    print(f"  Release Tier     : {tier.upper()}")
    print(f"  Target Version   : {next_version}")
    print(f"  Release Date     : {release_date}")
    if scope:
        print(f"  Release Scope    : {scope}")
    print("-------------------------------------------------------")

    try:
        # Update version files
        update_json_version(repo_root / "version.json", next_version, release_date)
        update_json_version(repo_root / "scripts" / "version.json", next_version, release_date)
        update_json_version(repo_root / "package.json", next_version, release_date)
        update_readme_version(repo_root / "readme.md", next_version)
        update_changelog_release(repo_root / "changelog.md", next_version, release_date, scope)
        update_gitmap_release(repo_root, next_version, release_date, scope)

        # Run pre-release generators to sync registry summary, docs, completions, and aliases
        run_pre_release_generators(repo_root)

        staged_files = stage_release_files(repo_root, next_version)
        print(f"  Staged Files     : {', '.join(staged_files)}")

        commit_hash = create_release_commit(next_version, scope)
        print(f"  Release Commit   : {commit_hash} (release: v{next_version})")

        release_branch, tag_name = create_release_branch_and_tag(next_version, scope)
        print(f"  Release Branch   : {release_branch}")
        print(f"  Annotated Tag    : {tag_name}")

        if has_push:
            push_release_artifacts(original_branch, release_branch, tag_name)
            print("  Git Remote Push  : SUCCESS")
        else:
            print("  Git Remote Push  : SKIPPED (--no-push)")

        return {
            "original_branch": original_branch,
            "previous_version": current_version,
            "next_version": next_version,
            "commit_hash": commit_hash,
            "release_branch": release_branch,
            "tag_name": tag_name,
            "is_pushed": has_push,
        }
    finally:
        ensure_active_branch_restored(original_branch)
        final_branch = get_current_git_branch()
        print(f"  Restored Branch  : {final_branch}")
        print("=======================================================\n")


def main() -> None:
    args = parse_arguments()
    is_push_enabled = not args.no_push
    execute_release_orchestration(
        tier=args.tier,
        scope=args.scope,
        has_push=is_push_enabled,
    )


if __name__ == "__main__":
    main()
