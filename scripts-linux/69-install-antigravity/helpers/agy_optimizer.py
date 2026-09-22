#!/usr/bin/env python3
"""
Antigravity Optimizer & SQLite Conversation Pruner Engine.

Cross-platform utility (Windows, Linux, macOS) for analyzing, pruning,
and optimizing Antigravity conversation databases and Gemini brain directories.
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

    if appdata:
        roaming = Path(appdata) / "Antigravity"
        for sub in [
            "Cache",
            "Code Cache",
            "GPUCache",
            "DawnGraphiteCache",
            "DawnWebGPUCache",
            "blob_storage",
            "Session Storage",
        ]:
            dirs.append(roaming / sub)

    if localappdata:
        dirs.append(Path(localappdata) / "Antigravity" / "Cache")
        dirs.append(Path(localappdata) / "antigravity-updater")

    # Linux standard paths
    dirs.append(home / ".config" / "Antigravity" / "Cache")
    dirs.append(home / ".config" / "Antigravity" / "Code Cache")
    dirs.append(home / ".config" / "Antigravity" / "GPUCache")
    dirs.append(home / ".cache" / "antigravity")
    dirs.append(home / ".local" / "share" / "antigravity-updater")

    # macOS standard paths
    mac_app_support = home / "Library" / "Application Support" / "Antigravity"
    for sub in [
        "Cache",
        "Code Cache",
        "GPUCache",
        "DawnGraphiteCache",
        "DawnWebGPUCache",
        "blob_storage",
        "Session Storage",
    ]:
        dirs.append(mac_app_support / sub)

    dirs.append(home / "Library" / "Caches" / "Antigravity")
    dirs.append(home / "Library" / "Caches" / "com.google.antigravity")

    return dirs


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


def scan_brain_cleanup_items(protected_cids: Optional[set[str]] = None) -> List[BrainCleanupItem]:
    gemini_dir = get_gemini_base_dir()
    items: List[BrainCleanupItem] = []
    protected = protected_cids or set()

    # Static targets
    static_targets = [
        ("Crashes", gemini_dir / "crashes"),
        ("Logs", gemini_dir / "log"),
        ("TempMedia", gemini_dir / "brain" / "tempmediaStorage"),
        ("BrainCache", gemini_dir / "brain" / "cache"),
    ]
    for cat, p in static_targets:
        if p.is_dir():
            cnt, bsz = get_dir_stats(p)
            if cnt > 0:
                items.append(BrainCleanupItem(category=cat, path=str(p), file_count=cnt, total_bytes=bsz))

    # Dynamic conversation scratch and tasks
    brain_dir = gemini_dir / "brain"
    if brain_dir.is_dir():
        for cdir in brain_dir.iterdir():
            if not cdir.is_dir() or cdir.name == "tempmediaStorage":
                continue
            if cdir.name in protected:
                continue
            scratch = cdir / "scratch"
            if scratch.is_dir():
                cnt, bsz = get_dir_stats(scratch)
                if cnt > 0:
                    items.append(BrainCleanupItem(category=f"Scratch ({cdir.name[:8]})", path=str(scratch), file_count=cnt, total_bytes=bsz))
            tasks = cdir / ".system_generated" / "tasks"
            if tasks.is_dir():
                cnt, bsz = get_dir_stats(tasks)
                if cnt > 0:
                    items.append(BrainCleanupItem(category=f"TaskLogs ({cdir.name[:8]})", path=str(tasks), file_count=cnt, total_bytes=bsz))

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


def predict_optimization(threshold_bytes: int = 200 * 1024, keep_count: int = 0, as_json: bool = False) -> int:
    convs = discover_conversations(threshold_bytes, keep_count=keep_count)
    preserved_convs = [c for c in convs if c.is_preserved]
    older_convs = [c for c in convs if not c.is_preserved]
    heavy_convs = [c for c in convs if c.is_heavy]
    heavy_convs.sort(key=lambda x: x.file_size, reverse=True)

    protected_cids = {c.conversation_id for c in preserved_convs}
    brain_items = scan_brain_cleanup_items(protected_cids=protected_cids)

    total_conv_bytes = sum(c.file_size for c in convs)
    preserved_bytes = sum(c.file_size for c in preserved_convs)
    older_bytes = sum(c.file_size for c in older_convs)
    heavy_bytes = sum(c.file_size for c in heavy_convs)
    brain_bytes = sum(b.total_bytes for b in brain_items)
    brain_files = sum(b.file_count for b in brain_items)

    # Projecting savings (keeping last 2 steps reduces size down to ~50-100KB per DB)
    projected_pruned_conv_bytes = len(heavy_convs) * 80 * 1024
    projected_conv_savings = max(0, heavy_bytes - projected_pruned_conv_bytes)
    projected_total_savings = projected_conv_savings + brain_bytes

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
            "projected_savings_bytes": projected_total_savings,
            "heavy_conversations": [asdict(c) for c in heavy_convs],
            "brain_items": [asdict(b) for b in brain_items],
        }
        print(json.dumps(payload, indent=2))
        return 0

    print("================================================================================")
    print(" [==] Antigravity Optimizer & Conversation Prediction Engine")
    print("================================================================================")
    print(f" Total Conversations Scanned : {len(convs)} ({format_bytes(total_conv_bytes)})")
    if keep_count > 0:
        print(f" Retention Policy            : Keeping latest {keep_count} conversations intact")
        print(f" Preserved Recent Convs      : {len(preserved_convs)} ({format_bytes(preserved_bytes)})")
        print(f" Older Convs Scanned         : {len(older_convs)} ({format_bytes(older_bytes)})")
    print(f" Heavy Conversations (> {format_bytes(threshold_bytes)}): {len(heavy_convs)} ({format_bytes(heavy_bytes)})")
    print(f" Gemini Brain Cleanup Targets : {len(brain_items)} folders, {brain_files} files ({format_bytes(brain_bytes)})")
    print(f" Projected Disk Reclamation  : ~{format_bytes(projected_total_savings)}")
    print("--------------------------------------------------------------------------------")

    if heavy_convs:
        print("\n [==] Top Heavy Conversations to Prune:")
        print(f"  {'CONVERSATION ID':<38} {'SLUG':<20} {'STEPS':<8} {'SIZE':<10}")
        print("  " + ("-" * 78))
        for c in heavy_convs[:10]:
            print(f"  {c.conversation_id:<38} {c.project_slug[:18]:<20} {c.step_count:<8} {format_bytes(c.file_size):<10}")
        if len(heavy_convs) > 10:
            print(f"  ... and {len(heavy_convs) - 10} more heavy conversations")

    if brain_items:
        print("\n [==] Gemini Brain Cleanup Targets:")
        print(f"  {'CATEGORY':<28} {'FILES':<8} {'SIZE':<10}")
        print("  " + ("-" * 48))
        for b in brain_items[:10]:
            print(f"  {b.category:<28} {b.file_count:<8} {format_bytes(b.total_bytes):<10}")
        if len(brain_items) > 10:
            print(f"  ... and {len(brain_items) - 10} more brain directories")

    print("================================================================================")
    print(" [NOTE] Prediction mode active. No Antigravity processes killed. No files modified.")
    print("================================================================================")
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
    c_target.execute("SELECT MAX(idx), COUNT(*) FROM steps")
    row = c_target.fetchone()
    if not row or row[0] is None or row[1] <= keep_turns:
        conn_target.close()
        return None

    max_idx = row[0]
    cutoff_idx = max(0, max_idx - keep_turns)

    # Fetch steps to archive
    c_target.execute(
        "SELECT idx, step_type, status, step_payload, metadata FROM steps WHERE idx < ?",
        (cutoff_idx,),
    )
    steps_to_archive = c_target.fetchall()
    if not steps_to_archive:
        conn_target.close()
        return None

    # Archive to backup database
    conn_backup = sqlite3.connect(str(backup_db))
    c_backup = conn_backup.cursor()

    for s in steps_to_archive:
        idx, stype, status, payload, meta = s
        c_backup.execute(
            """
            INSERT OR REPLACE INTO pruned_steps 
            (transaction_id, conversation_id, idx, step_type, status, step_payload, metadata)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (tx_id, c_info.conversation_id, idx, stype, status, payload, meta),
        )

    # Delete old steps from target
    c_target.execute("DELETE FROM steps WHERE idx < ?", (cutoff_idx,))
    c_target.execute("DELETE FROM gen_metadata WHERE idx < ?", (cutoff_idx,))
    conn_target.commit()

    # VACUUM to physically shrink database
    c_target.execute("VACUUM")
    conn_target.close()

    new_sz = db_path.stat().st_size
    steps_archived = len(steps_to_archive)

    # Record transaction
    c_backup.execute(
        """
        INSERT INTO prune_transactions
        (transaction_id, timestamp, conversation_id, workspace_uri, project_slug, original_size, pruned_size, steps_archived, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pruned')
        """,
        (
            tx_id,
            timestamp,
            c_info.conversation_id,
            c_info.workspace_uri,
            c_info.project_slug,
            c_info.file_size,
            new_sz,
            steps_archived,
        ),
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


def undo_transaction(transaction_id: str) -> bool:
    backup_db = get_backup_db_path()
    if not backup_db.is_file():
        print(f"Backup database not found: {backup_db}")
        return False

    conn_backup = sqlite3.connect(str(backup_db))
    c_backup = conn_backup.cursor()
    c_backup.execute(
        "SELECT conversation_id, status FROM prune_transactions WHERE transaction_id = ?",
        (transaction_id,),
    )
    tx = c_backup.fetchone()
    if not tx:
        print(f"Transaction not found: {transaction_id}")
        conn_backup.close()
        return False

    cid, status = tx
    if status == "reverted":
        print(f"Transaction {transaction_id} was already reverted.")
        conn_backup.close()
        return True

    target_db = get_gemini_base_dir() / "conversations" / f"{cid}.db"
    if not target_db.is_file():
        print(f"Target conversation database missing: {target_db}")
        conn_backup.close()
        return False

    # Fetch archived steps
    c_backup.execute(
        "SELECT idx, step_type, status, step_payload, metadata FROM pruned_steps WHERE transaction_id = ?",
        (transaction_id,),
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
        (transaction_id,),
    )
    conn_backup.commit()
    conn_backup.close()

    print(f"Successfully reverted transaction {transaction_id} ({len(archived_steps)} steps restored).")
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

        rel_dest = backup_bundle / item.category.replace(" ", "_").replace("(", "").replace(")", "")
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


def apply_optimization(threshold_bytes: int = 200 * 1024, keep_count: int = 0, keep_turns: int = 2) -> int:
    convs = discover_conversations(threshold_bytes, keep_count=keep_count)
    preserved_convs = [c for c in convs if c.is_preserved]
    heavy_convs = [c for c in convs if c.is_heavy]
    protected_cids = {c.conversation_id for c in preserved_convs}
    brain_items = scan_brain_cleanup_items(protected_cids=protected_cids)

    print("================================================================================")
    print(" [==] Applying Antigravity Optimization & Conversation Pruning")
    print("================================================================================")
    if keep_count > 0:
        print(f" Retention Policy       : Keeping latest {keep_count} conversations intact")
        print(f" Preserved Conversations: {len(preserved_convs)}")
    print(f" Heavy Conversations    : {len(heavy_convs)} will be pruned (latest {keep_turns} turns kept)")
    print(f" Brain Cleanup Items    : {len(brain_items)} directories backed up to OS temp")
    print("--------------------------------------------------------------------------------")

    pruned_results = []
    for c in heavy_convs:
        res = prune_conversation(c, keep_turns=keep_turns)
        if res:
            pruned_results.append(res)
            print(f"  [OK] Pruned {c.conversation_id[:16]}... ({c.project_slug}): {format_bytes(res['original_size'])} -> {format_bytes(res['pruned_size'])}")

    freed_brain, backup_bundle = backup_and_clean_brain_items(brain_items, is_apply=True)
    print(f"  [OK] Gemini brain items backed up to: {backup_bundle}")
    print(f"       Brain space reclaimed: {format_bytes(freed_brain)}")
    print("================================================================================")
    print(" [!!] NOTE: Brain backups are in OS temp and will expire based on OS temp policies.")
    print("      You can revert conversations anytime via: clear-agy --undo <tx_id>")
    print("================================================================================")
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
    parser.add_argument("--undo", type=str, help="Undo a specific transaction ID")
    parser.add_argument("--list-backups", action="store_true", help="List all backup transactions")

    args = parser.parse_args()
    threshold_bytes = args.threshold * 1024

    keep_count = args.keep
    if keep_count == 0 and args.count is not None:
        keep_count = args.count

    if args.undo:
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
        return apply_optimization(threshold_bytes=threshold_bytes, keep_count=keep_count, keep_turns=args.keep_turns)

    # Default to predict mode
    return predict_optimization(threshold_bytes=threshold_bytes, keep_count=keep_count, as_json=args.json)


if __name__ == "__main__":
    sys.exit(main())
