"""
Optimization prediction and disk space reclamation analytics.
"""

from __future__ import annotations

import json
from dataclasses import asdict

from agy_optimizer.conversations import discover_conversations
from agy_optimizer.models import BOLD, CYAN, RESET, WHITE
from agy_optimizer.scanner import scan_app_cache_items, scan_brain_cleanup_items
from agy_optimizer.summary import render_heavy_table, render_summary_box


def _filter_heavy_convs(convs: list, min_steps: int, filter_slug: str) -> list:
    heavy = [c for c in convs if c.is_heavy]
    if min_steps > 0:
        heavy = [c for c in heavy if c.step_count >= min_steps]

    if filter_slug:
        heavy = [c for c in heavy if filter_slug.lower() in c.project_slug.lower()]

    heavy.sort(key=lambda x: x.file_size, reverse=True)
    return heavy


def _build_json_payload(convs: list, preserved: list, heavy: list, brain: list, cache: list, proj_save: int, keep_cnt: int) -> dict:
    return {
        "keep_count": keep_cnt,
        "total_conversations": len(convs),
        "preserved_conversations_count": len(preserved),
        "heavy_conversations_count": len(heavy),
        "total_conversation_bytes": sum(c.file_size for c in convs),
        "brain_items_count": len(brain),
        "brain_bytes": sum(b.total_bytes for b in brain),
        "cache_items_count": len(cache),
        "cache_bytes": sum(c.total_bytes for c in cache),
        "projected_savings_bytes": proj_save,
        "heavy_conversations": [asdict(c) for c in heavy],
        "brain_items": [asdict(b) for b in brain],
        "cache_items": [asdict(c) for c in cache],
    }


def predict_optimization(threshold_bytes: int = 200 * 1024, keep_count: int = 0, min_steps: int = 0, filter_slug: str = "", as_json: bool = False) -> int:
    convs = discover_conversations(threshold_bytes, keep_count=keep_count)
    preserved = [c for c in convs if c.is_preserved]
    cid_to_slug = {c.conversation_id: c.project_slug for c in convs}
    heavy = _filter_heavy_convs(convs, min_steps, filter_slug)

    protected_cids = {c.conversation_id for c in preserved}
    brain_items = scan_brain_cleanup_items(protected_cids=protected_cids, cid_to_slug=cid_to_slug)
    cache_items = scan_app_cache_items()

    heavy_bytes = sum(c.file_size for c in heavy)
    proj_savings = max(0, heavy_bytes - (len(heavy) * 80 * 1024)) + sum(b.total_bytes for b in brain_items) + sum(c.total_bytes for c in cache_items)

    if as_json:
        print(json.dumps(_build_json_payload(convs, preserved, heavy, brain_items, cache_items, proj_savings, keep_count), indent=2))
        return 0

    print(f"\n{BOLD}{CYAN}{'=' * 80}{RESET}\n {BOLD}{CYAN}[==]{RESET} {BOLD}{WHITE}Antigravity Optimizer & Conversation Prediction Engine{RESET}\n{BOLD}{CYAN}{'=' * 80}{RESET}")
    render_heavy_table(heavy)
    render_summary_box(len(convs), sum(c.file_size for c in convs), preserved, heavy, cache_items, brain_items, proj_savings, keep_count)
    return 0
