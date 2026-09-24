"""Cache purge helpers for GitHub Actions storage management."""

from concurrent.futures import ThreadPoolExecutor, as_completed
import json
import subprocess
import time


def fetch_cache_batch(repo: str, page: int = 1, per_page: int = 100) -> dict | None:
    cmd = [
        "gh", "api",
        f"repos/{repo}/actions/caches?per_page={per_page}&page={page}",
        "--jq", "{total_count: .total_count, caches: [.actions_caches[] | {id: .id, key: .key, size: .size_in_bytes}]}"
    ]
    res = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")

    if res.returncode != 0:
        return None

    try:
        return json.loads(res.stdout)
    except Exception:
        return None


def delete_single_cache(repo: str, cache_id: int) -> bool:
    cmd = ["gh", "api", "-X", "DELETE", f"repos/{repo}/actions/caches/{cache_id}"]
    res = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")

    return res.returncode == 0


def delete_cache_workers(repo: str, caches: list, max_workers: int) -> tuple[int, int]:
    deleted_count = 0
    freed_bytes = 0

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_cache = {
            executor.submit(delete_single_cache, repo, c["id"]): c
            for c in caches
        }
        for future in as_completed(future_to_cache):
            c = future_to_cache[future]
            is_success = future.result()

            if is_success:
                deleted_count += 1
                freed_bytes += c.get("size", 0)

    return deleted_count, freed_bytes


def purge_repo_caches(repo: str, max_workers: int = 8) -> None:
    print(f"\n========================================================", flush=True)
    print(f" Scanning caches for repository: {repo}", flush=True)
    print(f"========================================================", flush=True)

    first_batch = fetch_cache_batch(repo, page=1, per_page=1)
    if not first_batch:
        print(f"❌ Failed to query caches for {repo} or repository not accessible.", flush=True)
        return

    total_count = first_batch.get("total_count", 0)
    print(f"Found {total_count} stored cache(s) in {repo}.", flush=True)
    if total_count == 0:
        print(f"✅ Repository {repo} has 0 stored caches.", flush=True)
        return

    deleted_count = 0
    freed_bytes = 0

    while True:
        batch = fetch_cache_batch(repo, page=1, per_page=100)
        has_items = batch and batch.get("caches")
        if not has_items:
            break

        caches = batch["caches"]
        print(f"Deleting batch of {len(caches)} cache(s)...", flush=True)
        batch_deleted, batch_freed = delete_cache_workers(repo, caches, max_workers)
        deleted_count += batch_deleted
        freed_bytes += batch_freed

        mb_freed = freed_bytes / (1024 * 1024)
        print(f"Progress: {deleted_count}/{total_count} caches deleted (~{mb_freed:.2f} MB freed)...", flush=True)
        time.sleep(0.5)

    mb_freed = freed_bytes / (1024 * 1024)
    print(f"[SUCCESS] Cache purge complete for {repo}: {deleted_count} deleted, ~{mb_freed:.2f} MB freed.", flush=True)
