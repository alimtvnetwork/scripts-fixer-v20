#!/usr/bin/env python3
"""
Automated Verification Script for Task 330:
Code Dryness & Custom Breakdown Options

Acceptance Criteria Verified:
1. Canonical Prompt 01-prompts/30-improvements/10-next-100-code-dryness-and-library-extraction.md exists & has 10 DRY clusters.
2. Native Antigravity Skill .agents/skills/next-100-code-dryness-improvements/skill.md exists.
3. Prompt template insert 01-prompts/31-next-wheel/inserts/dryness.md exists.
4. Rust ImprovementKind::Dryness, PROMPT_DRYNESS, parse aliases & discovery_prompt in src-tauri/src/modules/improvements/mod.rs.
5. TypeScript ImprovementKind union includes 'dryness' in src/services/improvementsService.ts.
6. Frontend category selector includes 'dryness' pill in PromptBreakdownPlanStep.tsx.
7. DetailNextBreakdownCapsule.tsx renders 'DRY' badge.
8. PromptBreakdownMenu.tsx renders 'Code Dryness' title, mode tabs, and mounts CustomBreakdownTab.
9. CustomBreakdownTab.tsx exists, has DEFAULT_CUSTOM_BREAKDOWNS, localStorage key, and buildCustomBreakdownPrompt.
10. BreakdownControlsCard.tsx, BreakdownSlotsList.tsx, and ImprovementsFlywheel.tsx include 'dryness'.
"""

import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

