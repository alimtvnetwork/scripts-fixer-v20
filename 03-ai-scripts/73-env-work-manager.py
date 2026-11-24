#!/usr/bin/env python3
"""
73-env-work-manager.py — Cross-Platform $WORK & Dynamic ENV Configuration Engine.
Resolves workspace root dynamically from environment or user prompt, establishes persistent
$WORK across OS reboots, configures shell profiles for 'cd $WORK', and injects variables on the fly.
"""
from __future__ import annotations

import argparse
import configparser
import os
import platform
import re
import subprocess
import sys
from enum import Enum
from pathlib import Path
from typing import ClassVar, Final, NamedTuple, Optional, Pattern


class ActionType(str, Enum):
    """Supported CLI action verbs."""
    STATUS = "status"
    INIT_WORK = "init-work"
    SET = "set"


class EnvConstants:
    """Canonical environment configuration keys and defaults."""
    ENV_WORK: Final[str] = "WORK"
    ENV_GITMAP_WORK_DIR: Final[str] = "GITMAP_WORK_DIR"
    SECTION_ENVIRONMENT: Final[str] = "environment"
    DEFAULT_CONFIG_PATH: Final[str] = "config/env.ini"


class LazyRegex:
    """Thread-safe lazy regular expression compiler (cached on demand)."""
    _cache: ClassVar[dict[str, Pattern[str]]] = {}

    @classmethod
    def get(cls, pattern: str, flags: int = 0) -> Pattern[str]:
        """Retrieve compiled pattern from cache or compile and store."""
        key = f"{pattern}::{flags}"
        if key not in cls._cache:
            cls._cache[key] = re.compile(pattern, flags)
        return cls._cache[key]

    @classmethod
    def clear(cls) -> None:
        """Clear cached patterns."""
        cls._cache.clear()


class EnvResult(NamedTuple):
    is_success: bool
    message: str
    value: Optional[str] = None


def get_work_dir(interactive: bool = True) -> Path:
    """
    Discover workspace root directory dynamically.
    Checks $WORK, $GITMAP_WORK_DIR, repository parent, or prompts the operator.
    Never hardcodes fixed filesystem paths.
    """
    work_val = os.environ.get(EnvConstants.ENV_WORK)
    if work_val and Path(work_val).exists():
        return Path(work_val).resolve()

    gitmap_work_val = os.environ.get(EnvConstants.ENV_GITMAP_WORK_DIR)
    if gitmap_work_val and Path(gitmap_work_val).exists():
        return Path(gitmap_work_val).resolve()

    cwd = Path.cwd().resolve()
    if (cwd / ".git").exists():
        return cwd.parent

    home_work = Path.home() / "git-work"
    if home_work.exists():
        return home_work

    if interactive and sys.stdin.isatty():
        try:
            user_input = input("Enter WORK workspace directory path: ").strip()
            if user_input and Path(user_input).exists():
                return Path(user_input).resolve()
        except (EOFError, KeyboardInterrupt):
            pass

    return cwd.parent


def _update_powershell_profile(profile_path: Path, work_dir: Path) -> None:
    """Append $global:WORK hook to PowerShell profile if missing."""
    hook = '\n# $WORK bare expansion hook\nif ($env:WORK) { $global:WORK = $env:WORK }\n'
    content = ""
    if profile_path.exists():
        content = profile_path.read_text(encoding="utf-8")
    if "$global:WORK" in content:
        return
    profile_path.parent.mkdir(parents=True, exist_ok=True)
    with open(profile_path, "a", encoding="utf-8", newline="\n") as f:
        f.write(hook)


def _persist_windows_env(key: str, val: str) -> bool:
    """Persist environment variable to Windows User Registry."""
    cmd = f'[System.Environment]::SetEnvironmentVariable("{key}", "{val}", "User")'
    res = subprocess.run(["powershell", "-NoProfile", "-Command", cmd], capture_output=True)
    return res.returncode == 0


def _persist_posix_env(key: str, val: str) -> None:
    """Append export to POSIX startup profiles."""
    export_line = f'\nexport {key}="{val}"\n'
    for rc in [Path.home() / ".bashrc", Path.home() / ".zshrc"]:
        if not rc.exists():
            continue
        content = rc.read_text(encoding="utf-8")
        if f"export {key}=" in content:
            continue
        with open(rc, "a", encoding="utf-8", newline="\n") as f:
            f.write(export_line)


