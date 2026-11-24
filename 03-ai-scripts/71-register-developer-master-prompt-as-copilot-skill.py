"""Register Developer Daily Master Prompt as an AI skill or system instruction.

Supports GitHub Copilot (.github/copilot-instructions.md), Cursor (.cursorrules /
.cursor/rules/), and Google Antigravity (.agents/skills/developer-daily-work/skill.md).
"""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from pathlib import Path
from typing import Any, Generic, TypeVar

T = TypeVar("T")
E = TypeVar("E", bound="BaseParsableEnum")


@dataclass(frozen=True)
class AppError:
    """Structured immutable application error container."""

    code: str
    message: str
    operation: str = ""
    details: dict[str, Any] = field(default_factory=dict)

    def __str__(self) -> str:
        """Format error as human-readable string."""
        if self.operation:
            return f"[{self.code}] {self.operation}: {self.message}"

        return f"[{self.code}] {self.message}"


class Result(Generic[T]):
    """Monadic container holding either a value or an AppError."""

    def __init__(self, value: T | None, error: AppError | None, is_safe: bool) -> None:
        self._value = value
        self._error = error
        self._is_safe = is_safe

    @classmethod
    def ok(cls, value: T) -> Result[T]:
        """Construct successful result."""
        return cls(value=value, error=None, is_safe=True)

    @classmethod
    def fail(cls, error: AppError) -> Result[T]:
        """Construct failed result."""
        return cls(value=None, error=error, is_safe=False)

    @property
    def is_safe(self) -> bool:
        """Check whether result is successful."""
        return self._is_safe

    @property
    def has_error(self) -> bool:
        """Check whether result holds an error."""
        return not self._is_safe

    @property
    def value(self) -> T:
        """Retrieve unwrapped value."""
        if self.has_error:
            raise RuntimeError(f"Cannot unwrap failed result: {self._error}")

        return self._value  # type: ignore[return-value]

    @property
    def error(self) -> AppError:
        """Retrieve unwrapped error."""
        if self.is_safe:
            raise RuntimeError("Cannot retrieve error from successful result")

        return self._error  # type: ignore[return-value]


class BaseParsableEnum(str, Enum):
    """Base parsable string enum with validation."""

    @classmethod
    def all_values(cls) -> list[str]:
        """List all valid enum values."""
        return [item.value for item in cls]

    @classmethod
    def is_valid(cls, raw: str) -> bool:
        """Check if raw string matches enum."""
        return raw.strip().lower() in cls.all_values()

    @classmethod
    def parse(cls: type[E], raw: str) -> Result[E]:
        """Parse raw string into enum."""
        normalized = raw.strip().lower()
        for item in cls:
            if item.value == normalized:
                return Result.ok(item)

        err = AppError("VALIDATION_ERROR", f"Invalid {cls.__name__}: '{raw}'. Allowed: {cls.all_values()}")
        return Result.fail(err)


class TargetPlatformType(BaseParsableEnum):
    """Supported AI tooling target platforms."""

    ALL = "all"
    COPILOT = "copilot"
    CURSOR = "cursor"
    ANTIGRAVITY = "antigravity"


class ExitCodeType(IntEnum):
    """POSIX and Windows standard exit codes."""

    SUCCESS = 0
    GENERAL_ERROR = 1
    USAGE_ERROR = 2
    SECURITY_ERROR = 3


class CredentialSecurityScanner:
    """Detects and alerts on unprotected credential files."""

    CREDENTIAL_PATTERNS = [
        ".env",
        ".env.*",
        "*.pem",
        "*.key",
        "id_rsa*",
        "id_ed25519*",
        "wp-credentials.json",
        "credentials.json",
    ]

    @classmethod
    def scan_for_credentials(cls, workspace: Path) -> list[str]:
        """Find unprotected credential files in workspace root."""
        found = []
        for pat in cls.CREDENTIAL_PATTERNS:
            for match in workspace.glob(pat):
                if match.name != ".env.example":
                    found.append(match.name)

        return sorted(list(set(found)))

    @classmethod
    def verify_gitignore_protection(cls, workspace: Path) -> bool:
        """Check if .gitignore exists and protects .env files."""
        gitignore = workspace / ".gitignore"
        if not gitignore.exists():
            return False

        content = gitignore.read_text(encoding="utf-8", errors="ignore")
        return ".env" in content


def load_master_prompt_content(repo_root: Path) -> Result[str]:
    """Load canonical master prompt content."""
    prompt_path = repo_root / "01-prompts" / "36-developer-daily-master-prompt" / "01-developer-daily-master-prompt.md"
    if not prompt_path.exists():
        fallback_path = repo_root / "01-prompts" / "35-universal-single-file-prompts" / "04-developer-daily-master-prompt.md"
        if fallback_path.exists():
            return Result.ok(fallback_path.read_text(encoding="utf-8"))

        return Result.fail(AppError("PROMPT_NOT_FOUND", f"Master prompt file not found at {prompt_path}"))

    return Result.ok(prompt_path.read_text(encoding="utf-8"))


