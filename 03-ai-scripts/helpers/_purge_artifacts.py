"""Artifact purge helpers for GitHub Actions storage management."""

from concurrent.futures import ThreadPoolExecutor, as_completed
import json
import subprocess
import time


def fetch_artifact_batch(repo: str, page: int = 1, per_page: int = 100) -> dict | None:
    cmd = [
        "gh", "api",
        f"repos/{repo}/actions/artifacts?per_page={per_page}&page={page}",
        "--jq", "{total_count: .total_count, artifacts: [.artifacts[] | {id: .id, name: .name, size: .size_in_bytes}]}"
    ]
    res = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")

    if res.returncode != 0:
        return None

    try:
        return json.loads(res.stdout)
    except Exception:
        return None


def delete_single_artifact(repo: str, artifact_id: int) -> bool:
    cmd = ["gh", "api", "-X", "DELETE", f"repos/{repo}/actions/artifacts/{artifact_id}"]
    res = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")

    return res.returncode == 0


def delete_artifact_workers(repo: str, artifacts: list, max_workers: int) -> tuple[int, int]:
    deleted_count = 0
    freed_bytes = 0

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_art = {
            executor.submit(delete_single_artifact, repo, art["id"]): art
            for art in artifacts
        }
        for future in as_completed(future_to_art):
            art = future_to_art[future]
            is_success = future.result()

            if is_success:
                deleted_count += 1
                freed_bytes += art.get("size", 0)

    return deleted_count, freed_bytes


def purge_repo_artifacts(repo: str, max_workers: int = 12) -> None:
    print(f"\n========================================================", flush=True)
    print(f" Scanning artifacts for repository: {repo}", flush=True)
    print(f"========================================================", flush=True)

    first_batch = fetch_artifact_batch(repo, page=1, per_page=1)
    if not first_batch:
        print(f"❌ Failed to query artifacts for {repo} or repository not accessible.", flush=True)
        return

    total_count = first_batch.get("total_count", 0)
    print(f"Found {total_count} stored artifact(s) in {repo}.", flush=True)
    if total_count == 0:
        print(f"✅ Repository {repo} has 0 stored artifacts.", flush=True)
        return

    deleted_count = 0
    freed_bytes = 0

    while True:
        batch = fetch_artifact_batch(repo, page=1, per_page=100)
        has_items = batch and batch.get("artifacts")
        if not has_items:
            break

        artifacts = batch["artifacts"]
        print(f"Deleting batch of {len(artifacts)} artifact(s)...", flush=True)
        batch_deleted, batch_freed = delete_artifact_workers(repo, artifacts, max_workers)
        deleted_count += batch_deleted
        freed_bytes += batch_freed

        mb_freed = freed_bytes / (1024 * 1024)
        print(f"Progress: {deleted_count}/{total_count} artifacts deleted (~{mb_freed:.2f} MB freed)...", flush=True)
        time.sleep(0.5)

    mb_freed = freed_bytes / (1024 * 1024)
    print(f"[SUCCESS] Artifact purge complete for {repo}: {deleted_count} deleted, ~{mb_freed:.2f} MB freed.", flush=True)
