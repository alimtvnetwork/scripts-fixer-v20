# Task 01: OS Disk Optimization & System Cache Purge

This task-scoped directory automates Windows and cross-platform OS disk optimization, temporary cache purging, and build artifact cleanup.

## Feature Stack
1. **Status & Size Assessment:** Inspects current filesystem space and target cache sizes with a visual gauge.
2. **Safe Cache Purge:** Cleans system temp directories while preserving protected configuration files (`.gitkeep`, `config.json`).
3. **Debug Build Removal:** Scans and eliminates `target/debug`, `bin/Debug`, and `__pycache__` artifacts.
4. **Dry-Run Simulation:** Previews all operations non-destructively via `--dry-run`.
5. **Interactive Suggestions:** Prints next recommended CLI actions upon completion.

## CLI Commands
- `.\run.ps1 status` — Check disk usage.
- `.\run.ps1 scan` — Scan cache directories.
- `.\run.ps1 purge --dry-run` — Simulate cache purge.
- `.\run.ps1 purge --all` — Execute full purge.
- `.\run.ps1 restart --category audio_device` — Restart Windows audio services.
- `.\run.ps1 restart --category vmware_network` — Cycle VMware virtual network adapters.

## Trace Reference
- Conversation trace: [`conversation/01-user-request.md`](conversation/01-user-request.md)
- Ingestion guide: [`what-to-read.md`](what-to-read.md)
