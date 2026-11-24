"""Dynamic cross-platform INI environment loader and variable resolution."""

from __future__ import annotations

import os
from pathlib import Path

from app_errors import AppError, Result
from core_constants import EncodingConstants


def parse_ini_line(line: str) -> tuple[str, str] | None:
    """Extract trimmed key and value from single INI line."""
    trimmed = line.strip()
    if not trimmed or trimmed.startswith(("#", ";")) or "=" not in trimmed:
        return None

    key, sep, val = trimmed.partition("=")
    return key.strip(), val.strip()


def locate_default_ini() -> Path:
    """Find default env.ini in task config, parent ini-env, or work directory."""
    here = Path(__file__).resolve().parent.parent
    local_ini = here / "config" / "env.ini"
    if local_ini.is_file():
        return local_ini

    parent_ini = here.parent / "ini-env" / "env.ini"
    if parent_ini.is_file():
        return parent_ini

    return local_ini


def load_env_ini(ini_path: Path | str | None = None) -> Result[dict[str, str]]:
    """Parse env.ini into dictionary and populate os.environ."""
    target = Path(ini_path).resolve() if ini_path else locate_default_ini()
    if not target.is_file():
        return Result.ok({})

    env_map: dict[str, str] = {}
    try:
        lines = target.read_text(encoding=EncodingConstants.UTF8).splitlines()
        for line in lines:
            parsed = parse_ini_line(line)
            if parsed:
                k, v = parsed
                env_map[k] = v
                os.environ[k] = v

        return Result.ok(env_map)
    except Exception as exc:
        err = AppError("IO_ERROR", f"Failed reading env.ini at {target}: {exc}")
        return Result.fail(err)


def interpolate_env_vars(text: str) -> str:
    """Expand ${KEY} and $KEY variable placeholders from current os.environ."""
    return os.path.expandvars(text)


def get_work_dir() -> Path:
    """Return resolved root work directory from WORK env var or project parent."""
    work_val = os.environ.get("WORK", "").strip()
    if work_val:
        return Path(work_val).resolve()

    return Path(__file__).resolve().parent.parent.parent


def get_env(key: str, default: str = "") -> str:
    """Retrieve string environment variable safely with fallback."""
    return os.environ.get(key, default)
