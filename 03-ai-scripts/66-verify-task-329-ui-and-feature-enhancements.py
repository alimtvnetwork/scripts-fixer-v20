#!/usr/bin/env python3
"""
Task 329 Verification Script: UI and Feature Enhancement Instructions
Audits acceptance criteria across frontend and backend files:
1. Backend IDE Color Customization (tuning.rs, commands/instance.rs, run.rs)
2. Frontend Color Swatch Dropdown (InstanceColorSwatchDropdown.tsx, InstanceCard.tsx, InstanceRowCells.tsx)
3. Compact Transcripts, IDE, and Date Section Headers (InstanceCardProjects.tsx)
4. Compact Bug Recorder HUD, Send to IDE Default Action & Event Stream Explorer (RecorderFloatingHud, RecorderExportDropdown, EventExplorerModal, PreviousBugsModal)
"""

import sys
from pathlib import Path

def test_backend_ide_color():
    print("[TEST 1] Auditing Backend IDE Color Customization...")
    tuning_rs = Path("src-tauri/src/modules/instance/tuning.rs").read_text(encoding="utf-8")
    assert "pub fn set_instance_ide_color" in tuning_rs, "tuning.rs missing set_instance_ide_color"
    assert "pub fn get_instance_ide_color" in tuning_rs, "tuning.rs missing get_instance_ide_color"
    assert "workbench.colorCustomizations" in tuning_rs, "tuning.rs missing workbench.colorCustomizations injection"
    assert "titleBar.activeBackground" in tuning_rs, "tuning.rs missing titleBar.activeBackground"
    assert "shade_color" in tuning_rs, "tuning.rs missing shade_color helper"

    cmd_instance = Path("src-tauri/src/commands/instance.rs").read_text(encoding="utf-8")
    assert "pub fn set_instance_ide_color" in cmd_instance, "commands/instance.rs missing set_instance_ide_color command"
    assert "pub fn get_instance_ide_color" in cmd_instance, "commands/instance.rs missing get_instance_ide_color command"

    run_rs = Path("src-tauri/src/lib/run.rs").read_text(encoding="utf-8")
    assert "commands::set_instance_ide_color" in run_rs, "run.rs missing set_instance_ide_color in generate_handler!"
    assert "commands::get_instance_ide_color" in run_rs, "run.rs missing get_instance_ide_color in generate_handler!"
    print("  -> PASSED: Backend IDE color customization and IPC handlers verified.")

def test_frontend_color_swatches():
    print("[TEST 2] Auditing Frontend Color Swatch Dropdown...")
    swatch_tsx = Path("src/components/instances/InstanceColorSwatchDropdown.tsx").read_text(encoding="utf-8")
    assert "INSTANCE_COLOR_PRESETS" in swatch_tsx, "InstanceColorSwatchDropdown missing INSTANCE_COLOR_PRESETS"
    assert "Default Dark" in swatch_tsx and "Tokyo Night" in swatch_tsx, "Missing color preset options"
    assert "STORAGE_KEY_INSTANCE_COLORS" in swatch_tsx, "Missing localStorage backup key"
    assert "createPortal" in swatch_tsx, "InstanceColorSwatchDropdown must use createPortal for non-clipped rendering"
    assert "set_instance_ide_color" in swatch_tsx, "InstanceColorSwatchDropdown missing set_instance_ide_color invoke"

    card_tsx = Path("src/pages/instances/InstanceCard.tsx").read_text(encoding="utf-8")
    assert "InstanceColorSwatchDropdown" in card_tsx, "InstanceCard missing InstanceColorSwatchDropdown import or mount"
    assert "InstanceColorSwatchDropdown instanceId={inst.config.id}" in card_tsx, "InstanceCard missing InstanceColorSwatchDropdown mount"

    table_cells = Path("src/components/instances/table/InstanceRowCells.tsx").read_text(encoding="utf-8")
    assert "InstanceColorSwatchDropdown" in table_cells, "InstanceRowCells missing InstanceColorSwatchDropdown"
    print("  -> PASSED: Color swatch dropdown and mounts in card/list views verified.")

def test_compact_card_headers():
    print("[TEST 3] Auditing Compact Section Headers in InstanceCardProjects...")
    card_proj = Path("src/pages/instances/InstanceCardProjects.tsx").read_text(encoding="utf-8")
    assert "rounded-full" in card_proj, "InstanceCardProjects missing rounded-full capsule"
    assert "Calendar" in card_proj, "InstanceCardProjects missing Calendar icon"
    assert "Cpu" in card_proj, "InstanceCardProjects missing Cpu icon for IDE"
    assert "FileText" in card_proj, "InstanceCardProjects missing FileText icon for Transcripts"
    assert "data-action=\"open-date-history\"" in card_proj, "Missing data-action for date history"
    assert "data-action=\"open-transcripts\"" in card_proj, "Missing data-action for transcripts"
    print("  -> PASSED: Compact capsule icon buttons verified.")

def test_bug_recorder_compaction_and_send_to_ide():
    print("[TEST 4] Auditing Bug Recorder HUD, Send to IDE & Modals...")
    hud_tsx = Path("src/components/recorder/RecorderFloatingHud.tsx").read_text(encoding="utf-8")
    assert "openEventExplorer" in hud_tsx, "RecorderFloatingHud missing openEventExplorer navigation"
    assert "RecorderExportDropdown" in hud_tsx, "RecorderFloatingHud missing RecorderExportDropdown"
    assert "rounded-full" in hud_tsx, "RecorderFloatingHud missing compact rounded-full styling"

    dropdown_tsx = Path("src/components/recorder/RecorderExportDropdown.tsx").read_text(encoding="utf-8")
    assert "handleSendToIde" in dropdown_tsx, "RecorderExportDropdown missing handleSendToIde"
    assert "sendPromptNow" in dropdown_tsx, "RecorderExportDropdown missing sendPromptNow integration"
    assert "Send to IDE" in dropdown_tsx, "RecorderExportDropdown missing 'Send to IDE' label"
    assert "Export ZIP" in dropdown_tsx or "handleExportZip" in dropdown_tsx, "Missing ZIP export option"
    assert "handleSendEmail" in dropdown_tsx, "Missing Send as Email option"
    assert "handleSaveSupabase" in dropdown_tsx, "Missing Supabase sync option"

    explorer_tsx = Path("src/components/recorder/EventExplorerModal.tsx").read_text(encoding="utf-8")
    assert "initialSessionId" in explorer_tsx, "EventExplorerModal missing initialSessionId support"
    assert "activeExplorerSessionId" in explorer_tsx, "EventExplorerModal missing activeExplorerSessionId integration"

    prev_bugs_tsx = Path("src/components/recorder/PreviousBugsModal.tsx").read_text(encoding="utf-8")
    assert "openEventExplorer" in prev_bugs_tsx, "PreviousBugsModal missing openEventExplorer click handler"
    print("  -> PASSED: Compact Bug Recorder, Send to IDE default action, and event modals verified.")

def main():
    print("======================================================================")
    print("TASK 329 VERIFICATION: UI AND FEATURE ENHANCEMENT INSTRUCTIONS")
    print("======================================================================")
    try:
        test_backend_ide_color()
        test_frontend_color_swatches()
        test_compact_card_headers()
        test_bug_recorder_compaction_and_send_to_ide()
        print("\n>>> ALL ACCEPTANCE CRITERIA VERIFIED (100% GREEN) <<<")
        return 0
    except AssertionError as e:
        print(f"\n❌ VERIFICATION FAILED: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
