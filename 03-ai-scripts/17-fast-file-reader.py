#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
17-fast-file-reader.py - High-performance cached repository exploration tool.
Provides rapid directory listing, cached file reads, and regex pattern searches.
"""

import os
import sys
import argparse
import hashlib
import json
import re
from pathlib import Path

# Ensure UTF-8 output across platforms
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
if hasattr(sys.stderr, "reconfigure"):
    try:
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

CACHE_DIR = Path("tmp/cache")


def get_cache_path(key: str) -> Path:
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    hashed = hashlib.sha256(key.encode("utf-8")).hexdigest()
    return CACHE_DIR / f"{hashed}.json"


def list_folder(folder_path: str, extensions: list = None) -> list:
    base_dir = Path(folder_path).resolve()
    if not base_dir.exists():
        print(f"Error: Folder does not exist: {folder_path}", file=sys.stderr)
        return []

    cache_key = f"list:{base_dir}:{','.join(sorted(extensions or []))}"
    cache_file = get_cache_path(cache_key)

    # Check cache freshness against directory mtime
    try:
        dir_mtime = os.path.getmtime(base_dir)
        if cache_file.exists():
            with open(cache_file, "r", encoding="utf-8") as f:
                cached = json.load(f)
                if cached.get("mtime", 0) >= dir_mtime:
                    return cached.get("files", [])
    except Exception:
        pass

    results = []
    norm_exts = [e.lower() if e.startswith(".") else f".{e.lower()}" for e in (extensions or [])]

    for root, dirs, files in os.walk(base_dir):
        # Skip heavy/vcs directories
        dirs[:] = [d for d in dirs if d not in {".git", "node_modules", ".cache", "tmp", "vendor"}]
        for file in files:
            p = Path(root) / file
            if norm_exts and p.suffix.lower() not in norm_exts:
                continue
            rel = p.relative_to(base_dir).as_posix()
            results.append(rel)

    results.sort()

    try:
        with open(cache_file, "w", encoding="utf-8") as f:
            json.dump({"mtime": os.path.getmtime(base_dir), "files": results}, f)
    except Exception:
        pass

    return results


def read_file(file_path: str, max_bytes: int = None) -> str:
    path = Path(file_path).resolve()
    if not path.exists():
        print(f"Error: File does not exist: {file_path}", file=sys.stderr)
        return ""

    try:
        file_size = os.path.getsize(path)
        read_len = min(file_size, max_bytes) if max_bytes and max_bytes > 0 else file_size
        with open(path, "rb") as f:
            raw = f.read(read_len)
        content = raw.decode("utf-8", errors="replace")
        return content
    except Exception as e:
        print(f"Error reading file {file_path}: {e}", file=sys.stderr)
        return ""


def search_pattern(pattern: str, search_path: str = ".") -> list:
    base_dir = Path(search_path).resolve()
    if not base_dir.exists():
        print(f"Error: Search directory does not exist: {search_path}", file=sys.stderr)
        return []

    try:
        regex = re.compile(pattern, re.IGNORECASE)
    except re.error as e:
        print(f"Error compiling regex '{pattern}': {e}", file=sys.stderr)
        return []

    matches = []
    for root, dirs, files in os.walk(base_dir):
        dirs[:] = [d for d in dirs if d not in {".git", "node_modules", ".cache", "tmp", "vendor"}]
        for file in files:
            p = Path(root) / file
            if p.suffix.lower() in {".exe", ".png", ".jpg", ".jpeg", ".ico", ".bin", ".zip", ".tar", ".gz"}:
                continue
            try:
                with open(p, "r", encoding="utf-8", errors="ignore") as f:
                    for line_idx, line in enumerate(f, 1):
                        if regex.search(line):
                            rel = p.relative_to(base_dir).as_posix()
                            matches.append({
                                "file": rel,
                                "line": line_idx,
                                "content": line.strip()
                            })
            except Exception:
                pass
    return matches


def main():
    parser = argparse.ArgumentParser(description="Fast Cached Repository Explorer")
    parser.add_argument("--list-folder", type=str, help="List files within the given folder path")
    parser.add_argument("--ext", type=str, default="", help="Comma-separated extensions filter, e.g. .md,.ts")
    parser.add_argument("--read-file", type=str, help="Read contents of a file")
    parser.add_argument("--max-bytes", type=int, default=0, help="Maximum bytes to read")
    parser.add_argument("--search-pattern", type=str, help="Regex pattern to search across files")
    parser.add_argument("--path", type=str, default=".", help="Base path for search or list")

    args = parser.parse_args()

    if args.list_folder:
        exts = [e.strip() for e in args.ext.split(",") if e.strip()] if args.ext else []
        items = list_folder(args.list_folder, exts)
        for item in items:
            print(item)
    elif args.read_file:
        content = read_file(args.read_file, args.max_bytes if args.max_bytes > 0 else None)
        sys.stdout.write(content)
        if content and not content.endswith("\n"):
            sys.stdout.write("\n")
    elif args.search_pattern:
        results = search_pattern(args.search_pattern, args.path)
        for r in results:
            print(f"{r['file']}:{r['line']}: {r['content']}")
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
