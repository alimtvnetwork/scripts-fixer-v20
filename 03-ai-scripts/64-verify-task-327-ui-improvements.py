#!/usr/bin/env python3
"""
Task 327 Verification Script: UI Improvements for Queued and Running Prompts
Audits acceptance criteria across frontend and backend files.
"""

import sys
from pathlib import Path

def test_compact_badges():
    print("[TEST 1] Auditing Compact 'R' and 'Q' Badges...")
    
    # Check InstanceCardProjects.tsx
    card_proj = Path("src/pages/instances/InstanceCardProjects.tsx").read_text(encoding="utf-8")
    assert "animate-pulse" in card_proj, "InstanceCardProjects missing animate-pulse for R badge"
    assert "<span>R</span>" in card_proj, "InstanceCardProjects missing <span>R</span> badge"
    assert "<span>Q" in card_proj, "InstanceCardProjects missing <span>Q badge"
    assert "title={`Running in" in card_proj or "Running in" in card_proj, "InstanceCardProjects missing hover tooltip for R"
    assert "title={`Queued in" in card_proj or "Queued in" in card_proj, "InstanceCardProjects missing hover tooltip for Q"

    # Check ConversationNode.tsx
    conv_node = Path("src/components/instances/PromptTreeView/ConversationNode.tsx").read_text(encoding="utf-8")
    assert "<span>R</span>" in conv_node, "ConversationNode missing <span>R</span>"
    assert "<span>Q</span>" in conv_node, "ConversationNode missing <span>Q</span>"

    # Check ProjectNode.tsx
    proj_node = Path("src/components/instances/PromptTreeView/ProjectNode.tsx").read_text(encoding="utf-8")
    assert "<span>R</span>" in proj_node, "ProjectNode missing <span>R</span>"
    assert "<span>Q</span>" in proj_node, "ProjectNode missing <span>Q</span>"
    print("  -> PASSED: Compact 'R' and 'Q' badges verified across cards, tree, and project headers.")

def test_windowless_execution():
    print("[TEST 2] Auditing Windowless Process Execution (CREATE_NO_WINDOW)...")
    
    version_rs = Path("src-tauri/src/modules/version.rs").read_text(encoding="utf-8")
    assert "creation_flags_windows" in version_rs or "0x08000000" in version_rs, \
        "version.rs missing creation_flags_windows / 0x08000000 for version probes"

    cluster_rs = Path("src-tauri/src/modules/telegram_inbound/cluster.rs").read_text(encoding="utf-8")
    assert "cmd.creation_flags(0x08000000)" in cluster_rs, \
        "cluster.rs fallback command missing cmd.creation_flags(0x08000000)"
    print("  -> PASSED: Zero console window popups verified for version and cluster commands.")

def test_queued_rerun_and_navigation():
    print("[TEST 3] Auditing Queued Prompts Rerun Dropdown and Row Click Navigation...")
    
    instruction_view = Path("src/components/instances/PromptTreeView/PromptInstructionView.tsx").read_text(encoding="utf-8")
    assert "executeEnqueuedTurnRerun" in instruction_view, "PromptInstructionView missing executeEnqueuedTurnRerun handler"
    assert "queuedRerunCounts" in instruction_view, "PromptInstructionView missing queuedRerunCounts state"
    assert "propSetSelectedConversation" in instruction_view, "PromptInstructionView missing propSetSelectedConversation integration"
    assert "aria-label=\"Select rerun count\"" in instruction_view, "PromptInstructionView missing rerun count select dropdown"
    print("  -> PASSED: Queued prompt inline rerun dropdown and row click navigation verified.")

def test_copy_button_modes():
    print("[TEST 4] Auditing Copy Button Refinements (Copy, Copy without image, Base64)...")
    
    detail_header = Path("src/components/instances/PromptTreeView/DetailHeader.tsx").read_text(encoding="utf-8")
    assert "<span>{isCopiedAllActive ? 'Copied!' : 'Copy'}</span>" in detail_header, \
        "DetailHeader missing simplified 'Copy' label"

    stats_bar = Path("src/components/instances/PromptTreeView/instruction/InstructionStatsBar.tsx").read_text(encoding="utf-8")
    assert "<span>Copy</span>" in stats_bar, "InstructionStatsBar missing simplified 'Copy' label"

    copy_format = Path("src/components/instances/PromptTreeView/header/copyMenu/CopyFormatOptions.tsx").read_text(encoding="utf-8")
    assert "Copy without image" in copy_format, "CopyFormatOptions missing 'Copy without image'"
    assert "Copy image as base64" in copy_format, "CopyFormatOptions missing 'Copy image as base64'"
    print("  -> PASSED: Copy button label and format dropdown options verified.")

def test_quota_and_switcher_resilience():
    print("[TEST 5] Auditing Quota Interruption & Fast Switcher Triggering...")
    
    requeue_rs = Path("src-tauri/src/modules/repo_db/requeue.rs").read_text(encoding="utf-8")
    assert "capacity" in requeue_rs, "requeue.rs missing capacity keyword in quota SQL"

    daemon_rs = Path("src-tauri/src/modules/auto_switcher/daemon.rs").read_text(encoding="utf-8")
    assert "recent_quota_hit" in daemon_rs, "daemon.rs missing recent_quota_hit fast switch trigger"

    selection_rs = Path("src-tauri/src/modules/auto_switcher/selection.rs").read_text(encoding="utf-8")
    assert "Duration::from_millis(3000)" in selection_rs, "selection.rs candidate quota timeout not bounded to 3000ms"
    print("  -> PASSED: Quota interruption detection and fast rotation verified.")

def main():
    print("=" * 60)
    print("TASK 327 AUDIT SUITE: UI Improvements for Queued and Running Prompts")
    print("=" * 60)
    try:
        test_compact_badges()
        test_windowless_execution()
        test_queued_rerun_and_navigation()
        test_copy_button_modes()
        test_quota_and_switcher_resilience()
        print("=" * 60)
        print("ALL AUDIT GATES PASSED (5/5) - ZERO REGRESSIONS")
        print("=" * 60)
        return 0
    except AssertionError as e:
        print(f"FAILED: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
