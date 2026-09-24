"""
Execution coordinator for applying database pruning and disk cache cleanup.
"""

from __future__ import annotations

from typing import List

from agy_optimizer.cache_cleaner import backup_and_clean_brain_items, clean_app_cache_items
from agy_optimizer.conversations import discover_conversations
from agy_optimizer.models import (
    BOLD,
    CYAN,
    DIM,
    GRAY,
    GREEN,
    RESET,
    WHITE,
    YELLOW,
    format_bytes,
)
from agy_optimizer.pruner import prune_conversation
from agy_optimizer.scanner import scan_app_cache_items, scan_brain_cleanup_items


def _filter_heavy_for_apply(convs: list, min_steps: int, filter_slug: str) -> list:
    heavy = [c for c in convs if c.is_heavy]
    if min_steps > 0:
        heavy = [c for c in heavy if c.step_count >= min_steps]

    if filter_slug:
        heavy = [c for c in heavy if filter_slug.lower() in c.project_slug.lower()]

    return heavy


def _print_completion_box(pruned_count: int, freed_conv: int, brain_count: int, freed_brain: int, cache_files: int, freed_cache: int) -> None:
    total_freed = freed_conv + freed_brain + freed_cache
    print(f"\n{BOLD}{CYAN}{'=' * 80}{RESET}\n {BOLD}{GREEN}[*] DISK SPACE RECLAMATION COMPLETED{RESET}\n{BOLD}{CYAN}{'=' * 80}{RESET}")
    print(f"  {BOLD}{WHITE}Conversations Pruned        :{RESET} {BOLD}{CYAN}{pruned_count}{RESET} {DIM}({format_bytes(freed_conv)} saved){RESET}")
    print(f"  {BOLD}{WHITE}Brain Artifacts Reclaimed   :{RESET} {BOLD}{CYAN}{brain_count} dirs{RESET} {DIM}({format_bytes(freed_brain)} saved){RESET}")
    print(f"  {BOLD}{WHITE}Application Caches Scrubbed :{RESET} {BOLD}{CYAN}{cache_files} files{RESET} {DIM}({format_bytes(freed_cache)} saved){RESET}")
    print(f"  {GRAY}{'-' * 80}{RESET}\n  {BOLD}{WHITE}TOTAL DISK SPACE RECLAIMED  :{RESET} {BOLD}{GREEN}{format_bytes(total_freed)}{RESET}")
    print(f"{BOLD}{CYAN}{'=' * 80}{RESET}\n")


def apply_optimization(threshold_bytes: int = 200 * 1024, keep_count: int = 0, keep_turns: int = 2, min_steps: int = 0, filter_slug: str = "") -> int:
    convs = discover_conversations(threshold_bytes, keep_count=keep_count)
    preserved = [c for c in convs if c.is_preserved]
    heavy = _filter_heavy_for_apply(convs, min_steps, filter_slug)

    protected_cids = {c.conversation_id for c in preserved}
    cid_to_slug = {c.conversation_id: c.project_slug for c in convs}
    brain_items = scan_brain_cleanup_items(protected_cids=protected_cids, cid_to_slug=cid_to_slug)
    cache_items = scan_app_cache_items()

    print(f"\n{BOLD}{CYAN}{'=' * 80}{RESET}\n {BOLD}{CYAN}[==]{RESET} {BOLD}{WHITE}Applying Antigravity Optimization & Conversation Pruning{RESET}\n{BOLD}{CYAN}{'=' * 80}{RESET}")
    pruned_results: List[dict] = []
    for c in heavy:
        res = prune_conversation(c, keep_turns=keep_turns)
        if res:
            pruned_results.append(res)
            print(f"  {GREEN}[OK]{RESET} Pruned {CYAN}{c.conversation_id[:16]}...{RESET}: {YELLOW}{format_bytes(res['original_size'])}{RESET} -> {GREEN}{format_bytes(res['pruned_size'])}{RESET}")

    freed_brain, backup_bundle = backup_and_clean_brain_items(brain_items, is_apply=True)
    freed_cache_files, freed_cache_bytes = clean_app_cache_items(cache_items, is_apply=True)
    freed_conv_bytes = sum(r["original_size"] - r["pruned_size"] for r in pruned_results)

    _print_completion_box(len(pruned_results), freed_conv_bytes, len(brain_items), freed_brain, freed_cache_files, freed_cache_bytes)
    return 0
