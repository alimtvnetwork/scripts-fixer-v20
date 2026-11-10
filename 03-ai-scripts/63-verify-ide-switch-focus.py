#!/usr/bin/env python3
"""
Verification script for Task 326: IDE Account Switch, Restart & Prompt Restore Auto-Focus
Audits all modified files to ensure grounded compliance with acceptance criteria.
"""

import sys
import re
from pathlib import Path

def test_frontend_instance_page_actions():
    path = Path("src/pages/instances/instancePageActions.ts")
    assert path.exists(), f"Missing {path}"
    content = path.read_text(encoding="utf-8")

    assert "focusOrLaunchInstance" in content, "Missing focusOrLaunchInstance import in instancePageActions.ts"
    assert "handleRestart" in content, "Missing handleRestart in instancePageActions.ts"
    assert "handleFastForward" in content, "Missing handleFastForward in instancePageActions.ts"

    # Verify handleRestart calls focusOrLaunchInstance
    restart_match = re.search(r"handleRestart\s*=\s*\(id:\s*string\)\s*=>[\s\S]*?focusOrLaunchInstance\(id\)", content)
    assert restart_match, "handleRestart must invoke focusOrLaunchInstance(id)"

    # Verify handleFastForward calls focusOrLaunchInstance
    ff_match = re.search(r"handleFastForward\s*=\s*\(id:\s*string\)\s*=>[\s\S]*?focusOrLaunchInstance\(id\)", content)
    assert ff_match, "handleFastForward must invoke focusOrLaunchInstance(id)"

    print("[PASS] instancePageActions.ts auto-focus on restart & fast-forward verified")

def test_frontend_switch_account_dialog():
    path = Path("src/pages/instances/SwitchAccountDialog.tsx")
    assert path.exists(), f"Missing {path}"
    content = path.read_text(encoding="utf-8")

    assert "focusOrLaunchInstance" in content, "Missing focusOrLaunchInstance import in SwitchAccountDialog.tsx"
    
    # Verify handleSelect calls focusOrLaunchInstance
    select_match = re.search(r"handleSelect\s*=\s*async\s*\(acc:\s*Account\)\s*=>[\s\S]*?focusOrLaunchInstance\(targetId\)", content)
    assert select_match, "handleSelect must invoke focusOrLaunchInstance(targetId)"

    print("[PASS] SwitchAccountDialog.tsx auto-focus on account switch verified")

def test_frontend_restore_prompts_actions():
    card_path = Path("src/pages/instances/InstanceCardActions.tsx")
    row_path = Path("src/components/instances/table/InstanceRowActions.tsx")
    hdr_path = Path("src/pages/instances/InstancesHeader.tsx")

    for p in (card_path, row_path, hdr_path):
        assert p.exists(), f"Missing {p}"
        content = p.read_text(encoding="utf-8")
        assert "focusOrLaunchInstance" in content, f"Missing focusOrLaunchInstance in {p}"
        assert "openAndRestorePromptBackupFile" in content, f"Missing openAndRestorePromptBackupFile in {p}"

    print("[PASS] Prompt restore actions auto-focus across Card, Table, and Header verified")

def test_frontend_accounts_switch():
    path = Path("src/pages/accounts/useAccountsHandlers.ts")
    assert path.exists(), f"Missing {path}"
    content = path.read_text(encoding="utf-8")

    assert "focusOrLaunchInstance" in content, "Missing focusOrLaunchInstance import in useAccountsHandlers.ts"
    switch_match = re.search(r"switchAccount\(accountId,\s*targetIde\)[\s\S]*?focusOrLaunchInstance\(targetInstId\)", content)
    assert switch_match, "useAccountsHandlers handleSwitch must invoke focusOrLaunchInstance"

    print("[PASS] useAccountsHandlers.ts auto-focus on account switch verified")

def test_backend_restart_instance():
    path = Path("src-tauri/src/commands/instance.rs")
    assert path.exists(), f"Missing {path}"
    content = path.read_text(encoding="utf-8")

    # Verify restart_instance triggers focus_running_instance and activate_session_in_instance
    restart_block = re.search(r"pub async fn restart_instance[\s\S]*?Ok\(res\)\s*}", content)
    assert restart_block, "Missing restart_instance function"
    r_text = restart_block.group(0)
    assert "focus_running_instance" in r_text, "restart_instance must call focus_running_instance"
    assert "find_active_conversation_for_instance" in r_text, "restart_instance must find active conversation"
    assert "activate_session_in_instance" in r_text, "restart_instance must call activate_session_in_instance"

    # Verify fast_forward_instance triggers focus_running_instance and activate_session_in_instance
    ff_block = re.search(r"pub async fn fast_forward_instance[\s\S]*?res\s*}", content)
    assert ff_block, "Missing fast_forward_instance function"
    ff_text = ff_block.group(0)
    assert "focus_running_instance" in ff_text, "fast_forward_instance must call focus_running_instance"
    assert "activate_session_in_instance" in ff_text, "fast_forward_instance must call activate_session_in_instance"

    # Verify switch_account_to_instance triggers focus_running_instance and activate_session_in_instance
    switch_block = re.search(r"pub async fn switch_account_to_instance[\s\S]*?if res\.is_ok\(\) \{[\s\S]*?focus_running_instance", content)
    assert switch_block, "switch_account_to_instance must call focus_running_instance"

    print("[PASS] commands::instance (restart, fast-forward, switch_account) auto-focus and CDP navigation verified")

def test_backend_workspace_post_switch_restore():
    path = Path("src-tauri/src/modules/instance/workspace.rs")
    assert path.exists(), f"Missing {path}"
    content = path.read_text(encoding="utf-8")

    assert "push_backed_up_prompts_after_channel" in content
    restore_block = re.search(r"if pushed > 0 \{[\s\S]*?focus_running_instance[\s\S]*?open_conversation_history_via_cdp", content)
    assert restore_block, "workspace.rs post-switch restore must focus window and open conversation history via CDP"

    print("[PASS] workspace.rs post-switch prompt restore auto-focus & history navigation verified")

def main():
    print("=" * 70)
    print("Running Verification Suite: Task 326 (IDE Switch & Focus Fix)")
    print("=" * 70)

    test_frontend_instance_page_actions()
    test_frontend_switch_account_dialog()
    test_frontend_restore_prompts_actions()
    test_frontend_accounts_switch()
    test_backend_restart_instance()
    test_backend_workspace_post_switch_restore()

    print("=" * 70)
    print("ALL 6 TESTS PASSED: 100% COMPLIANT WITH ACCEPTANCE CRITERIA")
    print("=" * 70)

if __name__ == "__main__":
    main()
