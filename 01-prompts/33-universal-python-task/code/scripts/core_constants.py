"""Core immutable constants for universal Python task automation."""

from __future__ import annotations

import os
import tempfile
from pathlib import Path


class AnsiColorConstants:
    """ANSI terminal styling and color escape sequences."""

    RESET = "\033[0m"
    BOLD = "\033[1m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    GRAY = "\033[90m"


class LogBadgeConstants:
    """Standardized ANSI badges for console telemetry."""

    OK = "[  OK  ]"
    FAIL = "[ FAIL ]"
    WARN = "[ WARN ]"
    INFO = "[ INFO ]"
    SKIP = "[ SKIP ]"
    AUDIT = "[ AUDT ]"


class SoftwarePackageConstants:
    """Software package identifiers and package manager commands."""

    CHOCOLATEY = "choco"
    WINGET = "winget"
    VSCODE = "code"
    CURSOR = "cursor"
    GIT = "git"
    PYTHON = "python"
    VMWARE = "vmware"
    WHATSAPP = "WhatsApp"
    CLAUDE_DESKTOP = "Claude"


def _resolve_system_root() -> Path:
    if os.name == "nt":
        root_str = os.environ.get("SystemRoot") or os.environ.get("WINDIR") or "C:\\Windows"
        return Path(root_str)
    return Path("/")


def _resolve_windows_temp() -> Path:
    if os.name == "nt":
        return _resolve_system_root() / "Temp"
    return Path("/tmp")


def _resolve_user_temp() -> Path:
    return Path(tempfile.gettempdir())


def _resolve_prefetch() -> Path:
    if os.name == "nt":
        return _resolve_system_root() / "Prefetch"
    return _resolve_user_temp() / "prefetch"


def _resolve_crash_dumps() -> Path:
    if os.name == "nt":
        return _resolve_system_root() / "Minidump"
    var_crash = Path("/var/crash")
    return var_crash if var_crash.exists() else _resolve_user_temp()


class OsPathConstants:
    """Standard operating system and directory cache paths resolved dynamically."""

    DEFAULT_LOGS_DIR = "logs"
    DEFAULT_LOG_FILE = "logs/task.log"
    DEFAULT_SUMMARY_FILE = "logs/taskSummary.json"

    @classmethod
    def get_system_root(cls) -> Path:
        """Resolve OS system root directory dynamically across Windows and POSIX."""
        return _resolve_system_root()

    @classmethod
    def get_windows_temp(cls) -> Path:
        """Resolve system temporary directory dynamically."""
        return _resolve_windows_temp()

    @classmethod
    def get_user_temp(cls) -> Path:
        """Resolve user temporary directory using standard tempfile OS function."""
        return _resolve_user_temp()

    @classmethod
    def get_prefetch(cls) -> Path:
        """Resolve Windows prefetch directory dynamically."""
        return _resolve_prefetch()

    @classmethod
    def get_crash_dumps(cls) -> Path:
        """Resolve system crash dumps / minidump directory dynamically."""
        return _resolve_crash_dumps()

    # Dynamic class-level string properties evaluated at module load
    WINDOWS_TEMP = str(_resolve_windows_temp())
    USER_TEMP = str(_resolve_user_temp())
    PREFETCH = str(_resolve_prefetch())
    CRASH_DUMPS = str(_resolve_crash_dumps())


class ProtectedNameConstants:
    """Files and patterns strictly protected from deletion or modification."""

    GITKEEP = ".gitkeep"
    CONFIG_JSON = "config.json"
    SETTINGS_JSON = "settings.json"
    ENV_FILE = ".env"
    PROTECTED_EXTENSIONS = (".git", ".svn", ".hg")


class StepTargetConstants:
    """Canonical step target identifiers borrowed from OS optimization."""

    DISM_CLEANUP = "DISM Component Store"
    WINDOWS_UPDATES = "Windows Updates"
    STALE_BUILD_TARGETS = "Stale Build Targets"
    DEVTOOLS_CACHES = "Dev Tools Caches"
    GITMAP_SCAN = "GitMap Work Scan"
    ANTIGRAVITY_CLEANUP = "Antigravity Chats"
    CURSOR_CHAT_SYNC = "Cursor Chat Sync"
    WORKDIR_FLEET = "Work Directory Fleet"


class ProjectNameConstants:
    """Canonical repository and project identifiers across fleet."""

    GITMAP = "gitmap"
    ANTIGRAVITY_MANAGER = "Antigravity-Manager"
    REPO_CACHE = "repo-cache"
    CAT_MY = "cat-my"
    LARA_PUBLISHING = "lara-publishing"
    WP_EXAM = "wp-exam"


class CursorSyncConstants:
    """SQLite tables and keys used during Cursor chat state sync."""

    TABLE_ITEM_TABLE = "ItemTable"
    TABLE_CURSOR_DISK_KV = "cursorDiskKV"
    TABLE_COMPOSER_HEADERS = "composerHeaders"
    KEY_CURSOR_AUTH_PREFIX = "cursorAuth/"
    KEY_COMPOSER_DATA_PREFIX = "composerData:"


class WindowsServiceConstants:
    """Canonical Windows service identifiers."""

    AUDIO_SRV = "AudioSrv"
    PRINT_SPOOLER = "Spooler"
    WINDOWS_UPDATE = "wuauserv"
    VMWARE_NAT = "VMnetDHCP"


class OsCachePathConstants:
    """Common OS-level cache directory relative and absolute patterns."""

    SYSTEM_TEMP = r"C:\Windows\Temp"
    USER_TEMP = "TEMP"
    PIP_CACHE = r"pip\cache"
    NPM_CACHE = r"npm-cache"
    GRADLE_CACHE = r".gradle\caches"


class TimeoutConstants:
    """Execution timeout thresholds in seconds."""

    DEFAULT_TIMEOUT_SEC = 15
    LONG_TIMEOUT_SEC = 60


class GitSyncConstants:
    """Git repository synchronization defaults and SSH prefixes."""

    DEFAULT_WORKERS = 4
    SSH_PREFIX = "git@github.com:"
    HTTPS_PREFIX = "https://github.com/"
    CONFIG_FILENAME = "config.json"


class TableConstants:
    """PascalCase SQLite table names."""

    TASK_EXECUTIONS: str = "TaskExecutions"
    CREDENTIALS: str = "Credentials"
    WP_CREDENTIALS: str = "WpCredentials"
    PAGE_BACKUPS: str = "PageBackups"
    AUDIT_LOGS: str = "AuditLogs"


class EnvConstants:
    """Canonical environment configuration keys and defaults."""

    ENV_WORK: str = "WORK"
    ENV_GITMAP_WORK_DIR: str = "GITMAP_WORK_DIR"
    SECTION_ENVIRONMENT: str = "environment"
    DEFAULT_CONFIG_PATH: str = "config/env.ini"


class EncodingConstants:
    """Standard character encoding format constants."""

    UTF8: str = "utf-8"
    ASCII: str = "ascii"
    UTF16: str = "utf-16"
    LATIN1: str = "latin-1"
