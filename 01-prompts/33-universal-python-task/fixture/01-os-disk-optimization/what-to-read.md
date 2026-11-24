# What to Read: 01-os-disk-optimization

Guide for downstream autonomous AI agents continuing work in this directory:

1. **Launcher Entrypoints:** Use `run.ps1` on Windows or `run.sh` on POSIX. Never execute python directly without passing through the launcher.
2. **Scripts Architecture:** All logic resides under `scripts/`. No file exceeds 200 lines. All functions are $\le 15$ lines.
3. **Logging & Auditing:** Every operation logs timestamped entries to `logs/task.log`.
4. **Coding Guidelines:** Enforce positive booleans (`is_*`, `has_*`), strongly typed enums in `scripts/core_enums.py`, and zero nested conditionals.
