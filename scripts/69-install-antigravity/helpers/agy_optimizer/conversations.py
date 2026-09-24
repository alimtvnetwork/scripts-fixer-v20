"""
Conversation discovery and lifecycle ranking engine.
"""

from __future__ import annotations

from pathlib import Path
from typing import List

from agy_optimizer.models import ConversationInfo
from agy_optimizer.shared.database import load_conversation_summaries
from agy_optimizer.shared.paths import extract_project_slug, get_gemini_base_dir


def _build_conv_info(item: Path, summaries: dict) -> ConversationInfo:
    cid = item.stem
    st = item.stat()
    meta = summaries.get(cid, {})
    w_uris = meta.get("workspace_uris", "")
    slug = extract_project_slug(w_uris)

    return ConversationInfo(
        conversation_id=cid,
        db_path=str(item),
        file_size=st.st_size,
        title=meta.get("title", ""),
        preview=meta.get("preview", ""),
        workspace_uri=w_uris,
        project_slug=slug,
        step_count=meta.get("step_count", 0),
        is_heavy=False,
        mtime=st.st_mtime,
        is_preserved=False,
    )


def discover_conversations(threshold_bytes: int = 200 * 1024, keep_count: int = 0) -> List[ConversationInfo]:
    gemini_dir = get_gemini_base_dir()
    conv_dir = gemini_dir / "conversations"
    if not conv_dir.is_dir():
        return []

    summaries = load_conversation_summaries(gemini_dir)
    conversations: List[ConversationInfo] = []

    for item in conv_dir.glob("*.db"):
        try:
            conversations.append(_build_conv_info(item, summaries))
        except OSError:
            continue

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
