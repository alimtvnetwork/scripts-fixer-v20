---
name: gitmap-binary-swap
description: >-
  Autonomously swap and replace active GitMap executable binaries with newly compiled binaries across Windows and POSIX systems using detached handoff scripts, retry backoff, process lock discovery, and verification.
---

# GitMap Binary Swap Skill

> **Invocation:** `@[gitmap-binary-swap](directory;.agents/skills/gitmap-binary-swap)`  
> **Command:** `gitmap swap-binary` (aliases: `swap-bin`, `bin-swap`, `replace-bin`, `replace-binary`, `swap`)  
> **Target Subsystem:** `cli/cmdswap/`, `cli/cmdupdate/`

---

## 1. Overview & Safety Contract

When compiling or updating GitMap binaries in place on Windows and POSIX systems, executing binaries are locked by the operating system (`ERROR_SHARING_VIOLATION` / Error 5 `Access is denied` on Windows, or `ETXTBSY: Text file busy` on Unix). Direct in-place file replacement (`Copy-Item` or `cp`) fails while the CLI, daemons, or background workers are holding file handles.

The `gitmap swap-binary` command provides an atomic, detached handoff mechanism that guarantees safe executable replacement without leaving a broken binary on disk.

### The Safety Contract:
1. **Source & Target Resolution:** Automatically locates freshly compiled source binaries (`cli/gitmap.exe`, `bin/gitmap.exe`, `gitmap.exe`) and resolves active installed target locations on `PATH`.
2. **PID Discovery & Graceful Termination:** Detects sibling processes locking the executable, sending graceful termination (`SIGTERM` / `Stop-Process`) before forceful fallback (`SIGKILL` / `Stop-Process -Force`) if `--kill` or `--force` is set.
3. **Detached Supervisor Script:** Generates and launches a standalone, detached handoff script (`.ps1` on Windows, `.sh` on Unix) and immediately exits the caller process so its own file lock is released.
4. **Renaming Out of the Way (`.old` / `.bak`):** Moves the active binary to `.old` (falling back to `.bak` if `.old` is locked or occupied) prior to placing the new binary.
5. **Exponential Backoff Retries:** Retries file placement up to 10 times with exponential delay (250ms doubling up to 2000ms) to accommodate anti-virus scanners and settling locks.
6. **Post-Swap Verification & Revert:** Validates the newly installed binary by executing `gitmap --version`. If verification fails, it restores the previous binary from `.old` / `.bak` and reports an error.
7. **Self-Cleanup:** The detached script unlinks itself after completion.

---

## 2. Command Reference & Options

```bash
gitmap swap-binary [flags] [positional-from-path]
```

### Supported Aliases:
- `gitmap swap`
- `gitmap swap-bin`
- `gitmap bin-swap`
- `gitmap replace-binary`
- `gitmap replace-bin`

### Command Flags:
| Flag | Short | Description |
| :--- | :--- | :--- |
| `--from <path>` | | Explicit path to newly compiled source binary |
| `--to <path>` | `-t`, `--target` | Explicit destination binary path on PATH |
| `--pid <pid>` | | Specific target PID to terminate before swap |
| `--kill` | `-k` | Discover and terminate active locking GitMap processes |
| `--force` | `-f` | Forcefully kill locking processes (`SIGKILL` / `-Force`) |
| `--restart` | `--reopen` | Run newly installed binary after swap verification |
| `--script-only` | | Output generated handoff script to stdout without running |
| `--dry-run` | `-n` | Validate source/target paths and checksums without modifying files |
| `--timeout <sec>` | | Maximum seconds to wait for locking processes (default: 5) |
| `--json` | `-j` | Emit structured JSON output envelope |

---

## 3. Standard Usage Patterns

### Scenario A: Replace PATH Binary After Local Compilation (Windows)
```powershell
# Compile new binary
go build -C cli -o ../bin/gitmap.exe .

# Execute atomic swap into deployed PATH binary
gitmap swap-binary --from bin/gitmap.exe --kill --force
```

### Scenario B: Replace PATH Binary After Local Compilation (Linux / macOS)
```bash
# Compile new binary
go build -C cli -o ../bin/gitmap .

# Execute atomic swap into deployed PATH binary
gitmap swap-binary --from bin/gitmap --kill --force
```

### Scenario C: Dry-Run and Script Inspection
```bash
# Preview what the swap engine will execute without making changes
gitmap swap-binary --from bin/gitmap.exe --dry-run --json

# Emit the raw platform handoff script to inspect the generated PowerShell or shell code
gitmap swap-binary --from bin/gitmap.exe --script-only
```

---

## 4. Verification & Diagnostics

To verify the swap completed successfully:
1. Check the active version: `gitmap --version`
2. Inspect GitMap health: `gitmap doctor`
3. If an update or swap script failed previously, run cleanup: `gitmap update-cleanup`
