#!/usr/bin/env python3
"""
Verification Script for Task 322: Prompt Tree View Bug Investigation and Fixes.
Checks and validates:
1. Cache-First Tree Loading (Decoupled invalidation, 30-day TTL, no DB wipe on force load).
2. Single Active Running Turn Invariant (LLM serial conversation clamp in backend and frontend).
3. Instance Selector Current Anchor (#1 Default not overridden by activeInstanceId).
4. Turn Banner Reduction & Text Selection Glitch (Suppressed bulky banner, select-text, no select-none on <br>).
5. Focus Button Reversion Guard (conversation_id parameter in focus_instance_workspace, no chained double focus).
"""

import os
import sys

def check_file_contains(filepath: str, expected_snippets: list[str], forbidden_snippets: list[str]) -> bool:
    if not os.path.isfile(filepath):
        print(f"[-] File not found: {filepath}")
        return False
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    success = True
    for snip in expected_snippets:
        if snip not in content:
            print(f"[-] Missing expected snippet in {filepath}: {snip[:80]}...")
            success = False
        else:
            print(f"[+] Found expected snippet in {filepath}: {snip[:60]}...")

    for snip in forbidden_snippets:
        if snip in content:
            print(f"[-] Found forbidden snippet in {filepath}: {snip[:80]}...")
            success = False
        else:
            print(f"[+] Forbidden snippet correctly absent in {filepath}: {snip[:60]}...")

    return success

