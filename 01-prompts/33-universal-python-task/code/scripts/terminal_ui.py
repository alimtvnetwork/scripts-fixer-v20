"""Universal terminal UI formatter with left-hand padding and tree hierarchies."""

from __future__ import annotations

import os
from typing import Any


class AnsiColorConstants:
    """Terminal ANSI escape color constants."""

    RESET = "\033[0m"
    BOLD = "\033[1m"
    RED = "\033[91m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    MAGENTA = "\033[95m"
    CYAN = "\033[96m"
    WHITE = "\033[97m"
    GRAY = "\033[90m"


class TerminalUi:
    """Renders formatted tree diagrams, badges, and padded telemetry in the terminal."""

    LEFT_PAD = "  "  # 2-space left padding invariant for readable terminal margins

    @classmethod
    def print_workflow_header(cls, title: str) -> None:
        """Render distinct banner header with left-hand padding."""
        border = "=" * 65
        pad = cls.LEFT_PAD
        print(f"\n{pad}{AnsiColorConstants.CYAN}{border}")
        print(f"{pad}  {AnsiColorConstants.BOLD}{title}{AnsiColorConstants.RESET}")
        print(f"{pad}{AnsiColorConstants.CYAN}{border}{AnsiColorConstants.RESET}\n", flush=True)

    @classmethod
    def print_section_title(cls, icon: str, title: str) -> None:
        """Render section heading with standardized icon and left padding."""
        pad = cls.LEFT_PAD
        print(f"{pad}{icon}  {AnsiColorConstants.BOLD}{title}{AnsiColorConstants.RESET}:", flush=True)

    @classmethod
    def print_tree_node(
        cls,
        title: str,
        properties: list[tuple[str, str]],
        is_last: bool = False,
        status_badge: str = "",
    ) -> None:
        """Render a hierarchical tree node with box-drawing branches and left padding."""
        pad = cls.LEFT_PAD
        branch = "└──" if is_last else "├──"
        pipe = "   " if is_last else "│  "
        badge_str = f" {status_badge}" if status_badge else ""
        print(f"{pad}{branch} {AnsiColorConstants.BOLD}{title}{AnsiColorConstants.RESET}{badge_str}")
        prop_count = len(properties)
        for idx, (label, val) in enumerate(properties, start=1):
            sub_branch = "└──" if idx == prop_count else "├──"
            print(f"{pad}{pipe} {sub_branch} {label.ljust(18)}: {val}")
        print(f"{pad}{pipe}", flush=True)

    @classmethod
    def print_summary_card(cls, title: str, items: list[tuple[str, str, bool]]) -> None:
        """Render summary card with boolean-colored metrics and box-drawing lines."""
        pad = cls.LEFT_PAD
        print(f"{pad}📋 {AnsiColorConstants.BOLD}{title}{AnsiColorConstants.RESET}")
        total = len(items)
        for idx, (icon, label, is_ok) in enumerate(items, start=1):
            branch = "└──" if idx == total else "├──"
            c_val = f"{AnsiColorConstants.GREEN}[PASS]{AnsiColorConstants.RESET}" if is_ok else f"{AnsiColorConstants.RED}[FAIL]{AnsiColorConstants.RESET}"
            print(f"{pad}{branch} {icon} {label.ljust(22)}: {c_val}")
        print("", flush=True)

    @classmethod
    def print_error_tree(cls, operation: str, error_code: str, message: str, details: str = "") -> None:
        """Render explicit error diagnostics tree with left padding and zero swallowing."""
        pad = cls.LEFT_PAD
        border = "=" * 65
        print(f"\n{pad}{AnsiColorConstants.RED}{border}")
        print(f"{pad}  {AnsiColorConstants.BOLD}[FAIL] Execution Error: {operation}{AnsiColorConstants.RESET}")
        print(f"{pad}{AnsiColorConstants.RED}{border}{AnsiColorConstants.RESET}")
        print(f"{pad}❌ Error Code    : {error_code}")
        print(f"{pad}💬 Error Message : {message}")
        if details:
            print(f"{pad}🔍 Diagnostics   : {details}")
        print("", flush=True)

    @classmethod
    def print_rich_help(cls, app_name: str, actions: list[tuple[str, str]], flags: list[tuple[str, str]]) -> None:
        """Render formatted help menu and command reference with left padding."""
        cls.print_workflow_header(f"{app_name} — Universal Task Engine")
        pad = cls.LEFT_PAD
        print(f"{pad}Usage: pwsh -NoProfile -File run.ps1 <action> [options]\n")
        print(f"{pad}⚡ Supported Actions:")
        for name, desc in actions:
            print(f"{pad}  ├── {name.ljust(12)}: {desc}")
        print(f"\n{pad}🔧 Command Flags:")
        for flag, desc in flags:
            print(f"{pad}  ├── {flag.ljust(24)}: {desc}")
        print("", flush=True)
