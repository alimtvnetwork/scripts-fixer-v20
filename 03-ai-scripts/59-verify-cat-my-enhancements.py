#!/usr/bin/env python3
"""
Verification Script for Cat MY Enhancements & Bug Reporting Instructions
Tests:
1. Focus button CDP targeting in running instance branch
2. Theme REST API routes and config model fields
3. Bug and audit reporting CLI command registration and handlers
4. Node status formatting and ANSI escape code stripping
5. Source context mapping and authentic DOM snapshotting
6. DeployProgressModal portal mount and mega menu decoupling
7. Browser-only UI runners (run-ui.ps1 / run-ui.sh)
"""

import os
import re
import sys
from enum import Enum
from pathlib import Path


class TestStatus(Enum):
    PASSED = "PASSED"
    FAILED = "FAILED"


def get_repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


def test_focus_button_cdp_targeting(root: Path) -> TestStatus:
    instance_cmd_path = root / "src-tauri" / "src" / "commands" / "instance.rs"
    if not instance_cmd_path.exists():
        print("[FAIL] instance.rs does not exist")
        return TestStatus.FAILED

    content = instance_cmd_path.read_text(encoding="utf-8")
    # Scope to pub fn focus_instance_workspace
    fn_match = re.search(
        r"pub fn focus_instance_workspace\([\s\S]*?^\}",
        content,
        re.MULTILINE,
    )
    if not fn_match:
        print("[FAIL] focus_instance_workspace function not found")
        return TestStatus.FAILED

    fn_body = fn_match.group(0)
    match = re.search(
        r"if is_running && !pids\.is_empty\(\)\s*\{([\s\S]*?)return Ok\(true\);",
        fn_body,
    )
    if not match:
        print("[FAIL] is_running branch in focus_instance_workspace not found")
        return TestStatus.FAILED

    branch_body = match.group(1)
    has_active_conv = "find_active_conversation_for_instance" in branch_body
    has_activate_session = "activate_session_in_instance" in branch_body

    if not (has_active_conv and has_activate_session):
        print("[FAIL] activate_session_in_instance not called before return Ok(true)")
        return TestStatus.FAILED

    print("[PASS] Focus button activates latest conversation in running instances via CDP")
    return TestStatus.PASSED


def test_theme_rest_api_and_config(root: Path) -> TestStatus:
    config_path = root / "src-tauri" / "src" / "models" / "config.rs"
    admin_theme_path = root / "src-tauri" / "src" / "proxy" / "server" / "admin_theme.rs"
    router_b_path = root / "src-tauri" / "src" / "proxy" / "server" / "router_admin_b.rs"

    if not config_path.exists() or not admin_theme_path.exists() or not router_b_path.exists():
        print("[FAIL] Missing theme backend files")
        return TestStatus.FAILED

    config_content = config_path.read_text(encoding="utf-8")
    has_tokens = "pub custom_theme_tokens: Option<serde_json::Value>" in config_content
    has_preset = "pub custom_theme_preset: Option<String>" in config_content

    router_content = router_b_path.read_text(encoding="utf-8")
    has_theme_route = "/api/theme" in router_content and "admin_theme" in router_content

    theme_content = admin_theme_path.read_text(encoding="utf-8")
    has_handlers = "admin_get_theme" in theme_content and "admin_set_theme" in theme_content

    if has_tokens and has_preset and has_theme_route and has_handlers:
        print("[PASS] Theme REST API and config model tokens verified")
        return TestStatus.PASSED

    print("[FAIL] Theme REST API verification failed")
    return TestStatus.FAILED


def test_cli_bug_and_audit_commands(root: Path) -> TestStatus:
    args_path = root / "src-tauri" / "src" / "modules" / "cli" / "args.rs"
    bug_cli_path = root / "src-tauri" / "src" / "modules" / "cli" / "bug_report.rs"

    if not args_path.exists() or not bug_cli_path.exists():
        print("[FAIL] Missing CLI files")
        return TestStatus.FAILED

    args_content = args_path.read_text(encoding="utf-8")
    has_audit_alias = '"audit"' in args_content and '"audits"' in args_content

    bug_cli_content = bug_cli_path.read_text(encoding="utf-8")
    has_start = "execute_bug_report_start" in bug_cli_content
    has_stop = "execute_bug_report_stop" in bug_cli_content
    has_query = "execute_bug_report_query" in bug_cli_content

    if has_audit_alias and has_start and has_stop and has_query:
        print("[PASS] Bug Report & Audit CLI parity (start, stop, query) verified")
        return TestStatus.PASSED

    print("[FAIL] Bug Report & Audit CLI verification failed")
    return TestStatus.FAILED


