"""
Terminal summary and table rendering functions for optimization predictions.
"""

from __future__ import annotations

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


def render_heavy_table(heavy_convs: list) -> None:
    if not heavy_convs:
        return

    print(f"\n {BOLD}{YELLOW}[==] Top Heavy Conversations to Prune:{RESET}")
    for c in heavy_convs[:10]:
        print(f"  {CYAN}{c.conversation_id[:36]:<38}{RESET} {WHITE}{c.project_slug[:18]:<20}{RESET} {YELLOW}{c.step_count:<8}{RESET} {GREEN}{format_bytes(c.file_size):<10}{RESET}")


def render_summary_box(
    total_convs: int,
    total_bytes: int,
    preserved_convs: list,
    heavy_convs: list,
    cache_items: list,
    brain_items: list,
    projected_savings: int,
    keep_count: int,
) -> None:
    p_bytes = sum(c.file_size for c in preserved_convs)
    h_bytes = sum(c.file_size for c in heavy_convs)
    c_bytes = sum(c.total_bytes for c in cache_items)
    b_bytes = sum(b.total_bytes for b in brain_items)

    print(f"\n{BOLD}{CYAN}{'=' * 80}{RESET}\n {BOLD}{GREEN}[*] DISK SPACE RECLAMATION & CONVERSATION SUMMARY{RESET}\n{BOLD}{CYAN}{'=' * 80}{RESET}")
    print(f"  {BOLD}{WHITE}Total Conversations Scanned  :{RESET} {BOLD}{CYAN}{total_convs}{RESET} {DIM}({format_bytes(total_bytes)}){RESET}")
    if keep_count > 0:
        print(f"  {BOLD}{WHITE}Retention Policy             :{RESET} {BOLD}{YELLOW}Keeping latest {keep_count} conversations intact{RESET}")
        print(f"  {BOLD}{WHITE}Preserved Recent Convs       :{RESET} {BOLD}{GREEN}{len(preserved_convs)}{RESET} {DIM}({format_bytes(p_bytes)}){RESET}")

    print(f"  {BOLD}{WHITE}Heavy Older Convs            :{RESET} {BOLD}{YELLOW}{len(heavy_convs)}{RESET} {DIM}({format_bytes(h_bytes)}){RESET}")
    print(f"  {BOLD}{WHITE}Application Cache Targets    :{RESET} {BOLD}{CYAN}{len(cache_items)} folders{RESET} {DIM}({format_bytes(c_bytes)}){RESET}")
    print(f"  {BOLD}{WHITE}Gemini Brain Cleanup Targets :{RESET} {BOLD}{CYAN}{len(brain_items)} folders{RESET} {DIM}({format_bytes(b_bytes)}){RESET}")
    print(f"  {GRAY}{'-' * 80}{RESET}\n  {BOLD}{WHITE}PROJECTED DISK RECLAMATION   :{RESET} {BOLD}{GREEN}~{format_bytes(projected_savings)}{RESET}")
    print(f"{BOLD}{CYAN}{'=' * 80}{RESET}")