def configure_work_variable(target_dir: Optional[Path] = None) -> EnvResult:
    """Configure WORK environment variable across OS reboots."""
    work_path = (target_dir or get_work_dir()).resolve()
    work_str = str(work_path)
    os.environ[EnvConstants.ENV_WORK] = work_str

    if platform.system() == "Windows":
        is_ok = _persist_windows_env(EnvConstants.ENV_WORK, work_str)
        ps_doc = Path.home() / "Documents" / "PowerShell" / "Microsoft.PowerShell_profile.ps1"
        _update_powershell_profile(ps_doc, work_path)
        msg = f"Configured Windows User WORK='{work_str}' (survives restart, cd $WORK enabled)"
        return EnvResult(is_ok, msg, work_str)

    _persist_posix_env(EnvConstants.ENV_WORK, work_str)
    return EnvResult(True, f"Configured POSIX WORK='{work_str}' in ~/.bashrc and ~/.zshrc", work_str)


def update_env_ini(key: str, val: str, ini_path: Optional[Path] = None) -> EnvResult:
    """Update or append variable to config/env.ini file."""
    target_ini = ini_path or Path(EnvConstants.DEFAULT_CONFIG_PATH)
    target_ini.parent.mkdir(parents=True, exist_ok=True)

    config = configparser.ConfigParser()
    if target_ini.exists():
        config.read(target_ini, encoding="utf-8")
    if not config.has_section(EnvConstants.SECTION_ENVIRONMENT):
        config.add_section(EnvConstants.SECTION_ENVIRONMENT)

    config.set(EnvConstants.SECTION_ENVIRONMENT, key, val)
    with open(target_ini, "w", encoding="utf-8", newline="\n") as f:
        config.write(f)

    return EnvResult(True, f"Updated {target_ini} with {key}={val}", val)


def set_variable_on_the_fly(key_val_pair: str, ini_path: Optional[Path] = None) -> EnvResult:
    """Parse key=value using LazyRegex, update env.ini, active process and persistent environment."""
    kv_pattern = LazyRegex.get(r"^([A-Za-z_][A-Za-z0-9_]*)=(.*)$")
    match = kv_pattern.match(key_val_pair.strip())
    if not match:
        return EnvResult(False, "Format must be KEY=VALUE (e.g. API_KEY=xyz123)")

    key, val = match.group(1).strip(), match.group(2).strip()

    ini_res = update_env_ini(key, val, ini_path)
    if not ini_res.is_success:
        return ini_res

    os.environ[key] = val

    if platform.system() == "Windows":
        _persist_windows_env(key, val)
    else:
        _persist_posix_env(key, val)

    return EnvResult(True, f"Successfully set and persisted {key}={val} (active + restart)", val)


def get_status() -> None:
    """Display current WORK and environment variable status."""
    work_dir = get_work_dir(interactive=False)
    work_env = os.environ.get(EnvConstants.ENV_WORK, "(not set in current process)")
    gitmap_work_env = os.environ.get(EnvConstants.ENV_GITMAP_WORK_DIR, "(not set)")
    print(f"Detected Work Directory       : {work_dir}")
    print(f"Active Process $WORK          : {work_env}")
    print(f"Fallback $GITMAP_WORK_DIR     : {gitmap_work_env}")
    print(f"Platform                      : {platform.system()}")


def main() -> None:
    """CLI Entrypoint for env and work manager."""
    parser = argparse.ArgumentParser(description="Universal $WORK and Dynamic ENV Manager")
    parser.add_argument("action", choices=[m.value for m in ActionType], help="Action to perform")
    parser.add_argument("param", nargs="?", default="", help="Parameter for set (KEY=VALUE) or custom dir")
    args = parser.parse_args()

    if args.action == ActionType.STATUS.value:
        get_status()
    elif args.action == ActionType.INIT_WORK.value:
        custom = Path(args.param) if args.param else None
        res = configure_work_variable(custom)
        print(f"[{'OK' if res.is_success else 'ERR'}] {res.message}")
    elif args.action == ActionType.SET.value:
        res = set_variable_on_the_fly(args.param)
        print(f"[{'OK' if res.is_success else 'ERR'}] {res.message}")


if __name__ == "__main__":
    main()
