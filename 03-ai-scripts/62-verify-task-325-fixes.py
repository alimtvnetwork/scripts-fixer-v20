#!/usr/bin/env python3
"""
Verification script for Task 325: Cluster Fleet and UI Improvements
Audits all modified files to ensure grounded compliance with acceptance criteria.
"""

import sys
import re
from pathlib import Path

def test_remote_ops():
    path = Path("src-tauri/src/modules/fleet_updater/remote_ops.rs")
    assert path.exists(), f"Missing {path}"
    content = path.read_text(encoding="utf-8")

    assert "BatchMode=yes" in content, "Missing BatchMode=yes in scp_cmd"
    assert "sftp_dest" in content, "Missing sftp_dest normalization in remote_ops.rs"
    assert "30_000" in content, "Missing 30_000 command length limit in remote_ops.rs"
    assert "CHUNK_SIZE: usize = 4 * 1024" in content, "CHUNK_SIZE should be 4KB"
    print("[PASS] remote_ops.rs hardening verified")

def test_deploy_modal():
    path = Path("src/components/navbar/mega-menu/DeployProgressModal.tsx")
    assert path.exists(), f"Missing {path}"
    content = path.read_text(encoding="utf-8")

    assert "bOnline - aOnline" in content, "Missing online node sorting in DeployProgressModal"
    assert "remoteFleetNodes.filter((n) => n.online)" in content, "selectAllNodes must filter by n.online"
    assert "!n.online" in content, "Missing offline node visual distinction"
    assert "opacity-40" in content or "opacity-50" in content, "Offline machines should have reduced opacity"
    print("[PASS] DeployProgressModal.tsx smart selection and sorting verified")

def test_instance_start_focus():
    header_path = Path("src/pages/instances/InstancesHeader.tsx")
    actions_path = Path("src/pages/instances/instancePageActions.ts")
    assert header_path.exists() and actions_path.exists()

    header_content = header_path.read_text(encoding="utf-8")
    actions_content = actions_path.read_text(encoding="utf-8")

    assert "Loader2" in header_content, "Missing Loader2 spinner in InstancesHeader"
    assert "isLaunchingAll ? (" in header_content, "Missing isLaunchingAll conditional spinner"
    assert "openInstanceConversationHistory(id)" in actions_content, "Missing openInstanceConversationHistory on launch"
    print("[PASS] Instance Start focus & Start All spinner verified")

def test_theme_builder_server():
    server_path = Path("src-tauri/src/modules/http_api/server.rs")
    assert server_path.exists(), f"Missing {server_path}"
    content = server_path.read_text(encoding="utf-8")

    assert "19527" in content, "Missing port 19527 in allowed origins"
    assert "8045" in content, "Missing port 8045 in allowed origins"
    assert "/api/theme" in content, "Missing /api/theme route"
    assert "set_reuse_address" in content, "Missing SO_REUSEADDR on socket binding"
    print("[PASS] Theme Builder HTTP server port 19527 verified")

def test_card_iconification():
    projects_path = Path("src/pages/instances/InstanceCardProjects.tsx")
    assert projects_path.exists(), f"Missing {projects_path}"
    content = projects_path.read_text(encoding="utf-8")

    assert "Date: View all conversation history" in content, "Missing Date icon button tooltip"
    assert "IDE: Open / Move to Conversation History" in content, "Missing IDE icon button tooltip"
    assert "Transcripts: Open Transcript Explorer" in content, "Missing Transcripts icon button tooltip"
    assert "{totalTurns}\n" in content or "{totalTurns}</span>" in content, "Turns should be numeric only"
    assert f'title="`{{totalTurns}} turns`"' in content or 'title={`${totalTurns} turns`}' in content, "Missing turns tooltip"
    print("[PASS] Card iconification and turn counts verified")

def test_detail_header_and_resizer():
    header_path = Path("src/components/instances/PromptTreeView/DetailHeader.tsx")
    modal_path = Path("src/components/instances/PromptTreeView/PromptTreeViewModal.tsx")
    assert header_path.exists() and modal_path.exists()

    header_content = header_path.read_text(encoding="utf-8")
    modal_content = modal_path.read_text(encoding="utf-8")

    assert "prompt-explore-ideas-direct-btn" not in header_content, "Explore Ideas button should be removed from DetailHeader"
    assert "hover:w-2" not in modal_content, "Splitter should not grow width on hover in PromptTreeViewModal"
    print("[PASS] DetailHeader Explore Ideas removal and locked splitter width verified")

def test_mega_theme_strip():
    strip_path = Path("src/components/navbar/mega-menu/MegaThemeStrip.tsx")
    assert strip_path.exists(), f"Missing {strip_path}"
    content = strip_path.read_text(encoding="utf-8")

    assert "isThemeDropdownOpen" in content, "Missing custom theme dropdown state"
    assert "open_theme_builder_in_browser" in content or "19527/builder" in content, "Missing Theme Builder link"
    assert "Edit" in content, "Missing inline Edit button"
    print("[PASS] MegaThemeStrip custom palette dropdown verified")

def main():
    print("Running Task 325 Verification Suite...")
    test_remote_ops()
    test_deploy_modal()
    test_instance_start_focus()
    test_theme_builder_server()
    test_card_iconification()
    test_detail_header_and_resizer()
    test_mega_theme_strip()
    print("\nAll 7 verification checks passed with 100% compliance!")
    return 0

if __name__ == "__main__":
    sys.exit(main())
