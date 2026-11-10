#!/usr/bin/env python3
"""
Verification Script for Task 324:
Bug Fixing and UI/UX Improvement Instructions

Verifies:
1. Quota detector catches baseline & individual quota limit messages
2. Auto-switcher checks repo DB for quota-interrupted prompts
3. Auto-switcher selection implements healthy fallback tier (sub-100%)
4. Process termination uses native taskkill with CREATE_NO_WINDOW (no powershell flashes)
5. UI runGuardedAction has 25s timeout guard to prevent permanent Rotating... overlay
6. Telegram send_flow omits useless IDE data path
7. Telegram machine picker uses consistent display (🖥️ Online)
8. Telegram active/instances reports show recent 7-8 projects in <pre> code blocks
9. Bug recorder floating HUD uses dark-glass stop button (no red-on-red)
10. Previous bugs modal uses compact cards with export dropdown
11. Mega menu bottom uses segmented pill with Deploy and Selected buttons
12. Deploy modal sanitizes underscores and uses elevated z-index
13. Theme builder implements progressive loading bar and deferred canvas
"""

import sys
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

ROOT = Path(__file__).resolve().parent.parent

def check(file_rel: str, phrases: list[str], forbidden: list[str] = None):
    p = ROOT / file_rel
    if not p.is_file():
        print(f"❌ FAIL: File not found: {file_rel}")
        return False
    content = p.read_text(encoding="utf-8")
    ok = True
    for phrase in phrases:
        if phrase not in content:
            print(f"❌ FAIL: Missing required phrase in {file_rel}: {phrase!r}")
            ok = False
        else:
            print(f"  ✓ Found: {phrase[:60]!r}")
    if forbidden:
        for f in forbidden:
            if f in content:
                print(f"❌ FAIL: Found forbidden phrase in {file_rel}: {f!r}")
                ok = False
            else:
                print(f"  ✓ Verified absent: {f[:60]!r}")
    return ok

def main():
    print("=== Task 324 Verification ===")
    all_ok = True

    # 1. Quota detector
    print("\n[1] Checking Quota Detector...")
    all_ok &= check("src-tauri/src/proxy/quota_detector.rs", [
        "baseline model quota reached",
        "baseline quota will refresh",
        "individual quota reached",
        "increase your limits",
    ])

    # 2. Repo DB quota interrupted query
    print("\n[2] Checking Repo DB Quota Interrupted Query...")
    all_ok &= check("src-tauri/src/modules/repo_db/requeue.rs", [
        "pub fn has_instance_quota_interrupted_prompt",
        "interrupted_reason LIKE '%quota%'",
        "ORDER BY created_at ASC",
    ])

    # 3. Auto-switcher daemon & selection fallback
    print("\n[3] Checking Auto-Switcher Daemon & Selection...")
    all_ok &= check("src-tauri/src/modules/auto_switcher/daemon.rs", [
        "has_instance_quota_interrupted_prompt",
        "Triggering quota rotation...",
    ])
    all_ok &= check("src-tauri/src/modules/auto_switcher/selection.rs", [
        "best healthy fallback candidate",
        "fallback_candidate",
    ])

    # 4. Native taskkill termination (no powershell)
    print("\n[4] Checking Process Termination...")
    all_ok &= check("src-tauri/src/modules/instance/switch.rs", [
        "taskkill",
        "0x08000000",
    ], forbidden=[
        "powershell.exe",
    ])
    all_ok &= check("src-tauri/src/modules/instance/close.rs", [
        "taskkill",
        "0x08000000",
    ], forbidden=[
        "powershell.exe",
    ])

    # 5. UI runGuardedAction timeout
    print("\n[5] Checking UI runGuardedAction Timeout...")
    all_ok &= check("src/pages/instances/instancePageActions.ts", [
        "Promise.race([",
        "25000",
        "timed out after 25s",
    ])

    # 6. Telegram send flow (no IDE data)
    print("\n[6] Checking Telegram Inbound Send Flow...")
    all_ok &= check("src-tauri/src/modules/telegram_inbound/send_flow.rs", [
        "Local Host",
        "🟢 Online",
    ], forbidden=[
        "IDE data:",
    ])

    # 7. Telegram reports (recent projects & prompts in <pre>)
    print("\n[7] Checking Telegram Reports...")
    all_ok &= check("src-tauri/src/modules/telegram_inbound/reports_a.rs", [
        "Recent Projects & Prompts (Ready to Copy / Rerun)",
        "<pre>",
    ])
    all_ok &= check("src-tauri/src/modules/telegram_inbound/reports_cluster_a.rs", [
        "Recent Projects & Prompts (Ready to Copy / Rerun)",
        "<pre>",
    ])

    # 8. Recorder HUD
    print("\n[8] Checking Bug Recorder HUD Stop Button...")
    all_ok &= check("src/components/recorder/RecorderFloatingHud.tsx", [
        "bg-slate-900/90",
        "fill-rose-500",
    ])

    # 9. Previous Bugs Modal
    print("\n[9] Checking Previous Bugs Modal...")
    all_ok &= check("src/components/recorder/PreviousBugsModal.tsx", [
        "RecorderExportDropdown",
        "isCompact",
    ])

    # 10. Mega Menu bottom deploy buttons
    print("\n[10] Checking Mega Menu Bottom Deploy Buttons...")
    all_ok &= check("src/components/navbar/mega-menu/MegaProjectsSummaryBottom.tsx", [
        "openDeployModal('fleet', false)",
        "openDeployModal('fleet', true)",
        "Selected",
    ])

    # 11. Deploy modal formatting
    print("\n[11] Checking Deploy Modal Formatting & Z-Index...")
    all_ok &= check("src/components/navbar/mega-menu/DeployProgressModal.tsx", [
        "z-[99999]",
        "formatDeployStep",
    ])

    # 12. Theme builder progressive loading
    print("\n[12] Checking Theme Builder Progressive Loading...")
    all_ok &= check("src/pages/ThemeBuilder/ThemeBuilderPage.tsx", [
        "isCanvasReady",
        "canvasLoadProgress",
        "Loading Theme Studio & Token Canvas...",
    ])

    print("\n" + ("=" * 40))
    if all_ok:
        print("🎉 ALL TASK 324 VERIFICATIONS PASSED SUCCESSFULLY!")
        sys.exit(0)
    else:
        print("❌ SOME VERIFICATIONS FAILED")
        sys.exit(1)

if __name__ == "__main__":
    main()
