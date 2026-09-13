# Repository Coding Guidelines

> **Version:** 2.1.0  
> **Status:** Canonical Rule Set  
> **Updated:** 2026-09-13  
> **Scope:** Cross-platform scripts (PowerShell, Bash, Python), TypeScript/React, and configuration files.

---

## 1. Core Principles

1. **Guard Clauses Over Nesting (No Nested `if` Statements)**
   - Always return early or bail out using guard clauses.
   - Deeply nested conditional blocks (`if` within `if`) are strictly forbidden. Flatten control flow to at most one level of indentation for conditional branching.

2. **Micro-Functions (Target ≤ 8 Lines)**
   - Functions must do one atomic thing well.
   - Aim for ≤ 8 lines of execution logic per function. Decompose orchestration into dedicated helper functions.

3. **File Size Target (≤ 100 Lines Per File)**
   - Monolithic script files are anti-patterns. Modularize logic into cohesive sub-modules under `helpers/`, `modules/`, or `components/`.

4. **DRY First (Strict Helper Reuse)**
   - Never reinvent shared functionality.
   - Always reuse existing cross-platform modules from `scripts/shared/` (PowerShell) and `scripts-linux/_shared/` (Bash).

5. **No Magic Strings or Magic Numbers**
   - Centralize ports, timeouts, status constants, and paths in configuration objects, enums, or `config.json`.

---

## 2. Naming & Type Conventions

1. **Boolean Variables: Strict `is` / `has` Prefix**
   - All boolean variables, parameters, and flags must be named with an `is` or `has` prefix.
   - Examples: `$isValid`, `$hasInstalled`, `$isDryRun`, `is_root`, `has_sqlite`.
   - Never use negative booleans (e.g. `$isNotInstalled`, `$noUpgrade` is acceptable only as legacy CLI flag, internally mapped to `$isUpgradeEnabled = $false`). Avoid bare `-not` confusion.

2. **TypeScript: Zero `any` Policy**
   - Explicit types or strict generics only. The `any` escape hatch is strictly disallowed in `src/`.

3. **Dev Directory Standard Naming**
   - The default development directory is ALWAYS `dev-tool` (hyphenated).
   - Never use `devtool`, `devtools`, or `dev_tool` in code, help text, logs, or documentation.

---

## 3. CODE RED: Error & Path Logging Standards

1. **Exact File Path + Failure Reason (Mandatory)**
   - Every `catch` block, error branch, or file operation failure MUST report both:
     - The **exact absolute file path** being operated on.
     - The **precise reason / exception message** why the operation failed.
   - In PowerShell: Use `Write-FileError -Path $path -Reason $reason` or `Write-Log "[ERROR] Failed accessing $path: $_"`.
   - In Bash: Use `log_file_error "$path" "$reason"` or standard shared logging.

2. **Install-Paths Trio (Source, Temp, Target)**
   - Every file download, archive extraction, installation, repair, or synchronization must log all three path coordinates:
     - `Source:` Origin URL, repository, or archive path.
     - `Temp:` Intermediate scratch/extraction path.
     - `Target:` Destination installation directory.
   - In PowerShell: Call `Write-InstallPaths` from `scripts/shared/install-paths.ps1`.

---

## 4. PowerShell 5.1 & Cross-Version Rules

1. **No PowerShell 7+ Syntax in Shared/Root Scripts**
   - Null-coalescing operator (`??` or `??=`) does not exist in PowerShell 5.1. Always use explicit `if ($null -ne $val) { ... } else { ... }`.
   - Ternary operator (`? :`) is unsupported in PowerShell 5.1. Use standard `if / else`.

2. **StrictMode Array Unwrapping Protection**
   - Under `Set-StrictMode -Version Latest`, functions returning a single-item array unwrap into a scalar object.
   - Caller functions must wrap received values with `@(...)` before evaluating `.Length` or `.Count`.

3. **BOM & UTF-8 Pipe Decoding**
   - When redirecting stdout from PowerShell 5.1 into Python bridges or external tools, a UTF-8 BOM (`\xef\xbb\xbf`) may be prepended.
   - Downstream consumers (e.g. `sqlite-bridge.py`) must decode standard input using `utf-8-sig`.

4. **Terminal Glyph Safety**
   - Do NOT use raw multibyte emoji or non-standard Unicode characters in UTF-8 `.ps1` files without BOM, as PS 5.1 may misinterpret them.
   - Use ASCII status indicators `[OK]`, `[FAIL]`, `[WARN]`, `[INFO]` or explicit `[char]0x2714`.

---

## 5. Linux / Bash Rules

1. **Strict Execution Mode**
   - Every bash script must start with `set -euo pipefail`.
   - Handle expected non-zero exits explicitly (e.g., `command || true`).

2. **Line Endings & Encoding**
   - Unix LF line endings only.
   - UTF-8 without BOM.

---

## 6. Nginx & Web Server Configuration Rules

1. **Forward-Slash Path Normalization (Windows)**
   - Nginx parser on Windows fails when paths contain backslashes `\`.
   - All document roots, log paths, SSL certificate paths, and FastCGI script filenames MUST be normalized using forward slashes `/` (e.g. `C:/dev-tool/nginx/html/domain.com`).

2. **Atomic Tri-State Mutations**
   - Mutations to web configurations must atomically synchronize:
     - SQLite database ledger.
     - Master and per-site INI configuration files.
     - Nginx virtual host configurations (`conf.d/*.conf`).
   - Run configuration validation (`nginx -t`) before activating any changes. Roll back state if validation fails.