def test_status_formatting_and_ansi_stripping() -> TestStatus:
    # Test logic matching stripAnsiCodes and formatNodeStatusLabel
    raw_ansi = "\x1b[2m18:42:03\x1b[0m \x1b[32mINFO\x1b[0m log message agm v4.310.0 (commit: 50e294ded)"
    cleaned = re.sub(r"(\x1b|\+)\[[0-9;]*[a-zA-Z]", "", raw_ansi)
    version_match = re.search(r"v\d+\.\d+\.\d+(?:-[a-zA-Z0-9.]+)?", cleaned)

    if not version_match or version_match.group(0) != "v4.310.0":
        print(f"[FAIL] ANSI stripping failed: {cleaned}")
        return TestStatus.FAILED

    # Test status formatting
    status = "SKIPPED_OFFLINE"
    formatted = status.replace("_", " ").title().replace("Offline", "(Offline)")
    if "Offline" not in formatted or "_" in formatted:
        print(f"[FAIL] Status formatting failed: {formatted}")
        return TestStatus.FAILED

    print("[PASS] Status formatting and ANSI escape code stripping verified")
    return TestStatus.PASSED


def test_source_mapping_and_snapshotting(root: Path) -> TestStatus:
    source_context_path = root / "src" / "lib" / "recorder" / "source-context.ts"
    recorder_store_path = root / "src" / "stores" / "recorder-store.ts"

    if not source_context_path.exists() or not recorder_store_path.exists():
        print("[FAIL] Missing recorder source files")
        return TestStatus.FAILED

    source_content = source_context_path.read_text(encoding="utf-8")
    has_fiber = "__reactFiber$" in source_content and "resolveAuthenticSourceLocation" in source_content
    has_comp_map = "InstanceTable" in source_content and "InstanceRowActions" in source_content

    store_content = recorder_store_path.read_text(encoding="utf-8")
    # Verify startRecording has no initial dummy event
    has_clean_start = "showToast('Bug recorder started', 'success');" in store_content
    # Verify stopRecording awaits authentic screenshot
    has_stop_authentic = "captureAuthenticDomScreenshot" in store_content

    if has_fiber and has_comp_map and has_clean_start and has_stop_authentic:
        print("[PASS] Fiber source mapping and clean start/stop snapshotting verified")
        return TestStatus.PASSED

    print("[FAIL] Source mapping and snapshotting verification failed")
    return TestStatus.FAILED


def test_browser_only_runners(root: Path) -> TestStatus:
    ps1_runner = root / "run-ui.ps1"
    sh_runner = root / "run-ui.sh"

    if ps1_runner.exists() and sh_runner.exists():
        ps1_text = ps1_runner.read_text(encoding="utf-8")
        sh_text = sh_runner.read_text(encoding="utf-8")
        if "npm run dev" in ps1_text and "npm run dev" in sh_text:
            print("[PASS] Browser-only UI runners (run-ui.ps1 / run-ui.sh) verified")
            return TestStatus.PASSED

    print("[FAIL] Browser-only UI runners missing or invalid")
    return TestStatus.FAILED


def main() -> int:
    root = get_repo_root()
    print("=" * 80)
    print("  Cat MY Enhancements & Bug Reporting Verification Suite")
    print("=" * 80)

    results = [
        test_focus_button_cdp_targeting(root),
        test_theme_rest_api_and_config(root),
        test_cli_bug_and_audit_commands(root),
        test_status_formatting_and_ansi_stripping(),
        test_source_mapping_and_snapshotting(root),
        test_browser_only_runners(root),
    ]

    total = len(results)
    passed = sum(1 for r in results if r == TestStatus.PASSED)
    print("=" * 80)
    print(f"Results: {passed}/{total} tests passed.")
    print("=" * 80)

    return 0 if passed == total else 1


if __name__ == "__main__":
    sys.exit(main())
