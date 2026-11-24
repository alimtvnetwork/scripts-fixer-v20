#!/usr/bin/env python3
"""
Test Chunk Download Verification Script

Verifies chunk downloading from GitLab API raw endpoint with an explicit timeout,
progress reporting, SHA-256 verification, and automatic cleanup.
"""

import argparse
import hashlib
import os
import sys
import tempfile
import time
import urllib.request
import urllib.error

PROJECT_CHUNKS = {
    "gitmap": {
        "url": (
            "https://gitlab.com/api/v4/projects/rup-gitlab%2Fdeploy-gitmap/"
            "repository/files/releases%2Fv6.693.0%2Fwindows-amd64%2Fgitmap-windows-amd64.7z.001/raw"
        ),
        "sha256": "dc360b26a095294e07226669ed904e43fedeee5d3311fbe1116eb895c250d215",
        "size": 8388608,
    },
    "agm": {
        "url": (
            "https://gitlab.com/api/v4/projects/rup-gitlab%2Fdeploy-antigravity-manager/"
            "repository/files/releases%2Fv5.55.0%2Fwindows-amd64%2Fagm-windows-amd64.7z.001/raw"
        ),
        "sha256": "5dfedf96ae5f2df9634543e271218f2b4e7823a1d17ce68aafb4e11d4d99e8af",
        "size": 5242880,
    },
}
TIMEOUT_DEFAULT = 30


def run_chunk_download_test(url: str, expected_size: int = None, expected_sha: str = None, timeout: int = TIMEOUT_DEFAULT) -> bool:
    print(f"=== GitLab API Chunk Download Test ===")
    print(f"Target URL: {url}")
    print(f"Timeout:    {timeout}s")
    if expected_size:
        print(f"Expected:   {expected_size} bytes")

    temp_dir = tempfile.gettempdir()
    dest_path = os.path.join(temp_dir, f"test-chunk-{int(time.time())}.001")

    start_time = time.time()
    try:
        req = urllib.request.Request(
            url,
            headers={"User-Agent": "GitMap-Deploy-Verifier/1.0"}
        )

        print("Connecting...", flush=True)
        with urllib.request.urlopen(req, timeout=timeout) as response:
            status_code = response.getcode()
            headers = dict(response.info())
            content_length = int(headers.get("Content-Length", 0))
            print(f"HTTP Status: {status_code}")
            print(f"Content-Length: {content_length} bytes")

            hasher = hashlib.sha256()
            downloaded = 0
            with open(dest_path, "wb") as f:
                while True:
                    chunk = response.read(64 * 1024)
                    if not chunk:
                        break
                    f.write(chunk)
                    hasher.update(chunk)
                    downloaded += len(chunk)

            elapsed = time.time() - start_time
            actual_sha256 = hasher.hexdigest().lower()

            print(f"Downloaded:  {downloaded} bytes in {elapsed:.2f}s ({downloaded / elapsed / 1024 / 1024:.2f} MB/s)")
            print(f"SHA-256:     {actual_sha256}")

            is_ok = True
            if expected_size and downloaded != expected_size:
                print(f"✗ FAIL: Size mismatch (got {downloaded}, expected {expected_size})")
                is_ok = False
            if expected_sha and actual_sha256 != expected_sha.lower():
                print(f"✗ FAIL: SHA-256 mismatch (got {actual_sha256}, expected {expected_sha})")
                is_ok = False

            if is_ok:
                print("✓ PASS: Download completed and verified successfully!")
            return is_ok

    except urllib.error.HTTPError as e:
        print(f"✗ HTTP Error {e.code}: {e.reason}", file=sys.stderr)
        return False
    except urllib.error.URLError as e:
        print(f"✗ URL/Connection Error: {e.reason}", file=sys.stderr)
        return False
    except TimeoutError:
        print(f"✗ Timeout: Download exceeded {timeout}s limit", file=sys.stderr)
        return False
    except Exception as e:
        print(f"✗ Unexpected Error: {e}", file=sys.stderr)
        return False
    finally:
        if os.path.exists(dest_path):
            try:
                os.remove(dest_path)
                print(f"Cleaned up temporary file: {dest_path}")
            except OSError:
                pass


def main():
    parser = argparse.ArgumentParser(description="GitLab API chunk download test verifier")
    parser.add_argument("--project", choices=["gitmap", "agm"], default="gitmap", help="Target project")
    parser.add_argument("--url", default="", help="Custom download URL override")
    parser.add_argument("--timeout", type=int, default=TIMEOUT_DEFAULT, help="Network timeout in seconds")
    args = parser.parse_args()

    cfg = PROJECT_CHUNKS.get(args.project, PROJECT_CHUNKS["gitmap"])
    url = args.url if args.url else cfg["url"]
    expected_size = cfg["size"] if not args.url else None
    expected_sha = cfg["sha256"] if not args.url else None

    ok = run_chunk_download_test(url=url, expected_size=expected_size, expected_sha=expected_sha, timeout=args.timeout)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
