"""Terminal rich tree, left-hand padding, and box-drawing telemetry formatter."""

from __future__ import annotations


class AnsiColorConstants:
    """Standard terminal ANSI escape codes."""

    RESET = "\033[0m"
    BOLD = "\033[1m"
    CYAN = "\033[36m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"


class TerminalUi:
    """Renders formatted tree diagrams, badges, and padded telemetry in the terminal."""

    LEFT_PAD = "  "

    @classmethod
    def print_workflow_header(cls, title: str) -> None:
        """Render distinct banner header with left-hand padding."""
        border = "=" * 65
        print(f"\n{cls.LEFT_PAD}{AnsiColorConstants.CYAN}{border}")
        print(f"{cls.LEFT_PAD}  {AnsiColorConstants.BOLD}{title}{AnsiColorConstants.RESET}")
        print(f"{cls.LEFT_PAD}{AnsiColorConstants.CYAN}{border}{AnsiColorConstants.RESET}\n", flush=True)

    @classmethod
    def print_section_heading(cls, title: str, icon: str = "📁") -> None:
        """Render section heading with standardized icon and left padding."""
        print(f"{cls.LEFT_PAD}{icon} {AnsiColorConstants.BOLD}{title}{AnsiColorConstants.RESET}\n", flush=True)

    @classmethod
    def print_tree_node(cls, label: str, value: str, is_last: bool = False, pipe: str = "") -> None:
        """Render a hierarchical tree node with box-drawing branches and left padding."""
        branch = "└── " if is_last else "├── "
        print(f"{cls.LEFT_PAD}{pipe}{branch}{label}: {value}", flush=True)

    @classmethod
    def print_error_tree(cls, action_title: str, err_code: str, err_msg: str, diag: str = "") -> None:
        """Render explicit error diagnostics tree with left padding and zero swallowing."""
        border = "=" * 65
        print(f"\n{cls.LEFT_PAD}{AnsiColorConstants.RED}{border}")
        print(f"{cls.LEFT_PAD}  [FAIL] {action_title}")
        print(f"{cls.LEFT_PAD}{border}{AnsiColorConstants.RESET}")
        print(f"{cls.LEFT_PAD}❌ Error Code    : {err_code}")
        print(f"{cls.LEFT_PAD}💬 Error Message : {err_msg}")
        if diag:
            print(f"{cls.LEFT_PAD}🔍 Diagnostics   : {diag}")
        print(f"{cls.LEFT_PAD}{AnsiColorConstants.RED}{border}{AnsiColorConstants.RESET}\n", flush=True)