def main() -> int:
    print("=== Task 322: Prompt Tree View Invariants & Regression Verification ===")
    all_ok = True

    # 1. Backend instance commands & cache decoupling
    inst_cmd = os.path.join("src-tauri", "src", "commands", "instance.rs")
    all_ok &= check_file_contains(
        inst_cmd,
        expected_snippets=[
            "crate::modules::repo_db::invalidate_prompt_tree_cache(instance_id.as_deref());",
            "conversation_id: Option<String>",
            "target_conv",
        ],
        forbidden_snippets=[
            "pub async fn invalidate_prompt_tree_cache(instance_id: Option<String>) -> Result<String, String> {\n    reset_prompt_tree_cache(instance_id).await",
        ],
    )

    # 2. Backend tree cache TTL
    tree_rs = os.path.join("src-tauri", "src", "modules", "repo_db", "tree.rs")
    all_ok &= check_file_contains(
        tree_rs,
        expected_snippets=[
            "2592000",
            "prompt-tree cache write has a 30-day TTL",
        ],
        forbidden_snippets=[
            "VALUES (?1, ?2, ?3, ?4, ?5, ?6, 30)",
        ],
    )

    # 3. Backend single active turn clamp
    tree_conv_rs = os.path.join("src-tauri", "src", "modules", "repo_db", "tree_node_conv.rs")
    all_ok &= check_file_contains(
        tree_conv_rs,
        expected_snippets=[
            "clamp_single_active_running_turn",
            "Enforce at most 1 active RUNNING turn per conversation",
            "turn.is_running = false;\n                turn.status = \"COMPLETED\".to_string();",
        ],
        forbidden_snippets=[],
    )

    # 4. Frontend modal mount & instance ID resolution
    modal_tsx = os.path.join("src", "components", "instances", "PromptTreeView", "PromptTreeViewModal.tsx")
    all_ok &= check_file_contains(
        modal_tsx,
        expected_snippets=[
            "const effectiveInstanceId = (instanceId && instanceId.trim() !== '')",
        ],
        forbidden_snippets=[
            "instanceId !== 'default'",
        ],
    )

    # 5. Frontend SWR cache load & background polling
    tree_data_ts = os.path.join("src", "components", "instances", "PromptTreeView", "usePromptTreeData.ts")
    all_ok &= check_file_contains(
        tree_data_ts,
        expected_snippets=[
            "void loadTree(false, false, latestArchived, latestPinned);",
            "loadTree(true, false, latestArchived, latestPinned);",
            "invalidate_prompt_tree_cache",
        ],
        forbidden_snippets=[
            "void loadTree(false, true, latestArchived, latestPinned);",
            "loadTree(true, true, latestArchived, latestPinned);",
            "await invoke('reset_prompt_tree_cache', { instanceId: instanceId || null });",
        ],
    )

    # 6. Frontend single running turn invariant in ConversationNode
    conv_node_tsx = os.path.join("src", "components", "instances", "PromptTreeView", "ConversationNode.tsx")
    all_ok &= check_file_contains(
        conv_node_tsx,
        expected_snippets=[
            "const activeRunningTurn = allRunning.length > 0",
            "const isTurnRunning = activeRunningTurn ? turn.turn_number === activeRunningTurn.turn_number : false;",
        ],
        forbidden_snippets=[],
    )

    # 7. Text selection & markdown formatting
    markdown_tsx = os.path.join("src", "components", "instances", "PromptTreeView", "markdown.tsx")
    all_ok &= check_file_contains(
        markdown_tsx,
        expected_snippets=[
            '<br key={`br-${nodeIdx}-${pIdx}`} className="my-1" />',
        ],
        forbidden_snippets=[
            'className="my-1.5 block select-none"',
            'className="my-1 block select-none"',
        ],
    )

    inst_view_tsx = os.path.join("src", "components", "instances", "PromptTreeView", "PromptInstructionView.tsx")
    all_ok &= check_file_contains(
        inst_view_tsx,
        expected_snippets=[
            "cursor-text select-text transition-colors shadow-inner",
        ],
        forbidden_snippets=[
            "onDoubleClick={() => openInspector(selectedConversation",
            '<br className="my-1.5 block select-none" />',
        ],
    )

    # 8. InstanceCardProjects & MegaMenu double-focus elimination
    mega_menu_bottom = os.path.join("src", "components", "navbar", "mega-menu", "MegaProjectsSummaryBottom.tsx")
    all_ok &= check_file_contains(
        mega_menu_bottom,
        expected_snippets=[
            "await focusInstanceWorkspace(instanceId, repoPath, repoName || '')",
        ],
        forbidden_snippets=[
            "await focusInstanceChat(instanceId, repoPath)",
            "await focusInstanceChat(instanceId)",
        ],
    )

    card_proj = os.path.join("src", "pages", "instances", "InstanceCardProjects.tsx")
    all_ok &= check_file_contains(
        card_proj,
        expected_snippets=[
            "await api.focusOrLaunchInstance(inst.config.id, proj.repo_path);",
        ],
        forbidden_snippets=[
            "await focusInstanceChat(inst.config.id, proj.repo_path);",
        ],
    )

    # 9. DetailHeader target instance selection reset & no hijacking
    detail_header_tsx = os.path.join("src", "components", "instances", "PromptTreeView", "DetailHeader.tsx")
    all_ok &= check_file_contains(
        detail_header_tsx,
        expected_snippets=[
            "setSelectedTargetInstId(propInstanceId || selectedConversation.instance_id || 'default');",
            "setTargetNodeAlias('local');",
            "activeInstanceId={propInstanceId || defaultInstanceId}",
        ],
        forbidden_snippets=[
            "else if (runningOpt && (selectedTargetInstId === 'default' || !opts.some((o) => o.id === selectedTargetInstId && o.isRunning)))",
        ],
    )

    # 10. InstanceSelectorDropdown Current badge & default anchor
    inst_dropdown_tsx = os.path.join("src", "components", "instances", "PromptTreeView", "dispatch", "InstanceSelectorDropdown.tsx")
    all_ok &= check_file_contains(
        inst_dropdown_tsx,
        expected_snippets=[
            "isInstanceCurrent",
            "isDefaultInstanceAlias",
            "Current",
        ],
        forbidden_snippets=[],
    )

    if all_ok:
        print("\n[SUCCESS] All Task 322 verification checks passed cleanly!")
        return 0
    else:
        print("\n[FAILURE] One or more Task 322 verification checks failed!")
        return 1

if __name__ == "__main__":
    sys.exit(main())