def install_copilot_instructions(workspace: Path, prompt_text: str, is_dry_run: bool) -> Result[Path]:
    """Register prompt as GitHub Copilot instruction."""
    dest = workspace / ".github" / "copilot-instructions.md"
    if is_dry_run:
        return Result.ok(dest)

    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(prompt_text, encoding="utf-8", newline="\n")
    return Result.ok(dest)


def install_cursor_rules(workspace: Path, prompt_text: str, is_dry_run: bool) -> Result[list[Path]]:
    """Register prompt as Cursor rules."""
    dest_rules = workspace / ".cursorrules"
    dest_mdc = workspace / ".cursor" / "rules" / "developer-daily-work.mdc"
    if is_dry_run:
        return Result.ok([dest_rules, dest_mdc])

    dest_rules.write_text(prompt_text, encoding="utf-8", newline="\n")
    dest_mdc.parent.mkdir(parents=True, exist_ok=True)
    dest_mdc.write_text(prompt_text, encoding="utf-8", newline="\n")
    return Result.ok([dest_rules, dest_mdc])


def install_antigravity_skill(workspace: Path, repo_root: Path, is_dry_run: bool) -> Result[Path]:
    """Register prompt as Google Antigravity skill."""
    dest = workspace / ".agents" / "skills" / "developer-daily-work" / "skill.md"
    if is_dry_run:
        return Result.ok(dest)

    source = repo_root / ".agents" / "skills" / "developer-daily-work" / "skill.md"
    content = source.read_text(encoding="utf-8") if source.exists() else "---\nname: developer-daily-work\n---"
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(content, encoding="utf-8", newline="\n")
    return Result.ok(dest)


def execute_registration(
    target: TargetPlatformType,
    workspace: Path,
    repo_root: Path,
    prompt_text: str,
    is_dry_run: bool,
) -> ExitCodeType:
    """Execute installation across chosen target platforms."""
    print(f"[ INFO ] Registering master prompt for target '{target.value}' into {workspace}")

    if target in (TargetPlatformType.COPILOT, TargetPlatformType.ALL):
        c_res = install_copilot_instructions(workspace, prompt_text, is_dry_run)
        print(f" [  OK  ] GitHub Copilot: {c_res.value} {'(DRY-RUN)' if is_dry_run else ''}")

    if target in (TargetPlatformType.CURSOR, TargetPlatformType.ALL):
        cu_res = install_cursor_rules(workspace, prompt_text, is_dry_run)
        print(f" [  OK  ] Cursor Rules: {cu_res.value} {'(DRY-RUN)' if is_dry_run else ''}")

    if target in (TargetPlatformType.ANTIGRAVITY, TargetPlatformType.ALL):
        a_res = install_antigravity_skill(workspace, repo_root, is_dry_run)
        print(f" [  OK  ] Antigravity Skill: {a_res.value} {'(DRY-RUN)' if is_dry_run else ''}")

    return ExitCodeType.SUCCESS


def parse_arguments() -> argparse.ArgumentParser:
    """Construct command-line argument parser."""
    parser = argparse.ArgumentParser(description="Register Developer Daily Master Prompt as AI Skill")
    parser.add_argument(
        "--target",
        default=TargetPlatformType.ALL.value,
        choices=TargetPlatformType.all_values(),
        help="Target AI platform (default: all)",
    )
    parser.add_argument(
        "--workspace",
        default=".",
        help="Target workspace root directory (default: current directory)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Inspect installation actions without writing files",
    )
    return parser


def check_and_report_security(workspace: Path) -> None:
    """Scan and print credential security warnings."""
    creds = CredentialSecurityScanner.scan_for_credentials(workspace)
    if creds:
        print(f"[ WARN ] Detected live credential file(s) in workspace: {creds}")
        print("         The master prompt strictly bans AI reading these files.")

    is_protected = CredentialSecurityScanner.verify_gitignore_protection(workspace)
    if not is_protected:
        print("[ WARN ] .gitignore does not explicitly exclude '.env'. Add '.env' to prevent leaks.")


def main() -> int:
    """Main CLI execution entrypoint."""
    parser = parse_arguments()
    args = parser.parse_args()

    target_res = TargetPlatformType.parse(args.target)
    if target_res.has_error:
        print(f"[ FAIL ] {target_res.error}")
        return int(ExitCodeType.USAGE_ERROR)

    workspace = Path(args.workspace).resolve()
    repo_root = Path(__file__).resolve().parent.parent

    check_and_report_security(workspace)

    prompt_res = load_master_prompt_content(repo_root)
    if prompt_res.has_error:
        print(f"[ FAIL ] {prompt_res.error}")
        return int(ExitCodeType.GENERAL_ERROR)

    exit_code = execute_registration(
        target=target_res.value,
        workspace=workspace,
        repo_root=repo_root,
        prompt_text=prompt_res.value,
        is_dry_run=args.dry_run,
    )
    return int(exit_code)


if __name__ == "__main__":
    sys.exit(main())
