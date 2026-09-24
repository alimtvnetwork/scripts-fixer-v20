"""
Optimization prediction and disk space reclamation analytics.
"""

from __future__ import annotations

import json
from dataclasses import asdict
from typing import List

from agy_optimizer.conversations import discover_conversations
from agy_optimizer.models import (
    BOLD,
    CYAN,
    DIM,
    GRAY,
    GREEN,
    MAGENTA,
    RED,
    RESET,
    WHITE,
    YELLOW,
    format_bytes,
)
from agy_optimizer.scanner import scan_app_cache_items, scan_brain_cleanup_items


def _filter_heavy_convs(convs: list, min_steps: int, filter_slug: str) -> list:
    heavy = [c for c in convs if c.is_heavy]
    if min_steps > 0:
        heavy = [c for c in heavy if c.step_count >= min_steps]

    if filter_slug:
        heavy = [c for c in heavy if filter_slug.lower() in c.project_slug.lower()]

    heavy.sort(key=lambda x: x.file_size, reverse=True)
    return heavy


def _render_summary(total_convs: int, total_b: int, p_convs: list, h_convs: list, c_items: list, b_items: list, proj_save: int, keep_cnt: int) -> None:
    p_bytes = sum(c.file_size for c in p_convs)
    h_bytes = sum(c.file_size for c in h_convs)
    c_bytes = sum(c.total_bytes for c in c_items)
    b_bytes = sum(b.total_bytes for b in b_items)

    print(f"\n{BOLD}{CYAN}{'=' * 80}{RESET}\n {BOLD}{GREEN}[*] DISK SPACE RECLAMATION & CONVERSATION SUMMARY{RESET}\n{BOLD}{CYAN}{'=' * 80}{RESET}")
    print(f"  {BOLD}{WHITE}Total Conversations Scanned  :{RESET} {BOLD}{CYAN}{total_convs}{RESET} {DIM}({format_bytes(total_b)}){RESET}")
    if keep_cnt > 0:
        print(f"  {BOLD}{WHITE}Retention Policy             :{RESET} {BOLD}{YELLOW}Keeping latest {keep_cnt} conversations intact{RESET}")
        print(f"  {BOLD}{WHITE}Preserved Recent Convs       :{RESET} {BOLD}{GREEN}{len(p_convs)}{RESET} {DIM}({format_bytes(p_bytes)}){RESET}")

    print(f"  {BOLD}{WHITE}Heavy Older Convs            :{RESET} {BOLD}{YELLOW}{len(h_convs)}{RESET} {DIM}({format_bytes(h_bytes)}){RESET}")
    print(f"  {BOLD}{WHITE}Application Cache Targets    :{RESET} {BOLD}{CYAN}{len(c_items)} folders{RESET} {DIM}({format_bytes(c_bytes)}){RESET}")
    print(f"  {BOLD}{WHITE}Gemini Brain Cleanup Targets :{RESET} {BOLD}{CYAN}{len(b_items)} folders{RESET} {DIM}({format_bytes(b_bytes)}){RESET}")
    print(f"  {GRAY}{'-' * 80}{RESET}\n  {BOLD}{WHITE}PROJECTED DISK RECLAMATION   :{RESET} {BOLD}{GREEN}~{format_bytes(proj_save)}{RESET}")
    print(f"{BOLD}{CYAN}{'=' * 80}{RESET}")


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
    if heavy:
        print(f"\n {BOLD}{YELLOW}[==] Top Heavy Conversations to Prune:{RESET}")
        for c in heavy[:10]:
            print(f"  {CYAN}{c.conversation_id[:36]:<38}{RESET} {WHITE}{c.project_slug[:18]:<20}{RESET} {YELLOW}{c.step_count:<8}{RESET} {GREEN}{format_bytes(c.file_size):<10}{RESET}")

    _render_summary(len(convs), sum(c.file_size for c in convs), preserved, heavy, cache_items, brain_items, proj_savings, keep_count)
    return 0
