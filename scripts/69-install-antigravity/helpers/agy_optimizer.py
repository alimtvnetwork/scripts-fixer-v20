#!/usr/bin/env python3
"""
Antigravity Optimizer & SQLite Conversation Pruner Engine.

Cross-platform utility (Windows, Linux, macOS) for analyzing, pruning,
and optimizing Antigravity conversation databases, Electron/GPU caches,
and Gemini brain directories.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import sqlite3
import sys
import tempfile
import time
import urllib.parse
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, List, Optional, Tuple

# Cross-platform ANSI terminal color palette and safe UTF-8 output
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

if sys.platform == "win32":
    os.system("")  # Initialize Windows VT100 / ANSI escape sequence handler

RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
CYAN = "\033[96m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
MAGENTA = "\033[95m"
WHITE = "\033[97m"
BLUE = "\033[94m"
RED = "\033[91m"
GRAY = "\033[90m"


@dataclass
class ConversationInfo:
    conversation_id: str
    db_path: str
    file_size: int
    title: str
    preview: str
    workspace_uri: str
    project_slug: str
    step_count: int
    is_heavy: bool
    mtime: float = 0.0
    is_preserved: bool = False


@dataclass
class BrainCleanupItem:
    category: str
    path: str
    file_count: int
    total_bytes: int


def get_gemini_base_dir() -> Path:
    return Path.home() / ".gemini" / "antigravity"


def get_cache_directories() -> List[Path]:
    dirs: List[Path] = []
    appdata = os.environ.get("APPDATA")
    localappdata = os.environ.get("LOCALAPPDATA")
    home = Path.home()

    sub_dirs = [
        "Cache",
        "Code Cache",
        "GPUCache",
        "DawnGraphiteCache",
        "DawnWebGPUCache",
        "blob_storage",
        "Session Storage",
        "Shared Dictionary",
        "Crashpad",
    ]

    if appdata:
        roaming = Path(appdata) / "Antigravity"
        for sub in sub_dirs:
            dirs.append(roaming / sub)

    if localappdata:
        dirs.append(Path(localappdata) / "Antigravity" / "Cache")
        dirs.append(Path(localappdata) / "Antigravity" / "Crashpad")
        dirs.append(Path(localappdata) / "antigravity-updater")

    for sub in sub_dirs:
        dirs.append(home / ".config" / "Antigravity" / sub)
        dirs.append(home / ".config" / "antigravity" / sub)

    dirs.append(home / ".cache" / "antigravity")
    dirs.append(home / ".local" / "share" / "antigravity-updater")

    mac_app_support = home / "Library" / "Application Support" / "Antigravity"
    for sub in sub_dirs:
        dirs.append(mac_app_support / sub)

    dirs.append(home / "Library" / "Caches" / "Antigravity")
    dirs.append(home / "Library" / "Caches" / "com.google.antigravity")

    return dirs


def scan_app_cache_items() -> List[BrainCleanupItem]:
    cache_dirs = get_cache_directories()
    items: List[BrainCleanupItem] = []
    seen: set[str] = set()

    for d in cache_dirs:
        str_path = str(d.resolve()) if d.exists() else str(d)
        if str_path in seen:
            continue
        seen.add(str_path)

        if not d.is_dir():
            continue

        cnt, bsz = get_dir_stats(d)
        if cnt > 0:
            parent_name = d.parent.name
            cat_name = (
                f"AppCache ({parent_name}/{d.name})"
                if parent_name in ("Antigravity", "antigravity")
                else f"AppCache ({d.name})"
            )
            items.append(BrainCleanupItem(category=cat_name, path=str(d), file_count=cnt, total_bytes=bsz))

    return items


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


def get_backup_db_path() -> Path:
    backup_dir = Path.home() / ".scripts-fixer"
    backup_dir.mkdir(parents=True, exist_ok=True)
    return backup_dir / "antigravity-backup.db"


def init_backup_database(db_path: Path) -> None:
    conn = sqlite3.connect(str(db_path))
    c = conn.cursor()
    c.execute(
        """
        CREATE TABLE IF NOT EXISTS prune_transactions (
            transaction_id TEXT PRIMARY KEY,
            timestamp TEXT,
            conversation_id TEXT,
            workspace_uri TEXT,
            project_slug TEXT,
            original_size INTEGER,
            pruned_size INTEGER,
            steps_archived INTEGER,
            status TEXT
        )
        """
    )
    c.execute(
        """
        CREATE TABLE IF NOT EXISTS pruned_steps (
            transaction_id TEXT,
            conversation_id TEXT,
            idx INTEGER,
            step_type INTEGER,
            status INTEGER,
            step_payload BLOB,
            metadata BLOB,
            gen_metadata_data BLOB,
            gen_metadata_size INTEGER,
            PRIMARY KEY (transaction_id, conversation_id, idx)
        )
        """
    )
    conn.commit()
    conn.close()


def extract_project_slug(workspace_uri: str) -> str:
    if not workspace_uri:
        return "unknown"
    try:
        parsed = urllib.parse.unquote(workspace_uri)
        clean = parsed.rstrip("/").split("/")[-1]
        clean = clean.replace("file://", "").strip(":").strip('"]').strip('["').strip('"').strip("'")
        return clean or "unknown"
    except Exception:
        return "unknown"


def load_conversation_summaries(gemini_dir: Path) -> dict[str, dict[str, Any]]:
    summaries_db = gemini_dir / "conversation_summaries.db"
    if not summaries_db.is_file():
        return {}
    results: dict[str, dict[str, Any]] = {}
    try:
        conn = sqlite3.connect(f"file:{summaries_db}?mode=ro", uri=True)
        c = conn.cursor()
        query = "SELECT conversation_id, title, preview, step_count, workspace_uris, last_modified_time FROM conversation_summaries"
        for row in c.execute(query).fetchall():
            cid, title, prev, sc, w_uris, last_mod = row
            results[cid] = {
                "title": title or "",
                "preview": prev or "",
                "step_count": sc or 0,
                "workspace_uris": w_uris or "",
                "last_modified_time": last_mod or "",
            }
        conn.close()
    except Exception:
        pass
    return results


def discover_conversations(threshold_bytes: int = 200 * 1024, keep_count: int = 0) -> List[ConversationInfo]:
    gemini_dir = get_gemini_base_dir()
    conv_dir = gemini_dir / "conversations"
    if not conv_dir.is_dir():
        return []

    summaries = load_conversation_summaries(gemini_dir)
    conversations: List[ConversationInfo] = []

    for item in conv_dir.glob("*.db"):
        cid = item.stem
        try:
            st = item.stat()
            sz = st.st_size
            mtime = st.st_mtime
        except OSError:
            continue

        meta = summaries.get(cid, {})
        w_uris = meta.get("workspace_uris", "")
        slug = extract_project_slug(w_uris)

        conversations.append(
            ConversationInfo(
                conversation_id=cid,
                db_path=str(item),
                file_size=sz,
                title=meta.get("title", ""),
                preview=meta.get("preview", ""),
                workspace_uri=w_uris,
                project_slug=slug,
                step_count=meta.get("step_count", 0),
                is_heavy=False,
                mtime=mtime,
                is_preserved=False,
            )
        )

    # Sort conversations by recency (last_modified_time or mtime descending)
    conversations.sort(
        key=lambda x: (
            summaries.get(x.conversation_id, {}).get("last_modified_time") or "",
            x.mtime,
        ),
        reverse=True,
    )

    for idx, conv in enumerate(conversations):
        if keep_count > 0 and idx < keep_count:
            conv.is_preserved = True
            conv.is_heavy = False
        else:
            conv.is_preserved = False
            conv.is_heavy = (conv.file_size >= threshold_bytes)

    return conversations


def scan_brain_cleanup_items(
    protected_cids: Optional[set[str]] = None,
    cid_to_slug: Optional[dict[str, str]] = None,
) -> List[BrainCleanupItem]:
    gemini_dir = get_gemini_base_dir()
    items: List[BrainCleanupItem] = []
    protected = protected_cids or set()
    slug_map = cid_to_slug or {}

    static_targets = [
        ("Crashes", gemini_dir / "crashes"),
        ("Logs", gemini_dir / "log"),
        ("TempMedia", gemini_dir / "brain" / "tempmediaStorage"),
        ("BrainCache", gemini_dir / "brain" / "cache"),
    ]
    for cat, p in static_targets:
        if not p.is_dir():
            continue

        cnt, bsz = get_dir_stats(p)
        if cnt > 0:
            items.append(BrainCleanupItem(category=cat, path=str(p), file_count=cnt, total_bytes=bsz))

    brain_dir = gemini_dir / "brain"
    if not brain_dir.is_dir():
        return items

    for cdir in brain_dir.iterdir():
        if not cdir.is_dir() or cdir.name == "tempmediaStorage":
            continue

        if cdir.name in protected:
            continue

        cid_short = cdir.name[:8]
        proj_slug = slug_map.get(cdir.name, "")
        label_suffix = f" ({cid_short}: {proj_slug[:16]})" if proj_slug and proj_slug != "unknown" else f" ({cid_short})"

        scratch = cdir / "scratch"
        if scratch.is_dir():
            cnt, bsz = get_dir_stats(scratch)
            if cnt > 0:
                items.append(BrainCleanupItem(category=f"Scratch{label_suffix}", path=str(scratch), file_count=cnt, total_bytes=bsz))

        tasks = cdir / ".system_generated" / "tasks"
        if tasks.is_dir():
            cnt, bsz = get_dir_stats(tasks)
            if cnt > 0:
                items.append(BrainCleanupItem(category=f"TaskLogs{label_suffix}", path=str(tasks), file_count=cnt, total_bytes=bsz))

    return items


def get_dir_stats(p: Path) -> Tuple[int, int]:
    cnt = 0
    total_sz = 0
    try:
        for root, _, files in os.walk(p):
            for f in files:
                fp = Path(root) / f
                try:
                    total_sz += fp.stat().st_size
                    cnt += 1
                except OSError:
                    pass
    except OSError:
        pass
    return cnt, total_sz


def format_bytes(b: int) -> str:
    if b >= 1024 * 1024 * 1024:
        return f"{b / (1024 * 1024 * 1024):.2f} GB"
    if b >= 1024 * 1024:
        return f"{b / (1024 * 1024):.2f} MB"
    if b >= 1024:
        return f"{b / 1024:.2f} KB"
    return f"{b} B"


def predict_optimization(
    threshold_bytes: int = 200 * 1024,
    keep_count: int = 0,
    min_steps: int = 0,
    filter_slug: str = "",
    as_json: bool = False,
) -> int:
    convs = discover_conversations(threshold_bytes, keep_count=keep_count)
    preserved_convs = [c for c in convs if c.is_preserved]
    older_convs = [c for c in convs if not c.is_preserved]

    cid_to_slug = {c.conversation_id: c.project_slug for c in convs}

    heavy_convs = [c for c in convs if c.is_heavy]
    if min_steps > 0:
        heavy_convs = [c for c in heavy_convs if c.step_count >= min_steps]
    if filter_slug:
        heavy_convs = [c for c in heavy_convs if filter_slug.lower() in c.project_slug.lower()]

    heavy_convs.sort(key=lambda x: x.file_size, reverse=True)

    protected_cids = {c.conversation_id for c in preserved_convs}
    brain_items = scan_brain_cleanup_items(protected_cids=protected_cids, cid_to_slug=cid_to_slug)
    cache_items = scan_app_cache_items()

    total_conv_bytes = sum(c.file_size for c in convs)
    preserved_bytes = sum(c.file_size for c in preserved_convs)
    older_bytes = sum(c.file_size for c in older_convs)
    heavy_bytes = sum(c.file_size for c in heavy_convs)

    brain_bytes = sum(b.total_bytes for b in brain_items)
    brain_files = sum(b.file_count for b in brain_items)

    cache_bytes = sum(c.total_bytes for c in cache_items)
    cache_files = sum(c.file_count for c in cache_items)

    # Projecting savings (keeping last 2 steps reduces size down to ~50-100KB per DB)
    projected_pruned_conv_bytes = len(heavy_convs) * 80 * 1024
    projected_conv_savings = max(0, heavy_bytes - projected_pruned_conv_bytes)
    projected_total_savings = projected_conv_savings + brain_bytes + cache_bytes

    if as_json:
        payload = {
            "keep_count": keep_count,
            "total_conversations": len(convs),
            "preserved_conversations_count": len(preserved_convs),
            "preserved_conversation_bytes": preserved_bytes,
            "older_conversations_count": len(older_convs),
            "older_conversation_bytes": older_bytes,
            "heavy_conversations_count": len(heavy_convs),
            "total_conversation_bytes": total_conv_bytes,
            "heavy_conversation_bytes": heavy_bytes,
            "brain_items_count": len(brain_items),
            "brain_files_count": brain_files,
            "brain_bytes": brain_bytes,
            "cache_items_count": len(cache_items),
            "cache_files_count": cache_files,
            "cache_bytes": cache_bytes,
            "projected_savings_bytes": projected_total_savings,
            "heavy_conversations": [asdict(c) for c in heavy_convs],
            "brain_items": [asdict(b) for b in brain_items],
            "cache_items": [asdict(c) for c in cache_items],
        }
        print(json.dumps(payload, indent=2))
        return 0

    print(f"\n{BOLD}{CYAN}================================================================================{RESET}")
    print(f" {BOLD}{CYAN}[==]{RESET} {BOLD}{WHITE}Antigravity Optimizer & Conversation Prediction Engine{RESET}")
    print(f"{BOLD}{CYAN}================================================================================{RESET}")

    if heavy_convs:
        print(f"\n {BOLD}{YELLOW}[==] Top Heavy Conversations to Prune:{RESET}")
        print(f"  {BOLD}{WHITE}{'CONVERSATION ID':<38} {'SLUG':<20} {'STEPS':<8} {'SIZE':<10}{RESET}")
        print(f"  {GRAY}{'-' * 78}{RESET}")
        display_heavy = heavy_convs[:15]
        for c in display_heavy:
            print(f"  {CYAN}{c.conversation_id:<38}{RESET} {WHITE}{c.project_slug[:18]:<20}{RESET} {YELLOW}{c.step_count:<8}{RESET} {GREEN}{format_bytes(c.file_size):<10}{RESET}")
        if len(heavy_convs) > len(display_heavy):
            print(f"  {GRAY}... and {len(heavy_convs) - len(display_heavy)} more heavy conversations{RESET}")

    if cache_items:
        print(f"\n {BOLD}{YELLOW}[==] Antigravity Application Caches to Scrub (Electron / GPU / Code Cache):{RESET}")
        print(f"  {BOLD}{WHITE}{'CACHE TARGET':<42} {'FILES':<8} {'SIZE':<10}{RESET}")
        print(f"  {GRAY}{'-' * 62}{RESET}")
        for c in cache_items:
            print(f"  {CYAN}{c.category:<42}{RESET} {YELLOW}{c.file_count:<8}{RESET} {GREEN}{format_bytes(c.total_bytes):<10}{RESET}")

    if brain_items:
        print(f"\n {BOLD}{YELLOW}[==] Gemini Brain Cleanup Targets:{RESET}")
        print(f"  {BOLD}{WHITE}{'CATEGORY':<42} {'FILES':<8} {'SIZE':<10}{RESET}")
        print(f"  {GRAY}{'-' * 62}{RESET}")
        display_brain = brain_items[:15]
        for b in display_brain:
            print(f"  {CYAN}{b.category:<42}{RESET} {YELLOW}{b.file_count:<8}{RESET} {GREEN}{format_bytes(b.total_bytes):<10}{RESET}")
        if len(brain_items) > len(display_brain):
            print(f"  {GRAY}... and {len(brain_items) - len(display_brain)} more brain directories{RESET}")

    # Summary box placed at the end as requested
    print(f"\n{BOLD}{CYAN}================================================================================{RESET}")
    print(f" {BOLD}{GREEN}[*] DISK SPACE RECLAMATION & CONVERSATION SUMMARY{RESET}")
    print(f"{BOLD}{CYAN}================================================================================{RESET}")
    print(f"  {BOLD}{WHITE}Total Conversations Scanned  :{RESET} {BOLD}{CYAN}{len(convs)}{RESET} {DIM}({format_bytes(total_conv_bytes)}){RESET}")
    if keep_count > 0:
        print(f"  {BOLD}{WHITE}Retention Policy             :{RESET} {BOLD}{YELLOW}Keeping latest {keep_count} conversations intact{RESET}")
        print(f"  {BOLD}{WHITE}Preserved Recent Convs       :{RESET} {BOLD}{GREEN}{len(preserved_convs)}{RESET} {DIM}({format_bytes(preserved_bytes)}){RESET}")
        print(f"  {BOLD}{WHITE}Older Convs Scanned          :{RESET} {BOLD}{CYAN}{len(older_convs)}{RESET} {DIM}({format_bytes(older_bytes)}){RESET}")
    print(f"  {BOLD}{WHITE}Heavy Older Convs (> {format_bytes(threshold_bytes)})  :{RESET} {BOLD}{YELLOW}{len(heavy_convs)}{RESET} {DIM}({format_bytes(heavy_bytes)}){RESET}")
    print(f"  {BOLD}{WHITE}Application Cache Targets    :{RESET} {BOLD}{CYAN}{len(cache_items)} folders{RESET}, {YELLOW}{cache_files} files{RESET} {DIM}({format_bytes(cache_bytes)}){RESET}")
    print(f"  {BOLD}{WHITE}Gemini Brain Cleanup Targets :{RESET} {BOLD}{CYAN}{len(brain_items)} folders{RESET}, {YELLOW}{brain_files} files{RESET} {DIM}({format_bytes(brain_bytes)}){RESET}")
    print(f"  {GRAY}{'-' * 80}{RESET}")
    print(f"  {BOLD}{WHITE}PROJECTED DISK RECLAMATION   :{RESET} {BOLD}{GREEN}~{format_bytes(projected_total_savings)}{RESET}")
    if keep_count > 0:
        print(f"  {GRAY}{'-' * 80}{RESET}")
        print(f"  {MAGENTA}Preserved Storage Insight    :{RESET} {format_bytes(preserved_bytes)} remains in the latest {keep_count} active conversations.")
        print(f"                                 Use --keep 5 to prune more, or --keep 0 to prune all heavy.")
    print(f"{BOLD}{CYAN}================================================================================{RESET}")

    print(f"\n {BOLD}{YELLOW}[TIP] Undo / Rollback Capability:{RESET}")
    print(f"  Pruned conversation steps are backed up to {CYAN}~/.scripts-fixer/antigravity-backup.db{RESET}.")
    print(f"  To revert any operation after applying, simply run:")
    print(f"    {BOLD}{CYAN}./run agy undo latest{RESET}")
    print(f"    {BOLD}{CYAN}./run agy undo <transaction_id>{RESET}")
    print(f"    {BOLD}{CYAN}./run agy list-backups{RESET}")
    print(f"\n {BOLD}{YELLOW}[TIP] Advanced Filtering & Space Reclamation Options:{RESET}")
    print(f"  Filter by min steps : {CYAN}./run agy clear --keep 10 --min-steps 200{RESET}")
    print(f"  Filter by min size  : {CYAN}./run agy clear --keep 10 --threshold 500{RESET}")
    print(f"  Apply optimization  : {GREEN}./run agy clear --keep 10 -y{RESET}")
    print(f"  Scrub caches & kill : {RED}./run agy clear --keep 10 -y --kill{RESET}")

    print(f"\n{BOLD}{CYAN}================================================================================{RESET}")
    print(f" {BOLD}{MAGENTA}[NOTE] Prediction mode active. No Antigravity processes killed. No files modified.{RESET}")
    print(f"{BOLD}{CYAN}================================================================================{RESET}\n")
    return 0


def prune_conversation(c_info: ConversationInfo, keep_turns: int = 2) -> Optional[dict[str, Any]]:
    db_path = Path(c_info.db_path)
    if not db_path.is_file():
        return None

    backup_db = get_backup_db_path()
    init_backup_database(backup_db)

    tx_id = f"tx_{int(time.time())}_{c_info.conversation_id[:8]}"
    timestamp = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

    conn_target = sqlite3.connect(str(db_path))
    c_target = conn_target.cursor()

    # Get max step idx
    try:
        c_target.execute("SELECT MAX(idx) FROM steps")
        max_idx_row = c_target.fetchone()
        max_idx = max_idx_row[0] if max_idx_row and max_idx_row[0] is not None else 0
    except Exception as e:
        conn_target.close()
        return None

    cutoff_idx = max(0, max_idx - keep_turns)
    if cutoff_idx <= 0:
        conn_target.close()
        return None

    # Fetch steps to archive
    try:
        c_target.execute(
            """
            SELECT idx, step_type, status, step_payload, metadata, gen_metadata_data, gen_metadata_size
            FROM steps WHERE idx < ?
            """,
            (cutoff_idx,),
        )
        prune_rows = c_target.fetchall()
    except Exception:
        # Fallback if gen_metadata columns do not exist
        c_target.execute(
            """
            SELECT idx, step_type, status, step_payload, metadata, NULL, 0
            FROM steps WHERE idx < ?
            """,
            (cutoff_idx,),
        )
        prune_rows = c_target.fetchall()

    if not prune_rows:
        conn_target.close()
        return None

    # Archive into backup db
    conn_backup = sqlite3.connect(str(backup_db))
    c_backup = conn_backup.cursor()

    for row in prune_rows:
        idx, stype, stat, payload, meta, gm_data, gm_size = row
        c_backup.execute(
            """
            INSERT OR REPLACE INTO pruned_steps
            (transaction_id, conversation_id, idx, step_type, status, step_payload, metadata, gen_metadata_data, gen_metadata_size)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (tx_id, c_info.conversation_id, idx, stype, stat, payload, meta, gm_data, gm_size),
        )

    # Delete from target DB
    c_target.execute("DELETE FROM steps WHERE idx < ?", (cutoff_idx,))
    conn_target.commit()

    # Vacuum target DB
    try:
        c_target.execute("VACUUM")
    except Exception:
        pass
    conn_target.close()

    new_sz = db_path.stat().st_size
    steps_archived = len(prune_rows)

    c_backup.execute(
        """
        INSERT INTO prune_transactions
        (transaction_id, timestamp, conversation_id, workspace_uri, project_slug, original_size, pruned_size, steps_archived, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (tx_id, timestamp, c_info.conversation_id, c_info.workspace_uri, c_info.project_slug, c_info.file_size, new_sz, steps_archived, "applied"),
    )
    conn_backup.commit()
    conn_backup.close()

    return {
        "transaction_id": tx_id,
        "conversation_id": c_info.conversation_id,
        "original_size": c_info.file_size,
        "pruned_size": new_sz,
        "steps_archived": steps_archived,
    }


def undo_transaction(transaction_id: Optional[str]) -> bool:
    backup_db = get_backup_db_path()
    if not backup_db.is_file():
        print(f"Backup database not found: {backup_db}")
        return False

    conn_backup = sqlite3.connect(str(backup_db))
    c_backup = conn_backup.cursor()

    target_tx = transaction_id
    if not target_tx or target_tx.strip().lower() in ("latest", "last"):
        c_backup.execute(
            "SELECT transaction_id FROM prune_transactions WHERE status != 'reverted' ORDER BY timestamp DESC LIMIT 1"
        )
        row = c_backup.fetchone()
        if not row:
            print("  [WARN] No active (non-reverted) prune transactions found to undo.")
            conn_backup.close()
            return False

        target_tx = row[0]
        print(f"  [INFO] Resolved 'latest' to transaction: {target_tx}")

    c_backup.execute(
        "SELECT conversation_id, status FROM prune_transactions WHERE transaction_id = ?",
        (target_tx,),
    )
    tx = c_backup.fetchone()
    if not tx:
        print(f"  [XX] Transaction not found: {target_tx}")
        conn_backup.close()
        return False

    cid, status = tx
    if status == "reverted":
        print(f"  [INFO] Transaction {target_tx} was already reverted.")
        conn_backup.close()
        return True

    target_db = get_gemini_base_dir() / "conversations" / f"{cid}.db"
    if not target_db.is_file():
        print(f"  [XX] Target conversation database missing: {target_db}")
        conn_backup.close()
        return False

    # Fetch archived steps
    c_backup.execute(
        "SELECT idx, step_type, status, step_payload, metadata FROM pruned_steps WHERE transaction_id = ?",
        (target_tx,),
    )
    archived_steps = c_backup.fetchall()

    conn_target = sqlite3.connect(str(target_db))
    c_target = conn_target.cursor()
    for s in archived_steps:
        idx, stype, stat, payload, meta = s
        c_target.execute(
            """
            INSERT OR REPLACE INTO steps (idx, step_type, status, step_payload, metadata)
            VALUES (?, ?, ?, ?, ?)
            """,
            (idx, stype, stat, payload, meta),
        )

    conn_target.commit()
    c_target.execute("VACUUM")
    conn_target.close()

    c_backup.execute(
        "UPDATE prune_transactions SET status = 'reverted' WHERE transaction_id = ?",
        (target_tx,),
    )
    conn_backup.commit()
    conn_backup.close()

    print(f"  [OK] Successfully reverted transaction {target_tx} ({len(archived_steps)} steps restored).")
    return True


def backup_and_clean_brain_items(items: List[BrainCleanupItem], is_apply: bool = False) -> Tuple[int, str]:
    temp_dir = Path(tempfile.gettempdir()) / "antigravity-brain-backup"
    ts = time.strftime("%Y%m%d_%H%M%S")
    backup_bundle = temp_dir / ts
    backup_bundle.mkdir(parents=True, exist_ok=True)

    manifest: List[dict[str, Any]] = []
    freed_bytes = 0

    for item in items:
        src = Path(item.path)
        if not src.exists():
            continue

        rel_dest = backup_bundle / item.category.replace(" ", "_").replace("(", "").replace(")", "").replace(":", "_")
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
        except Exception as e:
            print(f"  [WARN] Failed to process {src}: {e}")

    with open(backup_bundle / "manifest.json", "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)

    return freed_bytes, str(backup_bundle)


def apply_optimization(
    threshold_bytes: int = 200 * 1024,
    keep_count: int = 0,
    keep_turns: int = 2,
    min_steps: int = 0,
    filter_slug: str = "",
) -> int:
    convs = discover_conversations(threshold_bytes, keep_count=keep_count)
    preserved_convs = [c for c in convs if c.is_preserved]
    heavy_convs = [c for c in convs if c.is_heavy]

    if min_steps > 0:
        heavy_convs = [c for c in heavy_convs if c.step_count >= min_steps]
    if filter_slug:
        heavy_convs = [c for c in heavy_convs if filter_slug.lower() in c.project_slug.lower()]

    protected_cids = {c.conversation_id for c in preserved_convs}
    cid_to_slug = {c.conversation_id: c.project_slug for c in convs}
    brain_items = scan_brain_cleanup_items(protected_cids=protected_cids, cid_to_slug=cid_to_slug)
    cache_items = scan_app_cache_items()

    print(f"\n{BOLD}{CYAN}================================================================================{RESET}")
    print(f" {BOLD}{CYAN}[==]{RESET} {BOLD}{WHITE}Applying Antigravity Optimization & Conversation Pruning{RESET}")
    print(f"{BOLD}{CYAN}================================================================================{RESET}")
    if keep_count > 0:
        print(f"  {WHITE}Retention Policy        :{RESET} {BOLD}{YELLOW}Keeping latest {keep_count} conversations intact{RESET}")
        print(f"  {WHITE}Preserved Conversations :{RESET} {BOLD}{GREEN}{len(preserved_convs)}{RESET}")
    print(f"  {WHITE}Heavy Conversations     :{RESET} {BOLD}{YELLOW}{len(heavy_convs)}{RESET} will be pruned (latest {keep_turns} turns kept)")
    print(f"  {WHITE}Brain Cleanup Items     :{RESET} {BOLD}{CYAN}{len(brain_items)}{RESET} directories backed up to OS temp")
    print(f"  {WHITE}Application Caches      :{RESET} {BOLD}{CYAN}{len(cache_items)}{RESET} cache directories to scrub")
    print(f"  {GRAY}{'-' * 80}{RESET}\n")

    pruned_results = []
    for c in heavy_convs:
        res = prune_conversation(c, keep_turns=keep_turns)
        if res:
            pruned_results.append(res)
            print(f"  {GREEN}[OK]{RESET} Pruned {CYAN}{c.conversation_id[:16]}...{RESET} ({WHITE}{c.project_slug}{RESET}): {YELLOW}{format_bytes(res['original_size'])}{RESET} -> {GREEN}{format_bytes(res['pruned_size'])}{RESET}")

    freed_brain, backup_bundle = backup_and_clean_brain_items(brain_items, is_apply=True)
    freed_cache_files, freed_cache_bytes = clean_app_cache_items(cache_items, is_apply=True)

    print(f"\n  {GREEN}[OK]{RESET} Gemini brain items backed up to: {CYAN}{backup_bundle}{RESET}")
    print(f"       Brain space reclaimed: {BOLD}{GREEN}{format_bytes(freed_brain)}{RESET}")
    print(f"  {GREEN}[OK]{RESET} Application caches scrubbed: {CYAN}{freed_cache_files} files{RESET} ({BOLD}{GREEN}{format_bytes(freed_cache_bytes)}{RESET})")

    freed_conv_bytes = sum(r["original_size"] - r["pruned_size"] for r in pruned_results)
    total_freed_bytes = freed_conv_bytes + freed_brain + freed_cache_bytes

    print(f"\n{BOLD}{CYAN}================================================================================{RESET}")
    print(f" {BOLD}{GREEN}[*] DISK SPACE RECLAMATION COMPLETED{RESET}")
    print(f"{BOLD}{CYAN}================================================================================{RESET}")
    print(f"  {BOLD}{WHITE}Conversations Pruned        :{RESET} {BOLD}{CYAN}{len(pruned_results)}{RESET} {DIM}({format_bytes(freed_conv_bytes)} saved){RESET}")
    print(f"  {BOLD}{WHITE}Brain Artifacts Reclaimed   :{RESET} {BOLD}{CYAN}{len(brain_items)} dirs{RESET} {DIM}({format_bytes(freed_brain)} saved){RESET}")
    print(f"  {BOLD}{WHITE}Application Caches Scrubbed :{RESET} {BOLD}{CYAN}{freed_cache_files} files{RESET} {DIM}({format_bytes(freed_cache_bytes)} saved){RESET}")
    print(f"  {GRAY}{'-' * 80}{RESET}")
    print(f"  {BOLD}{WHITE}TOTAL DISK SPACE RECLAIMED  :{RESET} {BOLD}{GREEN}{format_bytes(total_freed_bytes)}{RESET}")
    print(f"{BOLD}{CYAN}================================================================================{RESET}")

    latest_tx = pruned_results[0]["transaction_id"] if pruned_results else "latest"
    print(f"\n {BOLD}{YELLOW}[TIP] Undo / Rollback Capability:{RESET}")
    print(f"  To revert conversations from this operation, run:")
    print(f"    {BOLD}{CYAN}./run agy undo {latest_tx}{RESET}")
    print(f"    {BOLD}{CYAN}./run agy undo latest{RESET}")
    print(f" {BOLD}{MAGENTA}[!!] NOTE: Brain backups are in OS temp and will expire based on OS temp policies.{RESET}\n")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Antigravity Optimizer & Conversation Pruning Engine")
    parser.add_argument("--predict", action="store_true", help="Predict optimization savings without modifying files")
    parser.add_argument("--dry-run", action="store_true", help="Alias for --predict")
    parser.add_argument("--yes", "-y", action="store_true", help="Apply optimization changes")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")
    parser.add_argument("--threshold", type=int, default=200, help="Conversation size threshold in KB (default: 200)")
    parser.add_argument("--keep", "-k", type=int, default=0, help="Number of latest conversations to keep intact (e.g. 5, 10)")
    parser.add_argument("count", nargs="?", type=int, default=None, help="Optional positional conversation retention count (e.g. 10)")
    parser.add_argument("--keep-turns", type=int, default=2, help="Number of latest conversation turns to preserve (default: 2)")
    parser.add_argument("--min-steps", type=int, default=0, help="Filter conversations with at least N steps")
    parser.add_argument("--filter-slug", type=str, default="", help="Filter conversations by project slug substring")
    parser.add_argument("--undo", nargs="?", const="latest", type=str, help="Undo a specific transaction ID or 'latest'")
    parser.add_argument("--list-backups", action="store_true", help="List all backup transactions")

    args = parser.parse_args()
    threshold_bytes = args.threshold * 1024

    keep_count = args.keep
    if keep_count == 0 and args.count is not None:
        keep_count = args.count

    if args.undo is not None:
        return 0 if undo_transaction(args.undo) else 1

    if args.list_backups:
        backup_db = get_backup_db_path()
        if not backup_db.is_file():
            print("No backup database found.")
            return 0
        conn = sqlite3.connect(str(backup_db))
        c = conn.cursor()
        print(f"{'TX ID':<26} {'TIMESTAMP':<22} {'CONVERSATION ID':<38} {'SLUG':<16} {'STATUS':<10}")
        print("-" * 115)
        for r in c.execute("SELECT transaction_id, timestamp, conversation_id, project_slug, status FROM prune_transactions"):
            print(f"{r[0]:<26} {r[1]:<22} {r[2]:<38} {r[3][:15]:<16} {r[4]:<10}")
        conn.close()
        return 0

    if args.yes:
        return apply_optimization(
            threshold_bytes=threshold_bytes,
            keep_count=keep_count,
            keep_turns=args.keep_turns,
            min_steps=args.min_steps,
            filter_slug=args.filter_slug,
        )

    # Default to predict mode
    return predict_optimization(
        threshold_bytes=threshold_bytes,
        keep_count=keep_count,
        min_steps=args.min_steps,
        filter_slug=args.filter_slug,
        as_json=args.json,
    )


if __name__ == "__main__":
    sys.exit(main())