def run_checks() -> bool:
    all_passed = True

    def check(title: str, condition: bool, details: str = ""):
        nonlocal all_passed
        if condition:
            print(f"[PASS] {title}")
        else:
            print(f"[FAIL] {title} - {details}")
            all_passed = False

    print("=====================================================================")
    print("TASK 330: CODE DRYNESS & CUSTOM BREAKDOWN VERIFICATION")
    print("=====================================================================")

    # 1. Canonical Prompt
    prompt_path = REPO_ROOT / "01-prompts" / "30-improvements" / "10-next-100-code-dryness-and-library-extraction.md"
    check("1. Canonical DRY prompt exists", prompt_path.is_file(), str(prompt_path))
    if prompt_path.is_file():
        content = prompt_path.read_text(encoding="utf-8")
        check("1a. Canonical DRY prompt contains 10 DRY clusters", "The 10 Code Dryness Rule Families" in content and "10-Field Specification Card Schema" in content)
        check("1b. Canonical DRY prompt is substantive (>50 lines)", len(content.splitlines()) > 50)

    # 2. Antigravity Skill
    skill_path = REPO_ROOT / ".agents" / "skills" / "next-100-code-dryness-improvements" / "skill.md"
    check("2. DRY skill exists", skill_path.is_file(), str(skill_path))
    if skill_path.is_file():
        skill_content = skill_path.read_text(encoding="utf-8")
        check("2a. Skill frontmatter contains name & description", "name: next-100-code-dryness-improvements" in skill_content)

    # 3. Next Wheel insert
    insert_path = REPO_ROOT / "01-prompts" / "31-next-wheel" / "inserts" / "dryness.md"
    check("3. Next-wheel dryness insert exists", insert_path.is_file(), str(insert_path))

    # 4. Rust backend improvements module
    rust_mod = REPO_ROOT / "src-tauri" / "src" / "modules" / "improvements" / "mod.rs"
    check("4. Rust improvements mod.rs exists", rust_mod.is_file(), str(rust_mod))
    if rust_mod.is_file():
        mod_src = rust_mod.read_text(encoding="utf-8")
        check("4a. ImprovementKind enum has Dryness", "Dryness," in mod_src)
        check("4b. PROMPT_DRYNESS defined", "PROMPT_DRYNESS: &str =" in mod_src and "10-next-100-code-dryness-and-library-extraction.md" in mod_src)
        check("4c. parse aliases include dryness/dry/code_dryness", '"dryness" | "dry" | "code_dryness"' in mod_src)
        check("4d. discovery_prompt maps Dryness", "Self::Dryness => PROMPT_DRYNESS" in mod_src)

    # 5. TypeScript improvementsService
    ts_service = REPO_ROOT / "src" / "services" / "improvementsService.ts"
    check("5. improvementsService.ts exists", ts_service.is_file(), str(ts_service))
    if ts_service.is_file():
        ts_src = ts_service.read_text(encoding="utf-8")
        check("5a. ImprovementKind type includes 'dryness'", "'dryness'" in ts_src)
        check("5b. planAll categories include 'dryness'", "'dryness'" in ts_src and "planAll" in ts_src)

    # 6. PromptBreakdownPlanStep category pill
    plan_step = REPO_ROOT / "src" / "components" / "instances" / "PromptTreeView" / "header" / "breakdown" / "PromptBreakdownPlanStep.tsx"
    check("6. PromptBreakdownPlanStep.tsx exists", plan_step.is_file(), str(plan_step))
    if plan_step.is_file():
        plan_src = plan_step.read_text(encoding="utf-8")
        check("6a. CATEGORY_ITEMS includes 'dryness'", "'dryness'" in plan_src and "CATEGORY_ITEMS" in plan_src)

    # 7. DetailNextBreakdownCapsule
    capsule = REPO_ROOT / "src" / "components" / "instances" / "PromptTreeView" / "header" / "DetailNextBreakdownCapsule.tsx"
    check("7. DetailNextBreakdownCapsule.tsx exists", capsule.is_file(), str(capsule))
    if capsule.is_file():
        cap_src = capsule.read_text(encoding="utf-8")
        check("7a. Renders 'DRY' badge for dryness category", "'DRY'" in cap_src and "breakdownCategory === 'dryness'" in cap_src)

    # 8. PromptBreakdownMenu
    menu = REPO_ROOT / "src" / "components" / "instances" / "PromptTreeView" / "header" / "PromptBreakdownMenu.tsx"
    check("8. PromptBreakdownMenu.tsx exists", menu.is_file(), str(menu))
    if menu.is_file():
        menu_src = menu.read_text(encoding="utf-8")
        check("8a. Contains 'Code Dryness' title mapping", "'Code Dryness'" in menu_src)
        check("8b. Contains 'custom_breakdowns' tab", "custom_breakdowns" in menu_src)
        check("8c. Mounts CustomBreakdownTab component", "<CustomBreakdownTab" in menu_src)

    # 9. CustomBreakdownTab component
    custom_tab = REPO_ROOT / "src" / "components" / "instances" / "PromptTreeView" / "header" / "breakdown" / "CustomBreakdownTab.tsx"
    check("9. CustomBreakdownTab.tsx exists", custom_tab.is_file(), str(custom_tab))
    if custom_tab.is_file():
        tab_src = custom_tab.read_text(encoding="utf-8")
        check("9a. Exports DEFAULT_CUSTOM_BREAKDOWNS", "DEFAULT_CUSTOM_BREAKDOWNS" in tab_src)
        check("9b. Uses localStorage key agm_custom_next_breakdowns", "agm_custom_next_breakdowns" in tab_src)
        check("9c. Exports buildCustomBreakdownPrompt", "buildCustomBreakdownPrompt" in tab_src)

    # 10. Secondary category integrations
    card = REPO_ROOT / "src" / "components" / "instances" / "PromptTreeView" / "breakdown" / "BreakdownControlsCard.tsx"
    slots = REPO_ROOT / "src" / "components" / "instances" / "PromptTreeView" / "breakdown" / "BreakdownSlotsList.tsx"
    flywheel = REPO_ROOT / "src" / "components" / "telegram" / "ImprovementsFlywheel.tsx"
    check("10a. BreakdownControlsCard includes dryness", card.is_file() and "'dryness'" in card.read_text(encoding="utf-8"))
    check("10b. BreakdownSlotsList includes dryness", slots.is_file() and "'dryness'" in slots.read_text(encoding="utf-8"))
    check("10c. ImprovementsFlywheel includes dryness", flywheel.is_file() and "'dryness'" in flywheel.read_text(encoding="utf-8"))

    print("=====================================================================")
    if all_passed:
        print("ALL VERIFICATION CHECKS PASSED (100% OK)")
    else:
        print("SOME VERIFICATION CHECKS FAILED")
    print("=====================================================================")
    return all_passed

if __name__ == "__main__":
    success = run_checks()
    sys.exit(0 if success else 1)
